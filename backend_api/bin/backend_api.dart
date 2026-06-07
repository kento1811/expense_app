import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'dart:io';

void main() async {
  // 1. Thiết lập kết nối tới Postgres trong Docker
  final String dbHost = Platform.environment['DB_HOST'] ?? 'db_spending';
  final String dbName = Platform.environment['DB_NAME'] ?? 'spending_db';
  final String dbUser = Platform.environment['DB_USER'] ?? 'admin';
  final String dbPass = Platform.environment['DB_PASSWORD'] ?? 'secret';
  final int dbPort = int.parse(Platform.environment['DB_PORT'] ?? '5432');
  
  final conn = await Connection.open(
    Endpoint(
      host: dbHost, // Tên dịch vụ trong Docker Compose
      database: dbName,
      username: dbUser,
      password: dbPass,
      port: dbPort, // Cổng nội bộ của Docker luôn là 5432
    ),
    settings: ConnectionSettings(
      sslMode: dbHost == 'db_spending' ? SslMode.disable : SslMode.require,
    ),
  );

  final router = Router();

  // 2. Định nghĩa Endpoint GET: Lấy danh sách chi tiêu
  router.get('/expenses', (Request request) async {
    final results = await conn.execute('SELECT * FROM expenses');
    
    // Chuyển đổi dữ liệu từ DB sang định dạng JSON
    final data = results.map((row) => {
      'id': row[0],    // <-- SỬA TẠI ĐÂY: row[0] tương ứng với cột ID trong bảng
      'title': row[1],
      'amount': row[2],
      'date': (row[3] as DateTime).toIso8601String(),
    }).toList();

    return Response.ok(jsonEncode(data), headers: {'Content-Type': 'application/json'});
  });

  // 3. Khởi chạy Server nội bộ của container tại cổng 8080
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router.call);
  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('API Server đang chạy tại: http://${server.address.host}:${server.port}');
}