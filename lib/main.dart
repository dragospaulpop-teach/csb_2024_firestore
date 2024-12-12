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
  final TextEditingController _messageController = TextEditingController();
  FirebaseFirestore database = FirebaseFirestore.instance;
  late CollectionReference messagesCollection;
  late Stream<QuerySnapshot> messagesStream;

  @override
  void initState() {
    super.initState();

    messagesCollection = database.collection('messages');
    messagesStream = messagesCollection.snapshots();
  }

  Future<void> createDocument() async {
    await messagesCollection.add({'name': _messageController.text});
    _messageController.clear();
  }

  Future<void> deleteDocument(String id) async {
    await messagesCollection.doc(id).delete();
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
                    child: StreamBuilder<QuerySnapshot>(
                        stream: messagesStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Center(child: Text('Error'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: Text('Loading...'));
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No documents found'));
                          }

                          return ListView(
                              children: snapshot.data!.docs.map((doc) {
                            return Card(
                              child: ListTile(
                                title: Text(doc['name']),
                                trailing: IconButton(
                                  onPressed: () => deleteDocument(doc.id),
                                  icon: const Icon(Icons.delete),
                                ),
                              ),
                            );
                          }).toList());
                        }),
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
