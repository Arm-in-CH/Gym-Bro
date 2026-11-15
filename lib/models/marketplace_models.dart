import '../core/storage/safe_cast.dart';

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  String get displayNameFa {
    switch (this) {
      case BookingStatus.pending:
        return 'در انتظار تایید';
      case BookingStatus.confirmed:
        return 'تایید شده (در نوبت)';
      case BookingStatus.completed:
        return 'انجام شد و بسته شد';
      case BookingStatus.cancelled:
        return 'لغو شده';
    }
  }

  bool canTransitionTo(BookingStatus next) {
    switch (this) {
      case BookingStatus.pending:
        return next == BookingStatus.confirmed ||
            next == BookingStatus.cancelled;
      case BookingStatus.confirmed:
        return next == BookingStatus.completed ||
            next == BookingStatus.cancelled;
      case BookingStatus.completed:
      case BookingStatus.cancelled:
        return false;
    }
  }

  static BookingStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class Gym {
  final String id;
  final String name;
  final String address;
  final String district;
  final double latitude;
  final double longitude;
  final int monthlyFeeToman;
  final double rating;
  final int reviewCount;
  final List<String> amenities;

  Gym({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.monthlyFeeToman,
    required this.rating,
    required this.reviewCount,
    required this.amenities,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'district': district,
        'latitude': latitude,
        'longitude': longitude,
        'monthlyFeeToman': monthlyFeeToman,
        'rating': rating,
        'reviewCount': reviewCount,
        'amenities': amenities,
      };

  factory Gym.fromJson(Map<String, dynamic> json) => Gym(
        id: SafeCast.toStringVal(json['id']),
        name: SafeCast.toStringVal(json['name']),
        address: SafeCast.toStringVal(json['address']),
        district: SafeCast.toStringVal(json['district']),
        latitude: SafeCast.toDouble(json['latitude'], 35.7),
        longitude: SafeCast.toDouble(json['longitude'], 51.4),
        monthlyFeeToman: SafeCast.toInt(json['monthlyFeeToman'], 0),
        rating: SafeCast.toDouble(json['rating'], 4.8),
        reviewCount: SafeCast.toInt(json['reviewCount'], 0),
        amenities: (json['amenities'] as List<dynamic>?)
                ?.map((e) => SafeCast.toStringVal(e))
                .toList() ??
            [],
      );
}

class Trainer {
  final String id;
  final String name;
  final String title;
  final String specialty;
  final String bio;
  final int hourlyRateToman;
  final String sessionType;
  final double rating;
  final int reviewCount;

  Trainer({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.bio,
    required this.hourlyRateToman,
    required this.sessionType,
    required this.rating,
    required this.reviewCount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'specialty': specialty,
        'bio': bio,
        'hourlyRateToman': hourlyRateToman,
        'sessionType': sessionType,
        'rating': rating,
        'reviewCount': reviewCount,
      };

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        id: SafeCast.toStringVal(json['id']),
        name: SafeCast.toStringVal(json['name']),
        title: SafeCast.toStringVal(json['title']),
        specialty: SafeCast.toStringVal(json['specialty']),
        bio: SafeCast.toStringVal(json['bio']),
        hourlyRateToman: SafeCast.toInt(json['hourlyRateToman'], 0),
        sessionType: SafeCast.toStringVal(json['sessionType'], 'Both'),
        rating: SafeCast.toDouble(json['rating'], 4.9),
        reviewCount: SafeCast.toInt(json['reviewCount'], 0),
      );
}

class Booking {
  final String id;
  final String trainerId;
  final String trainerName;
  final String date;
  final String timeSlot;
  final String sessionType;
  BookingStatus status;
  final int priceToman;
  final int commissionToman;

  Booking({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.date,
    required this.timeSlot,
    required this.sessionType,
    this.status = BookingStatus.pending,
    required this.priceToman,
    required this.commissionToman,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'trainerId': trainerId,
        'trainerName': trainerName,
        'date': date,
        'timeSlot': timeSlot,
        'sessionType': sessionType,
        'status': status.name,
        'priceToman': priceToman,
        'commissionToman': commissionToman,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: SafeCast.toStringVal(json['id']),
        trainerId: SafeCast.toStringVal(json['trainerId']),
        trainerName: SafeCast.toStringVal(json['trainerName']),
        date: SafeCast.toStringVal(json['date']),
        timeSlot: SafeCast.toStringVal(json['timeSlot']),
        sessionType: SafeCast.toStringVal(json['sessionType']),
        status:
            BookingStatus.fromString(SafeCast.toStringVal(json['status'], 'pending')),
        priceToman: SafeCast.toInt(json['priceToman'], 0),
        commissionToman: SafeCast.toInt(json['commissionToman'], 0),
      );
}
