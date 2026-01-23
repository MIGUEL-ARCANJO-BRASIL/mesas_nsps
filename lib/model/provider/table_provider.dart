import 'package:flutter/material.dart';
import 'package:mesasnsps/model/table.dart';

class TableProvider extends ChangeNotifier {
  double _globalPrice = 50.0;
  double get globalPrice => _globalPrice;

  List<TableModel> tables = List.generate(
    100,
    (index) => TableModel(number: index + 1, price: 50.0),
  );

  Set<int> selectedNumbers = {};

  void updateEventConfig(int count, double price) {
    _globalPrice = price;
    for (var table in tables) {
      table.price = price;
    }

    if (count > tables.length) {
      int startNumber = tables.length + 1;
      for (int i = startNumber; i <= count; i++) {
        tables.add(TableModel(number: i, price: price));
      }
    } else if (count < tables.length && count > 0) {
      tables = tables.sublist(0, count);
    }
    notifyListeners();
  }

  double get totalArrecadado {
    return tables.where((t) => t.status == TableStatusEnum.paid).length *
        _globalPrice;
  }

  double get totalPendente {
    return tables.where((t) => t.status == TableStatusEnum.reserved).length *
        _globalPrice;
  }

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

  Future<void> clearReservation(String userName) async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (var table in tables) {
      if (table.userName == userName) {
        table.userName = null;
        table.phoneNumber = null;
        table.paymentMethod = null;
        table.status = TableStatusEnum.available;
      }
    }
    notifyListeners();
  }

  // --- ALTERADO PARA FUTURE<VOID> E ASYNC ---
  Future<void> updateReservation({
    required String oldUserName,
    required List<int> newTableNumbers,
    required String name,
    required String phone,
    required bool isPaid,
    String? method,
    String? path,
  }) async {
    // Simula um pequeno atraso para a animação ser percebida pelo usuário
    await Future.delayed(const Duration(milliseconds: 600));

    for (var table in tables) {
      if (table.userName == oldUserName) {
        table.userName = null;
        table.phoneNumber = null;
        table.paymentMethod = null;
        table.status = TableStatusEnum.available;
        table.receiptPath = null;
      }
    }

    for (var num in newTableNumbers) {
      var table = tables.firstWhere((t) => t.number == num);
      table.userName = name;
      table.phoneNumber = phone;
      table.paymentMethod = method;
      table.status = isPaid ? TableStatusEnum.paid : TableStatusEnum.reserved;
      table.receiptPath = path;
    }
    clearSelection();
    // notifyListeners já é chamado dentro de clearSelection
  }

  // --- ALTERADO PARA FUTURE<VOID> E ASYNC ---
  Future<void> confirmReservation({
    required List<int> tableNumbers,
    required String name,
    required String phone,
    required bool isPaid,
    String? method,
    String? path,
  }) async {
    // Simula um pequeno atraso para a animação
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

  void prepareForEdit(List<int> tableNumbers) {
    selectedNumbers.clear();
    selectedNumbers.addAll(tableNumbers);
    notifyListeners();
  }
}
