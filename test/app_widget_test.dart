import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/core/chart_advisor_app.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_detail_page.dart';
import 'package:flutlytics_v1/features/charts/presentation/catalog_page.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/comparison/comparison_page.dart';

void main() {
  testWidgets('Home muestra el asistente y acceso al catálogo', (tester) async {
    await tester.pumpWidget(const FlutlyticsApp());
    expect(find.text('Flutlytics'), findsOneWidget);
    expect(
      find.text('Encuentra la gráfica ideal para tus datos'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Asistente de visualizaciones'));
    expect(find.text('Catálogo'), findsOneWidget);
  });

  testWidgets('chatbot recomienda dispersión tras elegir dos variables', (
    tester,
  ) async {
    await tester.pumpWidget(const FlutlyticsApp());
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
    await tester.pumpWidget(const FlutlyticsApp());
    await tester.tap(find.text('Catálogo'));
    await tester.pumpAndSettle();
    expect(find.text('65 visualizaciones'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('catalog-search')), 'cascada');
    await tester.pump();
    expect(find.text('1 visualizaciones'), findsOneWidget);
    await tester.tap(find.text('Cascada'));
    await tester.pumpAndSettle();
    expect(find.text('Problema que resuelve'), findsOneWidget);
  });

  testWidgets('detalle muestra selector y demo de línea', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChartDetailPage(concept: ChartCatalog.byId('line'))),
    );
    await tester.scrollUntilVisible(
      find.text('Soporte: Nativo verificado'),
      200,
    );
    expect(find.text('Soporte: Nativo verificado'), findsOneWidget);
    expect(find.byKey(const Key('library-selector')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Ventas mensuales'),
      200,
    );
    expect(find.textContaining('Ventas mensuales'), findsWidgets);
  });

  for (final width in [320.0, 500.0]) {
    testWidgets('Home y catálogo funcionan a ${width.toInt()} px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const FlutlyticsApp());
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Recomiéndame una gráfica'));
      await tester.pumpAndSettle();
      expect(find.text('Asistente de visualizaciones'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Asistente de visualizaciones')).dy,
        inInclusiveRange(0, 720),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const MaterialApp(home: CatalogPage()));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('catalog-filters')));
      await tester.pumpAndSettle();
      expect(find.text('Filtros'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Avanzadas'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('25 visualizaciones'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Detalle y comparación funcionan a ${width.toInt()} px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(home: ChartDetailPage(concept: ChartCatalog.byId('line'))),
      );
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byKey(const Key('library-selector')),
        200,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const MaterialApp(home: ComparisonPage()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

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
