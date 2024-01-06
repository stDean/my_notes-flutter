const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const dbName = 'notes.db';
const notesTable = 'notes';
const usersTable = 'users';

const createNoteTable = ''' 
  CREATE TABLE IF NOT EXISTS "notes" (
    "id"	INTEGER NOT NULL UNIQUE,
    "user_id"	INTEGER NOT NULL,
    "text"	TEXT NOT NULL,
    "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    PRIMARY KEY("id" AUTOINCREMENT)
  );
''';

const createUserTable = '''
  CREATE TABLE IF NOT EXISTS "users" (
    "id"	INTEGER NOT NULL UNIQUE,
    "email"	TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
''';
