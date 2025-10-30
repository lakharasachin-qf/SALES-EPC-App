import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_drawing_tools/google_maps_drawing_tools.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sales_app/utils/helper.dart';
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

enum DrawMode { none, pin, polyline, polygon }

class MapDrawingScreen extends StatefulWidget {
  const MapDrawingScreen({super.key});

  @override
  MapDrawingScreenState createState() => MapDrawingScreenState();
}

class MapDrawingScreenState extends State<MapDrawingScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final DrawingController _drawingController = DrawingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  LatLng? _currentLatLng;
  bool isDrawingMode = false;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Polygon> _polygons = {};
  final List<LatLng> _tempPoints = [];
  int _idSeed = 0;
  final Set<Marker> _vertexMarkers = {};
  DrawMode _mode = DrawMode.polygon;
  MapType _mapType = MapType.satellite;
  // Indicates if current polygon can be snapped/closed by tapping near first point
  bool _closable = false;
  static const String _kGoogleApiKey =
      'AIzaSyDp5o-2dsM59s2wBbXyY3vU05J17dw6Qkc';
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  bool _isSearching = false;
  List<Map<String, String>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _requestAndSetLocation();
    searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLatLng == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: AppBar(
          //   title: const Text('Draw on Map'),
          //   actions: <Widget>[
          //     // IconButton(
          //     //   icon: const Icon(Icons.center_focus_strong),
          //     //   onPressed: _recenter,
          //     //   tooltip: 'Recenter',
          //     // ),
          //     IconButton(
          //       icon: const Icon(Icons.download_for_offline_rounded),
          //       onPressed: _captureAndUploadMap,
          //       tooltip: 'Capture & Upload',
          //     ),
          //   ],
          // ),
          body: Screenshot(
            controller: _screenshotController,
            child: Stack(
              children: [
                DrawingMapWidget(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 16,
                  ),
                  mapType: _mapType,
                  controller: _drawingController,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  indoorViewEnabled: true,
                  markers: {..._markers, ..._vertexMarkers},
                  polylines: _polylines,
                  buildingsEnabled: true,
                  polygons: _polygons,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                  onTap: _onMapTap,
                ),
                // Animated measurement chip
                Positioned(
                  top: 13.h,
                  left: 3.5.w,
                  right: 3.5.w,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.15),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child:
                        ((_mode == DrawMode.polyline &&
                                _tempPoints.length >= 2) ||
                            (_mode == DrawMode.polygon &&
                                _tempPoints.length >= 2))
                        ? Align(
                            alignment: Alignment.topCenter,
                            key: const ValueKey('measure-chip'),
                            child: buildMeasurementChip(_liveMeasurementText()),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('measure-chip-empty'),
                          ),
                  ),
                ),
                // if ((_mode == DrawMode.polyline || _mode == DrawMode.polygon) &&
                //     _tempPoints.isEmpty)
                //   Positioned(
                //     top: 13.h,
                //     left: 12,
                //     right: 12,
                //     child: Align(
                //       alignment: Alignment.topCenter,
                //       child: _HintBanner(
                //         text: _mode == DrawMode.polyline
                //             ? 'Tip: Tap to add points. Drag vertices to adjust. Press Finish when done.'
                //             : 'Tip: Tap to add vertices. Drag to adjust. Tap near first point to close.',
                //       ),
                //     ),
                //   ),
                Positioned(
                  left: 3.w,
                  right: 3.w,
                  top: 5.h,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: TextField(
                          controller: searchController,
                          focusNode: _searchFocus,
                          autofocus: false,
                          cursorColor: primaryColor,
                          stylusHandwritingEnabled: true,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: primaryColor,
                            ),
                            hintText: 'Search place, address...',
                            filled: true,
                            fillColor: white,
                            suffixIcon: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : (searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            searchController.clear();
                                            setState(() => _searchResults = []);
                                          },
                                        )
                                      : null),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (v) => _fetchAutocomplete(v),
                        ),
                      ),
                      getDynamicSizedBox(height: 2.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _searchResults.isNotEmpty
                            ? Material(
                                key: const ValueKey('results'),
                                elevation: 6,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 280,
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.all(0),
                                    itemCount: _searchResults.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1),
                                    itemBuilder: (ctx, i) {
                                      final it = _searchResults[i];
                                      return buildSearchResultTile(
                                        description: it['description'] ?? '',
                                        onTap: () async {
                                          final desc = it['description'] ?? '';
                                          setState(() {
                                            searchController.text = "";
                                            _searchResults = [];
                                            _isSearching = false;
                                          });
                                          _searchFocus.unfocus();
                                          await _goToPlace(
                                            it['place_id']!,
                                            desc,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('no-results'),
                              ),
                      ),
                    ],
                  ),
                ),
                // Right-side floating buttons
                Positioned(
                  right: 2.w,
                  bottom: 15.h,
                  child: Column(
                    children: [
                      buildRoundFab(
                        icon: Icons.layers_outlined,
                        tooltip: 'Map type',
                        onTap: () => _showMapTypeDialog(),
                      ),
                      const SizedBox(height: 10),
                      buildRoundFab(
                        icon: Icons.my_location,
                        tooltip: 'Recenter',
                        onTap: _recenter,
                      ),
                      const SizedBox(height: 10),
                      buildRoundFab(
                        icon: Icons.add,
                        tooltip: 'Recenter',
                        onTap: _showModePicker,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 20,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    offset: _mode != DrawMode.none
                        ? Offset.zero
                        : const Offset(0, 0.3),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _mode != DrawMode.none ? 1 : 0,
                      child: buildBottomActionsBar(
                        context: context,
                        mode: _mode,
                        onPin: () => _setMode(DrawMode.pin),
                        onPolyline: () => _setMode(DrawMode.polyline),
                        onPolygon: () => _setMode(DrawMode.polygon),
                        onUndo: _undoLastPoint,
                        onFinish: _finishShape,
                        onClear: _clearAll,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showModePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // _ModePickTile(
                    //   icon: Icons.place,
                    //   label: 'Pin',
                    //   selected: _mode == DrawMode.pin,
                    //   onTap: () {
                    //     Navigator.pop(ctx);
                    //     _setMode(DrawMode.pin);
                    //   },
                    // ),
                    buildModePickTile(
                      context: context,
                      icon: Icons.show_chart,
                      label: 'Polyline',
                      selected: _mode == DrawMode.polyline,
                      onTap: () {
                        Navigator.pop(ctx);
                        _setMode(DrawMode.polyline);
                      },
                    ),
                    buildModePickTile(
                      context: context,
                      icon: Icons.gesture,
                      label: 'Polygon',
                      selected: _mode == DrawMode.polygon,
                      onTap: () {
                        Navigator.pop(ctx);
                        _setMode(DrawMode.polygon);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      futureDelay(() {
        FocusScope.of(context).unfocus();
      }, milliseconds: true);
    });
  }

  Future<void> _requestAndSetLocation() async {
    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    if (permission != PermissionStatus.granted) return;

    final locData = await location.getLocation();
    final latLng = LatLng(locData.latitude!, locData.longitude!);
    setState(() => _currentLatLng = latLng);

    if (_mapController.isCompleted) {
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 200),
        ),
      );
    }
  }

  // Search handlers
  void _onSearchChanged() {
    final text = searchController.text.trim();
    _debounce?.cancel();
    if (text.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchAutocomplete(text);
    });
  }

  Future<void> _fetchAutocomplete(String input) async {
    if (_kGoogleApiKey == 'AIzaSyDp5o-2dsM59s2wBbXyY3vU05J17dw6Qkc') {
      // return; // guard if key not set
      try {
        setState(() => _isSearching = true);
        final locBias = _currentLatLng != null
            ? '&location=${_currentLatLng!.latitude},${_currentLatLng!.longitude}&radius=20000'
            : '';
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}$locBias&key=$_kGoogleApiKey',
        );
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final preds =
              (data['predictions'] as List?)?.cast<Map<String, dynamic>>() ??
              [];
          final mapped = preds
              .map(
                (e) => {
                  'description': (e['description'] as String?) ?? '',
                  'place_id': (e['place_id'] as String?) ?? '',
                },
              )
              .where(
                (e) =>
                    e['description']!.isNotEmpty && e['place_id']!.isNotEmpty,
              )
              .toList();
          setState(() => _searchResults = mapped);
        }
      } catch (_) {
        // ignore
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _goToPlace(String placeId, String description) async {
    if (_kGoogleApiKey == 'YOUR_GOOGLE_API_KEY') return; // guard if key not set
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_kGoogleApiKey',
      );
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>?;
        final geometry = result?['geometry'] as Map<String, dynamic>?;
        final loc = geometry?['location'] as Map<String, dynamic>?;
        if (loc != null) {
          final lat = (loc['lat'] as num).toDouble();
          final lng = (loc['lng'] as num).toDouble();
          final target = LatLng(lat, lng);
          if (_mapController.isCompleted) {
            final c = await _mapController.future;
            await c.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: target, zoom: 16.5),
              ),
            );
          }
          setState(() {
            final id = 's_${_idSeed++}';
            _markers.add(
              Marker(
                markerId: MarkerId(id),
                position: target,
                infoWindow: InfoWindow(title: description),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
            );
            _searchResults = [];
          });
          _searchFocus.unfocus();
        }
      }
    } catch (_) {
      // ignore
    }
  }

  void _setMode(DrawMode mode) {
    setState(() {
      _mode = mode;
      if (mode == DrawMode.polyline || mode == DrawMode.polygon) {
        _tempPoints.clear();
        _vertexMarkers.clear();
      }
    });
  }

  /// Removes the last added point (for correcting mistake)
  void _undoLastPoint() {
    if (_tempPoints.isNotEmpty) {
      setState(() {
        _tempPoints.removeLast();
        _updatePreviewShapes();
      });
    }
  }

  // void _onMapTap(LatLng pos) {
  //   if (_mode == DrawMode.pin) {
  //     final id = 'm_${_idSeed++}';
  //     setState(() {
  //       _markers.add(Marker(markerId: MarkerId(id), position: pos));
  //     });
  //   } else if (_mode == DrawMode.polyline) {
  //     setState(() {
  //       _tempPoints.add(pos);
  //       _polylines.removeWhere((p) => p.polylineId.value == 'pl_temp');
  //       _polylines.add(
  //         Polyline(
  //           polylineId: const PolylineId('pl_temp'),
  //           points: List.of(_tempPoints),
  //           width: 4,
  //           color: Colors.blue,
  //         ),
  //       );
  //       _rebuildVertexMarkers();
  //     });
  //   } else if (_mode == DrawMode.polygon) {
  //     if (_tempPoints.isNotEmpty &&
  //         _tempPoints.length >= 3 &&
  //         _isNear(pos, _tempPoints.first, 12)) {
  //       _finishShape();
  //       return;
  //     }
  //     setState(() {
  //       _tempPoints.add(pos);
  //       _polygons.removeWhere((p) => p.polygonId.value == 'pg_temp');
  //       _polygons.add(
  //         Polygon(
  //           polygonId: const PolygonId('pg_temp'),
  //           points: List.of(_tempPoints),
  //           strokeWidth: 3,
  //           strokeColor: primaryColor,
  //           fillColor: primaryColor.withOpacity(0.15),
  //         ),
  //       );
  //       _rebuildVertexMarkers();
  //     });
  //   }
  // }

  void _onMapTap(LatLng pos) {
    // Check if the tap is near an existing vertex marker
    int? tappedVertexIndex;
    for (int i = 0; i < _tempPoints.length; i++) {
      if (_isNear(pos, _tempPoints[i], 12)) {
        tappedVertexIndex = i;
        break;
      }
    }

    if (tappedVertexIndex != null) {
      // Tap is on an existing vertex, select it for dragging (handled by marker's onTap)
      return;
    }

    if (_mode == DrawMode.pin) {
      final id = 'm_${_idSeed++}';
      setState(() {
        _markers.add(Marker(markerId: MarkerId(id), position: pos));
      });
    } else if (_mode == DrawMode.polyline) {
      setState(() {
        _tempPoints.add(pos);
        _updatePreviewShapes();
      });
    } else if (_mode == DrawMode.polygon) {
      setState(() {
        _tempPoints.add(pos);
        _updatePreviewShapes();
        if (_tempPoints.length >= 3 && _isNear(pos, _tempPoints.first, 12)) {
          _finishShape();
          return;
        }
      });
    }
  }

  void _rebuildVertexMarkers() {
    setState(() {
      _vertexMarkers.clear();
      for (int i = 0; i < _tempPoints.length; i++) {
        final point = _tempPoints[i];
        final id = 'v_${i}_$_idSeed';
        _vertexMarkers.add(
          Marker(
            markerId: MarkerId(id),
            position: point,
            draggable: true,
            flat: true,
            onTap: () {
              // Update marker icon to indicate selection
              setState(() {
                _vertexMarkers.removeWhere((m) => m.markerId.value == id);
                _vertexMarkers.add(
                  Marker(
                    markerId: MarkerId(id),
                    position: point,
                    draggable: true,
                    flat: true,
                    onTap: () {}, // Prevent recursive tap handling
                    onDrag: (newPos) {
                      _tempPoints[i] = newPos;
                      _updatePreviewShapes(triggerSetState: true);
                    },
                    onDragEnd: (newPos) {
                      setState(() {
                        _tempPoints[i] = newPos;
                        _updatePreviewShapes();
                        // Reset icon after drag ends
                        _rebuildVertexMarkers();
                      });
                    },
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue, // Highlight selected vertex
                    ),
                  ),
                );
              });
            },
            onDrag: (newPos) {
              _tempPoints[i] = newPos;
              _updatePreviewShapes(triggerSetState: true);
            },
            onDragEnd: (newPos) {
              setState(() {
                _tempPoints[i] = newPos;
                _updatePreviewShapes();
                _rebuildVertexMarkers(); // Reset icons after drag
              });
            },
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    });
  }

  void _updatePreviewShapes({bool triggerSetState = false}) {
    if (triggerSetState) {
      setState(() {
        _doUpdatePreviewShapes();
      });
    } else {
      _doUpdatePreviewShapes();
    }
  }

  void _doUpdatePreviewShapes() {
    if (_mode == DrawMode.polyline) {
      _polylines.removeWhere((p) => p.polylineId.value == 'pl_temp');
      if (_tempPoints.isNotEmpty) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('pl_temp'),
            points: List.of(_tempPoints),
            width: 4,
            color: Colors.blue,
          ),
        );
      }
    } else if (_mode == DrawMode.polygon) {
      _polygons.removeWhere((p) => p.polygonId.value == 'pg_temp');
      if (_tempPoints.isNotEmpty) {
        // Visual cue: when closeable, turn stroke to green
        final canClose =
            _tempPoints.length >= 3 &&
            _isNear(_tempPoints.last, _tempPoints.first, 12);
        _closable = canClose;
        _polygons.add(
          Polygon(
            polygonId: const PolygonId('pg_temp'),
            points: List.of(_tempPoints),
            strokeWidth: 3,
            strokeColor: canClose ? Colors.green : primaryColor,
            fillColor: (canClose ? Colors.green : primaryColor).withOpacity(
              0.15,
            ),
          ),
        );
      }
    }
    _rebuildVertexMarkers();
  }

  void _finishShape() {
    if ((_mode == DrawMode.polyline && _tempPoints.length >= 2) ||
        (_mode == DrawMode.polygon && _tempPoints.length >= 3)) {
      final isPolygon = _mode == DrawMode.polygon;
      final id = '${isPolygon ? 'pg' : 'pl'}_${_idSeed++}';
      final points = List.of(_tempPoints);

      setState(() {
        if (isPolygon) {
          _polygons.removeWhere((p) => p.polygonId.value == 'pg_temp');
          _polygons.add(
            Polygon(
              polygonId: PolygonId(id),
              points: points,
              strokeWidth: 3,
              strokeColor: primaryColor,
              fillColor: primaryColor.withOpacity(0.15),
            ),
          );
        } else {
          _polylines.removeWhere((p) => p.polylineId.value == 'pl_temp');
          _polylines.add(
            Polyline(
              polylineId: PolylineId(id),
              points: points,
              width: 4,
              color: Colors.blue,
            ),
          );
        }

        _tempPoints.clear();
        _mode = DrawMode.none;
        _vertexMarkers.clear();
      });

      // ✅ Calculate measurements
      final measurePoints = points
          .map((e) => mp.LatLng(e.latitude, e.longitude))
          .toList();

      final area = isPolygon
          ? mp.SphericalUtil.computeArea(measurePoints)
          : 0.0;
      final perimeter = isPolygon
          ? mp.SphericalUtil.computeLength([
              ...measurePoints,
              measurePoints.first,
            ])
          : mp.SphericalUtil.computeLength(measurePoints);
      final areaInSqKm = area / 1e6;
      final areaInAcre = area / 4046.85642;
      final perimeterInKm = perimeter / 1000;

      _showMeasurementBottomSheet(
        title: isPolygon ? "Polygon Measurement" : "Polyline Measurement",
        rows: [
          {"label": "Area (m²)", "value": area.toStringAsFixed(2)},
          {"label": "Area (km²)", "value": areaInSqKm.toStringAsFixed(4)},
          {"label": "Area (acres)", "value": areaInAcre.toStringAsFixed(4)},
          {"label": "Perimeter (m)", "value": perimeter.toStringAsFixed(2)},
          {
            "label": "Perimeter (km)",
            "value": perimeterInKm.toStringAsFixed(3),
          },
        ],
      );
    } else if (_mode == DrawMode.pin && _tempPoints.length == 1) {
      final point = _tempPoints.first;
      setState(() {
        _markers.add(
          Marker(markerId: MarkerId('m_${_idSeed++}'), position: point),
        );
        _tempPoints.clear();
        _mode = DrawMode.none;
      });

      // ✅ Show coordinates
      _showMeasurementBottomSheet(
        title: "Pin Location",
        rows: [
          {"label": "Latitude", "value": point.latitude.toStringAsFixed(6)},
          {"label": "Longitude", "value": point.longitude.toStringAsFixed(6)},
        ],
      );
    }
  }

  void _showMeasurementBottomSheet({
    required String title,
    required List<Map<String, String>> rows,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...rows.map((r) => _buildInfoRow(r["label"]!, r["value"]!)),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _clearAll();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _clearAll();
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      _polygons.clear();
      _tempPoints.clear();
      _vertexMarkers.clear();
      _mode = DrawMode.polygon;
    });
  }

  Future<void> _recenter() async {
    if (!mounted) return;
    if (_currentLatLng == null) return;

    try {
      if (!_mapController.isCompleted) return;
      final controller = await _mapController.future;

      // Only run if map is still valid
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng!, zoom: 18),
        ),
      );
    } catch (e, stack) {
      debugPrint("❌ Recenter error: $e");
      debugPrint(stack.toString());
    }
  }

  Future<void> _showMapTypeDialog() async {
    MapType tmp = _mapType;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: StatefulBuilder(
          builder: (ctx, setS) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Map Type",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildMapTypeTile(
                        label: 'Default',
                        icon: Icons.map_rounded,
                        selected: tmp == MapType.normal,
                        onTap: () => setS(() => tmp = MapType.normal),
                      ),
                      getDynamicSizedBox(width: 2.w),
                      buildMapTypeTile(
                        label: 'Satellite',
                        icon: Icons.satellite_alt_rounded,
                        selected: tmp == MapType.hybrid,
                        onTap: () => setS(() => tmp = MapType.hybrid),
                      ),
                      getDynamicSizedBox(width: 2.w),
                      buildMapTypeTile(
                        label: 'Terrain',
                        icon: Icons.terrain_rounded,
                        selected: tmp == MapType.terrain,
                        onTap: () => setS(() => tmp = MapType.terrain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          textStyle: TextStyle(fontSize: 15.sp),
                        ),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _mapType = tmp);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).whenComplete(() {
      futureDelay(() {
        FocusScope.of(context).unfocus();
      }, milliseconds: true);
    });
  }

  Widget buildMapTypeTile({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? primaryColor : white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? white : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? primaryColor.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: selected ? white : Colors.grey[700]),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModePickTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? [primary.withOpacity(0.12), primary.withOpacity(0.04)]
                    : [white, white],
              ),
              border: Border.all(
                color: selected ? primary : Colors.black26,
                width: selected ? 2 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected ? primary : Colors.black87,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? primary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.check, size: 14, color: white),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildRoundFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: white,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Tooltip(message: tooltip, child: Icon(icon, size: 22)),
        ),
      ),
    );
  }

  Widget buildIconTextButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon),
      label: Text(text),
    );
  }

  Widget buildMeasurementChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.straighten, size: 18, color: Colors.black87),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchResultTile({
    required String description,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.place_outlined, color: primaryColor),
      ),
      title: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget buildBottomActionsBar({
    required BuildContext context,
    required DrawMode mode,
    required VoidCallback onPin,
    required VoidCallback onPolyline,
    required VoidCallback onPolygon,
    required VoidCallback onUndo,
    required VoidCallback onFinish,
    required VoidCallback onClear,
  }) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildIconTextButton(
                      icon: Icons.undo,
                      text: 'Undo',
                      onTap: onUndo,
                    ),
                    buildIconTextButton(
                      icon: Icons.check,
                      text: 'Finish',
                      onTap: onFinish,
                    ),
                    buildIconTextButton(
                      icon: Icons.clear_all,
                      text: 'Clear',
                      onTap: onClear,
                    ),
                  ],
                ),
              ),
              Text(
                mode == DrawMode.pin
                    ? 'Pin mode'
                    : mode == DrawMode.polyline
                    ? 'Polyline mode'
                    : mode == DrawMode.polygon
                    ? 'Polygon mode'
                    : 'No mode',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _searchFocus.dispose();
    _drawingController.dispose();
    super.dispose();
  }
}

