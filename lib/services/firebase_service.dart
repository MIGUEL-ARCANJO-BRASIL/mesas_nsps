import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/table.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Salvar ou atualizar um evento
  Future<void> saveEvent(EventModel event) async {
    await _db.collection('events').doc(event.id).set(event.toMap());
  }

  Future<void> updateEventConfig(
    String eventId,
    double newPrice,
    List<TableModel> newTables,
  ) async {
    try {
      await _db.collection('events').doc(eventId).update({
        'tablePrice': newPrice,
        'tables': newTables.map((t) => t.toMap()).toList(),
      });
    } catch (e) {
      print("Erro ao atualizar configurações: $e");
      rethrow;
    }
  }

  // Escutar os eventos em tempo real
  Stream<List<EventModel>> getEventsStream() {
    return _db.collection('events').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data()))
          .toList();
    });
  }
}
