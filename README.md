## LiteSQL

SQLite wrap for package 'sqlite3'.

## Usage


```dart
List<Topics> ls = Topics.table().list(Topics.new, where: Topics.USERID.EQ(userId), order: Topics.UPDATETIME.DESC);
```
