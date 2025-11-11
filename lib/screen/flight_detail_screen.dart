import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/airline_controller.dart';
import '../models/flights_model.dart';

class FlightDetailsScreen extends StatelessWidget {
  final FareItinerary itinerary;

  FlightDetailsScreen({required this.itinerary});

  final AirlineController airlineController = Get.find<AirlineController>();

  @override
  Widget build(BuildContext context) {
    final segment = itinerary.originDestinations.first.segment;
    final airline = airlineController.getAirlineByCode(segment.airlineName);
    final fare = itinerary.fareInfo.totalFares;

    final departureTime = DateFormat('HH:mm').format(DateTime.parse(segment.departureTime));
    final arrivalTime = DateFormat('HH:mm').format(DateTime.parse(segment.arrivalTime));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Flight Details',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Airline Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: airline?.airLineLogo ?? '',
                      width: 50,
                      height: 50,
                      errorWidget: (context, url, error) =>
                          Icon(Icons.flight, color: Colors.grey, size: 40),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            airline?.airLineName ?? segment.airlineName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Flight ${segment.flightNumber}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Route info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                segment.departureAirport,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                departureTime,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(Icons.flight_takeoff, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(
                              segment.journeyDuration,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                segment.arrivalAirport,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                arrivalTime,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stops: ${itinerary.originDestinations.length - 1}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          itinerary.ticketType ?? 'Economy',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Fare details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fare Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildFareRow('Base Fare', fare.baseFare, fare.currencyCode),
                    _buildFareRow('Taxes & Fees', fare.totalTax, fare.currencyCode),
                    const Divider(),
                    _buildFareRow('Total Fare', fare.totalFare, fare.currencyCode,
                        isTotal: true),
                    const SizedBox(height: 8),
                    Text(
                      itinerary.fareInfo.isRefundable == 'true'
                          ? 'Refundable'
                          : 'Non-Refundable',
                      style: TextStyle(
                        color: itinerary.fareInfo.isRefundable == 'true'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CTA button
            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Booking Coming Soon',
                  'You can integrate a booking API later.',
                  backgroundColor: Colors.blue[50],
                  colorText: Colors.black87,
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Book This Flight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String label, double amount, String currency,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
              )),
          Text(
            '$currency ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
              color: isTotal ? Colors.blue[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
