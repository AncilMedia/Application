class Item {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String url;
  final int index;
  final String type;
  final String? parentId;

  Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.url,
    required this.index,
    required this.type,
    this.parentId,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
      index: json['index'] ?? 0,
      type: json['type'] ?? 'link', // default to 'link' if missing
      parentId: json['parentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'url': url,
      'index': index,
      'type': type,
      'parentId': parentId,
    };
  }
}
