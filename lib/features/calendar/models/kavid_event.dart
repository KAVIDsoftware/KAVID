
class KavidEvent {
  final String id;
  final String title;

  const KavidEvent({
    required this.id,
    required this.title,
  });

  @override
  String toString() => 'KavidEvent($title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is KavidEvent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
