import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/core/chart_advisor_app.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_detail_page.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';

void main() {
  testWidgets('Home muestra el asistente y acceso al catálogo', (tester) async {
    await tester.pumpWidget(const ChartAdvisorApp());
    expect(find.text('¿Qué gráfica necesito?'), findsOneWidget);
    expect(find.text('Asistente de gráficas'), findsOneWidget);
    expect(find.text('Catálogo completo'), findsOneWidget);
  });

  testWidgets('chatbot recomienda dispersión tras elegir dos variables', (
    tester,
  ) async {
    await tester.pumpWidget(const ChartAdvisorApp());
    await tester.ensureVisible(find.text('Relacionar variables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Relacionar variables'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Dos variables'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dos variables'));
    await tester.pumpAndSettle();
    expect(find.text('Recomendación: Dispersión'), findsOneWidget);
    expect(find.text('Ver ejemplo'), findsOneWidget);
  });

  testWidgets('catálogo busca y abre detalle', (tester) async {
    await tester.pumpWidget(const ChartAdvisorApp());
    await tester.ensureVisible(find.text('Catálogo completo'));
    await tester.tap(find.text('Catálogo completo'));
    await tester.pumpAndSettle();
    expect(find.text('65 conceptos'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('catalog-search')), 'cascada');
    await tester.pump();
    expect(find.text('1 conceptos'), findsOneWidget);
    await tester.tap(find.text('Cascada'));
    await tester.pumpAndSettle();
    expect(find.text('Problema que resuelve'), findsOneWidget);
  });

  testWidgets('detalle muestra selector y demo de línea', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChartDetailPage(concept: ChartCatalog.byId('line'))),
    );
    expect(find.text('Soporte: Nativo verificado'), findsOneWidget);
    expect(find.byKey(const Key('library-selector')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Ventas mensuales'),
      200,
    );
    expect(find.textContaining('Ventas mensuales'), findsWidgets);
  });

  for (final library in [
    ChartLibrary.flChart,
    ChartLibrary.syncfusion,
    ChartLibrary.graphic,
  ]) {
    for (final id in ['line', 'bar']) {
      for (final width in [320.0, 500.0]) {
        testWidgets('$library renderiza $id a ${width.toInt()} px sin error', (
          tester,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: width,
                  height: 300,
                  child: ChartRenderer.buildChart(
                    concept: ChartCatalog.byId(id),
                    library: library,
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
