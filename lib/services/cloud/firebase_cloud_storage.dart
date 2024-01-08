import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_motes/services/cloud/cloud_note.dart';
import 'package:my_motes/services/cloud/cloud_storage_constants.dart';
import 'package:my_motes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // making this a singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  // get all notes by a articular user id
  Stream<Iterable<CloudNote>> getAllNotes({required String ownerUserId}) =>
      notes.snapshots().map(
            (event) => event.docs
                .map((doc) => CloudNote.fromSnapShot(doc))
                .where((note) => note.userId == ownerUserId),
          );

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) {
              return CloudNote(
                documentId: doc.id,
                userId: doc.data()[ownerUserIdFieldName] as String,
                text: doc.data()[textFieldName] as String,
              );
            }),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
