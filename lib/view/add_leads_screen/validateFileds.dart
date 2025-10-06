import 'package:get/get.dart';
import 'package:sales_app/controller/leads_controller/add_leads_controller.dart';

class ValidateAddLeadfileds {
  final AddLeadsController ctr = Get.find<AddLeadsController>();

  void validateCompanyName(String? val) {
    ctr.companyNameModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Company Name is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateAddress(String? val) {
    ctr.addressModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Address is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateCountry(String? val) {
    ctr.countryModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Country is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateState(String? val) {
    ctr.stateModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "State is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateDistrict(String? val) {
    ctr.districtModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "District is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validatePersonName(String? val) {
    ctr.personNameModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Contact Person Name is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validatePersonMobile(String? val) {
    ctr.personMobileModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Contact Person Mobile is required";
        model.isValidate = false;
      } else if (val.length < 10) {
        model!.error = "Enter valid mobile number";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateLatitude(String? val) {
    ctr.latitudeModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid latitude";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateLongitude(String? val) {
    ctr.longitudeModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid longitude";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateRequiredSolutionType(String? val) {
    ctr.requiredSolutionTypeModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Solution Type";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateRequiredSolution(String? val) {
    ctr.requiredSolutionModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Required Solution";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateLeadCategory(String? val) {
    ctr.leadCategoryModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Lead Category";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateDGCapacity(String? val) {
    ctr.dgCapacityModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid DG Capacity";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateDGSync(String? val) {
    ctr.dgSyncModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter DG Sync selection";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateInstalledSolarCap(String? val) {
    ctr.installedSolarCapModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid Installed Solar Capacity";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateSanctionedLoad(String? val) {
    ctr.sanctionedLoadModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid Sanctioned Load";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateVFD(String? val) {
    ctr.vfdModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter VFD selection";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validateGridAvailability(String? val) {
    ctr.gridAvailabilityModel.update((model) {
      if (val != null && val.isNotEmpty && double.tryParse(val) == null) {
        model!.error = "Enter valid Grid Availability (hours)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep1();
  }

  void validatePeakMonthlyEnergy(String? val) {
    ctr.peakMonthlyEnergyModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Peak Monthly Energy";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid Peak Monthly Energy (kWh)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateRequiredSolarCap(String? val) {
    ctr.requiredSolarCapModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Required Solar Cap";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid Required Solar Cap (kWp)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateDistanceToTransformer(String? val) {
    ctr.distanceToTransformerModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Distance to Nearest Transformer";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid distance (Mtrs)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateRatingOfTransformer(String? val) {
    ctr.ratingOfTransformerModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Rating of Nearest Transformer";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid rating (kVA)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validatePurposeOfSolarization(String? val) {
    ctr.purposeOfSolarizationModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Purpose of Solarization is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateDistInverterACDB(String? val) {
    ctr.distInverterACDBModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Distance Inverter & ACDB Panel";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid distance (Mtrs)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateDistSolarACDB(String? val) {
    ctr.distSolarACDBModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Distance Solar & ACDB Panel";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid distance (Mtrs)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateBuildingHeight(String? val) {
    ctr.buildingHeightModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Building Height";
        model.isValidate = false;
      } else if (int.tryParse(val) == null) {
        model!.error = "Enter valid number of floors";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateRoofSizeLength(String? val) {
    ctr.roofSizeLengthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Roof Size Length";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid length (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateRoofSizeBreadth(String? val) {
    ctr.roofSizeBreadthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Roof Size Breadth";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid breadth (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateRoofNature(String? val) {
    ctr.roofNatureModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Roof Nature";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateAgeOfMetalSheet(String? val) {
    ctr.ageOfMetalSheetModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Age of Metal Sheet";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid age (years)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateGroundSizeLength(String? val) {
    ctr.groundSizeLengthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Ground Size Length";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid length (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateGroundSizeBreadth(String? val) {
    ctr.groundSizeBreadthModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Enter Ground Size Breadth";
        model.isValidate = false;
      } else if (double.tryParse(val) == null) {
        model!.error = "Enter valid breadth (ft)";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateOtherRemarks(String? val) {
    ctr.otherRemarksModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Other Remarks is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }

  void validateScheduleMeeting(String? val) {
    ctr.scheduleMeeeingModel.update((model) {
      if (val == null || val.trim().isEmpty) {
        model!.error = "Schedule Meeting is required";
        model.isValidate = false;
      } else {
        model!.error = null;
        model.isValidate = true;
      }
    });
    ctr.validateStep2();
  }
}
