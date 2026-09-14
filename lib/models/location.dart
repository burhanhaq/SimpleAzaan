class Location {
  final String city;
  final String state;
  final String country;
  final double? latitude;
  final double? longitude;

  Location({
    required this.city,
    required this.state,
    required this.country,
    this.latitude,
    this.longitude,
  });

  String get displayName => [city, state.isNotEmpty ? state : country]
      .where((part) => part.isNotEmpty)
      .join(', ');

  String get fullDisplayName =>
      [city, state, country].where((part) => part.isNotEmpty).join(', ');

  Location copyWith({
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    return Location(
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.city == city &&
        other.state == state &&
        other.country == country &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(city, state, country, latitude, longitude);
}
