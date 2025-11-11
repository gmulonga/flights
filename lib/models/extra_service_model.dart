class ExtraServicesResponseModel {
  final ExtraServicesResult extraServicesResult;

  ExtraServicesResponseModel({required this.extraServicesResult});

  factory ExtraServicesResponseModel.fromJson(Map<String, dynamic> json) {
    return ExtraServicesResponseModel(
      extraServicesResult: ExtraServicesResult.fromJson(
        json['ExtraServicesResponse']['ExtraServicesResult'],
      ),
    );
  }
}

class ExtraServicesResult {
  final bool success;
  final ExtraServicesData extraServicesData;

  ExtraServicesResult({
    required this.success,
    required this.extraServicesData,
  });

  factory ExtraServicesResult.fromJson(Map<String, dynamic> json) {
    return ExtraServicesResult(
      success: json['success'] ?? false,
      extraServicesData: ExtraServicesData.fromJson(json['ExtraServicesData']),
    );
  }
}

class ExtraServicesData {
  final List<DynamicBaggage> dynamicBaggage;
  final List<dynamic> dynamicMeal;
  final List<dynamic> dynamicSeat;

  ExtraServicesData({
    required this.dynamicBaggage,
    required this.dynamicMeal,
    required this.dynamicSeat,
  });

  factory ExtraServicesData.fromJson(Map<String, dynamic> json) {
    return ExtraServicesData(
      dynamicBaggage: (json['DynamicBaggage'] as List<dynamic>?)
          ?.map((item) => DynamicBaggage.fromJson(item))
          .toList() ??
          [],
      dynamicMeal: json['DynamicMeal'] ?? [],
      dynamicSeat: json['DynamicSeat'] ?? [],
    );
  }
}

class DynamicBaggage {
  final String behavior;
  final bool isMultiSelect;
  final List<List<Service>> services;

  DynamicBaggage({
    required this.behavior,
    required this.isMultiSelect,
    required this.services,
  });

  factory DynamicBaggage.fromJson(Map<String, dynamic> json) {
    var serviceList = (json['Services'] as List<dynamic>?)
        ?.map((innerList) => (innerList as List<dynamic>)
        .map((item) => Service.fromJson(item))
        .toList())
        .toList() ??
        [];

    return DynamicBaggage(
      behavior: json['Behavior'] ?? '',
      isMultiSelect: json['IsMultiSelect'] ?? false,
      services: serviceList,
    );
  }
}

class Service {
  final String serviceId;
  final String checkInType;
  final String description;
  final String fareDescription;
  final bool isMandatory;
  final int minimumQuantity;
  final int maximumQuantity;
  final ServiceCost serviceCost;

  Service({
    required this.serviceId,
    required this.checkInType,
    required this.description,
    required this.fareDescription,
    required this.isMandatory,
    required this.minimumQuantity,
    required this.maximumQuantity,
    required this.serviceCost,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['ServiceId'] ?? '',
      checkInType: json['CheckInType'] ?? '',
      description: json['Description'] ?? '',
      fareDescription: json['FareDescription'] ?? '',
      isMandatory: json['IsMandatory'] ?? false,
      minimumQuantity: json['MinimumQuantity'] ?? 0,
      maximumQuantity: json['MaximumQuantity'] ?? 0,
      serviceCost: ServiceCost.fromJson(json['ServiceCost']),
    );
  }
}

class ServiceCost {
  final String currencyCode;
  final String amount;
  final String decimalPlaces;

  ServiceCost({
    required this.currencyCode,
    required this.amount,
    required this.decimalPlaces,
  });

  factory ServiceCost.fromJson(Map<String, dynamic> json) {
    return ServiceCost(
      currencyCode: json['CurrencyCode'] ?? '',
      amount: json['Amount'] ?? '',
      decimalPlaces: json['DecimalPlaces'] ?? '',
    );
  }
}
