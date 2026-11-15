import 'mood.dart';

enum TextTone {
  light,
  dark,
}

class Scene {
  final String id;
  final String name;
  final String imageAsset;
  final String prompt;
  final Set<Mood> moods;
  final TextTone textTone;

  const Scene({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.prompt,
    required this.moods,
    this.textTone = TextTone.light,
  });

  static const Scene fallback = Scene(
    id: 'default',
    name: 'Quiet Space',
    imageAsset: '',
    prompt: 'What is on your mind today?',
    moods: {},
    textTone: TextTone.dark,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scene &&
        other.id == id &&
        other.name == name &&
        other.imageAsset == imageAsset &&
        other.prompt == prompt &&
        other.textTone == textTone &&
        other.moods.length == moods.length &&
        other.moods.containsAll(moods);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        imageAsset,
        prompt,
        textTone,
        Object.hashAllUnordered(moods),
      );
}
