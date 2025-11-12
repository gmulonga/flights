import 'package:flights/controllers/extra_services_controller.dart';
import 'package:flights/controllers/trip_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/airline_controller.dart';
import '../models/flights_model.dart';

class FlightDetailsScreen extends StatelessWidget {
  final FareItinerary itinerary;
  FlightDetailsScreen({required this.itinerary});

  final tripController = Get.put(TripDetailsController());
  final airlineController = Get.find<AirlineController>();
  final extraServicesController = Get.put(ExtraServicesController());

  @override
  Widget build(BuildContext context) {
    final seg = itinerary.originDestinations.first.segment;
    final airline = airlineController.getAirlineByCode(seg.airlineCode);
    final fare = itinerary.fareInfo.totalFares;

    final depTime = DateFormat('HH:mm').format(seg.departureDateTime);
    final arrTime = DateFormat('HH:mm').format(seg.arrivalDateTime);
    final depDate = DateFormat('EEE, MMM d').format(seg.departureDateTime);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Flight Details', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: airline?.airLineLogo ?? '',
                      width: 45,
                      height: 45,
                      errorWidget: (_, __, ___) => Icon(Icons.flight, color: Colors.blue.shade300, size: 35),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          airline?.airLineName ?? seg.airlineName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Color(0xFF1A1A1A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${seg.cabinClassText}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Flight Route Card with visual timeline
            _infoCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      _airportColumn(seg.departureAirportCode, depTime, alignEnd: false),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade300, Colors.blue.shade600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(Icons.flight, color: Colors.blue.shade600, size: 20),
                          ],
                        ),
                      ),
                      _airportColumn(seg.arrivalAirportCode, arrTime, alignEnd: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoChip(Icons.calendar_today, depDate),
                        _infoChip(Icons.airline_stops, '${itinerary.originDestinations.length - 1} Stop${itinerary.originDestinations.length - 1 != 1 ? 's' : ''}'),
                        _infoChip(Icons.airline_seat_recline_normal, itinerary.ticketType ?? 'Economy'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fare Breakdown Card
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fare Breakdown', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 16),
                  _fareRow('Base Fare', fare.baseFare, fare.currencyCode),
                  _fareRow('Taxes & Fees', fare.totalTax, fare.currencyCode),
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  _fareRow('Total Fare', fare.totalFare, fare.currencyCode, isTotal: true),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: itinerary.fareInfo.isRefundable == 'true' ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: itinerary.fareInfo.isRefundable == 'true' ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          itinerary.fareInfo.isRefundable == 'true' ? Icons.check_circle : Icons.info,
                          size: 16,
                          color: itinerary.fareInfo.isRefundable == 'true' ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          itinerary.fareInfo.isRefundable == 'true' ? 'Refundable' : 'Non-Refundable',
                          style: TextStyle(
                            color: itinerary.fareInfo.isRefundable == 'true' ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Trip Details
            Obx(() {
              if (tripController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Colors.blue.shade600),
                  ),
                );
              }

              final trip = tripController.tripDetails.value?.tripDetailsResult.travelItinerary;
              if (trip == null) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Passengers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 16),
                        ...trip.itineraryInfo.customerInfos.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(Icons.person, size: 20, color: Colors.blue.shade700),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${c.passengerTitle} ${c.passengerFirstName} ${c.passengerLastName}',
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${c.passengerType} • ${c.passengerNationality}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  if (trip.itineraryInfo.extraServices.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _infoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Extra Services', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 16),
                          ...trip.itineraryInfo.extraServices.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.shopping_bag, size: 18, color: Colors.amber.shade700),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(s.description, style: const TextStyle(fontSize: 14)),
                                ),
                                Text(
                                  '${s.serviceCost.currencyCode} ${s.serviceCost.amount}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: const EdgeInsets.all(20),
    child: child,
  );

  Widget _airportColumn(String code, String time, {required bool alignEnd}) => Column(
    crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Text(
        code,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
      ),
      const SizedBox(height: 4),
      Text(
        time,
        style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    ],
  );

  Widget _infoChip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
    ],
  );

  Widget _fareRow(String label, double amount, String currency, {bool isTotal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? const Color(0xFF1A1A1A) : Colors.grey[700],
          ),
        ),
        Text(
          '$currency ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 15,
            color: isTotal ? Colors.blue.shade700 : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    ),
  );
}