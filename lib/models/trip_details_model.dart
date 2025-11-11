class TripDetailsResponseModel {
  final TripDetailsResult tripDetailsResult;

  TripDetailsResponseModel({required this.tripDetailsResult});

  factory TripDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return TripDetailsResponseModel(
      tripDetailsResult: TripDetailsResult.fromJson(
        json['TripDetailsResponse']['TripDetailsResult'],
      ),
    );
  }
}

class TripDetailsResult {
  final String success;
  final String target;
  final TravelItinerary travelItinerary;

  TripDetailsResult({
    required this.success,
    required this.target,
    required this.travelItinerary,
  });

  factory TripDetailsResult.fromJson(Map<String, dynamic> json) {
    return TripDetailsResult(
      success: json['Success'] ?? '',
      target: json['Target'] ?? '',
      travelItinerary: TravelItinerary.fromJson(json['TravelItinerary']),
    );
  }
}

class TravelItinerary {
  final String bookingStatus;
  final bool crossBorderIndicator;
  final String destination;
  final String fareType;
  final bool isCommissionable;
  final bool isMOFare;
  final ItineraryInfo itineraryInfo;
  final String uniqueID;
  final String origin;
  final String ticketStatus;

  TravelItinerary({
    required this.bookingStatus,
    required this.crossBorderIndicator,
    required this.destination,
    required this.fareType,
    required this.isCommissionable,
    required this.isMOFare,
    required this.itineraryInfo,
    required this.uniqueID,
    required this.origin,
    required this.ticketStatus,
  });

  factory TravelItinerary.fromJson(Map<String, dynamic> json) {
    return TravelItinerary(
      bookingStatus: json['BookingStatus'] ?? '',
      crossBorderIndicator: json['CrossBorderIndicator'] ?? false,
      destination: json['Destination'] ?? '',
      fareType: json['FareType'] ?? '',
      isCommissionable: json['IsCommissionable'] ?? false,
      isMOFare: json['IsMOFare'] ?? false,
      itineraryInfo: ItineraryInfo.fromJson(json['ItineraryInfo']),
      uniqueID: json['UniqueID'] ?? '',
      origin: json['Origin'] ?? '',
      ticketStatus: json['TicketStatus'] ?? '',
    );
  }
}

class ItineraryInfo {
  final List<CustomerInfo> customerInfos;
  final ItineraryPricing itineraryPricing;
  final List<ReservationItem> reservationItems;
  final List<FareBreakdown> fareBreakdowns;
  final List<Service> extraServices;
  final List<dynamic> bookingNotes;

  ItineraryInfo({
    required this.customerInfos,
    required this.itineraryPricing,
    required this.reservationItems,
    required this.fareBreakdowns,
    required this.extraServices,
    required this.bookingNotes,
  });

  factory ItineraryInfo.fromJson(Map<String, dynamic> json) {
    return ItineraryInfo(
      customerInfos: (json['CustomerInfos'] as List)
          .map((e) => CustomerInfo.fromJson(e['CustomerInfo']))
          .toList(),
      itineraryPricing: ItineraryPricing.fromJson(json['ItineraryPricing']),
      reservationItems: (json['ReservationItems'] as List)
          .map((e) => ReservationItem.fromJson(e['ReservationItem']))
          .toList(),
      fareBreakdowns: (json['TripDetailsPTC_FareBreakdowns'] as List)
          .map((e) => FareBreakdown.fromJson(e['TripDetailsPTC_FareBreakdown']))
          .toList(),
      extraServices: (json['ExtraServices']['Services'] as List)
          .map((e) => Service.fromJson(e['Service']))
          .toList(),
      bookingNotes: json['BookingNotes'] ?? [],
    );
  }
}

class CustomerInfo {
  final String passengerType;
  final String passengerFirstName;
  final String passengerLastName;
  final String passengerTitle;
  final int itemRPH;
  final String eTicketNumber;
  final String dateOfBirth;
  final String emailAddress;
  final String? gender;
  final String passengerNationality;
  final String passportNumber;
  final String phoneNumber;
  final String postCode;

