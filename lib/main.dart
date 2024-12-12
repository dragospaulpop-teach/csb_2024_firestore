import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final List<DocumentSnapshot> documents = [];
  final TextEditingController _messageController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference collection;

  @override
  void initState() {
    super.initState();

    collection = firestore.collection('documents');
    collection.snapshots().listen((event) {
      setState(() {
        documents.clear();
        documents.addAll(event.docs);
      });
    });
  }

  Future<void> createDocument() async {
    await collection.add({'name': _messageController.text});
    _messageController.clear();
  }

  Future<void> deleteDocument(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: documents.isEmpty
                        ? const Center(child: Text('No documents found'))
                        : ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              final doc = documents[index];
                              return Card(
                                child: ListTile(
                                  title: Text(doc['name']),
                                  trailing: IconButton(
                                    onPressed: () => deleteDocument(doc.id),
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: TextField(
                      maxLines: 4,
                      minLines: 1,
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Enter message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () => createDocument(),
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
