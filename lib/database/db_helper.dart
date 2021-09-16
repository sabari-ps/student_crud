import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<Database> db() async {
    return openDatabase('students.db', version: 1,
        onCreate: (Database database, int version) async {
      await database.execute('''
      CREATE TABLE students(
      student_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      student_name TEXT NOT NULL,
      student_email VARCHAR UNIQUE NOT NULL,
      student_phone INTEGER UNIQUE NOT NULL,
      student_place TEXT NOT NULL
    )
        ''');
    });
  }

  static Future<int> createStudent(
      String name, String email, int phone, String place) async {
    final db = await DatabaseHelper.db();
    final data = {
      'student_name': name,
      'student_email': email,
      'student_phone': phone,
      'student_place': place,
    };
    final id = await db.insert(
      'students',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getStudent(String name) async {
    final db = await DatabaseHelper.db();
    return db.query('students', where: "student_name = ?", whereArgs: [name]);
  }

  static Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await DatabaseHelper.db();
    return db.query('students', orderBy: 'student_id');
  }

  static Future<int> updateStudent(
      int id, String name, String email, int phone, String place) async {
    final db = await DatabaseHelper.db();
    final data = {
      'student_name': name,
      'student_email': email,
      'student_phone': phone,
      'student_place': place,
    };
    final result = await db
        .update("students", data, where: "student_id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteStudent(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete('students', where: "student_id = ?", whereArgs: [id]);
    } catch (exception) {
      // ignore: avoid_print
      print(exception);
    }
  }
}
