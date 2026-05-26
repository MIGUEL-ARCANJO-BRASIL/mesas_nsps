class LayoutObstacleModel {
  String id;
  String type;
  String label;
  int x;
  int y;
  int width;
  int height;

  LayoutObstacleModel({
    required this.id,
    required this.type,
    required this.label,
    required this.x,
    required this.y,
    this.width = 1,
    this.height = 1,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'label': label,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  factory LayoutObstacleModel.fromMap(Map<String, dynamic> map) {
    return LayoutObstacleModel(
      id: map['id'] ?? '',
      type: map['type'] ?? 'unknown',
      label: map['label'] ?? '',
      x: map['x'] ?? 0,
      y: map['y'] ?? 0,
      width: map['width'] ?? 1,
      height: map['height'] ?? 1,
    );
  }
}
