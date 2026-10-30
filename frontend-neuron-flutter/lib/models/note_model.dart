class NoteModel {
  NoteModel({
    required this.id,
    required this.title,
    required this.preview,
    required this.date,
    required this.tags,
    this.isPinned = false,
    this.category = 'All',
  });

  final String id;
  final String title;
  final String preview;
  final String date;
  final List<String> tags;
  final bool isPinned;
  final String category;
}
