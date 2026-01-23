import 'package:mesasnsps/model/table.dart';

class EventModel {
  final String id;
  String name;
  DateTime date;
  double tablePrice;
  int totalTables;
  List<TableModel> tables;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    this.tablePrice = 20.0,
    this.totalTables = 50,
    required this.tables,
  });
}
