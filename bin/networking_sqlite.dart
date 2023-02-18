import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqlite3/sqlite3.dart';
import 'package:xml/xml.dart';

void main() async {
  final database = sqlite3.open('database1.db');

  //-----------------------Get json from sever-------------------------
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

  if (response.statusCode == 200) {
    // Create table posts
    database.execute('''
      CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY,
        title TEXT,
        body TEXT
      )
    ''');
    // Chuyển đổi dữ liệu từ json sang list
    final List<dynamic> data = jsonDecode(response.body);

    // Duyệt mảng list và lưu vào cở sở dữ liệu
    for (final item in data) {
      final id = item['id'] as int;
      final title = item['title'] as String;
      final body = item['body'] as String;

      database.execute('''
      INSERT INTO posts (id, title, body) VALUES (?, ?, ?)
      ''', [id, title, body]);
    }
  } else {
    throw Exception('Failed to load data');
  }

  //------------------Get json from sever------------------------

  var responseXml =
      await http.get(Uri.parse('http://feeds.bbci.co.uk/news/rss.xml'));
  if (responseXml.statusCode == 200) {
    var document = XmlDocument.parse(responseXml.body);
    var items = document.findAllElements('item');

    // Create table posts
    database.execute('''
        CREATE TABLE IF NOT EXISTS articles (
          id INTEGER PRIMARY KEY,
          title TEXT,
          description TEXT,
          link TEXT,
          pub_date TEXT
        )
      ''');
    var stmtXml = database.prepare(
        'INSERT INTO articles (title, description, link, pub_date) VALUES (?, ?, ?, ?)');

    for (var item in items) {
      var title = item.findElements('title').first.text;
      var description = item.findElements('description').first.text;
      var link = item.findElements('link').first.text;
      var pubDate = item.findElements('pubDate').first.text;

      stmtXml.execute([title, description, link, pubDate]);
    }
    stmtXml.dispose();
  } else {
    throw Exception('Failed to load data');
  }

  var results = database.select('SELECT * FROM posts');
  for (var row in results) {
    print(
        'ID: ${row[0]}, To: ${row[1]}, From: ${row[2]}, Heading: ${row[3]}, Body: ${row[4]}');
  }

  //-------------------Update data------------------------
  var updateStmtXml =
      database.prepare('UPDATE posts SET title = ?, body = ? WHERE id = ?');

  updateStmtXml.execute(['example1', 'Test 1', 1]);

  // ------------------Delete data--------------------------
  var deleteStmtXml = database.prepare('DELETE FROM posts WHERE id = ?');
  deleteStmtXml.execute([2]);
  database.dispose();
}
