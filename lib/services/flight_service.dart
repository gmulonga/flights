import 'dart:convert';
import 'package:flights/models/flights_model.dart';
import 'package:flutter/services.dart';

class FlightService {
  Future<List<AirSearchResponse>> loadFlights() async {
    final String response = await rootBundle.loadString('assets/json/flights.json');
    final data = jsonDecode(response);

    final List list = data['AirSearchResponse']['AirSearchResult']['FareItineraries'];
    return list.map((f) => AirSearchResponse.fromJson(f)).toList();
  }
}
