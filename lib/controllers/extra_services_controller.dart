import 'package:flights/models/extra_service_model.dart';
import 'package:flights/services/flight_service.dart';
import 'package:get/get.dart';


class ExtraServicesController extends GetxController {
  var isLoading = true.obs;
  var extraServices = Rxn<ExtraServicesResponseModel>();

  final FlightService _service = FlightService();

  @override
  void onInit() {
    super.onInit();
    fetchExtraServices();
  }

  Future<void> fetchExtraServices() async {
    try {
      isLoading(true);
      final result = await _service.fetchExtraServices();
      extraServices.value = result;
    } catch (e) {
      print("Error loading extra services: $e");
    } finally {
      isLoading(false);
    }
  }
}
