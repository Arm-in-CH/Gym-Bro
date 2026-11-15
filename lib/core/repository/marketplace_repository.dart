import '../../models/marketplace_models.dart';
import '../storage/local_storage_service.dart';

abstract class IMarketplaceRepository {
  Future<List<Gym>> getGyms();
  Future<void> saveGyms(List<Gym> gyms);

  Future<List<Trainer>> getTrainers();
  Future<void> saveTrainers(List<Trainer> trainers);

  Future<List<Booking>> getBookings();
  Future<void> saveBookings(List<Booking> bookings);
  Future<void> saveBooking(Booking booking);
}

class LocalMarketplaceRepository implements IMarketplaceRepository {
  final LocalStorageService storage;

  LocalMarketplaceRepository({required this.storage});

  @override
  Future<List<Gym>> getGyms() async {
    return storage.getGyms();
  }

  @override
  Future<void> saveGyms(List<Gym> gyms) async {
    await storage.saveGyms(gyms);
  }

  @override
  Future<List<Trainer>> getTrainers() async {
    return storage.getTrainers();
  }

  @override
  Future<void> saveTrainers(List<Trainer> trainers) async {
    await storage.saveTrainers(trainers);
  }

  @override
  Future<List<Booking>> getBookings() async {
    return storage.getBookings();
  }

  @override
  Future<void> saveBookings(List<Booking> bookings) async {
    await storage.saveBookings(bookings);
  }

  @override
  Future<void> saveBooking(Booking booking) async {
    await storage.saveBooking(booking);
  }
}
