class EntryPhoto {
  final String id;
  final String entryId;
  final String relativePath;
  final int position;

  const EntryPhoto({
    required this.id,
    required this.relativePath,
    this.entryId = "",
    this.position = 0,
  });

  EntryPhoto copyWith({
    String? id,
    String? entryId,
    String? relativePath,
    int? position,
  }) {
    return EntryPhoto(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      relativePath: relativePath ?? this.relativePath,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "entry_id": entryId,
      "relative_path": relativePath,
      "position": position,
    };
  }

  static EntryPhoto fromMap(Map<String, dynamic> map) {
    return EntryPhoto(
      id: map["id"] as String,
      entryId: (map["entry_id"] as String?) ?? "",
      relativePath: map["relative_path"] as String,
      position: (map["position"] as int?) ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntryPhoto &&
        other.id == id &&
        other.entryId == entryId &&
        other.relativePath == relativePath &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(id, entryId, relativePath, position);
}
