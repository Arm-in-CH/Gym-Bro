class IdGenerator {
  static int _counter = 0;

  /// Generates a guaranteed unique, URL-safe, time-ordered identifier.
  static String generate(String prefix) {
    final now = DateTime.now().microsecondsSinceEpoch;
    _counter = (_counter + 1) % 100000;
    return '${prefix}_${now}_$_counter';
  }

  /// Specialized generator for workout plans
  static String plan() => generate('plan');

  /// Specialized generator for workout plan exercises
  static String planExercise() => generate('pe');

  /// Specialized generator for workout session logs
  static String workoutLog() => generate('wlog');

  /// Specialized generator for individual set logs
  static String setLog() => generate('set');

  /// Specialized generator for exercises
  static String exercise() => generate('ex');
}
