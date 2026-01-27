import 'package:flutter/material.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:uuid/uuid.dart';

class TableProvider extends ChangeNotifier {
  // --- ESTADO ---
  List<EventModel> _events = [];
  List<EventModel> _archivedEvents = [];
  EventModel? _selectedEvent;
  Set<int> selectedNumbers = {};

  // --- GETTERS ---
  List<EventModel> get allEvents => _events;
  EventModel? get selectedEvent => _selectedEvent;

  /// Eventos que não foram arquivados e ainda não passaram da data de hoje
  List<EventModel> get activeEvents {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return _events.where((e) {
      return !e.date.isBefore(startOfToday);
    }).toList();
  }

  /// Eventos arquivados manualmente + eventos que já passaram da data
  List<EventModel> get historyEvents {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final expiredEvents = _events
        .where((e) => e.date.isBefore(startOfToday))
        .toList();
    return [..._archivedEvents, ...expiredEvents];
  }

  // Getters de conveniência
  double get globalPrice => _selectedEvent?.tablePrice ?? 0.0;
  List<TableModel> get tables => _selectedEvent?.tables ?? [];

  // --- GERENCIAMENTO DE EVENTOS ---

  void setCurrentEvent(EventModel event) {
    if (_selectedEvent?.id == event.id) return;
    _selectedEvent = event;
    selectedNumbers.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
    _events.add(newEvent);
    notifyListeners();
  }

  void archiveEvent(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _archivedEvents.add(_events[index]);
      _events.removeAt(index);

      // Se o evento arquivado era o selecionado, limpa a seleção
      if (_selectedEvent?.id == id) _selectedEvent = null;

      notifyListeners();
    }
  }

  void unarchiveEvent(String id) {
    final index = _archivedEvents.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events.add(_archivedEvents[index]);
      _archivedEvents.removeAt(index);
      notifyListeners();
    }
  }

  void deleteEvent(String id, {bool fromArchive = false}) {
    if (fromArchive) {
      _archivedEvents.removeWhere((e) => e.id == id);
    } else {
      _events.removeWhere((e) => e.id == id);
    }

    if (_selectedEvent?.id == id) _selectedEvent = null;
    notifyListeners();
  }

  void updateEventConfig(int count, double price) {
    if (_selectedEvent == null) return;

    _selectedEvent!.tablePrice = price;

    // Atualiza preço das mesas existentes
    for (var table in _selectedEvent!.tables) {
      table.price = price;
    }

    // Ajusta quantidade de mesas
    if (count > _selectedEvent!.tables.length) {
      int startNumber = _selectedEvent!.tables.length + 1;
      for (int i = startNumber; i <= count; i++) {
        _selectedEvent!.tables.add(TableModel(number: i, price: price));
      }
    } else if (count < _selectedEvent!.tables.length && count > 0) {
      _selectedEvent!.tables = _selectedEvent!.tables.sublist(0, count);
    }

    notifyListeners();
  }

  // --- LÓGICA DE RESERVAS ---

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

  Future<void> confirmReservation({
    required List<int> tableNumbers,
    required String name,
    required String phone,
    required bool isPaid,
    String? method,
    String? path,
  }) async {
    // Simulação de delay para UI
    await Future.delayed(const Duration(milliseconds: 400));

    for (var num in tableNumbers) {
      var table = tables.firstWhere((t) => t.number == num);
      table.userName = name;
      table.phoneNumber = phone;
      table.paymentMethod = method;
      table.receiptPath = path;
      table.status = isPaid ? TableStatusEnum.paid : TableStatusEnum.reserved;
    }
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
    await Future.delayed(const Duration(milliseconds: 400));

    // Limpa reservas antigas deste usuário
    for (var table in tables) {
      if (table.userName == oldUserName) {
        table.userName = null;
        table.phoneNumber = null;
        table.paymentMethod = null;
        table.receiptPath = null;
        table.status = TableStatusEnum.available;
      }
    }

    // Define novas reservas
    for (var num in newTableNumbers) {
      var table = tables.firstWhere((t) => t.number == num);
      table.userName = name;
      table.phoneNumber = phone;
      table.paymentMethod = method;
      table.receiptPath = path;
      table.status = isPaid ? TableStatusEnum.paid : TableStatusEnum.reserved;
    }
    clearSelection();
  }

  Future<void> clearReservation(String userName) async {
    await Future.delayed(const Duration(milliseconds: 400));
    for (var table in tables) {
      if (table.userName == userName) {
        table.userName = null;
        table.phoneNumber = null;
        table.paymentMethod = null;
        table.receiptPath = null;
        table.status = TableStatusEnum.available;
      }
    }
    notifyListeners();
  }

  void prepareForEdit(List<int> tableNumbers) {
    selectedNumbers.clear();
    selectedNumbers.addAll(tableNumbers);
    notifyListeners();
  }

  // --- FINANCEIRO ---

  double get totalArrecadado {
    return tables.where((t) => t.status == TableStatusEnum.paid).length *
        globalPrice;
  }

  double get totalPendente {
    return tables.where((t) => t.status == TableStatusEnum.reserved).length *
        globalPrice;
  }
}
