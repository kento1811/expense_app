import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,        -- SỬA: Đổi sang TEXT để đồng bộ chuẩn với UUID/String trên Postgres
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        is_synced INTEGER DEFAULT 0 -- SỬA: Đổi từ isSynced thành is_synced cho đồng nhất
      )
    ''');
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert(
      'expenses', 
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } 

  Future<List<Expense>> getAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }
}