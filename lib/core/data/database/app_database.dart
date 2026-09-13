import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// 负责创建和打开应用的本地 SQLite 数据库
abstract final class AppDatabase {
  static const String _fileName = 'zaiwan.db';
  static const int _version = 1;

  /// 打开数据库
  ///
  /// 正式运行时不需要传入参数
  /// 使用 sqflite 默认的数据库工厂
  /// 将数据库保存为应用数据库目录下的 zaiwan.db
  ///
  /// 测试时是可以注入数据库工厂和路径
  /// - [factory] 可以传入 databaseFactoryFfi
  /// - [databasePath] 可以传入 inMemoryDatabasePath
  /// - 生产代码和测试因此可以复用同一套建表逻辑
  static Future<Database> open({
    DatabaseFactory? factory,
    String? databasePath,
  }) async {
    // 未注入测试工厂时，使用 iOS/Android 平台提供的默认数据库工厂。
    final selectedFactory = factory ?? databaseFactory;

    /// 正式环境未指定路径时，获取平台数据提供的默认数据库工厂
    /// 再使用 path.join 安全拼接数据库文件名
    ///
    /// 测试可以直接写入 inMemoryDatabasePath
    /// 从而创建不会写入磁盘的内存数据库
    final resolvedPath =
        databasePath ??
        path.join(await selectedFactory.getDatabasesPath(), _fileName);

    // 通过选定的数据库工厂打开数据库
    //
    // 数据库第一次创建时会调用 _createVersion1
    // 以后数据库版本升级时，还需要增加 onUpgrade 迁移逻辑
    return selectedFactory.openDatabase(
      resolvedPath,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: _createVersion1,
      ),
    );
  }

  /// 创建数据库版本1 的结构
  static Future<void> _createVersion1(Database database, int version) async {
    await database.execute('''
    CREATE TABLE knowledge_decks (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    ''');
  }
}
