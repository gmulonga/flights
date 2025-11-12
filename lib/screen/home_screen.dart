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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Flights',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (flightController.isLoading.value) {
                return _buildStateView(
                  icon: null,
                  title: 'Loading flights...',
                  showProgress: true,
                );
              }

              if (flightController.errorMessage.value.isNotEmpty) {
                return _buildStateView(
                  icon: Icons.error_outline,
                  iconColor: Colors.red.shade300,
                  title: 'Oops!',
                  subtitle: flightController.errorMessage.value,
                  actionLabel: 'Retry',
                  onAction: () => flightController.loadFlights(),
                );
              }

              if (flightController.filteredItineraries.isEmpty) {
                return _buildStateView(
                  icon: Icons.flight_takeoff,
                  iconColor: Colors.grey.shade300,
                  title: 'No flights found',
                  subtitle: 'Try adjusting your filters',
                  actionLabel: 'Clear Filters',
                  onAction: () => flightController.resetFilters(),
                );
              }

              return RefreshIndicator(
                onRefresh: () => flightController.loadFlights(),
                color: Colors.blue.shade700,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: flightController.filteredItineraries.length,
                  itemBuilder: (context, index) {
                    return _buildFlightCard(context, flightController.filteredItineraries[index]);
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Obx(() => _buildSortButton())),
          const SizedBox(width: 12),
          _buildActionButton(
            icon: Icons.tune,
            onTap: () => Get.to(() => FilterScreen()),
            color: Colors.blue.shade700,
          ),
          Obx(() {
            final hasFilters = flightController.selectedCabinClasses.isNotEmpty ||
                flightController.selectedAirlines.isNotEmpty;
            return hasFilters
                ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _buildActionButton(
                icon: Icons.close,
                onTap: () => flightController.resetFilters(),
                color: Colors.red.shade600,
              ),
            )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    const sortOptions = {
      'price_asc': 'Price: Low to High',
      'price_desc': 'Price: High to Low',
      'duration': 'Duration',
    };

    return InkWell(
      onTap: () => _showSortSheet(sortOptions),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.sort, size: 18, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                sortOptions[flightController.sortBy.value] ?? 'Sort',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(Map<String, String> options) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...options.entries.map((entry) {
              return Obx(() => RadioListTile<String>(
                title: Text(entry.value, style: const TextStyle(fontSize: 15)),
                value: entry.key,
                groupValue: flightController.sortBy.value,
                activeColor: Colors.blue.shade700,
                contentPadding: EdgeInsets.zero,
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
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildFlightCard(BuildContext context, dynamic itinerary) {
    final segment = itinerary.originDestinations.first.segment;
    final airline = airlineController.getAirlineByCode(segment.airlineCode);
    final depTime = DateFormat('HH:mm').format(segment.departureDateTime);
    final arrTime = DateFormat('HH:mm').format(segment.arrivalDateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => Get.to(() => FlightDetailsScreen(itinerary: itinerary)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: airline?.airLineLogo != null
                        ? CachedNetworkImage(
                      imageUrl: airline!.airLineLogo,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(Icons.flight, color: Colors.blue.shade300),
                    )
                        : Icon(Icons.flight, color: Colors.blue.shade300),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          segment.airlineName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          segment.cabinClassText,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${itinerary.totalFare.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Total', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildTimeColumn(depTime, segment.departureAirportCode, false),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade200, Colors.blue.shade400],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${segment.journeyDuration}m',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildTimeColumn(arrTime, segment.arrivalAirportCode, true),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildBadge(
                    icon: itinerary.isRefundable ? Icons.check_circle : Icons.cancel,
                    label: itinerary.isRefundable ? 'Refundable' : 'Non-refundable',
                    color: itinerary.isRefundable ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String time, String code, bool alignEnd) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 4),
        Text(code, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBadge({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStateView({
    IconData? icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    bool showProgress = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showProgress) CircularProgressIndicator(color: Colors.blue.shade700),
            if (icon != null) Icon(icon, size: 72, color: iconColor ?? Colors.grey.shade400),
            SizedBox(height: showProgress || icon != null ? 20 : 0),
            Text(
              title,
              style: TextStyle(
                fontSize: showProgress ? 16 : 22,
                fontWeight: FontWeight.bold,
                color: showProgress ? Colors.grey[600] : const Color(0xFF1A1A1A),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}