import 'package:flutter/material.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:uuid/uuid.dart'; // Recomendo adicionar 'uuid' no pubspec.yaml

class TableProvider extends ChangeNotifier {
  // Lista de todos os eventos cadastrados
  List<EventModel> _events = [];
  List<EventModel> _archivedEvents = [];
  List<EventModel> get events => _events;

  // O evento que está aberto no momento
  EventModel? _selectedEvent;
  EventModel? get selectedEvent => _selectedEvent;

  // Set de seleção de mesas (permanece global para a tela do mapa)
  Set<int> selectedNumbers = {};

  // Getters de conveniência para o evento selecionado
  double get globalPrice => _selectedEvent?.tablePrice ?? 0.0;
  List<TableModel> get tables => _selectedEvent?.tables ?? [];

  // --- GERENCIAMENTO DE EVENTOS ---
  void setCurrentEvent(EventModel event) {
    // Só notifica se o evento for realmente diferente
    if (_selectedEvent?.id == event.id) return;

    _selectedEvent = event;
    selectedNumbers.clear();

    // Garante que a notificação aconteça após o frame atual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void archiveEvent(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _archivedEvents.add(_events[index]);
      _events.removeAt(index);
      if (_selectedEvent?.id == id) _selectedEvent = null;
      notifyListeners();
    }
  }

  // Desarquivar Evento
  void unarchiveEvent(String id) {
    final index = _archivedEvents.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events.add(_archivedEvents[index]);
      _archivedEvents.removeAt(index);
      notifyListeners();
    }
  }

  void deleteEvent(String id, {bool isArchived = false}) {
    if (isArchived) {
      _archivedEvents.removeWhere((e) => e.id == id);
    } else {
      _events.removeWhere((e) => e.id == id);
    }
    if (_selectedEvent?.id == id) _selectedEvent = null;
    notifyListeners();
  }

  Future<void> addEvent(String name, int tableCount, double price) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newEvent = EventModel(
      id: const Uuid().v4(),
      name: name,
      date: DateTime.now(),
      tablePrice: price,
      tables: List.generate(
        tableCount,
        (index) => TableModel(number: index + 1, price: price),
      ),
    );
    _events.add(newEvent);
    notifyListeners();
  }

  // --- CONFIGURAÇÃO DO EVENTO ATUAL ---

  void updateEventConfig(int count, double price) {
    if (_selectedEvent == null) return;

    _selectedEvent!.tablePrice = price;

    // Atualiza preço das existentes
    for (var table in _selectedEvent!.tables) {
      table.price = price;
    }

    // Ajusta quantidade
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

  // --- FINANCEIRO (BASEADO NO EVENTO SELECIONADO) ---

  double get totalArrecadado {
    return tables.where((t) => t.status == TableStatusEnum.paid).length *
        globalPrice;
  }

  double get totalPendente {
    return tables.where((t) => t.status == TableStatusEnum.reserved).length *
        globalPrice;
  }

  // --- RESERVAS (MANTÉM SUA LÓGICA ORIGINAL, MAS APLICA AO EVENTO ATIVO) ---

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
    await Future.delayed(const Duration(milliseconds: 600));

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
    await Future.delayed(const Duration(milliseconds: 600));

    // Limpa antigas
    for (var table in tables) {
      if (table.userName == oldUserName) {
        table.userName = null;
        table.phoneNumber = null;
        table.paymentMethod = null;
        table.status = TableStatusEnum.available;
        table.receiptPath = null;
      }
    }

    // Define novas
    for (var num in newTableNumbers) {
      var table = tables.firstWhere((t) => t.number == num);
      table.userName = name;
      table.phoneNumber = phone;
      table.paymentMethod = method;
      table.status = isPaid ? TableStatusEnum.paid : TableStatusEnum.reserved;
      table.receiptPath = path;
    }
    clearSelection();
  }
  // Re-adicionando o que sumiu:

  Future<void> clearReservation(String userName) async {
    await Future.delayed(const Duration(milliseconds: 600));
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
}
