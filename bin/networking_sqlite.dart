import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart';

void main() async {
  final database = sqlite3.open('example.db');

  database.execute('''
  CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY,
    title TEXT,
    body TEXT
  )
  ''');

  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    for (final item in data) {
      final id = item['id'] as int;
      final title = item['title'] as String;
      final body = item['body'] as String;

      database.execute('''
      INSERT INTO posts (id, title, body)
      VALUES (?, ?, ?)
      ''', [id, title, body]);
    }
  } else {
    throw Exception('Failed to load data');
  }

  database.dispose();
}
