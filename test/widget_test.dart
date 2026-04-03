import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:matricules/main.dart';
import 'package:matricules/providers/model_provider.dart';

void main() {
  testWidgets('App loads and displays model list', (WidgetTester tester) async {
    // Envolvemos VWClassicsApp con los Providers necesarios para el test
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => ModelProvider()),
        ],
        child: const MatriculesApp(), // Usamos el nombre correcto del widget principal
      ),
    );

    // Verificamos que se muestra un indicador de carga inicialmente
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Esperamos a que los datos se carguen y la UI se reconstruya
    await tester.pumpAndSettle();

    // Verificamos que se muestra al menos un modelo (p. ej., Beetle)
    expect(find.text('Beetle'), findsOneWidget);
  });
}
