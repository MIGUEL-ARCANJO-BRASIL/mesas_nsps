import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/model/obstacle.dart';

class EventModel {
  final String id;
  final String ownerId;
  String name;
  DateTime date;
  double tablePrice;
  int totalTables;
  List<TableModel> tables;
  List<LayoutObstacleModel> obstacles;
  int gridColumns;
  int gridRows;
  bool isArchived;
  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'date': date.toIso8601String(),
    'tablePrice': tablePrice,
    'tables': tables.map((t) => t.toMap()).toList(),
    'obstacles': obstacles.map((o) => o.toMap()).toList(),
    'gridColumns': gridColumns,
    'gridRows': gridRows,
    'isArchived': isArchived,
  };
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      date: DateTime.parse(map['date']),
      tablePrice: (map['tablePrice'] ?? 0.0).toDouble(),
      // Mapeia a lista de Dynamic para uma lista de TableModel
      tables:
          (map['tables'] as List<dynamic>?)
              ?.map((t) => TableModel.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      obstacles:
          (map['obstacles'] as List<dynamic>?)
              ?.map((o) => LayoutObstacleModel.fromMap(o as Map<String, dynamic>))
              .toList() ??
          [],
      gridColumns: map['gridColumns'] ?? 10,
      gridRows: map['gridRows'] ?? 15,
      isArchived: map['isArchived'] ?? false,
    );
  }
  EventModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.date,
    this.tablePrice = 20.0,
    this.totalTables = 50,
    required this.tables,
    this.obstacles = const [],
    this.gridColumns = 10,
    this.gridRows = 15,
    this.isArchived = false,
  });
  bool get isExpired =>
      DateTime.now().isAfter(date.add(const Duration(days: 1)));
  EventModel copyWith({
    String? name,
    DateTime? date,
    double? tablePrice,
    List<TableModel>? tables,
    List<LayoutObstacleModel>? obstacles,
    int? gridColumns,
    int? gridRows,
    bool? isArchived,
    String? ownerId,
  }) {
    return EventModel(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      date: date ?? this.date,
      tablePrice: tablePrice ?? this.tablePrice,
      tables: tables ?? this.tables,
      obstacles: obstacles ?? this.obstacles,
      gridColumns: gridColumns ?? this.gridColumns,
      gridRows: gridRows ?? this.gridRows,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
