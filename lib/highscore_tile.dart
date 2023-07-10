import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighScoreTile extends StatelessWidget {
  final String documentId;
  const HighScoreTile({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*get the collection of highscores */
    CollectionReference highscores =
        FirebaseFirestore.instance.collection('highscores');

    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Row(
            children: [
              Text(data['score'].toString()),
              SizedBox(
                width: 30,
              ),
              Text(data['name']),
            ],
          );
        } else {
          return const Text("Loading...");
        }
      },
    );
  }
}
