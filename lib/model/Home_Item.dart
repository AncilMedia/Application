class Item {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String url;
  final int index;

  Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.url,
    required this.index,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'],
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
      index: json['index'] ?? 0,
    );
  }
}
