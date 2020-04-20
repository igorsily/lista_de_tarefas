import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff1a237e),
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController tarefaController = TextEditingController();

  List _todoList = [];
  int _lastRemovedPosition;
  dynamic _lastRemoved;

  void _addTodo() {
    final todo = {
      "title": tarefaController.text,
      "check": false,
    };
    tarefaController.clear();
    setState(() {
      _todoList.add(todo);
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(
      Duration(seconds: 1),
    );

    _todoList.sort((a, b) {
      if (a['check'] && !b['check']) {
        return 1;
      }
      if (!a['check'] && b['check']) {
        return -1;
      }
      return 0;
    });

    final newTodoList = _todoList;

    setState(() {
      _todoList = newTodoList;
    });

    _saveData();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.5,
              vertical: 10.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    controller: tarefaController,
                    decoration: InputDecoration(
                      labelText: 'Tarefa',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ButtonTheme(
                    height: 50,
                    child: RaisedButton(
                      child: Text(
                        'Adicionar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      color: Color(0xff1a237e),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Color(0xff1a237e),
                        ),
                      ),
                      onPressed: _addTodo,
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(
                      DateTime.now().millisecond.toString(),
                    ),
                    onDismissed: (_) {
                      _lastRemoved = _todoList[index];
                      _lastRemovedPosition = index;
                      setState(() {
                        _todoList.removeAt(index);
                      });

                      _saveData();

                      final snackbar = SnackBar(
                        content:
                            Text("Tarefa ${_lastRemoved['title']} removida!"),
                        action: SnackBarAction(
                          label: "Desfazer",
                          onPressed: () {
                            setState(() {
                              _todoList.insert(
                                  _lastRemovedPosition, _lastRemoved);
                            });
                            _saveData();
                          },
                        ),
                        duration: Duration(
                          seconds: 3,
                        ),
                      );
                      Scaffold.of(context).showSnackBar(snackbar);
                    },
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment(-0.9, 0),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    direction: DismissDirection.startToEnd,
                    child: CheckboxListTile(
                      title: Text(
                        _todoList[index]["title"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _todoList[index]["check"] = value;
                        });
                      },
                      activeColor: Color(0xff1a237e),
                      checkColor: Colors.white,
                      value: _todoList[index]["check"],
                      secondary: CircleAvatar(
                        child: Icon(
                          _todoList[index]["check"] ? Icons.check : Icons.error,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = jsonEncode(_todoList);

    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _getData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
