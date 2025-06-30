class Vehicle {
  final String vehicleId;
  final int currentLoad;
  final int maxLoad;
  final String ledStatus;
  final bool needsConfirmation;
  final int coordX;
  final int coordY;
  final int aiCoordX;
  final int aiCoordY;

  Vehicle({
    required this.vehicleId,
    required this.currentLoad,
    required this.maxLoad,
    required this.ledStatus,
    required this.needsConfirmation,
    required this.coordX,
    required this.coordY,
    required this.aiCoordX,
    required this.aiCoordY,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicle_id'] ?? '',
      currentLoad: json['current_load'] ?? 0,
      maxLoad: json['max_load'] ?? 0,
      ledStatus: json['led_status'] ?? '',
      needsConfirmation: json['needs_confirmation'] ?? false,
      coordX: json['coord_x'] ?? 0,
      coordY: json['coord_y'] ?? 0,
      aiCoordX: json['AI_coord_x'] ?? 0,
      aiCoordY: json['AI_coord_y'] ?? 0,
    );
  }
}
