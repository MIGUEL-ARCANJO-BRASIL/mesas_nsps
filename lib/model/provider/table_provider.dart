import 'package:flutter/material.dart';
import 'package:mesasnsps/model/table.dart';

class TableProvider extends ChangeNotifier {
  // O preço agora é uma variável que pode ser editada
  double _globalPrice = 50.0;
  double get globalPrice => _globalPrice;

  // Iniciamos a lista (pode começar com 0 ou 100, conforme sua preferência)
  List<TableModel> tables = List.generate(
    100,
    (index) => TableModel(number: index + 1, price: 50.0),
  );

  Set<int> selectedNumbers = {};

  // --- NOVO MÉTODO DE CONFIGURAÇÃO ---
  void updateEventConfig(int count, double price) {
    _globalPrice = price;

    // 1. Ajustar o preço de todas as mesas (existentes e novas)
    for (var table in tables) {
      table.price = price;
    }

    // 2. Lógica de redimensionar a quantidade de mesas
    if (count > tables.length) {
      // Se aumentou, adicionamos novas mesas no final
      int startNumber = tables.length + 1;
      for (int i = startNumber; i <= count; i++) {
        tables.add(TableModel(number: i, price: price));
      }
    } else if (count < tables.length && count > 0) {
      // Se diminuiu, removemos as últimas (cuidado: isso remove os dados das mesas excluídas)
      tables = tables.sublist(0, count);
    }

    notifyListeners();
  }

  // --- MÉTODOS DE CÁLCULO FINANCEIRO (O "Toque Extra") ---

  double get totalArrecadado {
    return tables.where((t) => t.status == TableStatusEnum.paid).length *
        _globalPrice;
  }

  double get totalPendente {
    return tables.where((t) => t.status == TableStatusEnum.reserved).length *
        _globalPrice;
  }

  // ... (mantenha seus métodos toggleTableSelection, clearSelection, etc. abaixo)

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

  void clearReservation(String userName) {
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

  void updateReservation({
    required String oldUserName,
    required List<int> newTableNumbers,
    required String name,
    required String phone,
    required bool isPaid,
    String? method,
    String? path,
  }) {
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
  }

  void confirmReservation({
    required List<int> tableNumbers,
    required String name,
    required String phone,
    required bool isPaid,
    String? method,
    String? path,
  }) {
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
