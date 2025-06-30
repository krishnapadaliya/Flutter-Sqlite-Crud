import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NormalCrud extends StatefulWidget {
  const NormalCrud({super.key});

  @override
  State<NormalCrud> createState() => _NormalCrudState();
}

class _NormalCrudState extends State<NormalCrud> {
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _controller = TextEditingController();
  List<Note> _notes = [];
  Note? _editingNote;

  void _refreshNotes() async {
    final data = await _dbHelper.getNotes();
    setState(() => _notes = data);
  }

  void _submitNote() async {
    String text = _controller.text;
    if (text.isEmpty) return;

    if (_editingNote != null) {
      await _dbHelper.updateNote(Note(id: _editingNote!.id, title: text));
      _editingNote = null;
    } else {
      await _dbHelper.insertNote(Note(title: text));
    }

    _controller.clear();
    _refreshNotes();
  }

  void _edit(Note note) {
    setState(() {
      _editingNote = note;
      _controller.text = note.title;
    });
  }

  void _delete(int id) async {
    await _dbHelper.deleteNote(id);
    _refreshNotes();
  }

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter note'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _submitNote,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(note.title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _edit(note),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(note.id!),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class Note {
  final int? id;
  final String title;

  Note({this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}


class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "notes.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      return Note(id: maps[i]['id'], title: maps[i]['title']);
    });
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
