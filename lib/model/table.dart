enum TableStatusEnum { available, paid, reserved }

class TableModel {
  int number;
  String? userName;
  String? phoneNumber;
  String? paymentMethod;
  String? receiptPath;
  TableStatusEnum status;
  double price;
  int? x;
  int? y;

  Map<String, dynamic> toMap() => {
    'number': number,
    'status': status.index, // Guardamos o index do Enum
    'userName': userName,
    'phoneNumber': phoneNumber,
    'paymentMethod': paymentMethod,
    'receiptPath': receiptPath,
    'price': price,
    'x': x,
    'y': y,
  };
  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      number: map['number'] ?? 0,
      status: TableStatusEnum.values[map['status'] ?? 0],
      userName: map['userName'],
      phoneNumber: map['phoneNumber'],
      paymentMethod: map['paymentMethod'],
      receiptPath: map['receiptPath'],
      price: (map['price'] ?? 0.0).toDouble(),
      x: map['x'],
      y: map['y'],
    );
  }
  TableModel({
    required this.number,
    this.userName,
    this.phoneNumber,
    this.paymentMethod,
    this.receiptPath,
    this.status = TableStatusEnum.available,
    this.price = 0.0,
    this.x,
    this.y,
  });
}
