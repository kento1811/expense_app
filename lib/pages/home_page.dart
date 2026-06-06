import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../service/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _addExpense() async {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) return; // Kiểm tra tính hợp lệ (Validation)

    // Khởi tạo đối tượng từ Model đã học
    final newExpense = Expense(
      title: title,
      amount: amount,
      date: DateTime.now(),
    );

    await DatabaseHelper.instance.insertExpense(newExpense);

    _titleController.clear();
    _amountController.clear();
    setState(() {});
  } 

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiem tra data chi tieu"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Tên khoản chi")),
                TextField(controller: _amountController, decoration: const InputDecoration(labelText: "Số tiền"), keyboardType: TextInputType.number),
                const SizedBox(height: 10), // Hộp rỗng tạo khoảng cách [9]
                ElevatedButton(onPressed: _addExpense, child: const Text("Lưu vào SQLite")),
              ],
            ),
          ),
           const Divider(),
           Expanded(
            child: FutureBuilder<List<Expense>>(
              future: DatabaseHelper.instance.getAllExpenses(), 
              builder: (context, snapshot) {
                if(!snapshot.hasData ) return const Center(child: CircularProgressIndicator());

                final expenses = snapshot.data!;
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context ,index){
                    final item = expenses[index];
                    return ListTile(
                      leading: const Icon(Icons.money),
                      title: Text(item.title),
                      subtitle: Text(item.date.toIso8601String()),
                      trailing: Text("${item.amount}đ"),
                    );
                  },
                );

                }
              ),
            )
        ],
      ),
    );
  }
}