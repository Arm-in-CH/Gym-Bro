import '../../models/timer_settings.dart';
import '../storage/local_storage_service.dart';

abstract class ISettingsRepository {
  Future<TimerSettings> getTimerSettings();
  Future<void> saveTimerSettings(TimerSettings settings);

  Future<String> getGeminiApiKey();
  Future<void> saveGeminiApiKey(String key);

  Future<String> getGeminiModel();
  Future<void> saveGeminiModel(String model);

  Future<String> getOpenRouterApiKey();
  Future<void> saveOpenRouterApiKey(String key);
}

class LocalSettingsRepository implements ISettingsRepository {
  final LocalStorageService storage;

  LocalSettingsRepository({required this.storage});

  @override
  Future<TimerSettings> getTimerSettings() async {
    return storage.getTimerSettings();
  }

  @override
  Future<void> saveTimerSettings(TimerSettings settings) async {
    await storage.saveTimerSettings(settings);
  }

  @override
  Future<String> getGeminiApiKey() async {
    return storage.getGeminiApiKey();
  }

  @override
  Future<void> saveGeminiApiKey(String key) async {
    await storage.saveGeminiApiKey(key);
  }

  @override
  Future<String> getGeminiModel() async {
    return storage.getGeminiModel();
  }

  @override
  Future<void> saveGeminiModel(String model) async {
    await storage.saveGeminiModel(model);
  }

  @override
  Future<String> getOpenRouterApiKey() async {
    return storage.getOpenRouterApiKey();
  }

  @override
  Future<void> saveOpenRouterApiKey(String key) async {
    await storage.saveOpenRouterApiKey(key);
  }
}
