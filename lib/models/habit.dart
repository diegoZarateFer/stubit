enum Categories { estudio, fisicos, autocuidado, sociales, mentales }

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.strategy,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String strategy;
}
