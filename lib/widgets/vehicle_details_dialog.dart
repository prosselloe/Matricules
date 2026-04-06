
import 'package:flutter/material.dart';

class VehicleDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> data;

  const VehicleDetailsDialog({super.key, required this.data});

  String _getValue(String key) => data[key]?.toString() ?? 'N/A';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${_getValue('MARCA')} ${_getValue('MODELO')}',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      content: SizedBox(
        width: 400, // Manté una amplada fixa per al diàleg
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Matriculat el ${_getValue('FECHA_MATRICULACION')}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const Divider(height: 16),
              _infoRow(context, Icons.directions_car_filled, 'Carrosseria', _getValue('CARROCERIA')),
              _infoRow(context, Icons.miscellaneous_services, 'Tipus Motor', _getValue('TPMOTOR')),
              _infoRow(context, Icons.bolt, 'Potència', '${_getValue('KWs')} kW'),
              _infoRow(context, Icons.settings, 'Codi Motor', _getValue('MOTOR')),
              _infoRow(context, Icons.local_gas_station, 'Tipus Combustible', _getValue('TYMOTOR')),
              _infoRow(context, Icons.power, 'Injecció', _getValue('INYECCION')),
              _infoRow(context, Icons.drive_eta, 'Tracció', _getValue('TRACCION')),
              _infoRow(context, Icons.qr_code_scanner, 'VIN', _getValue('VIN')),
              _infoRow(context, Icons.public, 'País', _getValue('PAIS')),
              const SizedBox(height: 12),
              const Text("Identificadors interns", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              _infoRow(context, Icons.tag, 'ID Marca', _getValue('IDMARCA')),
              _infoRow(context, Icons.tag, 'ID Model', _getValue('IDMODELO')),
              _infoRow(context, Icons.tag, 'ID Marca (TecDoc)', _getValue('ID_MARCA_TECDOC')),
              _infoRow(context, Icons.tag, 'ID Model (TecDoc)', _getValue('ID_MODELO_TECDOC')),
              _infoRow(context, Icons.tag, 'ID KType', _getValue('ID_KTYPE')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tancar'),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: <TextSpan>[
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
