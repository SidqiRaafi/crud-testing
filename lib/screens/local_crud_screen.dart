import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalCrudScreen extends StatefulWidget {
  const LocalCrudScreen({super.key});

  @override
  State<LocalCrudScreen> createState() => _LocalCrudScreenState();
}

class _LocalCrudScreenState extends State<LocalCrudScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  late final Box _itemsBox;

  @override
  void initState() {
    super.initState();
    _itemsBox = Hive.box('items_box');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // CREATE & UPDATE
  void _showItemDialog({int? key}) {
    if (key != null) {
      final item = _itemsBox.get(key);
      _titleController.text = item['title'];
      _descController.text = item['description'];
    } else {
      _titleController.clear();
      _descController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(key == null ? 'Add Item' : 'Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title cannot be empty')),
                );
                return;
              }

              final data = {
                'title': _titleController.text,
                'description': _descController.text,
                'createdAt': DateTime.now().toIso8601String(),
              };

              if (key == null) {
                // CREATE
                _itemsBox.add(data);
              } else {
                // UPDATE
                _itemsBox.put(key, data);
              }

              Navigator.pop(context);
              setState(() {});
            },
            child: Text(key == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  // DELETE
  void _deleteItem(int key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _itemsBox.delete(key);
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage CRUD'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _itemsBox.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storage, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No items yet\nTap + to add new item',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _itemsBox.length,
              itemBuilder: (context, index) {
                final key = _itemsBox.keys.toList()[index];
                final item = _itemsBox.get(key);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      item['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showItemDialog(key: key),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(key),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
