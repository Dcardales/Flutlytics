import 'chart_concept.dart';

class ChartFilters {
  const ChartFilters({
    this.query = '',
    this.level,
    this.category,
    this.library,
    this.problem = '',
  });

  final String query;
  final ChartLevel? level;
  final ChartCategory? category;
  final ChartLibrary? library;
  final String problem;

  List<ChartConcept> apply(Iterable<ChartConcept> concepts) {
    final needle = query.trim().toLowerCase();
    final problemNeedle = problem.trim().toLowerCase();
    return concepts
        .where((concept) {
          final searchable =
              '${concept.name} ${concept.description} ${concept.tags.join(' ')}'
                  .toLowerCase();
          final problems =
              '${concept.useCase} ${concept.problemSolved} ${concept.recommendedFor} ${concept.category.label}'
                  .toLowerCase();
          return (needle.isEmpty || searchable.contains(needle)) &&
              (level == null || concept.level == level) &&
              (category == null || concept.category == category) &&
              (library == null ||
                  concept.supportedLibraries.contains(library)) &&
              (problemNeedle.isEmpty || problems.contains(problemNeedle));
        })
        .toList(growable: false);
  }
}
