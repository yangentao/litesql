@ffi.DefaultAsset('package:sqlite3/src/ffi/libsqlite3.g.dart')
library;

import 'dart:ffi' as ffi;

@ffi.Native<ffi.Int64 Function(ffi.Pointer<ffi.Opaque>, ffi.Int64)>()
external int sqlite3_set_last_insert_rowid(ffi.Pointer<ffi.Opaque> db, int value);
