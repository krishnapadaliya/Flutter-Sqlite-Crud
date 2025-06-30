import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiCrud extends StatefulWidget {
  const ApiCrud({super.key});

  @override
  State<ApiCrud> createState() => _ApiCrudState();
}

class _ApiCrudState extends State<ApiCrud> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes CRUD')),
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
                  onPressed: () async {
                    if (_controller.text.trim().isNotEmpty) {
                      await insertApi(_controller.text.trim());
                      _controller.clear();
                      setState(() {});
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<http.Response>(
              future: getApi(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final List data = jsonDecode(snapshot.data!.body.toString());

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(data[index]['title']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _controller.text = data[index]['title'];

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Update Note'),
                                  content: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(hintText: 'Edit note'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        if (_controller.text.trim().isNotEmpty) {
                                          await updateApi(
                                            data[index]['id'],
                                            _controller.text.trim(),
                                          );
                                          _controller.clear();
                                          Navigator.pop(context);
                                          setState(() {});
                                        }
                                      },
                                      child: Text('Update'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await deleteApi(data[index]['id']);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// GET
Future<http.Response> getApi() async {
  var res = await http.get(
    Uri.parse("https://6861123a8e7486408444d339.mockapi.io/Note"),
  );
  return res;
}

// DELETE
Future<http.Response> deleteApi(String id) async {
  var res = await http.delete(
    Uri.parse("https://6861123a8e7486408444d339.mockapi.io/Note/$id"),
  );
  return res;
}

// UPDATE
Future<http.Response> updateApi(String id, String value) async {
  Map<String, dynamic> map = {"title": value};

  var res = await http.put(
    Uri.parse("https://6861123a8e7486408444d339.mockapi.io/Note/$id"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(map),
  );
  return res;
}

// INSERT
Future<http.Response> insertApi(String value) async {
  Map<String, dynamic> map = {"title": value};

  var res = await http.post(
    Uri.parse("https://6861123a8e7486408444d339.mockapi.io/Note"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(map),
  );
  return res;
}
