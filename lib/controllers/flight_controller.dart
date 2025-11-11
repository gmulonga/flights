import 'package:flights/models/flights_model.dart';
import 'package:flights/services/flight_service.dart';
import 'package:get/get.dart';

class FlightController extends GetxController {
  // Store complete fare itineraries instead of just segments
  final fareItineraries = <FareItinerary>[].obs;
  final filteredItineraries = <FareItinerary>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final FlightService _flightService = FlightService();

  // Filter state
  final selectedCabinClasses = <String>[].obs;
  final selectedAirlines = <String>[].obs;
  final maxPrice = RxDouble(double.infinity);
  final minPrice = RxDouble(0.0);
  final sortBy = 'price_asc'.obs; // price_asc, price_desc, duration

  @override
  void onInit() {
    super.onInit();
    loadFlights();
  }

  Future<void> loadFlights() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _flightService.loadFlights();

      // Data is already a list of FareItinerary objects
      fareItineraries.assignAll(data);  // Changed this
      filteredItineraries.assignAll(data);  // Changed this

      // Calculate price range for filter
      if (data.isNotEmpty) {
        final prices = data.map((i) => i.fareInfo.totalFares.totalFare).toList()..sort();
        minPrice.value = prices.first;
        maxPrice.value = prices.last;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load flights: $e';
      print('Error loading flights: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    var filtered = fareItineraries.toList();

    // Filter by cabin class
    if (selectedCabinClasses.isNotEmpty) {
      filtered = filtered.where((itinerary) {
        final cabinClass = itinerary.originDestinations.first.segment.airlineName;
        return selectedCabinClasses.contains(cabinClass);
      }).toList();
    }

    // Filter by airline
    if (selectedAirlines.isNotEmpty) {
      filtered = filtered.where((itinerary) {
        final airline = itinerary.originDestinations.first.segment.airlineName;
        return selectedAirlines.contains(airline);
      }).toList();
    }

    // Filter by price
    filtered = filtered.where((itinerary) {
      return itinerary.fareInfo.totalFares.totalFare >= minPrice.value &&
          itinerary.fareInfo.totalFares.totalFare <= maxPrice.value;
    }).toList();

    // Sort
    switch (sortBy.value) {
      case 'price_asc':
        filtered.sort((a, b) => a.fareInfo.totalFares.totalFare.compareTo(b.fareInfo.totalFares.totalFare));
        break;
      case 'price_desc':
        filtered.sort((a, b) => b.fareInfo.totalFares.totalFare.compareTo(a.fareInfo.totalFares.totalFare));
        break;
      case 'duration':
        filtered.sort((a, b) {
          final durationA = int.parse(a.originDestinations.first.segment.journeyDuration);
          final durationB = int.parse(b.originDestinations.first.segment.journeyDuration);
          return durationA.compareTo(durationB);
        });
        break;
    }

    filteredItineraries.assignAll(filtered);
  }

  void resetFilters() {
    selectedCabinClasses.clear();
    selectedAirlines.clear();
    sortBy.value = 'price_asc';
    filteredItineraries.assignAll(fareItineraries);
  }

  // Get unique airlines for filter
  List<String> get uniqueAirlines {
    return fareItineraries
        .map((i) => i.originDestinations.first.segment.airlineName)
        .toSet()
        .toList();
  }

  // Get unique cabin classes for filter
  List<String> get uniqueCabinClasses {
    return fareItineraries
        .map((i) => i.originDestinations.first.segment.airlineName)
        .toSet()
        .toList();
  }
}