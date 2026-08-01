import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de la App', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // App Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            // App Name & Version
            const Text(
              'DSD-Neo Ventas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versión 1.0.0 (Build 20260731)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),

            // Divider
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 24),

            // Description Paragraphs
            const Text(
              'Descripción del Sistema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Esta aplicación móvil es una extensión oficial del ERP de Ventas DSD-Neo. Permite a los agentes comerciales en terreno registrar nuevos pedidos de venta (checkout), consultar existencias en tiempo real, actualizar el estado de procesamiento del stock y gestionar cancelaciones directamente con las bodegas principales de forma instantánea.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Text(
              'Gracias a la integración en tiempo real, los cobros y descuentos de impuestos se procesan de forma inmediata en el servidor central del ERP, evitando descuadres de inventario y optimizando la entrega física del producto.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),

            // Info Card (Developer & Rights)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('Desarrollado por', 'DSD-Neo ERP Team'),
                    const Divider(height: 20),
                    _buildInfoRow('Soporte Técnico', 'soporte@dsdneo.cl'),
                    const Divider(height: 20),
                    _buildInfoRow('Sitio Web Oficial', 'www.dsdneo.cl'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Copyright Footer
            Text(
              '© ${DateTime.now().year} DSD-Neo ERP. Todos los derechos reservados.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
