class Airline {
  final String airLineCode;
  final String airLineName;
  final String airLineLogo;

  Airline({
    required this.airLineCode,
    required this.airLineName,
    required this.airLineLogo,
  });

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      airLineCode: json['AirLineCode'] ?? '',
      airLineName: json['AirLineName'] ?? '',
      airLineLogo: json['AirLineLogo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AirLineCode': airLineCode,
      'AirLineName': airLineName,
      'AirLineLogo': airLineLogo,
    };
  }

  static List<Airline> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Airline.fromJson(json)).toList();
  }
}
