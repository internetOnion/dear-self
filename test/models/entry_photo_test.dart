import "package:dear_self/models/entry_photo.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("EntryPhoto", () {
    const photo = EntryPhoto(
      id: "p-1",
      entryId: "e-1",
      relativePath: "photos/p-1.jpg",
      position: 2,
    );

    final validMap = <String, dynamic>{
      "id": "p-1",
      "entry_id": "e-1",
      "relative_path": "photos/p-1.jpg",
      "position": 2,
    };

    group("constructor", () {
      test("should assign properties correctly", () {
        expect(photo.id, "p-1");
        expect(photo.entryId, "e-1");
        expect(photo.relativePath, "photos/p-1.jpg");
        expect(photo.position, 2);
      });

      test("should default entryId to empty and position to 0", () {
        const minimal = EntryPhoto(id: "p-1", relativePath: "photos/p-1.jpg");

        expect(minimal.entryId, "");
        expect(minimal.position, 0);
      });
    });

    group("copyWith", () {
      test("should create an exact copy when no parameters are provided", () {
        expect(photo.copyWith(), photo);
      });

      test("should return a new instance not the same object", () {
        expect(identical(photo.copyWith(), photo), isFalse);
      });

      test("should update all properties when all parameters are provided", () {
        final updated = photo.copyWith(
          id: "p-2",
          entryId: "e-2",
          relativePath: "photos/p-2.jpg",
          position: 5,
        );

        expect(updated.id, "p-2");
        expect(updated.entryId, "e-2");
        expect(updated.relativePath, "photos/p-2.jpg");
        expect(updated.position, 5);
      });

      test("should change only id when only id is provided", () {
        final updated = photo.copyWith(id: "p-2");

        expect(updated.id, "p-2");
        expect(updated.entryId, photo.entryId);
        expect(updated.relativePath, photo.relativePath);
        expect(updated.position, photo.position);
      });

      test("should change only entryId when only entryId is provided", () {
        final updated = photo.copyWith(entryId: "e-2");

        expect(updated.id, photo.id);
        expect(updated.entryId, "e-2");
        expect(updated.relativePath, photo.relativePath);
        expect(updated.position, photo.position);
      });

      test(
        "should change only relativePath when only relativePath is provided",
        () {
          final updated = photo.copyWith(relativePath: "photos/other.jpg");

          expect(updated.id, photo.id);
          expect(updated.entryId, photo.entryId);
          expect(updated.relativePath, "photos/other.jpg");
          expect(updated.position, photo.position);
        },
      );

      test("should change only position when only position is provided", () {
        final updated = photo.copyWith(position: 0);

        expect(updated.id, photo.id);
        expect(updated.entryId, photo.entryId);
        expect(updated.relativePath, photo.relativePath);
        expect(updated.position, 0);
      });
    });

    group("toMap", () {
      test("should convert the photo to a map correctly", () {
        expect(photo.toMap(), validMap);
      });

      test("should store the default entryId and position", () {
        const minimal = EntryPhoto(id: "p-1", relativePath: "photos/p-1.jpg");

        expect(minimal.toMap(), {
          "id": "p-1",
          "entry_id": "",
          "relative_path": "photos/p-1.jpg",
          "position": 0,
        });
      });
    });

    group("fromMap", () {
      test("should create a photo from a map correctly", () {
        expect(EntryPhoto.fromMap(validMap), photo);
      });

      test("should default entry_id to empty when missing or null", () {
        final missing = Map<String, dynamic>.of(validMap)..remove("entry_id");

        expect(EntryPhoto.fromMap(missing).entryId, "");
        expect(EntryPhoto.fromMap({...validMap, "entry_id": null}).entryId, "");
      });

      test("should default position to 0 when missing or null", () {
        final missing = Map<String, dynamic>.of(validMap)..remove("position");

        expect(EntryPhoto.fromMap(missing).position, 0);
        expect(EntryPhoto.fromMap({...validMap, "position": null}).position, 0);
      });

      for (final key in ["id", "relative_path"]) {
        test("should throw when required $key is missing", () {
          final map = Map<String, dynamic>.of(validMap)..remove(key);

          expect(() => EntryPhoto.fromMap(map), throwsA(isA<TypeError>()));
        });
      }

      test("should throw when position has the wrong type", () {
        expect(
          () => EntryPhoto.fromMap({...validMap, "position": "2"}),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group("round trip", () {
      test("should produce the same photo", () {
        expect(EntryPhoto.fromMap(photo.toMap()), photo);
      });

      test("should produce the same photo with default values", () {
        const minimal = EntryPhoto(id: "p-1", relativePath: "photos/p-1.jpg");

        expect(EntryPhoto.fromMap(minimal.toMap()), minimal);
      });
    });

    group("equality", () {
      test("should return true for photos with the same properties", () {
        expect(photo == EntryPhoto.fromMap(validMap), isTrue);
      });

      test("should return true when compared with itself", () {
        expect(photo == photo, isTrue);
      });

      final changes = <String, EntryPhoto>{
        "id": photo.copyWith(id: "p-2"),
        "entryId": photo.copyWith(entryId: "e-2"),
        "relativePath": photo.copyWith(relativePath: "photos/other.jpg"),
        "position": photo.copyWith(position: 3),
      };

      for (final MapEntry(key: field, value: other) in changes.entries) {
        test("should return false for photos with different $field", () {
          expect(photo == other, isFalse);
        });
      }

      test("should return false when compared with another type", () {
        // ignore: unrelated_type_equality_checks
        expect(photo == "not a photo", isFalse);
      });
    });

    group("hashCode", () {
      test("should be the same for photos with the same properties", () {
        expect(photo.hashCode, EntryPhoto.fromMap(validMap).hashCode);
      });

      test("should be stable across calls", () {
        expect(photo.hashCode, photo.hashCode);
      });
    });
  });
}
