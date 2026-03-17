class City {
  final String name;
  final String region;
  final String country;
  final double? latitude;
  final double? longitude;

  City({
    required this.name,
    required this.region,
    required this.country,
    this.latitude,
    this.longitude,
  });

  // @override permet de redefinir la methode parente toString() de la classe Object afin de print l'objet City
  // pour faire apparaitre le nom, la region et le pays au lieu de 'Instance of 'City'
  @override
  String toString() {
    return '$name, $region, $country, Lat: $latitude, Lon: $longitude';
  }
}
