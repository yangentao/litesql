part of 'sql.dart';

typedef LiteTableItem = ({String schema, String name, String type, int ncol, int wr, int strict});
typedef LiteTableInfo = ({String name, int cid, String type, int notnull, String? dflt_value, int pk});
typedef LiteTableInfoX = ({String name, int cid, String type, int notnull, String? dflt_value, int pk, int hidden});

typedef LiteIndexItem = ({int seq, String name, int unique, String origin, int partial});
typedef LiteIndexInfo = ({int seqno, String name, int cid});
typedef LiteIndexInfoX = ({int seqno, String? name, int cid, int desc, String coll, int key});

class Pragma {
  LiteSQL lite;

  Pragma(this.lite);

  int get analysis_limit => getInt("analysis_limit");

  set analysis_limit(int n) => setInt("analysis_limit", n);

  int get application_id => getInt("application_id");

  set application_id(int n) => setInt("application_id", n);

  int get auto_vacuum => getInt("auto_vacuum");

  set auto_vacuum(int n) => setInt("auto_vacuum", n);

  bool get automatic_index => getBool("automatic_index");

  set automatic_index(bool value) => setBool("automatic_index", value);

  int get busy_timeout => getInt("busy_timeout");

  set busy_timeout(int value) => setInt("busy_timeout", value);

  int get cache_size => getInt("cache_size");

  set cache_size(int value) => setInt("cache_size", value);

  int get cache_spill => getInt("cache_spill");

  set cache_spill(int value) => setInt("cache_spill", value);

  bool get case_sensitive_like => getBool("case_sensitive_like");

  set case_sensitive_like(bool value) => setBool("case_sensitive_like", value);

  bool get cell_size_check => getBool("cell_size_check");

  set cell_size_check(bool value) => setBool("cell_size_check", value);

  bool get checkpoint_fullfsync => getBool("checkpoint_fullfsync ");

  set checkpoint_fullfsync(bool value) => setBool("checkpoint_fullfsync ", value);

  List<String> get collation_list => listString("collation_list", key: "name");

  List<String> get compile_options => listString("compile_options");

  bool get count_changes => getBool("count_changes");

  set count_changes(bool value) => setBool("count_changes", value);

  int get data_version => getInt("data_version");

  bool get defer_foreign_keys => getBool("defer_foreign_keys");

  set defer_foreign_keys(bool value) => setBool("defer_foreign_keys", value);

  List<({String name, String file})> get database_list {
    return mapRow("database_list", (e) => (name: e["name"], file: e["file"]));
  }

  String get encoding => getString("encoding");

  set encoding(String value) => setString("encoding", value);

  bool get foreign_keys => getBool("foreign_keys");

  set foreign_keys(bool value) => setBool("foreign_keys", value);

  int get freelist_count => getInt("freelist_count");

  bool get full_column_names => getBool("full_column_names");

  set full_column_names(bool value) => setBool("full_column_names", value);

  bool get fullfsync => getBool("fullfsync");

  set fullfsync(bool value) => setBool("fullfsync", value);

  List<({String name, int builtin, String type, String enc, int narg, int flags})> get function_list {
    return mapRow("function_list", (e) => (name: e["name"], builtin: e["builtin"], type: e["type"], enc: e["enc"], narg: e["narg"], flags: e["flags"]));
  }

  int get hard_heap_limit => getInt("hard_heap_limit");

  set hard_heap_limit(int value) => setInt("hard_heap_limit", value);

  bool get ignore_check_constraints => getBool("ignore_check_constraints");

  set ignore_check_constraints(bool value) => setBool("ignore_check_constraints", value);

  int get incremental_vacuum => getInt("incremental_vacuum");

  set incremental_vacuum(int value) => setInt("incremental_vacuum", value, func: true);

  List<LiteIndexItem> index_list(String table, {String? schema}) {
    return query("index_list"._schema(schema), args: [table])
        .mapList((e) => (seq: e["seq"], name: e["name"], unique: e["unique"], origin: e["origin"], partial: e["partial"]));
  }

  List<LiteIndexInfo> index_info(String indexName, {String? schema}) {
    return query("index_info"._schema(schema), args: [indexName]).mapList((e) => (seqno: e["seqno"], name: e["name"], cid: e["cid"]));
  }

  List<LiteIndexInfoX> index_xinfo(String indexName, {String? schema}) {
    return query("index_xinfo"._schema(schema), args: [indexName])
        .mapList((e) => (seqno: e["seqno"], name: e["name"], cid: e["cid"], desc: e["desc"], coll: e["coll"], key: e["key"]));
  }

