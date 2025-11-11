import 'package:flights/services/flight_service.dart';
import 'package:get/get.dart';
import '../models/trip_details_model.dart';

class TripDetailsController extends GetxController {
  final FlightService _service = FlightService();

  var isLoading = true.obs;
  var tripDetails = Rxn<TripDetailsResponseModel>();

  @override
  void onInit() {
    super.onInit();
    loadTripDetails();
  }

  Future<void> loadTripDetails() async {
    try {
      isLoading.value = true;
      final result = await _service.loadTripDetails();
      tripDetails.value = result;
    } catch (e) {
      print('Error loading trip details: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
