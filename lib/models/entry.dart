import 'entry_photo.dart';
import 'mood.dart';

class Entry {
  final String id;
  final String journalId;
  final String title;
  final String body;
  final Mood? mood;
  final String sceneId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EntryPhoto> photos;

  Entry({
    required this.id,
    required this.journalId,
    required this.title,
    required this.body,
    this.mood,
    required this.sceneId,
    required this.createdAt,
    required this.updatedAt,
    List<EntryPhoto> photos = const [],
  }) : photos = List.unmodifiable(photos);

  String get displayTitle {
    if (title.trim().isNotEmpty) {
      return title.trim();
    }

    final lines = body.split('\n');
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        return line.trim();
      }
    }

    return '';
  }

  Entry copyWith({
    String? id,
    String? journalId,
    String? title,
    String? body,
    Mood? mood,
    bool clearMood = false,
    String? sceneId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<EntryPhoto>? photos,
  }) {
    return Entry(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      title: title ?? this.title,
      body: body ?? this.body,
      mood: clearMood ? null : (mood ?? this.mood),
      sceneId: sceneId ?? this.sceneId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'journal_id': journalId,
      'title': title,
      'body': body,
      'mood': mood?.name,
      'scene_id': sceneId,
      'created_at': createdAt.toUtc().millisecondsSinceEpoch,
      'updated_at': updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }

  static Entry fromMap(
    Map<String, dynamic> map, [
    List<EntryPhoto> photos = const [],
  ]) {
    final moodName = map['mood'] as String?;
    return Entry(
      id: map['id'] as String,
      journalId: map['journal_id'] as String,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      mood: moodName != null ? Mood.values.byName(moodName) : null,
      sceneId: map['scene_id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int,
        isUtc: true,
      ),
      photos: photos,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Entry) return false;
    if (other.photos.length != photos.length) return false;

    for (int i = 0; i < photos.length; i++) {
      if (other.photos[i] != photos[i]) return false;
    }

    return other.id == id &&
        other.journalId == journalId &&
        other.title == title &&
        other.body == body &&
        other.mood == mood &&
        other.sceneId == sceneId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        journalId,
        title,
        body,
        mood,
        sceneId,
        createdAt,
        updatedAt,
        Object.hashAll(photos),
      );
}
