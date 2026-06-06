import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';

void main() async {
  // 1. Thiết lập kết nối tới Postgres trong Docker
  final conn = await Connection.open(
    Endpoint(
      host: 'db_spending', // Tên dịch vụ trong Docker Compose
      database: 'spending_db',
      username: 'admin',
      password: 'secret',
      port: 5432, // Cổng nội bộ của Docker
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );

  final router = Router();

  // 2. Định nghĩa Endpoint GET: Lấy danh sách chi tiêu
  router.get('/expenses', (Request request) async {
    final results = await conn.execute('SELECT * FROM expenses');
    
    // Chuyển đổi dữ liệu từ DB sang định dạng JSON
    final data = results.map((row) => {
      'id': row,
      'title': row[1],
      'amount': row[2],
      'date': (row[3] as DateTime).toIso8601String(),
    }).toList();

    return Response.ok(jsonEncode(data), headers: {'Content-Type': 'application/json'});
  });

  // 3. Khởi chạy Server tại cổng 8080
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router.call);
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('API Server đang chạy tại: http://${server.address.host}:${server.port}');
}