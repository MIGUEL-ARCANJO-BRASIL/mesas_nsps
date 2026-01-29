import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:uuid/uuid.dart';

class TableProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ESTADO ---
  List<EventModel> _events = [];
  List<EventModel> _archivedEvents = []; // Mantido conforme original
  EventModel? _selectedEvent;
  Set<int> selectedNumbers = {};

  // --- CONSTRUTOR ---
  TableProvider() {
    _listenToEvents();
  }

  // --- SINCRONIZAÇÃO EM TEMPO REAL ---
  void _listenToEvents() {
    _db.collection('events').snapshots().listen((snapshot) {
      _events = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Se o evento selecionado mudar no banco, atualiza ele aqui também
      if (_selectedEvent != null) {
        try {
          _selectedEvent = _events.firstWhere(
            (e) => e.id == _selectedEvent!.id,
          );
        } catch (_) {
          // Se não achar (foi deletado), não faz nada ou limpa
        }
      }
      notifyListeners();
    });
  }

  // --- GETTERS ---
  List<EventModel> get allEvents => _events;
  EventModel? get selectedEvent => _selectedEvent;

  double get globalPrice => _selectedEvent?.tablePrice ?? 0.0;
  List<TableModel> get tables => _selectedEvent?.tables ?? [];

  List<EventModel> get activeEvents {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return _events.where((e) => !e.date.isBefore(startOfToday)).toList();
  }

  List<EventModel> get historyEvents {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final expiredEvents = _events
        .where((e) => e.date.isBefore(startOfToday))
        .toList();
    return [..._archivedEvents, ...expiredEvents];
  }

  // --- GERENCIAMENTO DE EVENTOS (PERSISTENTE) ---

  void selectEvent(EventModel event) {
    _selectedEvent = event;
    notifyListeners();
  }

  void setCurrentEvent(EventModel event) {
    if (_selectedEvent?.id == event.id) return;
    _selectedEvent = event;
    selectedNumbers.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Future<void> addEvent(
    String name,
    int tableCount,
    double price,
    DateTime eventDate,
  ) async {
    final newEvent = EventModel(
      id: const Uuid().v4(),
      name: name,
      date: eventDate,
      tablePrice: price,
      tables: List.generate(
        tableCount,
        (index) => TableModel(number: index + 1, price: price),
      ),
    );
    await _db.collection('events').doc(newEvent.id).set(newEvent.toMap());
  }

  void archiveEvent(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _archivedEvents.add(_events[index]);
      // Nota: Para arquivamento persistente, você precisaria de um campo 'isArchived' no Firebase.
      // Aqui mantemos local como estava no seu original.
      deleteEvent(id);
    }
  }

  void unarchiveEvent(String id) {
    final index = _archivedEvents.indexWhere((e) => e.id == id);
    if (index != -1) {
      addEvent(
        _archivedEvents[index].name,
        _archivedEvents[index].tables.length,
        _archivedEvents[index].tablePrice,
        _archivedEvents[index].date,
      );
      _archivedEvents.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id, {bool fromArchive = false}) async {
    if (fromArchive) {
      _archivedEvents.removeWhere((e) => e.id == id);
    } else {
      await _db.collection('events').doc(id).delete();
    }
    if (_selectedEvent?.id == id) _selectedEvent = null;
    notifyListeners();
  }

  Future<void> updateEventConfig(int count, double price) async {
    if (_selectedEvent == null) return;

    _selectedEvent!.tablePrice = price;
    for (var table in _selectedEvent!.tables) {
      table.price = price;
    }

    if (count > _selectedEvent!.tables.length) {
      int startNumber = _selectedEvent!.tables.length + 1;
      for (int i = startNumber; i <= count; i++) {
        _selectedEvent!.tables.add(TableModel(number: i, price: price));
      }
    } else if (count < _selectedEvent!.tables.length && count > 0) {
      _selectedEvent!.tables = _selectedEvent!.tables.sublist(0, count);
    }

    await _db.collection('events').doc(_selectedEvent!.id).update({
      'tablePrice': price,
      'tables': _selectedEvent!.tables.map((t) => t.toMap()).toList(),
    });

    notifyListeners();
  }

  // --- LÓGICA DE RESERVAS (PERSISTENTE) ---

  void toggleTableSelection(int number) {
    if (selectedNumbers.contains(number)) {
      selectedNumbers.remove(number);
    } else {
      selectedNumbers.add(number);
    }
    notifyListeners();
  }

  void clearSelection() {
    selectedNumbers.clear();
    notifyListeners();
  }

  void prepareForEdit(List<int> tableNumbers) {
    selectedNumbers.clear();
    selectedNumbers.addAll(tableNumbers);
    notifyListeners();
  }

  Future<void> confirmReservation({
    required List<int> tableNumbers,
    required String name,
    required String phone,
    required bool isPaid,
    String? method,
    String? path,
  }) async {
    if (_selectedEvent == null) return;

    for (var num in tableNumbers) {
      var table = tables.firstWhere((t) => t.number == num);
      table.userName = name;
      table.phoneNumber = phone;
      table.paymentMethod = method;
      table.receiptPath = path;
      table.status = isPaid ? TableStatusEnum.paid : TableStatusEnum.reserved;
    }

    await _db
        .collection('events')
        .doc(_selectedEvent!.id)
        .update(_selectedEvent!.toMap());
    clearSelection();
  }

  Future<void> updateReservation({
    required String oldUserName,
    required List<int> newTableNumbers,
    required String name,
    required String phone,
    required bool isPaid,
    String? method,
    String? path,
  }) async {
    if (_selectedEvent == null) return;

    for (var table in tables) {
      if (table.userName == oldUserName) {
        table.userName = null;
        table.phoneNumber = null;
        table.paymentMethod = null;
        table.receiptPath = null;
        table.status = TableStatusEnum.available;
      }
    }

    for (var num in newTableNumbers) {
      var table = tables.firstWhere((t) => t.number == num);
      table.userName = name;
      table.phoneNumber = phone;
      table.paymentMethod = method;
      table.receiptPath = path;
      table.status = isPaid ? TableStatusEnum.paid : TableStatusEnum.reserved;
    }

    await _db
        .collection('events')
        .doc(_selectedEvent!.id)
        .update(_selectedEvent!.toMap());
    clearSelection();
  }

  Future<void> clearReservation(String userName) async {
    if (_selectedEvent == null) return;
    for (var table in tables) {
      if (table.userName == userName) {
        table.userName = null;
        table.phoneNumber = null;
        table.paymentMethod = null;
        table.receiptPath = null;
        table.status = TableStatusEnum.available;
      }
    }
    await _db
        .collection('events')
        .doc(_selectedEvent!.id)
        .update(_selectedEvent!.toMap());
  }

  // --- FINANCEIRO ---
  double get totalArrecadado =>
      tables.where((t) => t.status == TableStatusEnum.paid).length *
      globalPrice;
  double get totalPendente =>
      tables.where((t) => t.status == TableStatusEnum.reserved).length *
      globalPrice;
}
