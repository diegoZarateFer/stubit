import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/priority.dart';
import 'package:stubit/screens/task_details_screen.dart';
import 'package:stubit/widgets/dissmisible_backgrounds.dart';
import 'package:stubit/widgets/task_item.dart';

String description = """
  El tablero es tu espacio personal donde puedes organizar tus actividades de manera visual. 
  Aquí podrás crear y gestionar tareas, cambiando su estado a "Pendientes", "En progreso" o "Terminadas"
  según tu avance. Para comenzar, simplemente agrega tu primera actividad haciendo click en el botón "+".
""";

String apology = """
  Lo sentimos mucho pero no se ha podido conectar al servidor.
  Por favor, intentalo de nuevo más tarde.
""";

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  void _showTaskDetails(context, task, taskId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => TaskDetailsScreen(
          taskId: taskId,
          title: task["title"],
          description: task["description"],
          priority: task["priority"],
          status: task["status"],
        ),
      ),
    );
  }

  void _changeTaskStatus(taskId, userId, newStatus) async {
    try {
      await _firestore
          .collection("user_data")
          .doc(userId)
          .collection("tasks")
          .doc(taskId)
          .set({
        "status": newStatus,
      }, SetOptions(merge: true));

      String message = newStatus == "proceso" ? "¡Manos a la obra!": "¡Misión cumplida!";
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Ha ocurrido un error inesperado. Intentalo más tarde."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _deleteTask(taskId, userId) async {
    try {
      await _firestore
          .collection("user_data")
          .doc(userId)
          .collection("tasks")
          .doc(taskId)
          .delete();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tarea eliminada."),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Ha ocurrido un error inesperado. Intentalo más tarde."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid.toString();

    return StreamBuilder(
      stream: _firestore
          .collection("user_data")
          .doc(userId)
          .collection("tasks")
          .snapshots(),
      builder: (ctx, boardSnapshots) {
        if (boardSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!boardSnapshots.hasData || boardSnapshots.data!.docs.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Tablero Stu-Bit',
                  style: GoogleFonts.poppins(
                    fontSize: 31,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }

        if (boardSnapshots.hasError) {
          return Center(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Algo salió mal :(',
                  style: GoogleFonts.poppins(
                    fontSize: 31,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    apology,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }

        final loadedTasks = boardSnapshots.data!.docs;
        final toDoTasks =
            loadedTasks.where((task) => task["status"] == "pendiente").toList();
        final inProgressTasks =
            loadedTasks.where((task) => task["status"] == "proceso").toList();
        final completedTasks = loadedTasks
            .where((task) => task["status"] == "completado")
            .toList();

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Pendientes'),
                  Tab(text: 'En Proceso'),
                  Tab(text: 'Completadas'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    if (toDoTasks.isNotEmpty)
                      ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: toDoTasks.length,
                        itemBuilder: (ctx, index) {
                          final task = toDoTasks[index].data();
                          final taskId = toDoTasks[index].id.toString();
                          final taskPriority = task["priority"];
                          final taskColor = priorityColor[taskPriority];
                          return Dismissible(
                            key: Key(taskId),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                _changeTaskStatus(taskId, userId, "proceso");
                              } else {
                                _deleteTask(taskId, userId);
                              }
                            },
                            background: const DissmisibleBackground(),
                            secondaryBackground:
                                const DissmisibleSecondaryBackground(),
                            child: TaskItem(
                              onTap: () {
                                _showTaskDetails(context, task, taskId);
                              },
                              taskTitle: task["title"],
                              taskColor: taskColor!,
                            ),
                          );
                        },
                      ),
                    if (toDoTasks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            textAlign: TextAlign.center,
                            '¡Muy bien! Parece que no tienes actividades pendientes.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (inProgressTasks.isNotEmpty)
                      ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: inProgressTasks.length,
                        itemBuilder: (ctx, index) {
                          final task = inProgressTasks[index].data();
                          final taskId = inProgressTasks[index].id.toString();
                          final taskPriority = task["priority"];
                          final taskColor = priorityColor[taskPriority];
                          return Dismissible(
                            key: Key(taskId),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                _changeTaskStatus(taskId, userId, "completado");
                              } else {
                                _deleteTask(taskId, userId);
                              }
                            },
                            background: const DissmisibleBackground(),
                            secondaryBackground:
                                const DissmisibleSecondaryBackground(),
                            child: TaskItem(
                              onTap: () {
                                _showTaskDetails(context, task, taskId);
                              },
                              taskTitle: task["title"],
                              taskColor: taskColor!,
                            ),
                          );
                        },
                      ),
                    if (inProgressTasks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Por ahora no tienes ninguna actividad en progreso.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (completedTasks.isNotEmpty)
                      ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: completedTasks.length,
                        itemBuilder: (ctx, index) {
                          final task = completedTasks[index].data();
                          final taskId = completedTasks[index].id.toString();
                          final taskPriority = task["priority"];
                          final taskColor = priorityColor[taskPriority];
                          return Dismissible(
                            key: Key(taskId),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteTask(taskId, userId);
                            },
                            background: const DissmisibleSecondaryBackground(),
                            child: TaskItem(
                              onTap: () {
                                _showTaskDetails(context, task, taskId);
                              },
                              taskTitle: task["title"],
                              taskColor: taskColor!,
                            ),
                          );
                        },
                      ),
                    if (completedTasks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Aquí podrás ver tus actividades completadas.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
