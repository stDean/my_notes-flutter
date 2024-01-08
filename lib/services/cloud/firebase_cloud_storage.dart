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

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });

    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      userId: ownerUserId,
      text: '',
    );
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
            (value) => value.docs.map((doc) => CloudNote.fromSnapShot(doc)),
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