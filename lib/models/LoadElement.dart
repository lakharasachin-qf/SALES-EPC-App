class LoadElement {
  String deviceName;
  String category;
  String power;
  String usageHrs;
  String energyWh;
  String energyKWh;

  LoadElement({
    required this.deviceName,
    required this.category,
    required this.power,
    required this.usageHrs,
    required this.energyWh,
    required this.energyKWh,
  });
}

class UploadFile {
  String uploadFile;
  String category;
  // String power;

  UploadFile({required this.uploadFile, required this.category});
}
