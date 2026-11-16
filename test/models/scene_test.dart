import "package:dear_self/models/mood.dart";
import "package:dear_self/models/scene.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("Scene", () {
    const scene = Scene(
      id: "s-1",
      name: "Forest",
      imageAsset: "assets/scenes/forest.jpg",
      prompt: "What made you feel at peace today?",
      moods: {Mood.calm, Mood.thoughtful},
      textTone: TextTone.dark,
    );

    Scene buildScene({
      String id = "s-1",
      String name = "Forest",
      String imageAsset = "assets/scenes/forest.jpg",
      String prompt = "What made you feel at peace today?",
      Set<Mood> moods = const {Mood.calm, Mood.thoughtful},
      TextTone textTone = TextTone.dark,
    }) {
      return Scene(
        id: id,
        name: name,
        imageAsset: imageAsset,
        prompt: prompt,
        moods: moods,
        textTone: textTone,
      );
    }

    group("constructor", () {
      test("should assign properties correctly", () {
        expect(scene.id, "s-1");
        expect(scene.name, "Forest");
        expect(scene.imageAsset, "assets/scenes/forest.jpg");
        expect(scene.prompt, "What made you feel at peace today?");
        expect(scene.moods, {Mood.calm, Mood.thoughtful});
        expect(scene.textTone, TextTone.dark);
      });

      test("should default textTone to light", () {
        const s = Scene(
          id: "s-1",
          name: "Forest",
          imageAsset: "assets/scenes/forest.jpg",
          prompt: "Prompt",
          moods: {},
        );

        expect(s.textTone, TextTone.light);
      });

      test("should allow an empty set of moods", () {
        expect(buildScene(moods: const {}).moods, isEmpty);
      });
    });

    group("fallback", () {
      test("should have the expected values", () {
        expect(Scene.fallback.id, "default");
        expect(Scene.fallback.name, "Quiet Space");
        expect(Scene.fallback.imageAsset, "");
        expect(Scene.fallback.prompt, "What is on your mind today?");
        expect(Scene.fallback.moods, isEmpty);
        expect(Scene.fallback.textTone, TextTone.dark);
      });

      test("should always be the same instance", () {
        expect(identical(Scene.fallback, Scene.fallback), isTrue);
      });
    });

    group("equality", () {
      test("should return true for scenes with the same properties", () {
        expect(scene == buildScene(), isTrue);
      });

      test("should return true when compared with itself", () {
        expect(scene == scene, isTrue);
      });

      test("should return true when moods are in a different order", () {
        final reordered = buildScene(moods: {Mood.thoughtful, Mood.calm});

        expect(scene == reordered, isTrue);
      });

      final changes = <String, Scene>{
        "id": buildScene(id: "s-2"),
        "name": buildScene(name: "Ocean"),
        "imageAsset": buildScene(imageAsset: "assets/scenes/ocean.jpg"),
        "prompt": buildScene(prompt: "Other prompt"),
        "textTone": buildScene(textTone: TextTone.light),
        "moods": buildScene(moods: {Mood.calm, Mood.sad}),
      };

      for (final MapEntry(key: field, value: other) in changes.entries) {
        test("should return false for scenes with different $field", () {
          expect(scene == other, isFalse);
        });
      }

      test("should return false when other has extra moods", () {
        final more = buildScene(moods: {Mood.calm, Mood.thoughtful, Mood.sad});

        expect(scene == more, isFalse);
        expect(more == scene, isFalse);
      });

      test("should return false when other has fewer moods", () {
        final fewer = buildScene(moods: {Mood.calm});

        expect(scene == fewer, isFalse);
        expect(fewer == scene, isFalse);
      });

      test("should return false when compared with another type", () {
        // ignore: unrelated_type_equality_checks
        expect(scene == "not a scene", isFalse);
      });
    });

    group("hashCode", () {
      test("should be the same for scenes with the same properties", () {
        expect(scene.hashCode, buildScene().hashCode);
      });

      test("should be the same when moods are in a different order", () {
        final reordered = buildScene(moods: {Mood.thoughtful, Mood.calm});

        expect(scene.hashCode, reordered.hashCode);
      });

      test("should be stable across calls", () {
        expect(scene.hashCode, scene.hashCode);
      });
    });
  });
}
