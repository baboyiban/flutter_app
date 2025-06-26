enum ScreenType { qr, parcel, vehicle }

extension ScreenTypeLabel on ScreenType {
  String get label {
    switch (this) {
      case ScreenType.qr:
        return 'QR';
      case ScreenType.parcel:
        return '택배';
      case ScreenType.vehicle:
        return '차량';
    }
  }
}
