class Vehicle {
  final String vehicleId;
  final int currentLoad;
  final int maxLoad;
  final String ledStatus;
  final bool needsConfirmation;
  final int coordX;
  final int coordY;

  Vehicle({
    required this.vehicleId,
    required this.currentLoad,
    required this.maxLoad,
    required this.ledStatus,
    required this.needsConfirmation,
    required this.coordX,
    required this.coordY,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicle_id'],
      currentLoad: json['current_load'],
      maxLoad: json['max_load'],
      ledStatus: json['led_status'],
      needsConfirmation: json['needs_confirmation'],
      coordX: json['coord_x'],
      coordY: json['coord_y'],
    );
  }
}
