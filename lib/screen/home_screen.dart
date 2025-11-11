import 'package:cached_network_image/cached_network_image.dart';
import 'package:flights/controllers/airline_controller.dart';
import 'package:flights/screen/filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flights/controllers/flight_controller.dart';
import 'package:intl/intl.dart';

import 'flight_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final FlightController flightController = Get.put(FlightController());
  final AirlineController airlineController = Get.put(AirlineController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flights',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'RTM → STN',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (flightController.isLoading.value) {
                return _buildLoadingState();
              }

              if (flightController.errorMessage.value.isNotEmpty) {
                return _buildErrorState(flightController.errorMessage.value);
              }

              if (flightController.filteredItineraries.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => flightController.loadFlights(),
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: flightController.filteredItineraries.length,
                  itemBuilder: (context, index) {
                    final itinerary = flightController.filteredItineraries[index];
                    return _buildFlightCard(context, itinerary);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => _buildSortButton()),
          ),
          SizedBox(width: 12),
          _buildFilterButton(),
          SizedBox(width: 12),
          Obx(() {
            final hasFilters = flightController.selectedCabinClasses.isNotEmpty ||
                flightController.selectedAirlines.isNotEmpty;
            return hasFilters
                ? InkWell(
              onTap: () => flightController.resetFilters(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
                : SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    final sortOptions = {
      'price_asc': 'Price: Low to High',
      'price_desc': 'Price: High to Low',
      'duration': 'Duration',
    };

    return InkWell(
      onTap: () {
        Get.bottomSheet(
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ...sortOptions.entries.map((entry) {
                  return Obx(() => RadioListTile<String>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: flightController.sortBy.value,
                    onChanged: (value) {
                      flightController.sortBy.value = value!;
                      flightController.applyFilters();
                      Get.back();
                    },
                  ));
                }),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 18, color: Colors.blue[700]),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                sortOptions[flightController.sortBy.value] ?? 'Sort',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.blue[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      onTap: () {
        Get.to(() => FilterScreen());
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.tune, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildFlightCard(BuildContext context, dynamic itinerary) {
    final segment = itinerary.originDestinations.first.segment;
    final airline = airlineController.getAirlineByCode(segment.airlineCode);

    final departureTime = DateFormat('HH:mm').format(segment.departureDateTime);
    final arrivalTime = DateFormat('HH:mm').format(segment.arrivalDateTime);
    final duration = '${segment.journeyDuration}m';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Get.to(() => FlightDetailsScreen(itinerary: itinerary));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header: Airline + Price
              Row(
                children: [
                  // Airline Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: airline?.airLineLogo != null
                        ? CachedNetworkImage(
                      imageUrl: airline!.airLineLogo,
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.flight, color: Colors.grey),
                    )
                        : Icon(Icons.flight, color: Colors.grey),
                  ),
                  SizedBox(width: 12),
                  // Airline Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          segment.airlineName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          segment.cabinClassText,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${itinerary.totalFare.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Flight Route
              Row(
                children: [
                  // Departure
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          departureTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          segment.departureAirportCode,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Duration indicator
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.flight_takeoff,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrival
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          arrivalTime,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          segment.arrivalAirportCode,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.event_seat,
                    label: '${itinerary.totalPassengers} seats',
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  _buildInfoChip(
                    icon: itinerary.isRefundable ? Icons.check_circle : Icons.cancel,
                    label: itinerary.isRefundable ? 'Refundable' : 'Non-refundable',
                    color: itinerary.isRefundable ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading flights...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            'Oops!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => flightController.loadFlights(),
            icon: Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, size: 64, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No flights found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          TextButton(
            onPressed: () => flightController.resetFilters(),
            child: Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}