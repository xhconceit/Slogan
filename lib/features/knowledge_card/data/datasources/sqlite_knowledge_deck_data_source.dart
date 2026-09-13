import 'package:sqflite/sqflite.dart';

import '../models/knowledge_deck_model.dart';
import 'knowledge_deck_data_source.dart';

/// 使用 SQLite 持久化知识库
final class SqliteKnowledgeDeckDataSource implements KnowledgeDeckDataSource {
  const SqliteKnowledgeDeckDataSource(this._database);

  static const String _tableName = 'knowledge_decks';

  final Database _database;

  @override
  Future<List<KnowledgeDeckModel>> getDecks() async {
    final rows = await _database.query(_tableName, orderBy: 'created_at DESC');

    return rows.map(_modelFromRow).toList(growable: false);
  }

  @override
  Future<KnowledgeDeckModel?> getDeckById(String id) async {
    final rows = await _database.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return _modelFromRow(rows.first);
  }

  @override
  Future<void> saveDeck(KnowledgeDeckModel deck) async {
    await _database.insert(
      _tableName,
      _rowFromModel(deck),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteDeck(String id) async {
    await _database.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> _rowFromModel(KnowledgeDeckModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'description': model.description,
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': model.updatedAt.toIso8601String(),
    };
  }

  KnowledgeDeckModel _modelFromRow(Map<String, Object?> row) {
    return KnowledgeDeckModel(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
