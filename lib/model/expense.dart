class Expense{
  final int? id;
  final String title;
  final double amount;
  final DateTime  date;
  final int? isSynced;

  Expense({this.id, required this.title, required this.amount, required this.date, this.isSynced = 0});

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'title' : title,
      'amount' : amount,
      'date' : date.toIso8601String(),
      'isSynced' : isSynced
    };
  }

  factory Expense.fromMap(Map<String,dynamic> map){
    return Expense(id : map['id'],title: map['title'], amount: map['amount'], date: DateTime.parse(map['date']), isSynced: map['isSynced']);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), // 2. Chuẩn hóa thời gian sang chuỗi ISO
    };
  }
}