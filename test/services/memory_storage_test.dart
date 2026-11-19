import "package:dear_self/models/entry.dart";
import "package:dear_self/models/entry_photo.dart";
import "package:dear_self/models/journal.dart";
import "package:dear_self/services/memory_storage.dart";
import "package:flutter_test/flutter_test.dart";

final storageStart = DateTime.utc(2026, 1, 1);

Entry makeEntry({
  String id = "e-1",
  String journalId = "j-1",
  String title = "Title",
  DateTime? createdAt,
  List<EntryPhoto> photos = const [],
}) {
  final time = createdAt ?? DateTime.utc(2026, 1, 1);

  return Entry(
    id: id,
    journalId: journalId,
    title: title,
    body: "Body",
    sceneId: "scene-1",
    createdAt: time,
    updatedAt: time,
    photos: photos,
  );
}

Journal makeJournal({
  String id = "j-1",
  String name = "Work",
  DateTime? createdAt,
}) {
  return Journal(
    id: id,
    name: name,
    createdAt: createdAt ?? DateTime.utc(2026, 2, 1),
  );
}

List<String> idsOf(List<Entry> entries) => entries.map((e) => e.id).toList();

void main() {
  late MemoryStorage storage;

  setUp(() {
    storage = MemoryStorage(clock: () => storageStart);
  });

  group("Entries", () {
    test("saveEntry then getEntry returns an equal entry", () {
      final entry = makeEntry();

      storage.saveEntry(entry);

      expect(storage.getEntry("e-1"), entry);
    });

    test("getEntry returns null for a missing id", () {
      expect(storage.getEntry("missing"), isNull);
    });

    test("saving the same id twice replaces it, no duplicate", () {
      final entry = makeEntry();
      storage.saveEntry(entry);

      storage.saveEntry(entry.copyWith(title: "New title"));

      final all = storage.getEntries();
      expect(all, hasLength(1));
      expect(all.single.title, "New title");
    });

    test("getEntries is newest first", () {
      storage.saveEntry(
        makeEntry(id: "middle", createdAt: DateTime.utc(2026, 1, 2)),
      );
      storage.saveEntry(
        makeEntry(id: "oldest", createdAt: DateTime.utc(2026, 1, 1)),
      );
      storage.saveEntry(
        makeEntry(id: "newest", createdAt: DateTime.utc(2026, 1, 3)),
      );

      expect(idsOf(storage.getEntries()), ["newest", "middle", "oldest"]);
    });

    test("getEntries with journalId only returns that journal's entries", () {
      storage.saveEntry(
        makeEntry(
          id: "e-1",
          journalId: "j-1",
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );
      storage.saveEntry(
        makeEntry(
          id: "e-2",
          journalId: "j-2",
          createdAt: DateTime.utc(2026, 1, 2),
        ),
      );
      storage.saveEntry(
        makeEntry(
          id: "e-3",
          journalId: "j-1",
          createdAt: DateTime.utc(2026, 1, 3),
        ),
      );

      expect(idsOf(storage.getEntries(journalId: "j-1")), ["e-3", "e-1"]);
    });

    test("an entry's photos come back unchanged", () {
      const photos = [
        EntryPhoto(id: "p-1", relativePath: "photos/p-1.jpg"),
        EntryPhoto(id: "p-2", relativePath: "photos/p-2.jpg"),
      ];
      storage.saveEntry(makeEntry(photos: photos));

      expect(storage.getEntry("e-1")!.photos, photos);
    });

    test("deleteEntry removes the entry", () {
      storage.saveEntry(makeEntry());

      storage.deleteEntry("e-1");

      expect(storage.getEntry("e-1"), isNull);
      expect(storage.getEntries(), isEmpty);
    });

    test("deleteEntry with a missing id does nothing", () {
      storage.saveEntry(makeEntry());

      expect(() => storage.deleteEntry("missing"), returnsNormally);
      expect(storage.getEntries(), hasLength(1));
    });

    test("changing the list from getEntries doesn't change storage", () {
      storage.saveEntry(makeEntry());

      storage.getEntries().clear();

      expect(storage.getEntries(), hasLength(1));
    });
  });

  group("Journals", () {
    test("fresh storage has exactly one journal, My Journal", () {
      final journals = storage.getJournals();

      expect(journals, hasLength(1));
      expect(journals.single.name, "My Journal");
    });

    test("My Journal is created at the time the clock gives", () {
      expect(storage.getJournals().single.createdAt, storageStart);
    });

    test("saveJournal then getJournal returns an equal journal", () {
      final journal = makeJournal();

      storage.saveJournal(journal);

      expect(storage.getJournal("j-1"), journal);
    });

    test("getJournal returns null for a missing id", () {
      expect(storage.getJournal("missing"), isNull);
    });

    test("saving the same id twice replaces it, no duplicate", () {
      final journal = makeJournal(name: "Work");
      storage.saveJournal(journal);

      storage.saveJournal(journal.copyWith(name: "Office"));

      expect(storage.getJournals(), hasLength(2)); // My Journal + j-1
      expect(storage.getJournal("j-1")!.name, "Office");
    });

    test("getJournals is oldest first", () {
      final myJournalId = storage.getJournals().single.id;
      // Saved in mixed order so insertion order can't pass by accident.
      storage.saveJournal(
        makeJournal(
          id: "march",
          name: "March",
          createdAt: DateTime.utc(2026, 3, 1),
        ),
      );
      storage.saveJournal(
        makeJournal(
          id: "feb",
          name: "Feb",
          createdAt: DateTime.utc(2026, 2, 1),
        ),
      );

      final ids = storage.getJournals().map((j) => j.id).toList();
      expect(ids, [myJournalId, "feb", "march"]);
    });

    test("changing the list from getJournals doesn't change storage", () {
      storage.getJournals().clear();

      expect(storage.getJournals(), hasLength(1));
    });

    test("deleteJournal removes the journal and its entries, keeps others", () {
      storage.saveJournal(makeJournal(id: "j-1", name: "Work"));
      storage.saveJournal(makeJournal(id: "j-2", name: "Travel"));
      storage.saveEntry(
        makeEntry(
          id: "e-1",
          journalId: "j-1",
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );
      storage.saveEntry(
        makeEntry(
          id: "e-2",
          journalId: "j-1",
          createdAt: DateTime.utc(2026, 1, 2),
        ),
      );
      storage.saveEntry(
        makeEntry(
          id: "e-3",
          journalId: "j-2",
          createdAt: DateTime.utc(2026, 1, 3),
        ),
      );

      storage.deleteJournal("j-1");

      expect(storage.getJournal("j-1"), isNull);
      expect(storage.getJournal("j-2"), isNotNull);
      expect(idsOf(storage.getEntries()), ["e-3"]);
    });

    test("deleteJournal with a missing id does nothing", () {
      expect(() => storage.deleteJournal("missing"), returnsNormally);
      expect(storage.getJournals(), hasLength(1));
    });
  });
}