extension on MapDrawingScreenState {
  String _liveMeasurementText() {
    if (_tempPoints.length < 2) return '';
    final pts = _tempPoints
        .map((e) => mp.LatLng(e.latitude, e.longitude))
        .toList();
    if (_mode == DrawMode.polyline) {
      final d = mp.SphericalUtil.computeLength(pts);
      return d >= 1000
          ? 'Length: ${(d / 1000).toStringAsFixed(3)} km'
          : 'Length: ${d.toStringAsFixed(2)} m';
    }
    if (_mode == DrawMode.polygon) {
      final per = mp.SphericalUtil.computeLength(
        pts.length >= 2 ? [...pts, pts.first] : pts,
      );
      if (_tempPoints.length >= 3) {
        final area = mp.SphericalUtil.computeArea(pts);
        final areaKm = area / 1e6;
        return 'Area: ${area.toStringAsFixed(2)} m² • ${areaKm.toStringAsFixed(4)} km² • Perimeter: ${per.toStringAsFixed(2)} m';
      }
      return 'Perimeter: ${per.toStringAsFixed(2)} m';
    }
    return '';
  }

  bool _isNear(LatLng a, LatLng b, double meters) {
    final d = mp.SphericalUtil.computeDistanceBetween(
      mp.LatLng(a.latitude, a.longitude),
      mp.LatLng(b.latitude, b.longitude),
    );
    return d <= meters;
  }
}

