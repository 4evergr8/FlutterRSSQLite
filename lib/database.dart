import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// 1. 设置表
class Settings extends Table {
  TextColumn get key => text()(); // 键名
  TextColumn get value => text().withDefault(const Constant(''))(); // 键值

  @override
  Set<Column> get primaryKey => {key}; // 指定键名为主键
}

// 2. 订阅表
class Feeds extends Table {
  TextColumn get feedUrl => text()(); // 订阅链接
  TextColumn get siteUrl => text().withDefault(const Constant(''))(); // 网站链接
  TextColumn get title => text().withDefault(const Constant(''))(); // 显示名
  TextColumn get category => text().withDefault(const Constant(''))(); // 分组名
  TextColumn get iconUrl => text().withDefault(const Constant(''))(); // 图标链接
  TextColumn get lastUpdated => text().withDefault(const Constant('0'))(); // 上次更新时间戳
  TextColumn get displayMode => text().withDefault(const Constant(''))(); // 显示模式

  @override
  Set<Column> get primaryKey => {feedUrl}; // 指定订阅链接为主键
}

// 3. 内容表
class Articles extends Table {
  TextColumn get guid => text()(); // guid
  TextColumn get title => text().withDefault(const Constant(''))(); // 标题
  TextColumn get feedUrl => text().withDefault(const Constant(''))(); // 所属订阅
  TextColumn get link => text().withDefault(const Constant(''))(); // 网页链接
  TextColumn get description => text().withDefault(const Constant(''))(); // 描述
  TextColumn get content => text().withDefault(const Constant(''))(); // 内容
  TextColumn get enclosure => text().withDefault(const Constant(''))(); // 媒体
  TextColumn get author => text().withDefault(const Constant(''))(); // 作者
  TextColumn get date => text().withDefault(const Constant(''))(); // 日期
  TextColumn get status => text().withDefault(const Constant(''))(); // 是否已读

  @override
  Set<Column> get primaryKey => {guid}; // 指定guid为主键
}

// 4. 数据库实例类（完美支持全平台）
@DriftDatabase(tables: [Settings, Feeds, Articles])
class AppDatabase extends _$AppDatabase {
  // 通过 super 传入 driftDatabase 自动适配 Android/iOS/Web/Windows/Mac/Linux
  AppDatabase()
    : super(
        driftDatabase(
          name: 'app_database',
          // Web 端配置：如果你需要数据在浏览器刷新后不丢失（持久化），需要传入以下参数
          web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
        ),
      );

  @override
  int get schemaVersion => 1;
}
