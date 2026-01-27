import 'package:mesasnsps/model/event_status.dart';

class EventHistoryModel {
  final String title;
  final DateTime date;
  final double totalRevenue;
  final int tablesSold;
  final EventStatus status;

  EventHistoryModel({
    required this.title,
    required this.date,
    required this.totalRevenue,
    required this.tablesSold,
    required this.status,
  });
}
