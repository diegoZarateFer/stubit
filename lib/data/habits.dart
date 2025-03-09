import 'package:stubit/models/habit.dart';

const habits = [
  //Estudio
  Habit(
    id: "h1",
    name: "Dedicar tiempo al estudio",
    description: "Registrar cuándo y cuánto tiempo se dedica al estudio. ",
    category: "c1",
    strategy: "TF",
  ),
  Habit(
    id: "h2",
    name: "Realizar con mis tareas académicas",
    description: "Crear y cumplir con las tareas académicas.",
    category: "c1",
    strategy: "TF",
  ),
  Habit(
    id: "h3",
    name: "Realizar autoevaluaciones",
    description: "Realizar autoevaluaciones regularmente.",
    category: "c1",
    strategy: "TF",
  ),
  Habit(
    id: "h4",
    name: "Tomar cursos adicionales",
    description:
        "Monitorear el progreso en cursos adicionales o fuentes de aprendizaje extracurriculares.",
    category: "c1",
    strategy: "TF",
  ),

  //Salud y físicos
  Habit(
    id: "h5",
    name: "Hacer ejercicio",
    description: "Hacer ejercicio regularmente.",
    category: "c2",
    strategy: "TF",
  ),
  Habit(
    id: "h6",
    name: "Realizar estiramientos al despertar",
    description: "Realizar estiramientos al despertar.",
    category: "c2",
    strategy: "TF",
  ),
  Habit(
    id: "h7",
    name: "Seguir una dieta balanceada",
    description:
        "Seguir una dieta balanceada que combine todos los grupos de alimentos.",
    category: "c2",
    strategy: "CF",
  ),
  Habit(
    id: "h8",
    name: "Evitar el consumo de tabaco y alcohol",
    description: "Evitar el consumo de tabaco y alcohol.",
    category: "c2",
    strategy: "CF",
  ),
  Habit(
    id: "h9",
    name: "Dormir adecuadamente",
    description: "Dormir de 7 a 9 horas diariamente.",
    category: "c2",
    strategy: "T",
  ),

  // Autocuidado
  Habit(
    id: "h10",
    name: "Meditación",
    description:
        "Practicar la meditación para reducir el estrés y mejorar la concentración.",
    category: "c3",
    strategy: "TF",
  ),
  Habit(
    id: "h11",
    name: "Pasar tiempo al aire libre",
    description: "Pasar tiempo al aire libre para reducir el estrés.",
    category: "c3",
    strategy: "TF",
  ),
  Habit(
    id: "h12",
    name: "Establecer momentos de calma y silencio",
    description:
        "Establecer momentos de calma y silencio para la introspección.",
    category: "c3",
    strategy: "TF",
  ),
  Habit(
    id: "h13",
    name: "Escuchar podcasts o audiolibros.",
    description: "Escuchar podcasts o audiolibros regularmente.",
    category: "c3",
    strategy: "TF",
  ),
  Habit(
    id: "h14",
    name: "Realizar actividades creativas",
    description: "Dedicar tiempo para una actividad creativa.",
    category: "c3",
    strategy: "TF",
  ),

  // Sociales.
  Habit(
    id: "h15",
    name: "Llamar a amigos y familiares",
    description:
        "Llamar, enviar mensajes o visitar a amigos y familiares de manera constante.",
    category: "c4",
    strategy: "CF",
  ),
  Habit(
    id: "h16",
    name: "Iniciar conversaciones con personas nuevas",
    description: "Iniciar conversaciones con personas nuevas.",
    category: "c4",
    strategy: "CF",
  ),
  Habit(
    id: "h17",
    name: "Asistir a eventos sociales",
    description: "Asistir a eventos sociales.",
    category: "c4",
    strategy: "CF",
  ),

  // Mentales.
  Habit(
    id: "h18",
    name: "Practicar la gratitud",
    description:
        "Hacer una lista de las cosas por las que te sientes agradecido este día.",
    category: "c5",
    strategy: "L",
  ),
  Habit(
    id: "h19",
    name: "Evitar la sobreexposición a redes sociales",
    description:
        "Evitar la sobreexposición a redes sociales y limitar el tiempo frente a la televisión o entretenimiento pasivo.",
    category: "c5",
    strategy: "T",
  ),
  Habit(
    id: "h20",
    name: "Dividir el trabajo en bloques de tiempo",
    description:
        "Dividir el trabajo en bloques de tiempo para mantener el enfoque y evitar el agotamiento.",
    category: "c5",
    strategy: "TP",
  ),
  Habit(
    id: "h21",
    name: "Leer",
    description: "Leer sobre algún tema que sea de tu interés.",
    category: "c5",
    strategy: "COF",
    unit: "páginas",
  ),
  Habit(
    id: "h22",
    name: "Resolver rompecabezas o juegos de lógica",
    description:
        "Resolver rompecabezas o juegos de lógica para ejercitar la mente.",
    category: "c5",
    strategy: "COF",
    unit: "rompecabezas",
  ),
];
