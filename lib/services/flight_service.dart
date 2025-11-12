import 'dart:convert';
import 'package:flights/models/airline_model.dart';
import 'package:flights/models/extra_service_model.dart';
import 'package:flights/models/flights_model.dart';
import 'package:flights/models/trip_details_model.dart';
import 'package:flutter/services.dart';

class FlightService {
  Future<List<FareItinerary>> loadFlights() async {
    final String response = await rootBundle.loadString('assets/json/flights.json');
    final data = jsonDecode(response);

    final List list = data['AirSearchResponse']['AirSearchResult']['FareItineraries'];
    return list.map((f) => FareItinerary.fromJson(f['FareItinerary'])).toList();
  }

  Future<List<Airline>> loadAirlines() async {
    final String response = await rootBundle.loadString('assets/json/airline-list.json');
    final List data = jsonDecode(response);
    return data.map((a) => Airline.fromJson(a)).toList();
  }

  Future<TripDetailsResponseModel> loadTripDetails() async {
    final String response = await rootBundle.loadString('assets/json/trip-details.json');
    final data = jsonDecode(response);
    return TripDetailsResponseModel.fromJson(data);
  }

  Future<ExtraServicesResponseModel> fetchExtraServices() async {
    final response = await rootBundle.loadString('assets/json-files/extra_services.json');
    final data = json.decode(response);

    return ExtraServicesResponseModel.fromJson(data);
  }
}
