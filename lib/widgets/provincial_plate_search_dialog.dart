import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matricules/providers/model_provider.dart';
import 'package:matricules/services/plate_api_service.dart';
import 'package:matricules/widgets/vehicle_details_dialog.dart'; // Canvi aquí

class ProvincialPlateSearchDialog extends StatefulWidget {
  final String? initialValue;
  const ProvincialPlateSearchDialog({super.key, this.initialValue});

  @override
  State<ProvincialPlateSearchDialog> createState() => _ProvincialPlateSearchDialogState();
}

class _ProvincialPlateSearchDialogState extends State<ProvincialPlateSearchDialog> {
  final _plateNumberController = TextEditingController();
  Map<String, dynamic>? _searchResultData;
  String? _errorText;
  int _flagClickCount = 0;
  bool _showDetailsButton = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _plateNumberController.text = widget.initialValue!;
      _searchPlate();
    }
  }

  void _searchPlate() {
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);
    final result = modelProvider.searchByProvincialPlate(_plateNumberController.text.trim());

    if (result.containsKey('error')) {
      setState(() {
        _searchResultData = null;
        _errorText = result['error'];
      });
    } else {
      setState(() {
        _searchResultData = result;
        _errorText = null;
        _flagClickCount = 0;
        _showDetailsButton = false;
      });
    }
  }

  void _showPlateInformationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informació sobre les Matrícules Provincials'),
        content: const SingleChildScrollView(
          child: Text(
            '''**Sistema Numèric (1900-1971):**
Una, dues o tres lletres que representen la província, seguides de fins a sis números (p. ex., B 123456).

**Sistema Alfanumèric (1971-2000):**
La sigla provincial, quatre números i una o dues lletres al final (p. ex., M 1234 AB).

**Validacions Alfanumèriques:**
- **Una lletra:** No es fan servir les vocals, ni Ñ, Q, R.
- **Dues lletres:**
  - La primera lletra no pot ser Ñ, Q, R.
  - La segona lletra no pot ser A, E, I, O, Ñ, Q, R.
- La combinació "WC" no està permesa.'''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }

  void _handleViewDetails() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final details = await PlateApiService().fetchDetails(_plateNumberController.text);

    if (!mounted) return;

    Navigator.pop(context);

    if (details != null) {
      showDialog(
        context: context,
        builder: (context) => VehicleDetailsDialog(data: details), // Canvi aquí
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No s\'han trobat detalls per a aquesta matrícula.')),
      );
    }
  }

  void _onFlagTapped() {
    setState(() {
      _flagClickCount++;
      if (_flagClickCount >= 7) {
        _showDetailsButton = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Cerca de Matrícules Provincials'),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPlateInformationDialog(context),
            tooltip: 'Informació sobre matrícules',
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Introdueix la matrícula provincial (p. ex., B 123456, M 1234 AB).',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _plateNumberController,
              decoration: InputDecoration(
                hintText: 'Introdueix la matrícula',
                errorText: _errorText,
              ),
              keyboardType: TextInputType.text,
            ),
            if (_searchResultData != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    if (_searchResultData!['flagUrl'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: GestureDetector(
                          onTap: _onFlagTapped,
                          child: Image.asset(
                            _searchResultData!['flagUrl'],
                            height: 100,
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ..._searchResultData!.entries.map((entry) {
                      final bool isModelLink = entry.key == 'Província';
                      final bool isIdField = entry.key == 'id';
                      final bool isFlagField = entry.key == 'flagUrl';

                      if (isIdField || isFlagField) return Container();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: isModelLink
                                  ? GestureDetector(
                                      onTap: () {
                                        final provinceName = _searchResultData!['Província'];
                                        Navigator.of(context).pop();
                                        Provider.of<ModelProvider>(context, listen: false).filterByProvince(provinceName);
                                      },
                                      child: Text(
                                        '${entry.value}',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      '${entry.value}',
                                    ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tancar'),
        ),
        ElevatedButton(
          onPressed: _searchPlate,
          child: const Text('Cercar'),
        ),
        if (_searchResultData != null && _showDetailsButton) ...[
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _handleViewDetails,
            icon: const Icon(Icons.directions_car),
            label: const Text('Veure detalls tècnics'),
          ),
          ]
      ],
    );
  }
}
