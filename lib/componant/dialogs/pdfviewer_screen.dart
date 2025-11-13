import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_app/componant/toolbar/toolbar.dart';
import 'package:sales_app/configs/colors_constant.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;
  final bool isLocalFile; // New parameter to indicate if the PDF is local

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.isLocalFile = false, // Default to false (network PDF)
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getDynamicSizedBox(height: 1.h),
            getCommonToolbar(
              // widget.title,
              isViwerScreenOpen: true,
              widget.title,
              onClick: () {
                Get.back(result: true);
              },
            ),
            getDynamicSizedBox(height: 1.h),
            // GestureDetector(
            //   onTap: () {
            //     Get.back();
            //   },
            //   child: Container(
            //     padding: EdgeInsets.only(left: 2.w, top: 2.h, bottom: 2.h),
            //     color: white,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         SvgPicture.asset(Asset.back, height: 1.8.h, width: 1.8.h),
            //         SizedBox(width: 1.w),
            //         Text(
            //           'Back',
            //           style: TextStyle(
            //             fontSize: 14.sp,
            //             fontFamily: plusJakartaSansRegular,
            //           ),
            //         ),
            //         getDynamicSizedBox(width: 5.w),
            //         Flexible(
            //           child: Text(
            //             maxLines: 1,
            //             widget.title,
            //             style: TextStyle(
            //               overflow: TextOverflow.ellipsis,
            //               fontFamily: plusJakartaSansBold,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Expanded(
              child: widget.isLocalFile
                  ? SfPdfViewer.file(
                      File(
                        widget.pdfUrl,
                      ), // Use SfPdfViewer.file for local files
                      controller: _controller,
                      onDocumentLoaded: (details) {
                        setState(() {
                          pages = details.document.pages.count;
                          isReady = true;
                        });
                      },
                      onPageChanged: (details) {
                        setState(() {
                          currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoadFailed: (details) {
                        Get.snackbar(
                          'Error',
                          'Failed to load PDF: ${details.description}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    )
                  : SfPdfViewer.network(
                      widget.pdfUrl, // Use SfPdfViewer.network for URLs
                      controller: _controller,
                      onDocumentLoaded: (details) {
                        setState(() {
                          pages = details.document.pages.count;
                          isReady = true;
                        });
                      },
                      onPageChanged: (details) {
                        setState(() {
                          currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoadFailed: (details) {
                        Get.snackbar(
                          'Error',
                          'Failed to load PDF: ${details.description}',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
            ),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       OutlinedButton(
            //         onPressed: () {
            //           _controller.previousPage();
            //         },
            //         child: const Icon(Icons.chevron_left),
            //       ),
            //       Text(_isReady ? '$_currentPage/$_pages' : 'Loading...'),
            //       OutlinedButton(
            //         onPressed: () {
            //           _controller.nextPage();
            //         },
            //         child: const Icon(Icons.chevron_right),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
