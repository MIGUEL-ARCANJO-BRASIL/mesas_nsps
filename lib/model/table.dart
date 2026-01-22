enum TableStatusEnum { available, paid, reserved }

class TableModel {
  int number;
  String? userName;
  String? phoneNumber;
  String? paymentMethod;
  String? receiptPath;
  TableStatusEnum status;
  double price;

  TableModel({
    required this.number,
    this.userName,
    this.phoneNumber,
    this.paymentMethod,
    this.receiptPath,
    this.status = TableStatusEnum.available,
    this.price = 0.0,
  });
}
