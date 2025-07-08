import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/item.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(title: 'CRED APP'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isDarkMode = true;
  final String serverUrl = 'http://localhost:3001';
  final TextEditingController nameController = TextEditingController();
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems().then((data) {
      setState(() {
        items = data;
      });
    });
  }

  Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$serverUrl/api/data')); 

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<Item> addItem(String name) async {
    final response = await http.post(
      Uri.parse('$serverUrl/api/data'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 201) {
      final dynamic json = jsonDecode(response.body);
      final Item item = Item.fromJson(json);
      return item;
    } else {
      throw Exception('Failed to add item');
    }
  }

  Future<void> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$serverUrl/api/data/$id'), 
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }

  Future<void> UpdateItem(int id, String name) async {
    final response = await http.put(
      Uri.parse('$serverUrl/api/data/$id'), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      body: SafeArea(
        child: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteItem(item.id).then((_) {
                                setState(() {
                                  items.removeAt(index);
                                });
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete item: $error')),
                                );
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              nameController.text = item.name;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Update Item'),
                                    content: TextFormField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Item Name',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final String updatedName = nameController.text;
                                          if (updatedName.isNotEmpty) {
                                            UpdateItem(item.id, updatedName).then((_) {
                                              setState(() {
                                                item.name = updatedName;
                                              });
                                              Navigator.of(context).pop();
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to update item: $error')),
                                              );
                                            });
                                          }
                                        },
                                        child: const Text('Update'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
        child: const Icon(Icons.color_lens),
        backgroundColor: Colors.yellow[700],
        tooltip: 'Toggle Theme',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: [
        FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Add Item'),
                  content: TextFormField( 
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final String name = nameController.text;
                        if (name.isNotEmpty) {
                          addItem(name).then((item) {
                            setState(() {
                              items.add(item);
                            });
                            Navigator.of(context).pop();
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add item: $error')),
                            );
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          tooltip: 'Add Item',
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
