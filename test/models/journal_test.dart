import "package:dear_self/models/journal.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("Journal", () {
    final journal = Journal(
      id: "j-1",
      name: "My Journal",
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final createdAtMillis = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;

    group("constructor", () {
      test("should assign properties correctly", () {
        expect(journal.id, "j-1");
        expect(journal.name, "My Journal");
        expect(journal.createdAt, DateTime.utc(2026, 1, 1));
      });
    });

    group("copyWith", () {
      test("should create an exact copy when no parameters are provided", () {
        final copiedJournal = journal.copyWith();
        expect(copiedJournal, journal);
      });

      test("should return a new instance not the same object", () {
        expect(identical(journal.copyWith(), journal), isFalse);
      });

      test("should update all properties when all parameters are provided", () {
        final updatedJournal = journal.copyWith(
          id: "j-2",
          name: "New Title",
          createdAt: DateTime.utc(2026, 1, 2),
        );

        expect(updatedJournal.id, "j-2");
        expect(updatedJournal.name, "New Title");
        expect(updatedJournal.createdAt, DateTime.utc(2026, 1, 2));
      });

      test("should change only id when only id is provided", () {
        final updated = journal.copyWith(id: "j-2");

        expect(updated.id, "j-2");
        expect(updated.name, journal.name);
        expect(updated.createdAt, journal.createdAt);
      });

      test("should change only name when only name is provided", () {
        final updated = journal.copyWith(name: "Other");

        expect(updated.id, journal.id);
        expect(updated.name, "Other");
        expect(updated.createdAt, journal.createdAt);
      });

      test("should change only createdAt when only createdAt is provided", () {
        final updated = journal.copyWith(createdAt: DateTime.utc(2026, 1, 2));

        expect(updated.id, journal.id);
        expect(updated.name, journal.name);
        expect(updated.createdAt, DateTime.utc(2026, 1, 2));
      });
    });

    group("toMap", () {
      test("should convert the journal to a map correctly", () {
        expect(journal.toMap(), {
          "id": "j-1",
          "name": "My Journal",
          "created_at": createdAtMillis,
        });
      });

      test("should store created_at as an int", () {
        expect(journal.toMap()["created_at"], isA<int>());
      });

      test("should keep the same moment in time for a local date", () {
        final local = DateTime(2026, 1, 1, 10, 30); // local, not UTC
        final map = journal.copyWith(createdAt: local).toMap();

        expect(map["created_at"], local.millisecondsSinceEpoch);
      });
    });

    group("fromMap", () {
      final validMap = <String, dynamic>{
        "id": "j-1",
        "name": "My Journal",
        "created_at": createdAtMillis,
      };

      test("should create a journal from a map correctly", () {
        expect(Journal.fromMap(validMap), journal);
      });

      test("should return createdAt as a UTC date", () {
        expect(Journal.fromMap(validMap).createdAt.isUtc, isTrue);
      });

      for (final key in validMap.keys) {
        test("should throw when $key is missing", () {
          final map = Map<String, dynamic>.of(validMap)..remove(key);

          expect(() => Journal.fromMap(map), throwsA(isA<TypeError>()));
        });
      }

      test("should throw when id has the wrong type", () {
        expect(
          () => Journal.fromMap({...validMap, "id": 5}),
          throwsA(isA<TypeError>()),
        );
      });

      test("should throw when created_at has the wrong type", () {
        expect(
          () => Journal.fromMap({...validMap, "created_at": "abc"}),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("round trip", () {
      test("should produce the same journal", () {
        expect(Journal.fromMap(journal.toMap()), journal);
      });

      test("should keep equality for a local date", () {
        final j = journal.copyWith(createdAt: DateTime(2026, 1, 1, 10, 10));

        expect(Journal.fromMap(j.toMap()), j);
      });

      test("should keep equality for a date with microseconds", () {
        final j = journal.copyWith(
          createdAt: DateTime.utc(2026, 1, 1, 10, 10, 10, 10, 10),
        );

        expect(Journal.fromMap(j.toMap()), j);
      });
    });

    group("equality", () {
      test("should return true for journals with the same properties", () {
        final anotherJournal = Journal(
          id: "j-1",
          name: "My Journal",
          createdAt: DateTime.utc(2026, 1, 1),
        );

        expect(journal == anotherJournal, isTrue);
      });

      test("should return true when compared with itself", () {
        expect(journal == journal, isTrue);
      });

      test("should return false for journals with different id", () {
        expect(journal == journal.copyWith(id: "j-2"), isFalse);
      });

      test("should return false for journals with different name", () {
        expect(journal == journal.copyWith(name: "Different Name"), isFalse);
      });

      test("should return false for journals with different createdAt", () {
        final differentJournal = journal.copyWith(
          createdAt: DateTime.utc(2026, 1, 2),
        );

        expect(journal == differentJournal, isFalse);
      });

      test("should return false when compared with another type", () {
        // ignore: unrelated_type_equality_checks
        expect(journal == "not a journal", isFalse);
      });
    });

    group("hashCode", () {
      test("should be the same for journals with the same properties", () {
        final anotherJournal = Journal(
          id: "j-1",
          name: "My Journal",
          createdAt: DateTime.utc(2026, 1, 1),
        );

        expect(journal.hashCode, anotherJournal.hashCode);
      });

      test("should be stable across calls", () {
        expect(journal.hashCode, journal.hashCode);
      });
    });
  });
}
