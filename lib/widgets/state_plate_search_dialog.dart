import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:matricules/providers/model_provider.dart';

class StatePlateSearchDialog extends StatefulWidget {
  final String? initialValue;
  const StatePlateSearchDialog({super.key, this.initialValue});

  @override
  State<StatePlateSearchDialog> createState() => _StatePlateSearchDialogState();
}

class _StatePlateSearchDialogState extends State<StatePlateSearchDialog> {
  final _plateNumberController = TextEditingController();
  Map<String, dynamic>? _searchResultData;
  String? _errorText;

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
    final result = modelProvider.searchByNationalPlate(_plateNumberController.text.trim());

    if (result.containsKey('error')) {
      setState(() {
        _searchResultData = null;
        _errorText = result['error'];
      });
    } else {
      setState(() {
        _searchResultData = result;
        _errorText = null;
      });
    }
  }

  void _showPlateInformationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informació sobre les Matrícules Estatals'),
        content: const SingleChildScrollView(
          child: Text(
            '''**Sistema Estatal (2000-Actualitat):**
Format: 1234 ABC

- Quatre números seguits de tres lletres.
- Les lletres no inclouen vocals, ni les lletres Ñ o Q.

**Numeració:**
El sistema de numeració de les matrícules estatals es basa en una combinació de 
tres lletres que van avançant de manera progressiva. Les lletres utilitzades són 
les consonants, excloent la Ñ i la Q per evitar confusions. La primera combinació 
és 'BBB' i l'última és 'ZZZ'.
'''),
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

  @override
  Widget build(BuildContext context) {
    final numberFormatter = intl.NumberFormat('#,##0', 'es_ES');
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Cerca de Matrícules Estatals'),
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
              'Introdueix la matrícula estatal (p. ex., 1234 ABC).',
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
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/spain.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            if (_searchResultData != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _searchResultData!.entries.map((entry) {
                    if (entry.key.startsWith('Matrícules provincials') && entry.value is List) {
                      final year = entry.key.replaceAll(RegExp(r'[^0-9]'), '');
                      final provincialEquivalents = entry.value as List;
                      return ExpansionTile(
                        initiallyExpanded: false,
                        title: Text(
                          'Veure detall Provincial (Any $year)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: provincialEquivalents.map((item) {
                          final equivalent = item as Map<String, String>;
                          final plateNumber = int.tryParse(equivalent['plate'] ?? '') ?? 0;
                          final flagUrl = equivalent['flagUrl'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (flagUrl.isNotEmpty)
                                        Image.asset(
                                          flagUrl,
                                          width: 30,
                                          height: 20,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const SizedBox(width: 30),
                                        )
                                      else
                                        const SizedBox(width: 30),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${equivalent['province']}:',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  numberFormatter.format(plateNumber),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
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
                            child: Text('${entry.value}'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
      ],
    );
  }
}
