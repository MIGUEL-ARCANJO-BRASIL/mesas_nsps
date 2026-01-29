import 'package:mesasnsps/model/table.dart';

class EventModel {
  final String id;
  String name;
  DateTime date;
  double tablePrice;
  int totalTables;
  List<TableModel> tables;
  bool isArchived;
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'date': date.toIso8601String(),
    'tablePrice': tablePrice,
    'tables': tables.map((t) => t.toMap()).toList(),
  };
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      date: DateTime.parse(map['date']),
      tablePrice: (map['tablePrice'] ?? 0.0).toDouble(),
      // Mapeia a lista de Dynamic para uma lista de TableModel
      tables:
          (map['tables'] as List<dynamic>?)
              ?.map((t) => TableModel.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  EventModel({
    required this.id,
    required this.name,
    required this.date,
    this.tablePrice = 20.0,
    this.totalTables = 50,
    required this.tables,
    this.isArchived = false,
  });
  bool get isExpired =>
      DateTime.now().isAfter(date.add(const Duration(days: 1)));
  EventModel copyWith({
    String? name,
    DateTime? date,
    double? tablePrice,
    List<TableModel>? tables,
    bool? isArchived,
  }) {
    return EventModel(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      tablePrice: tablePrice ?? this.tablePrice,
      tables: tables ?? this.tables,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
