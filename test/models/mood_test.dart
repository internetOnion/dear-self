import "package:dear_self/models/mood.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("Mood", () {
    // Mood names are saved to the database (entries.mood). Renaming or
    // removing a value breaks entries that are already stored, so these
    // names must only change together with a database migration.
    test("should keep the stored names unchanged", () {
      expect(Mood.values.map((m) => m.name), [
        "calm",
        "happy",
        "sad",
        "stressed",
        "thoughtful",
      ]);
    });
  });
}
