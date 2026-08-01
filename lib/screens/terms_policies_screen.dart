import 'package:flutter/material.dart';

class TermsPoliciesScreen extends StatelessWidget {
  const TermsPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Normas y Políticas', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image/Text Card
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Marco Legal y Operativo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Normas de seguridad, privacidad de datos y políticas de uso del ERP DSD-Neo.',
                            style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Terms of Service ExpansionTile
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.description_outlined, color: Colors.teal),
                title: const Text(
                  '1. Términos de Servicio',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      'El uso de esta aplicación móvil está estrictamente reservado a agentes de ventas autorizados y asociados a licencias vigentes del ERP DSD-Neo. '
                      'Toda transacción (checkout) realizada en terreno se considera vinculante en cuanto a la asignación de costos, reserva física de inventario e impuestos vigentes. '
                      'El usuario se compromete a no eludir los mecanismos de seguridad ni utilizar identidades falsas para alterar registros en el sistema central.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Privacy Policy ExpansionTile
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
                title: const Text(
                  '2. Políticas de Privacidad',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      'DSD-Neo Mobile ERP recolecta datos de operaciones móviles (IDs de clientes, cantidades de productos vendidos, referencias y marcas temporales) con el único fin de sincronizar los estados contables del ERP. '
                      'No vendemos ni compartimos datos personales de clientes ni de agentes con terceros no afiliados. '
                      'Las sesiones móviles y credenciales de API Key se almacenan cifradas localmente en el almacenamiento aislado de la aplicación.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Safety Rules ExpansionTile
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.security_rounded, color: Colors.teal),
                title: const Text(
                  '3. Normas de Seguridad',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      'Para salvaguardar la información comercial del sistema:\n\n'
                      '• No comparta su clave de API ni su contraseña con terceros.\n'
                      '• Evite ejecutar la aplicación en dispositivos que posean modificaciones de privilegios a nivel de sistema operativo (Root/Jailbreak).\n'
                      '• Toda petición de red es firmada y rastreada en el ERP central por auditoría interna; el fraude de inventario o alteración deliberada de precios está sujeto a rescisión contractual y acciones legales correspondientes.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Footer info
            Text(
              'Última actualización: 31 de Julio de 2026',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
