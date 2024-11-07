class Library {
  final String name;
  final String address;
  final String tel;
  final double latitude;
  final double longitude;
  final bool loanAvailable;
  final double distance;

  Library({
    required this.name,
    required this.address,
    required this.tel,
    required this.latitude,
    required this.longitude,
    required this.loanAvailable,
    required this.distance,
  });

  factory Library.fromJson(Map<String, dynamic> json, bool loanAvailable, double distance) {
    return Library(
      name: json['libName'] ?? '',
      address: json['address'] ?? '',
      tel: json['tel'] ?? '',
      latitude: double.parse(json['latitude'] ?? '0'),
      longitude: double.parse(json['longitude'] ?? '0'),
      loanAvailable: loanAvailable,
      distance: distance,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'tel': tel,
    'latitude': latitude,
    'longitude': longitude,
    'loanAvailable': loanAvailable,
    'distance': distance,
  };
}