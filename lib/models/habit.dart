enum Categories { estudio, fisicos, autocuidado, sociales, mentales }

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final Categories category;
}
