import "package:dear_self/models/entry.dart";
import "package:dear_self/models/journal.dart";
import "package:uuid/uuid.dart";

class MemoryStorage {
  final Map<String, Entry> _entries = {};
  final Map<String, Journal> _journals = {};

  MemoryStorage({DateTime Function()? clock}) {
    final DateTime Function() useClock = clock ?? DateTime.now;

    final DateTime now = useClock();

    final journal = Journal(
      id: const Uuid().v4(),
      name: "My Journal",
      createdAt: now,
    );

    _journals[journal.id] = journal;
  }

  List<Entry> getEntries({String? journalId}) {
    Iterable<Entry> result = _entries.values;

    if (journalId != null) {
      result = result.where((entry) => entry.journalId == journalId);
    }

    final list = result.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list;
  }

  Entry? getEntry(String entryId) {
    return _entries[entryId];
  }

  void saveEntry(Entry entry) {
    _entries[entry.id] = entry;
  }

  void deleteEntry(String entryId) {
    _entries.remove(entryId);
  }

  List<Journal> getJournals() {
    final List<Journal> list = _journals.values.toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Journal? getJournal(String journalId) {
    return _journals[journalId];
  }

  void saveJournal(Journal journal) {
    _journals[journal.id] = journal;
  }

  void deleteJournal(String journalId) {
    _entries.removeWhere((_, entry) => entry.journalId == journalId);
    _journals.remove(journalId);
  }
}
