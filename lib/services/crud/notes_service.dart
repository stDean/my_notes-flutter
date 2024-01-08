// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:my_motes/services/crud/crud_constants.dart';
// import 'package:my_motes/services/crud/crud_exceptions.dart';
// import 'package:my_motes/utils/extensions/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;

// class NoteService {
//   Database? _db;
//   DatabaseUser? _user;

//   // making this a singleton
//   static final NoteService _shared = NoteService._sharedInstance();
//   NoteService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NoteService() => _shared;

//   // for caching notes
//   List<DatabaseNote> _notes = [];

//   // enables reading pipes of notes
//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotesException();
//         }
//       });

//   Future<void> _cacheNotes() async {
//     final allNotes = await getNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Database _getDbOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DbIsNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DbAlreadyOpenException {
//       // empty
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DbAlreadyOpenException();
//     }

//     try {
//       // connect to db
//       final docsPath = await getApplicationCacheDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       // create users table
//       await db.execute(createUserTable);

//       // create notes table
//       await db.execute(createNoteTable);

//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirectoryException();
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DbIsNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   // CRUD OPERATION FOR USERS
//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();

//     final deletedCount = await db.delete(
//       usersTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUserException();
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final results = await db.query(
//       usersTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (results.isNotEmpty) throw UserAlreadyExistException();

//     final userId = await db.insert(
//       usersTable,
//       {emailColumn: email.toLowerCase()},
//     );

//     return DatabaseUser(
//       id: userId,
//       email: email,
//     );
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final res = await db.query(
//       usersTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (res.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DatabaseUser.fromRow(res.first);
//     }
//   }

//   // CRUD OPERATION FOR NOTES
//   Future<DatabaseNote> createNote({
//     required DatabaseUser owner,
//     // required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();

//     final dbUser = await getUser(email: owner.email);
//     // make sure owner exists in db with correct id
//     if (dbUser != owner) {
//       throw CouldNotFindUserException();
//     }

//     const text = '';
//     final noteId = await db.insert(notesTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     // after creating add note to cache
//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final delCount = await db.delete(
//       notesTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (delCount == 0) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       // after deleting remove note to cache
//       final countBefore = _notes.length;
//       _notes.removeWhere((note) => note.id == id);
//       if (_notes.length != countBefore) {
//         _notesStreamController.add(_notes);
//       }
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final allDeleted = await db.delete(notesTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return allDeleted;
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final res = await db.query(
//       notesTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (res.isEmpty) {
//       throw CouldNotFindNoteException();
//     } else {
//       final note = DatabaseNote.fromRow(res.first);

//       // first remove the note from the cache
//       _notes.removeWhere((note) => note.id == id);

//       // then add it if it has been updated
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();
//     final res = await db.query(notesTable);

//     return res.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDbOrThrow();

//     //  first get the note
//     await getNote(id: note.id);

//     // update the note
//     final updateCount = await db.update(
//       notesTable,
//       {textColumn: text, isSyncedWithCloudColumn: 0},
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );

//     if (updateCount == 0) {
//       throw CouldNotUpdateNoteException();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((ele) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person => ID: $id, EMAIL: $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// @immutable
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   const DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Notes => ID: $id, USER_ID: $userId, IS_SYNCED_WITH_CLOUD: $isSyncedWithCloud';

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }
