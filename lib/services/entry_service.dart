import "package:dear_self/models/entry.dart";
import "package:dear_self/models/entry_photo.dart";
import "package:dear_self/models/mood.dart";
import "package:dear_self/services/memory_storage.dart";
import "package:uuid/uuid.dart";

enum EntryError {
  blank,
  titleTooLong,
  tooManyPhotos,
  journalNotFound,
}

class EntryException implements Exception {
  final EntryError error;

  const EntryException(this.error);
}

class EntryService {
  final MemoryStorage _storage;
  final DateTime Function() _clock;

  static const int maxTitleLength = 100;
  static const int maxPhotos = 5;

  EntryService(this._storage, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static bool canSave(String title, String body) {
    return title.trim().isNotEmpty || body.trim().isNotEmpty;
  }

  static List<Entry> filter(List<Entry> entries, String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return List<Entry>.from(entries);
    }

    final List<Entry> result = [];
    for (final entry in entries) {
      final inTitle = entry.title.toLowerCase().contains(keyword);
      final inBody = entry.body.toLowerCase().contains(keyword);
      if (inTitle || inBody) {
        result.add(entry);
      }
    }
    return result;
  }

  List<Entry> getTimeline({String? journalId}) {
    return _storage.getEntries(journalId: journalId);
  }

  List<Entry> search(String query, {String? journalId}) {
    final entries = getTimeline(journalId: journalId);
    return filter(entries, query);
  }

  Entry? getById(String id) {
    return _storage.getEntry(id);
  }

  Entry? getNewest() {
    final entries = _storage.getEntries();
    if (entries.isEmpty) {
      return null;
    }
    return entries.first;
  }

  Entry create({
    required String journalId,
    required String title,
    required String body,
    Mood? mood,
    required String sceneId,
    List<EntryPhoto> photos = const [],
  }) {
    _validate(
      journalId: journalId,
      title: title,
      body: body,
      photos: photos,
    );

    final now = _clock();
    final entry = Entry(
      id: const Uuid().v4(),
      journalId: journalId,
      title: title,
      body: body,
      mood: mood,
      sceneId: sceneId,
      createdAt: now,
      updatedAt: now,
      photos: photos,
    );

    _storage.saveEntry(entry);
    return entry;
  }

  Entry update(Entry entry) {
    _validate(
      journalId: entry.journalId,
      title: entry.title,
      body: entry.body,
      photos: entry.photos,
    );

    final existing = _storage.getEntry(entry.id);
    final updated = entry.copyWith(
      createdAt: existing?.createdAt ?? entry.createdAt,
      updatedAt: _clock(),
    );

    _storage.saveEntry(updated);
    return updated;
  }

  void delete(String id) {
    _storage.deleteEntry(id);
  }

  void _validate({
    required String journalId,
    required String title,
    required String body,
    required List<EntryPhoto> photos,
  }) {
    if (!canSave(title, body)) {
      throw const EntryException(EntryError.blank);
    }
    if (title.length > maxTitleLength) {
      throw const EntryException(EntryError.titleTooLong);
    }
    if (photos.length > maxPhotos) {
      throw const EntryException(EntryError.tooManyPhotos);
    }
    if (_storage.getJournal(journalId) == null) {
      throw const EntryException(EntryError.journalNotFound);
    }
  }
}

