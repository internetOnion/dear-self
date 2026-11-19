import "package:dear_self/models/journal.dart";
import "package:dear_self/services/memory_storage.dart";
import "package:uuid/uuid.dart";

class JournalService {
  final MemoryStorage _storage;
  final DateTime Function() _clock;

  static const int maxNameLength = 30;
  static const String defaultName = "My Journal";

  JournalService(this._storage, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  void _validateName(String name, List<Journal> existing, {String? exceptId}) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError("Journal name cannot be empty");
    }
    if (trimmed.length > maxNameLength) {
      throw ArgumentError(
        "Journal name must be at most $maxNameLength characters",
      );
    }

    for (final journal in existing) {
      if (journal.id == exceptId) {
        continue;
      }
      if (journal.name.toLowerCase() == trimmed.toLowerCase()) {
        throw ArgumentError('A journal named "$trimmed" already exists');
      }
    }
  }

  List<Journal> getAll() {
    return _storage.getJournals();
  }

  Journal create(String name) {
    _validateName(name, _storage.getJournals());

    final journal = Journal(
      id: const Uuid().v4(),
      name: name.trim(),
      createdAt: _clock(),
    );

    _storage.saveJournal(journal);
    return journal;
  }

  Journal rename(String id, String newName) {
    final existing = _storage.getJournal(id);
    if (existing == null) {
      throw StateError("Journal not found: $id");
    }

    _validateName(newName, _storage.getJournals(), exceptId: id);

    final updated = existing.copyWith(name: newName.trim());
    _storage.saveJournal(updated);

    return updated;
  }

  int countEntries(String id) {
    return _storage.getEntries(journalId: id).length;
  }

  void delete(String id) {
    final journals = _storage.getJournals();
    if (journals.length <= 1 && _storage.getJournal(id) != null) {
      throw StateError("Cannot delete the last journal");
    }

    _storage.deleteJournal(id);
  }
}
