import 'package:get/get.dart';
import '../models/airline_model.dart';
import '../services/flight_service.dart';

class AirlineController extends GetxController {
  final airlines = <Airline>[].obs;
  final isLoading = false.obs;
  final _service = FlightService();

  @override
  void onInit() {
    super.onInit();
    loadAirlines();
  }

  Future<void> loadAirlines() async {
    try {
      isLoading.value = true;
      final data = await _service.loadAirlines();
      airlines.assignAll(data);
    } catch (e) {
      print('Error loading airlines: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Find airline by its code
  Airline? getAirlineByCode(String code) {
    try {
      return airlines.firstWhere(
            (a) => a.airLineCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null; // If not found
    }
  }
}
