import 'package:habuu/data/datasources/streak_data_source.dart';
import 'package:habuu/data/models/streak_data.dart';

/// Fuente de datos de racha controlable para tests.
/// Devuelve los datos configurados en el constructor, o lanza si [shouldFail] es true.
/// [delay] permite simular latencia para probar estados de carga.
class FakeStreakDataSource implements StreakDataSource {
  FakeStreakDataSource({
    StreakData? data,
    this.shouldFail = false,
    this.delay = Duration.zero,
  }) : _data = data ?? const StreakData.empty();

  final StreakData _data;
  bool shouldFail;

  /// Latencia simulada. Con Duration.zero el future resuelve en el mismo microtask.
  Duration delay;

  /// Número de veces que se llamó a [getStreak].
  int getCalls = 0;

  @override
  Future<StreakData> getStreak() async {
    getCalls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (shouldFail) throw Exception('Error simulado de racha');
    return _data;
  }
}