// void _finishShape() {
  //   if (_mode == DrawMode.polyline && _tempPoints.length >= 2) {
  //     final id = 'pl_${_idSeed++}';
  //     final points = List.of(_tempPoints);

  //     setState(() {
  //       _polylines.removeWhere((p) => p.polylineId.value == 'pl_temp');
  //       _polylines.add(
  //         Polyline(
  //           polylineId: PolylineId(id),
  //           points: points,
  //           width: 4,
  //           color: Colors.blue,
  //         ),
  //       );
  //       _tempPoints.clear();
  //       _mode = DrawMode.none;
  //     });

  //     // ✅ Calculate line length
  //     final linePoints = points
  //         .map((e) => mp.LatLng(e.latitude, e.longitude))
  //         .toList();
  //     final distance = mp.SphericalUtil.computeLength(linePoints);

  //     _showMeasurementBottomSheet(
  //       title: "Distance Measurement",
  //       rows: [
  //         {"label": "Length (m)", "value": distance.toStringAsFixed(2)},
  //         {
  //           "label": "Length (km)",
  //           "value": (distance / 1000).toStringAsFixed(3),
  //         },
  //       ],
  //     );
  //   } else if (_mode == DrawMode.polygon && _tempPoints.length >= 3) {
  //     final id = 'pg_${_idSeed++}';
  //     final points = List.of(_tempPoints);

  //     setState(() {
  //       _polygons.removeWhere((p) => p.polygonId.value == 'pg_temp');
  //       _polygons.add(
  //         Polygon(
  //           polygonId: PolygonId(id),
  //           points: points,
  //           strokeWidth: 3,
  //           strokeColor: Colors.red,
  //           fillColor: Colors.redAccent.withOpacity(0.15),
  //         ),
  //       );
  //       _tempPoints.clear();
  //       _mode = DrawMode.none;
  //     });

  //     // ✅ Calculate area & perimeter
  //     final polygonPoints = points
  //         .map((e) => mp.LatLng(e.latitude, e.longitude))
  //         .toList();
  //     final area = mp.SphericalUtil.computeArea(polygonPoints);
  //     final perimeter = mp.SphericalUtil.computeLength(polygonPoints);
  //     final areaInSqKm = area / 1e6;
  //     final areaInAcre = area / 4046.85642;

  //     _showMeasurementBottomSheet(
  //       title: "Area Measurement",
  //       rows: [
  //         {"label": "Area (m²)", "value": area.toStringAsFixed(2)},
  //         {"label": "Area (km²)", "value": areaInSqKm.toStringAsFixed(4)},
  //         {"label": "Area (acres)", "value": areaInAcre.toStringAsFixed(4)},
  //         {"label": "Perimeter (m)", "value": perimeter.toStringAsFixed(2)},
  //       ],
  //     );
  //   } else if (_mode == DrawMode.pin && _tempPoints.length == 1) {
  //     final point = _tempPoints.first;
  //     setState(() {
  //       _markers.add(
  //         Marker(markerId: MarkerId('m_${_idSeed++}'), position: point),
  //       );
  //       _tempPoints.clear();
  //       _mode = DrawMode.none;
  //     });

  //     // ✅ Show coordinates
  //     _showMeasurementBottomSheet(
  //       title: "Pin Location",
  //       rows: [
  //         {"label": "Latitude", "value": point.latitude.toStringAsFixed(6)},
  //         {"label": "Longitude", "value": point.longitude.toStringAsFixed(6)},
  //       ],
  //     );
  //   }
  // }

  // void _finishShape() {
  //   if (_mode == DrawMode.polygon && _tempPoints.length >= 3) {
  //     final id = 'pg_${_idSeed++}';
  //     final points = List.of(_tempPoints);

  //     setState(() {
  //       _polygons.removeWhere((p) => p.polygonId.value == 'pg_temp');
  //       _polygons.add(
  //         Polygon(
  //           polygonId: PolygonId(id),
  //           points: points,
  //           strokeWidth: 3,
  //           strokeColor: Colors.red,
  //           fillColor: Colors.redAccent.withOpacity(0.15),
  //         ),
  //       );
  //       _tempPoints.clear();
  //       _mode = DrawMode.none;
  //     });

  //     // Convert for calculation
  //     final polygonPoints = points
  //         .map((e) => mp.LatLng(e.latitude, e.longitude))
  //         .toList();

  //     // Calculate area & perimeter
  //     final area = mp.SphericalUtil.computeArea(polygonPoints);
  //     final perimeter = mp.SphericalUtil.computeLength(polygonPoints);

  //     final areaInSqKm = area / 1e6;
  //     final areaInAcre = area / 4046.85642;

  //     // Show result in bottom sheet
  //     showModalBottomSheet(
  //       context: context,
  //       backgroundColor: white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       builder: (_) {
  //         return Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Center(
  //                 child: Container(
  //                   width: 50,
  //                   height: 4,
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey[400],
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //               ),
  //               SizedBox(height: 15),
  //               Text(
  //                 "Measurement Summary",
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //               ),
  //               SizedBox(height: 10),
  //               _buildInfoRow("Area (m²)", area.toStringAsFixed(2)),
  //               _buildInfoRow("Area (km²)", areaInSqKm.toStringAsFixed(4)),
  //               _buildInfoRow("Area (acres)", areaInAcre.toStringAsFixed(4)),
  //               _buildInfoRow("Perimeter (m)", perimeter.toStringAsFixed(2)),
  //               SizedBox(height: 15),
  //               Align(
  //                 alignment: Alignment.centerRight,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                     _clearAll();
  //                   },
  //                   style: TextButton.styleFrom(
  //                     backgroundColor: primaryColor,
  //                     foregroundColor: white,
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 20,
  //                       vertical: 12,
  //                     ),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),
  //                   child: const Text("Close"),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }
