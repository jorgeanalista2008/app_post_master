import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPaymentStatus;

  const StatusBadge({
    super.key,
    required this.status,
    this.isPaymentStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    final normalizedStatus = status.toLowerCase().trim();

    if (isPaymentStatus) {
      switch (normalizedStatus) {
        case 'paid':
          color = Colors.teal;
          label = 'Pagado';
          break;
        case 'partial':
          color = Colors.amber.shade700;
          label = 'Pago Parcial';
          break;
        case 'pending':
        default:
          color = Colors.redAccent;
          label = 'Pago Pendiente';
          break;
      }
    } else {
      switch (normalizedStatus) {
        case 'completed':
          color = Colors.teal;
          label = 'Completado';
          break;
        case 'packing':
          color = Colors.orange;
          label = 'Empacando';
          break;
        case 'shipped':
          color = Colors.indigo;
          label = 'Enviado';
          break;
        case 'pending':
        default:
          color = Colors.blueGrey;
          label = 'Pendiente';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
