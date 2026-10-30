import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Monitora somente o GPS em primeiro plano enquanto a Home estiver aberta.
/// Não armazena nem envia coordenadas a um servidor do 67 Delivery.
class LiveLocation extends ChangeNotifier {
  String address = 'Toque para ativar GPS';
  String detail = 'Localização em tempo real';
  Position? position;
  bool active = false;
  bool loading = false;
  String? error;
  StreamSubscription<Position>? _stream;
  DateTime? _lastLookup;
  Position? _lastAddressPosition;
  final Geocoding _geocoding = Geocoding(locale: const Locale('pt', 'BR'));

  Future<void> start() async {
    if (loading || active) return;
    loading = true; error = null; notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Ative a localização nas configurações do tablet.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw StateError('Permissão bloqueada. Abra as configurações do app.');
      }
      if (permission == LocationPermission.denied) {
        throw StateError('Autorize o acesso à localização para usar o GPS.');
      }
      active = true;
      address = 'Buscando endereço...';
      detail = 'GPS ativo';
      _stream?.cancel();
      _stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20,
        ),
      ).listen(_onPosition, onError: (Object e) {
        active = false; error = 'Sinal GPS indisponível: $e'; notifyListeners();
      });
      final latest = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 16)),
      );
      _onPosition(latest);
    } catch (e) {
      error = e.toString().replaceFirst('Bad state: ', '');
      active = false;
      address = 'Localização indisponível';
      detail = 'Toque para tentar novamente';
    } finally {
      loading = false; notifyListeners();
    }
  }

  void _onPosition(Position value) {
    position = value;
    detail = '${value.latitude.toStringAsFixed(5)}, ${value.longitude.toStringAsFixed(5)} • GPS';
    notifyListeners();
    final now = DateTime.now();
    if (_lastLookup != null && now.difference(_lastLookup!) < const Duration(seconds: 30)) return;
    if (_lastAddressPosition != null && Geolocator.distanceBetween(
      _lastAddressPosition!.latitude, _lastAddressPosition!.longitude,
      value.latitude, value.longitude,
    ) < 65) return;
    _lastLookup = now;
    _lastAddressPosition = value;
    _resolveAddress(value);
  }

  Future<void> _resolveAddress(Position value) async {
    try {
      final places = await _geocoding.placemarkFromCoordinates(value.latitude, value.longitude);
      if (places.isEmpty) return;
      final p = places.first;
      final street = [p.street, p.subLocality]
          .where((s) => s != null && s.trim().isNotEmpty).join(' • ');
      final city = [p.subAdministrativeArea, p.administrativeArea]
          .where((s) => s != null && s.trim().isNotEmpty).join(' / ');
      address = street.isNotEmpty ? street : (p.locality?.isNotEmpty == true ? p.locality! : 'Minha localização');
      detail = city.isNotEmpty ? '$city • GPS em tempo real' : 'GPS em tempo real';
      notifyListeners();
    } catch (_) {
      address = 'Minha localização';
      // As coordenadas continuam disponíveis mesmo sem serviço de endereços.
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _stream?.cancel(); _stream = null;
    active = false; position = null;
    address = 'Localização pausada'; detail = 'Toque para ativar GPS';
    notifyListeners();
  }

  @override
  void dispose() { _stream?.cancel(); super.dispose(); }
}