  CustomerInfo({
    required this.passengerType,
    required this.passengerFirstName,
    required this.passengerLastName,
    required this.passengerTitle,
    required this.itemRPH,
    required this.eTicketNumber,
    required this.dateOfBirth,
    required this.emailAddress,
    this.gender,
    required this.passengerNationality,
    required this.passportNumber,
    required this.phoneNumber,
    required this.postCode,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      passengerType: json['PassengerType'] ?? '',
      passengerFirstName: json['PassengerFirstName'] ?? '',
      passengerLastName: json['PassengerLastName'] ?? '',
      passengerTitle: json['PassengerTitle'] ?? '',
      itemRPH: json['ItemRPH'] ?? 0,
      eTicketNumber: json['eTicketNumber'] ?? '',
      dateOfBirth: json['DateOfBirth'] ?? '',
      emailAddress: json['EmailAddress'] ?? '',
      gender: json['Gender'],
      passengerNationality: json['PassengerNationality'] ?? '',
      passportNumber: json['PassportNumber'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? '',
      postCode: json['PostCode'] ?? '',
    );
  }
}

class ItineraryPricing {
  final Fare equiFare;
  final Fare serviceTax;
  final Fare tax;
  final Fare totalFare;

  ItineraryPricing({
    required this.equiFare,
    required this.serviceTax,
    required this.tax,
    required this.totalFare,
  });

  factory ItineraryPricing.fromJson(Map<String, dynamic> json) {
    return ItineraryPricing(
      equiFare: Fare.fromJson(json['EquiFare']),
      serviceTax: Fare.fromJson(json['ServiceTax']),
      tax: Fare.fromJson(json['Tax']),
      totalFare: Fare.fromJson(json['TotalFare']),
    );
  }
}

class Fare {
  final String amount;
  final String currencyCode;
  final int decimalPlaces;

  Fare({
    required this.amount,
    required this.currencyCode,
    required this.decimalPlaces,
  });

  factory Fare.fromJson(Map<String, dynamic> json) {
    return Fare(
      amount: json['Amount'] ?? '',
      currencyCode: json['CurrencyCode'] ?? '',
      decimalPlaces: json['DecimalPlaces'] is int
          ? json['DecimalPlaces']
          : int.tryParse(json['DecimalPlaces'] ?? '0') ?? 0,
    );
  }
}

class ReservationItem {
  final String airlinePNR;
  final String arrivalAirportLocationCode;
  final String arrivalDateTime;
  final String baggage;
  final String cabinClassText;
  final String departureAirportLocationCode;
  final String departureDateTime;
  final String flightNumber;

  ReservationItem({
    required this.airlinePNR,
    required this.arrivalAirportLocationCode,
    required this.arrivalDateTime,
    required this.baggage,
    required this.cabinClassText,
    required this.departureAirportLocationCode,
    required this.departureDateTime,
    required this.flightNumber,
  });

  factory ReservationItem.fromJson(Map<String, dynamic> json) {
    return ReservationItem(
      airlinePNR: json['AirlinePNR'] ?? '',
      arrivalAirportLocationCode: json['ArrivalAirportLocationCode'] ?? '',
      arrivalDateTime: json['ArrivalDateTime'] ?? '',
      baggage: json['Baggage'] ?? '',
      cabinClassText: json['CabinClassText'] ?? '',
      departureAirportLocationCode: json['DepartureAirportLocationCode'] ?? '',
      departureDateTime: json['DepartureDateTime'] ?? '',
      flightNumber: json['FlightNumber'] ?? '',
    );
  }
}

class FareBreakdown {
  final String passengerType;
  final int quantity;
  final Fare totalFare;

  FareBreakdown({
    required this.passengerType,
    required this.quantity,
    required this.totalFare,
  });

  factory FareBreakdown.fromJson(Map<String, dynamic> json) {
    return FareBreakdown(
      passengerType: json['PassengerTypeQuantity']['Code'] ?? '',
      quantity: json['PassengerTypeQuantity']['Quantity'] ?? 0,
      totalFare: Fare.fromJson(json['TripDetailsPassengerFare']['TotalFare']),
    );
  }
}

class Service {
  final String description;
  final String serviceId;
  final Fare serviceCost;

  Service({
    required this.description,
    required this.serviceId,
    required this.serviceCost,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      description: json['Description'] ?? '',
      serviceId: json['ServiceId'] ?? '',
      serviceCost: Fare.fromJson(json['ServiceCost']),
    );
  }
}
