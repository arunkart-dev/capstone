class Badge {
  final String title;
  final String description;
  final String icon;
  bool unlocked;

  Badge({
    required this.title,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });

  // Factory constructor to create Badge from a map
  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      unlocked: map['unlocked'] ?? false,
    );
  }

  // Convert Badge to map (useful for saving to local storage)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked': unlocked,
    };
  }
}
