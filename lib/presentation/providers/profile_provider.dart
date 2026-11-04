import 'package:flutter/foundation.dart';

import '../../data/datasources/profile_data_source.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

enum ProfileStatus { initial, loading, ready, error }

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;

  ProfileStatus _status = ProfileStatus.initial;
  UserProfile? _profile;
  bool _isSaving = false;
  String? _errorMessage;
  bool _disposed = false;

  ProfileStatus get status => _status;
  UserProfile? get profile => _profile;
  bool get isSaving => _isSaving;

  /// Mensaje del último error, al cargar o al guardar.
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load() async {
    if (_status == ProfileStatus.loading) return;
    _status = ProfileStatus.loading;
    _errorMessage = null;
    _notify();

    try {
      _profile = await _repository.getProfile();
      _status = ProfileStatus.ready;
    } catch (e) {
      _errorMessage = _messageFor(e, 'No se pudo cargar tu perfil');
      _status = ProfileStatus.error;
    } finally {
      _notify();
    }
  }

  /// Devuelve true si se guardó. Si falla, el perfil queda como estaba.
  Future<bool> save(UserProfile updated) async {
    if (_isSaving || _profile == null) return false;
    _isSaving = true;
    _errorMessage = null;
    _notify();

    try {
      _profile = await _repository.saveProfile(updated);
      return true;
    } catch (e) {
      _errorMessage = _messageFor(e, 'No se pudieron guardar los cambios');
      return false;
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  String _messageFor(Object error, String fallback) {
    if (error is ProfileDataException) return error.message;
    debugPrint('ProfileProvider error: ${error.runtimeType}');
    return fallback;
  }

  /// Al cerrar sesión el provider se descarta, aunque haya una llamada en
  /// curso que después intente avisar.
  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
