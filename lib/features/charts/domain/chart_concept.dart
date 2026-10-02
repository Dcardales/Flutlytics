enum ChartLevel { basic, advanced }

enum ChartLibrary { flChart, syncfusion, graphic, graphify }

enum ChartSupportType { native, custom, simulated, unsupported }

class ChartDataProfile {
  const ChartDataProfile({
    required this.fields,
    required this.variableCount,
    required this.structure,
    this.invariant,
  });

  final List<String> fields;
  final int variableCount;
  final String structure;
  final String? invariant;
}

enum ChartCategory {
  comparison,
  temporal,
  composition,
  distribution,
  correlation,
  hierarchy,
  geospatial,
  financial,
  multidimensional,
  network,
  projectManagement,
  statistical,
  performance,
}

extension ChartLabels on ChartLevel {
  String get label => this == ChartLevel.basic ? 'Básica' : 'Avanzada';
}

extension ChartLibraryLabels on ChartLibrary {
  String get label => switch (this) {
    ChartLibrary.flChart => 'FL Chart',
    ChartLibrary.syncfusion => 'Syncfusion',
    ChartLibrary.graphic => 'Graphic',
    ChartLibrary.graphify => 'Graphify',
  };
}

extension ChartCategoryLabels on ChartCategory {
  String get label => switch (this) {
    ChartCategory.comparison => 'Comparación',
    ChartCategory.temporal => 'Evolución temporal',
    ChartCategory.composition => 'Composición',
    ChartCategory.distribution => 'Distribución',
    ChartCategory.correlation => 'Correlación',
    ChartCategory.hierarchy => 'Jerarquías',
    ChartCategory.geospatial => 'Geografía',
    ChartCategory.financial => 'Finanzas',
    ChartCategory.multidimensional => 'Múltiples dimensiones',
    ChartCategory.network => 'Relaciones',
    ChartCategory.projectManagement => 'Planificación',
    ChartCategory.statistical => 'Estadística',
    ChartCategory.performance => 'Rendimiento',
  };
}

extension ChartSupportLabels on ChartSupportType {
  String get label => switch (this) {
    ChartSupportType.native => 'Nativo verificado',
    ChartSupportType.custom => 'Personalizado',
    ChartSupportType.simulated => 'Simulado',
    ChartSupportType.unsupported => 'Sin soporte verificado',
  };
}

class ChartConcept {
  const ChartConcept({
    required this.id,
    required this.name,
    required this.level,
    required this.category,
    required this.description,
    required this.useCase,
    required this.problemSolved,
    required this.dataProfile,
    required this.tags,
    required this.recommendedFor,
    required this.avoidWhen,
    required this.support,
    this.compatibleCombinations = const [],
  });

  final String id;
  final String name;
  final ChartLevel level;
  final ChartCategory category;
  final String description;
  final String useCase;
  final String problemSolved;
  final ChartDataProfile dataProfile;
  final List<String> tags;
  final String recommendedFor;
  final String avoidWhen;
  final Map<ChartLibrary, ChartSupportType> support;
  final List<String> compatibleCombinations;

  String get slug => id;
  List<String> get dataTypes => dataProfile.fields;
  int get variablesCount => dataProfile.variableCount;
  List<ChartLibrary> get supportedLibraries => ChartLibrary.values
      .where((library) => support[library] != ChartSupportType.unsupported)
      .toList();
}
