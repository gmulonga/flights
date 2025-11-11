class AirSearchResponse {
  final String sessionId;
  final List<FareItinerary> fareItineraries;

  AirSearchResponse({
    required this.sessionId,
    required this.fareItineraries,
  });

  factory AirSearchResponse.fromJson(Map<String, dynamic> json) {
    final fareList = (json['AirSearchResult']?['FareItineraries'] ?? []) as List;
    return AirSearchResponse(
      sessionId: json['session_id'] ?? '',
      fareItineraries: fareList
          .map((item) => FareItinerary.fromJson(item['FareItinerary']))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'AirSearchResult': {
        'FareItineraries': fareItineraries
            .map((f) => {'FareItinerary': f.toJson()})
            .toList(),
      },
    };
  }
}

class FareItinerary {
  final String directionInd;
  final AirItineraryFareInfo fareInfo;
  final List<OriginDestinationOption> originDestinations;
  final String? sequenceNumber;
  final String? ticketType;
  final String? validatingAirlineCode;

  FareItinerary({
    required this.directionInd,
    required this.fareInfo,
    required this.originDestinations,
    this.sequenceNumber,
    this.ticketType,
    this.validatingAirlineCode,
  });

  factory FareItinerary.fromJson(Map<String, dynamic> json) {
    return FareItinerary(
      directionInd: json['DirectionInd'] ?? '',
      fareInfo: AirItineraryFareInfo.fromJson(json['AirItineraryFareInfo']),
      originDestinations: ((json['OriginDestinationOptions'] ?? []) as List)
          .expand((e) => e['OriginDestinationOption'] as List)
          .map((o) => OriginDestinationOption.fromJson(o))
          .toList(),
      sequenceNumber: json['SequenceNumber'],
      ticketType: json['TicketType'],
      validatingAirlineCode: json['ValidatingAirlineCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DirectionInd': directionInd,
      'AirItineraryFareInfo': fareInfo.toJson(),
      'OriginDestinationOptions': [
        {
          'OriginDestinationOption':
          originDestinations.map((e) => e.toJson()).toList()
        }
      ],
      'SequenceNumber': sequenceNumber,
      'TicketType': ticketType,
      'ValidatingAirlineCode': validatingAirlineCode,
    };
  }

  double get totalFare {
    final totalFareAmount =
        fareInfo.totalFares?.totalFare ?? 0.0;
    return totalFareAmount;
  }

  bool get isRefundable =>
      fareInfo.isRefundable?.toLowerCase() == 'yes';
}


class AirItineraryFareInfo {
  final String fareSourceCode;
  final String fareType;
  final String isRefundable;
  final ItinTotalFares totalFares;

  AirItineraryFareInfo({
    required this.fareSourceCode,
    required this.fareType,
    required this.isRefundable,
    required this.totalFares,
  });

  factory AirItineraryFareInfo.fromJson(Map<String, dynamic> json) {
    return AirItineraryFareInfo(
      fareSourceCode: json['FareSourceCode'] ?? '',
      fareType: json['FareType'] ?? '',
      isRefundable: json['IsRefundable'] ?? '',
      totalFares: ItinTotalFares.fromJson(json['ItinTotalFares']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FareSourceCode': fareSourceCode,
      'FareType': fareType,
      'IsRefundable': isRefundable,
      'ItinTotalFares': totalFares.toJson(),
    };
  }
}

class ItinTotalFares {
  final double baseFare;
  final double totalTax;
  final double totalFare;
  final String currencyCode;

  ItinTotalFares({
    required this.baseFare,
    required this.totalTax,
    required this.totalFare,
    required this.currencyCode,
  });

  factory ItinTotalFares.fromJson(Map<String, dynamic> json) {
    final total = json['TotalFare'] ?? {};
    return ItinTotalFares(
      baseFare: double.tryParse(json['BaseFare']?['Amount']?.toString() ?? '0') ?? 0.0,
      totalTax: double.tryParse(json['TotalTax']?['Amount']?.toString() ?? '0') ?? 0.0,
      totalFare: double.tryParse(total['Amount']?.toString() ?? '0') ?? 0.0,
      currencyCode: total['CurrencyCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BaseFare': {'Amount': baseFare, 'CurrencyCode': currencyCode},
      'TotalTax': {'Amount': totalTax, 'CurrencyCode': currencyCode},
      'TotalFare': {'Amount': totalFare, 'CurrencyCode': currencyCode},
    };
  }
}

class OriginDestinationOption {
  final FlightSegment segment;
  final int stopQuantity;
  final int seatsRemaining;

  OriginDestinationOption({
    required this.segment,
    required this.stopQuantity,
    required this.seatsRemaining,
  });

  factory OriginDestinationOption.fromJson(Map<String, dynamic> json) {
    return OriginDestinationOption(
      segment: FlightSegment.fromJson(json['FlightSegment']),
      stopQuantity: json['StopQuantity'] ?? 0,
      seatsRemaining: json['SeatsRemaining']?['Number'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FlightSegment': segment,
      'StopQuantity': stopQuantity,
      'SeatsRemaining': {'Number': seatsRemaining},
    };
  }
}

class FlightSegment {
  final String airlineCode;
  final String airlineName;
  final String cabinClassText;
  final DateTime departureDateTime;
  final DateTime arrivalDateTime;
  final String departureAirportCode;
  final String arrivalAirportCode;
  final String journeyDuration;

  FlightSegment({
    required this.airlineCode,
    required this.airlineName,
    required this.cabinClassText,
    required this.departureDateTime,
    required this.arrivalDateTime,
    required this.departureAirportCode,
    required this.arrivalAirportCode,
    required this.journeyDuration,
  });

  factory FlightSegment.fromJson(Map<String, dynamic> json) {
    return FlightSegment(
      airlineCode: json['MarketingAirlineCode'] ?? '',
      airlineName: json['MarketingAirlineName'] ?? '',
      cabinClassText: json['CabinClassText'] ?? '',
      departureDateTime: DateTime.parse(json['DepartureDateTime']),
      arrivalDateTime: DateTime.parse(json['ArrivalDateTime']),
      departureAirportCode: json['DepartureAirportLocationCode'] ?? '',
      arrivalAirportCode: json['ArrivalAirportLocationCode'] ?? '',
      journeyDuration: json['JourneyDuration'] ?? '',
    );
  }
}
