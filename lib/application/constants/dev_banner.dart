import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Exibe uma faixa indicativa de ambiente de desenvolvimento/local.
class DevBanner extends StatelessWidget {
  final Widget child;
  final String message;
  final Color color;
  final BannerLocation location;

  /// Controle global para ocultar o banner temporariamente (ex: para tirar screenshots limpos).
  static bool isEnabled = true;

  const DevBanner({
    required this.child,
    this.message = 'LOCAL',
    this.color = const Color(
      0xFFD50000,
    ), // Equivalente a Colors.redAccent.shade700
    this.location = BannerLocation.topStart,
    super.key,
  });

  /// Verifica se o banner deve ser exibido baseado no ambiente e na flag global.
  bool get _shouldShowBanner {
    if (!isEnabled) return false;

    if (kIsWeb) {
      final host = Uri.base.host;
      return host == 'localhost' || host == '127.0.0.1';
    }
    return !kReleaseMode;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowBanner) return child;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Banner(
        message: message,
        location: location,
        color: color,
        textStyle: const TextStyle(
          fontWeight:
              FontWeight.w900, // Fonte um pouco mais pesada para melhor leitura
          fontSize: 10.0,
          letterSpacing: 1.2,
          color: Colors.white,
        ),
        child: child,
      ),
    );
  }
}
