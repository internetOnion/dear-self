import "package:dear_self/models/entry.dart";
import "package:dear_self/models/entry_photo.dart";
import "package:dear_self/models/mood.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("Entry", () {
    const photo1 = EntryPhoto(
      id: "p-1",
      entryId: "e-1",
      relativePath: "photos/p-1.jpg",
      position: 0,
    );
    const photo2 = EntryPhoto(
      id: "p-2",
      entryId: "e-1",
      relativePath: "photos/p-2.jpg",
      position: 1,
    );

    final createdAt = DateTime.utc(2026, 1, 1);
    final updatedAt = DateTime.utc(2026, 1, 2);

    final entry = Entry(
      id: "e-1",
      journalId: "j-1",
      title: "A good day",
      body: "Went for a walk",
      mood: Mood.happy,
      sceneId: "s-1",
      createdAt: createdAt,
      updatedAt: updatedAt,
      photos: const [photo1, photo2],
    );

    final validMap = <String, dynamic>{
      "id": "e-1",
      "journal_id": "j-1",
      "title": "A good day",
      "body": "Went for a walk",
      "mood": "happy",
      "scene_id": "s-1",
      "created_at": createdAt.millisecondsSinceEpoch,
      "updated_at": updatedAt.millisecondsSinceEpoch,
    };

    group("constructor", () {
      test("should assign properties correctly", () {
        expect(entry.id, "e-1");
        expect(entry.journalId, "j-1");
        expect(entry.title, "A good day");
        expect(entry.body, "Went for a walk");
        expect(entry.mood, Mood.happy);
        expect(entry.sceneId, "s-1");
        expect(entry.createdAt, createdAt);
        expect(entry.updatedAt, updatedAt);
        expect(entry.photos, [photo1, photo2]);
      });

      test("should default mood to null and photos to empty", () {
        final minimal = Entry(
          id: "e-1",
          journalId: "j-1",
          title: "",
          body: "",
          sceneId: "s-1",
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(minimal.mood, isNull);
        expect(minimal.photos, isEmpty);
      });

      test("should not allow photos to be modified", () {
        expect(() => entry.photos.add(photo1), throwsUnsupportedError);
      });

      test("should not change when the original photo list changes", () {
        final source = [photo1];
        final e = entry.copyWith(photos: source);

        source.add(photo2);

        expect(e.photos, [photo1]);
      });
    });

    group("copyWith", () {
      test("should create an exact copy when no parameters are provided", () {
        expect(entry.copyWith(), entry);
      });

      test("should return a new instance not the same object", () {
        expect(identical(entry.copyWith(), entry), isFalse);
      });

      test("should update all properties when all parameters are provided", () {
        final updated = entry.copyWith(
          id: "e-2",
          journalId: "j-2",
          title: "New title",
          body: "New body",
          mood: Mood.sad,
          sceneId: "s-2",
          createdAt: DateTime.utc(2026, 2, 1),
          updatedAt: DateTime.utc(2026, 2, 2),
          photos: const [photo2],
        );

        expect(updated.id, "e-2");
        expect(updated.journalId, "j-2");
        expect(updated.title, "New title");
        expect(updated.body, "New body");
        expect(updated.mood, Mood.sad);
        expect(updated.sceneId, "s-2");
        expect(updated.createdAt, DateTime.utc(2026, 2, 1));
        expect(updated.updatedAt, DateTime.utc(2026, 2, 2));
        expect(updated.photos, [photo2]);
      });

      test("should change only title when only title is provided", () {
        final updated = entry.copyWith(title: "Other");

        expect(updated.title, "Other");
        expect(updated.id, entry.id);
        expect(updated.body, entry.body);
        expect(updated.mood, entry.mood);
        expect(updated.photos, entry.photos);
      });

      test("should keep the mood when mood is not provided", () {
        expect(entry.copyWith(title: "x").mood, Mood.happy);
      });

      test("should clear the mood when clearMood is true", () {
        expect(entry.copyWith(clearMood: true).mood, isNull);
      });

      test("should clear the mood even if a new mood is also provided", () {
        expect(entry.copyWith(mood: Mood.sad, clearMood: true).mood, isNull);
      });

      test("should replace photos with an empty list", () {
        expect(entry.copyWith(photos: const []).photos, isEmpty);
      });
    });

    group("toMap", () {
      test("should convert the entry to a map correctly", () {
        expect(entry.toMap(), validMap);
      });

      test("should not include photos", () {
        expect(entry.toMap().containsKey("photos"), isFalse);
      });

      test("should store mood as null when there is no mood", () {
        expect(entry.copyWith(clearMood: true).toMap()["mood"], isNull);
      });

      test("should store timestamps as ints", () {
        final map = entry.toMap();

        expect(map["created_at"], isA<int>());
        expect(map["updated_at"], isA<int>());
      });

      test("should keep the same moment in time for a local date", () {
        final local = DateTime(2026, 1, 1, 10, 30);
        final map = entry.copyWith(createdAt: local, updatedAt: local).toMap();

        expect(map["created_at"], local.millisecondsSinceEpoch);
        expect(map["updated_at"], local.millisecondsSinceEpoch);
      });
    });

    group("fromMap", () {
      test("should create an entry from a map correctly", () {
        expect(Entry.fromMap(validMap, const [photo1, photo2]), entry);
      });

      test("should default photos to empty when not provided", () {
        expect(Entry.fromMap(validMap).photos, isEmpty);
      });

      test("should return timestamps as UTC dates", () {
        final e = Entry.fromMap(validMap);

        expect(e.createdAt.isUtc, isTrue);
        expect(e.updatedAt.isUtc, isTrue);
      });

      test("should read a null mood as null", () {
        expect(Entry.fromMap({...validMap, "mood": null}).mood, isNull);
      });

      test("should read every mood by name", () {
        for (final mood in Mood.values) {
          expect(Entry.fromMap({...validMap, "mood": mood.name}).mood, mood);
        }
      });

      test("should throw when mood is not a known name", () {
        expect(
          () => Entry.fromMap({...validMap, "mood": "angry"}),
          throwsArgumentError,
        );
      });

      test("should default title and body to empty when null", () {
        final e = Entry.fromMap({...validMap, "title": null, "body": null});

        expect(e.title, "");
        expect(e.body, "");
      });

      for (final key in ["title", "body", "mood"]) {
        test("should not throw when optional $key is missing", () {
          final map = Map<String, dynamic>.of(validMap)..remove(key);

          expect(() => Entry.fromMap(map), returnsNormally);
        });
      }

      for (final key in [
        "id",
        "journal_id",
        "scene_id",
        "created_at",
        "updated_at",
      ]) {
        test("should throw when required $key is missing", () {
          final map = Map<String, dynamic>.of(validMap)..remove(key);

          expect(() => Entry.fromMap(map), throwsA(isA<TypeError>()));
        });
      }

      test("should throw when created_at has the wrong type", () {
        expect(
          () => Entry.fromMap({...validMap, "created_at": "abc"}),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("round trip", () {
      test("should produce the same entry", () {
        expect(Entry.fromMap(entry.toMap(), entry.photos), entry);
      });

      test("should produce the same entry without a mood", () {
        final e = entry.copyWith(clearMood: true);

        expect(Entry.fromMap(e.toMap(), e.photos), e);
      });

      test("should keep equality for a local date", () {
        final local = DateTime(2026, 1, 1, 10, 10);
        final e = entry.copyWith(createdAt: local, updatedAt: local);

        expect(Entry.fromMap(e.toMap(), e.photos), e);
      });

      test("should keep equality for a date with microseconds", () {
        final precise = DateTime.utc(2026, 1, 1, 10, 10, 10, 10, 10);
        final e = entry.copyWith(createdAt: precise, updatedAt: precise);

        expect(Entry.fromMap(e.toMap(), e.photos), e);
      });
    });

    group("equality", () {
      test("should return true for entries with the same properties", () {
        final another = Entry.fromMap(validMap, const [photo1, photo2]);

        expect(entry == another, isTrue);
      });

      test("should return true when compared with itself", () {
        expect(entry == entry, isTrue);
      });

      final changes = <String, Entry Function()>{
        "id": () => entry.copyWith(id: "e-2"),
        "journalId": () => entry.copyWith(journalId: "j-2"),
        "title": () => entry.copyWith(title: "Other"),
        "body": () => entry.copyWith(body: "Other"),
        "mood": () => entry.copyWith(mood: Mood.sad),
        "sceneId": () => entry.copyWith(sceneId: "s-2"),
        "createdAt": () => entry.copyWith(createdAt: DateTime.utc(2025)),
        "updatedAt": () => entry.copyWith(updatedAt: DateTime.utc(2025)),
        "photos": () => entry.copyWith(photos: const [photo1]),
      };

      for (final MapEntry(key: field, value: build) in changes.entries) {
        test("should return false for entries with different $field", () {
          expect(entry == build(), isFalse);
        });
      }

      test("should return false when one has a mood and the other none", () {
        expect(entry == entry.copyWith(clearMood: true), isFalse);
      });

      test("should return false when photos are in a different order", () {
        expect(
          entry == entry.copyWith(photos: const [photo2, photo1]),
          isFalse,
        );
      });

      test("should return false when compared with another type", () {
        // ignore: unrelated_type_equality_checks
        expect(entry == "not an entry", isFalse);
      });
    });

    group("hashCode", () {
      test("should be the same for entries with the same properties", () {
        final another = Entry.fromMap(validMap, const [photo1, photo2]);

        expect(entry.hashCode, another.hashCode);
      });

      test("should be the same when photos are equal but different lists", () {
        final a = entry.copyWith(photos: [photo1, photo2]);
        final b = entry.copyWith(photos: [photo1, photo2]);

        expect(a.hashCode, b.hashCode);
      });

      test("should be stable across calls", () {
        expect(entry.hashCode, entry.hashCode);
      });
    });
  });
}
