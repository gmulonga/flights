import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flights/controllers/flight_controller.dart';

class FilterScreen extends StatelessWidget {
  final FlightController flightController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Filters',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              flightController.resetFilters();
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceFilter(),
                  SizedBox(height: 24),
                  _buildCabinClassFilter(),
                  SizedBox(height: 24),
                  _buildAirlineFilter(),
                ],
              ),
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Obx(() {
      final min = flightController.minPrice.value;
      final max = flightController.maxPrice.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Range',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$${min.toStringAsFixed(0)} - \$${max.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          RangeSlider(
            values: RangeValues(min, max),
            min: flightController.fareItineraries.isEmpty
                ? 0
                : flightController.fareItineraries
                .map((i) => i.fareInfo.totalFares.totalFare)
                .reduce((a, b) => a < b ? a : b),
            max: flightController.fareItineraries.isEmpty
                ? 1000
                : flightController.fareItineraries
                .map((i) => i.fareInfo.totalFares.totalFare)
                .reduce((a, b) => a > b ? a : b),
            divisions: 20,
            activeColor: Colors.blue[700],
            onChanged: (RangeValues values) {
              flightController.minPrice.value = values.start;
              flightController.maxPrice.value = values.end;
            },
          ),
        ],
      );
    });
  }

  Widget _buildCabinClassFilter() {
    return Obx(() {
      final cabinClasses = flightController.selectedCabinClasses;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cabin Class',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cabinClasses.map((cabinClass) {
              final isSelected = flightController.selectedCabinClasses.contains(cabinClass);

              return FilterChip(
                label: Text(cabinClass),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    flightController.selectedCabinClasses.add(cabinClass);
                  } else {
                    flightController.selectedCabinClasses.remove(cabinClass);
                  }
                },
                selectedColor: Colors.blue[700],
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildAirlineFilter() {
    return Obx(() {
      final airlines = flightController.uniqueAirlines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Airlines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: airlines.map((airline) {
                final isSelected = flightController.selectedAirlines.contains(airline);

                return Column(
                  children: [
                    CheckboxListTile(
                      title: Text(
                        airline,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      value: isSelected,
                      activeColor: Colors.blue[700],
                      onChanged: (selected) {
                        if (selected == true) {
                          flightController.selectedAirlines.add(airline);
                        } else {
                          flightController.selectedAirlines.remove(airline);
                        }
                      },
                    ),
                    if (airline != airlines.last)
                      Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildApplyButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Obx(() {
                final count = flightController.filteredItineraries.length;

                return ElevatedButton(
                  onPressed: () {
                    flightController.applyFilters();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Show $count Flight${count != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
