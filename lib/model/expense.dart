class Expense {
  final String id; // Đổi sang kiểu String không có dấu hỏi chấm (?)
  final String title;
  final double amount;
  final DateTime date;
  final int isSynced; 

  Expense({
    String? id, // Nhận vào id nếu có (khi đọc từ DB)
    required this.title, 
    required this.amount, 
    required this.date, 
    this.isSynced = 0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(); // Nếu id null, tự sinh chuỗi id theo thời gian hiện tại

  // Đổi hoàn toàn sang 'is_synced' để khớp với Database cục bộ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'is_synced': isSynced, // SỬA: Đổi từ isSynced thành is_synced
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isSynced: map['is_synced'] ?? 0, // SỬA: Đổi từ isSynced thành is_synced
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(), 
    };
  }
}