import 'package:mesasnsps/model/table.dart';

class EventModel {
  final String id;
  String name;
  DateTime date;
  double tablePrice;
  int totalTables;
  List<TableModel> tables;
  bool isArchived;

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
