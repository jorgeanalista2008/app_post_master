import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final String title;

  const ErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.title = 'Ups, algo salió mal',
  });

  @override
  Widget build(BuildContext context) {
    final bool isAuthError = errorMessage.contains('No autorizado') || 
                            errorMessage.contains('401');
    final bool isConnectionError = errorMessage.contains('conexión') || 
                                   errorMessage.contains('SocketException') ||
                                   errorMessage.contains('500');

    IconData iconData = Icons.error_outline_rounded;
    Color color = Colors.redAccent;

    if (isAuthError) {
      iconData = Icons.lock_outline_rounded;
      color = Colors.amber.shade800;
    } else if (isConnectionError) {
      iconData = Icons.wifi_off_rounded;
      color = Colors.blueGrey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 60,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isAuthError ? 'Error de Autenticación' : title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Reintentar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
