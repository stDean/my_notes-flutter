import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_motes/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String userId;
  final String text;

  const CloudNote({
    required this.documentId,
    required this.userId,
    required this.text,
  });

  CloudNote.fromSnapShot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        userId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}