  List<LiteTableItem> table_list({String? table, String? schema}) {
    StringBuffer buf = StringBuffer();
    buf.write("table_list"._schema(schema));
    if (table.notEmpty) {
      buf.write("(${table!.singleQuoted})");
    }
    return query(buf.toString()).mapList((e) => (schema: e["schema"], name: e["name"], type: e["type"], ncol: e["ncol"], wr: e["wr"], strict: e["strict"]));
  }

  List<LiteTableInfo> table_info(String table, {String? schema}) {
    return query("table_info"._schema(schema), args: [table])
        .mapList((e) => (name: e["name"], cid: e["cid"], type: e["type"] ?? "TEXT", notnull: e["notnull"], dflt_value: e["dflt_value"], pk: e["pk"]));
  }

  List<LiteTableInfoX> table_xinfo(String table, {String? schema}) {
    return query("table_xinfo"._schema(schema), args: [table]).mapList(
        (e) => (name: e["name"], cid: e["cid"], type: e["type"] ?? "TEXT", notnull: e["notnull"], dflt_value: e["dflt_value"], pk: e["pk"], hidden: e["hidden"]));
  }

  /// NORMAL | EXCLUSIVE
  String get locking_mode => getString("locking_mode");

  set locking_mode(String value) => setString("locking_mode", value);

  int get max_page_count => getInt("max_page_count");

  set max_page_count(int value) => setInt("max_page_count", value);

  List<String> get module_list => listString("module_list");

  int get page_count => getInt("page_count");

  int get page_size => getInt("page_size");

  set page_size(int value) => setInt("page_size", value);

  List<String> get pragma_list => listString("pragma_list");

  bool get query_only => getBool("query_only");

  set query_only(bool value) => setBool("query_only", value);

  bool get read_uncommitted => getBool("read_uncommitted");

  set read_uncommitted(bool value) => setBool("read_uncommitted", value);

  bool get recursive_triggers => getBool("recursive_triggers");

  set recursive_triggers(bool value) => setBool("recursive_triggers", value);

  bool get reverse_unordered_selects => getBool("reverse_unordered_selects");

  set reverse_unordered_selects(bool value) => setBool("reverse_unordered_selects", value);

  int get schema_version => getInt("schema_version");

  set schema_version(int value) => setInt("schema_version", value);

  bool get secure_delete => getBool("secure_delete");

  set secure_delete(bool value) => setBool("secure_delete", value);

  void shrink_memory() {
    lite.execute("PROGMA shrink_memory");
  }

  int get soft_heap_limit => getInt("soft_heap_limit");

  set soft_heap_limit(int value) => setInt("soft_heap_limit", value);

  ///  0 | OFF | 1 | NORMAL | 2 | FULL | 3 | EXTRA
  int get synchronous => getInt("synchronous");

  ///  0 | OFF | 1 | NORMAL | 2 | FULL | 3 | EXTRA
  set synchronous(int value) => setInt("synchronous", value);

  ///  0 | DEFAULT | 1 | FILE | 2 | MEMORY
  int get temp_store => getInt("temp_store");

  ///  0 | DEFAULT | 1 | FILE | 2 | MEMORY
  set temp_store(int value) => setInt("temp_store", value);

  int get threads => getInt("threads");

  set threads(int value) => setInt("threads", value);

  int get user_version => getInt("user_version");

  set user_version(int value) => setInt("user_version", value);

  List<R> mapRow<R>(String name, R Function(Row) block) {
    final rs = query(name);
    return rs.mapList((e) => block(e));
  }

  ResultSet query(String name, {List<Object> args = const []}) {
    if (args.isEmpty) {
      return lite.rawQuery("PRAGMA $name");
    } else {
      String s = args.map((e) => e is String ? e.singleQuoted : e.toString()).join(", ");
      return lite.rawQuery("PRAGMA $name($s)");
    }
  }

  List<int> listInt(String name, {Object key = 0}) {
    return query(name).mapList((e) => e[key] as int);
  }

  List<String> listString(String name, {Object key = 0}) {
    return query(name).mapList((e) => e[key] as String);
  }

  bool getBool(String name) {
    return getInt(name) != 0;
  }

  void setBool(String name, bool value) {
    setInt(name, value ? 1 : 0);
  }

  int getInt(String name) {
    return lite.rawQuery("PRAGMA $name").firstValue() ?? 0;
  }

  void setInt(String name, int value, {bool func = false}) {
    if (func) {
      lite.execute("PRAGMA $name($value)");
    } else {
      lite.execute("PRAGMA $name = $value");
    }
  }

  String getString(String name) {
    return lite.rawQuery("PRAGMA $name").firstValue() ?? "";
  }

  void setString(String name, String value) {
    lite.execute("PRAGMA $name = ${value.singleQuoted}");
  }
}

extension on String {
  String _schema(String? schema) {
    if (schema == null || schema.isEmpty) return this;
    return "$schema.$this";
  }
}
