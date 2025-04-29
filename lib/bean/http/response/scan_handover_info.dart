/// Barcode : "BBEF3634-9F2F-4115-BE57-F6A290F331A4"
/// Index : "3"

class ScanHandoverInfo {
  ScanHandoverInfo({
      this.barcode, 
      this.index,});

  ScanHandoverInfo.fromJson(dynamic json) {
    barcode = json['Barcode'];
    index = json['Index'];
  }
  String? barcode;
  String? index;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Barcode'] = barcode;
    map['Index'] = index;
    return map;
  }

}