import "package:dear_self/models/journal.dart";
import "package:dear_self/services/memory_storage.dart";
import "package:uuid/uuid.dart";

enum JournalNameError {
  empty,
  tooLong,
  duplicate,
}

class JournalNameException implements Exception {
  final JournalNameError error;

  const JournalNameException(this.error);
}

class LastJournalException implements Exception {
  const LastJournalException();
}

class JournalService {
  final MemoryStorage _storage;
  final DateTime Function() _clock;

  static const int maxNameLength = 30;
  static const String defaultName = "My Journal";

  JournalService(this._storage, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static JournalNameError? validateName(
    String name,
    List<Journal> existing, {
    String? exceptId,
  }) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return JournalNameError.empty;
    }
    if (trimmed.length > maxNameLength) {
      return JournalNameError.tooLong;
    }

    for (final journal in existing) {
      if (journal.id == exceptId) {
        continue;
      }
      if (journal.name.toLowerCase() == trimmed.toLowerCase()) {
        return JournalNameError.duplicate;
      }
    }

    return null;
  }

  List<Journal> getAll() {
    return _storage.getJournals();
  }

  Journal create(String name) {
    final error = validateName(name, _storage.getJournals());
    if (error != null) {
      throw JournalNameException(error);
    }

    final journal = Journal(
      id: const Uuid().v4(),
      name: name.trim(),
      createdAt: _clock(),
    );

    _storage.saveJournal(journal);
    return journal;
  }

  Journal rename(String id, String newName) {
    final error = validateName(
      newName,
      _storage.getJournals(),
      exceptId: id,
    );
    if (error != null) {
      throw JournalNameException(error);
    }

    final existing = _storage.getJournal(id);
    if (existing == null) {
      throw StateError("Journal not found: $id");
    }

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
      throw const LastJournalException();
    }

    _storage.deleteJournal(id);
  }
}

