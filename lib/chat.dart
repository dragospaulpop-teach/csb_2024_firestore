import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  FirebaseFirestore database = FirebaseFirestore.instance;
  late CollectionReference messagesCollection;
  late Query<Object?> messagesQuery;
  late Stream<QuerySnapshot> messagesStream;
  late ScrollController _scrollController;
  int limit = 10;
  bool shouldAutoScroll = true;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    messagesCollection = database.collection('messages');
    messagesQuery =
        messagesCollection.orderBy('timestamp', descending: true).limit(limit);
    messagesStream = messagesQuery.snapshots();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels == 0) {
          print('Reached the top');
          setState(() {
            shouldAutoScroll = false;
            limit += 10;
            messagesQuery = messagesCollection
                .orderBy('timestamp', descending: false)
                .limit(limit);
            messagesStream = messagesQuery.snapshots();
          });
        }
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          print('Reached the bottom');
          setState(() {
            shouldAutoScroll = true;
          });
        }
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> createDocument() async {
    if (_messageController.text.isEmpty) {
      return;
    }
    await messagesCollection.add({
      'content': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'sender': 'user',
    });
    _messageController.clear();
  }

  Future<void> deleteDocument(String id) async {
    await messagesCollection.doc(id).delete();
  }

  void signOut() {
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () => signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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

                        if (snapshot.hasData) {
                          if (shouldAutoScroll) {
                            _scrollToBottom();
                          }
                        }

                        List<DocumentSnapshot> messages = snapshot.data!.docs;
                        messages.sort((a, b) {
                          if (a['timestamp'] == null) {
                            return 1;
                          }
                          if (b['timestamp'] == null) {
                            return -1;
                          }
                          return a['timestamp'].compareTo(b['timestamp']);
                        });

                        return SingleChildScrollView(
                            controller: _scrollController,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: snapshot.data!.docs.map((doc) {
                                        return Row(
                                          mainAxisAlignment:
                                              doc['sender'] == 'user'
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Card(
                                                color: doc['sender'] == 'user'
                                                    ? Colors.blue
                                                    : Colors.green,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              doc['content'],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              softWrap: true,
                                                            ),
                                                            Text(
                                                                doc['timestamp']
                                                                        ?.toDate()
                                                                        .toString() ??
                                                                    '',
                                                                style: TextStyle(
                                                                    color: doc['sender'] ==
                                                                            'user'
                                                                        ? Colors.blue[
                                                                            200]
                                                                        : Colors.green[
                                                                            200],
                                                                    fontSize:
                                                                        11,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic)),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () =>
                                                          deleteDocument(
                                                              doc.id),
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList()),
                                ),
                              ],
                            ));
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
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
