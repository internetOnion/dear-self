import "package:dear_self/models/timestamp.dart";

class Journal {
  final String id;
  final String name;
  final DateTime createdAt;

  Journal({required this.id, required this.name, required DateTime createdAt})
    : createdAt = normalizeTimestamp(createdAt);

  Journal copyWith({String? id, String? name, DateTime? createdAt}) {
    return Journal(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "created_at": createdAt.toUtc().millisecondsSinceEpoch,
    };
  }

  static Journal fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map["id"] as String,
      name: map["name"] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map["created_at"] as int,
        isUtc: true,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Journal &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
}
