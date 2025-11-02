class ContentItem {
  final String type; // paragraph, image, heading, subheading, point
  final String? text;
  final String? path;

  ContentItem({
    required this.type,
    this.text,
    this.path,
  });

  factory ContentItem.fromMap(Map<String, dynamic> map) {

    print('  🔍 Parsing ContentItem: ${map.toString()}');

    String type = (map['type'] ?? '').toString().trim();
    String? text = map['text']?.toString();
    String? path = map['path']?.toString();

    // Additional debug for images
    if (type.toLowerCase() == 'image') {
      print('  🖼️ IMAGE ITEM DETECTED');
      print('    - Raw path value: ${map['path']}');
      print('    - Path is null: ${map['path'] == null}');
      print('    - Path after toString: $path');
      print('    - All map keys: ${map.keys.toList()}');
    }

    // Trim whitespace from path if it exists
    if (path != null && path.isNotEmpty) {
      path = path.trim();
      print('  ✅ Path after trim: "$path"');
    } else {
      print('  ⚠️ Path is null or empty');
    }

    return ContentItem(
      type: map['type'] ?? '',
      text: map['text'],
      path: map['path'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (text != null) 'text': text,
      if (path != null) 'path': path,
    };
  }
}
