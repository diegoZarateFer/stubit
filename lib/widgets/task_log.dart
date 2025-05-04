import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stubit/screens/task_details_screen.dart';
import 'package:stubit/widgets/apology.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class TaskLog extends StatefulWidget {
  const TaskLog({
    super.key,
    required this.selectedDay,
  });

  final DateTime selectedDay;

  @override
  State<TaskLog> createState() => _TaskLogState();
}

class _TaskLogState extends State<TaskLog> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  Color _getTaskColor(String priority) {
    return priority == 'alta'
        ? Colors.red
        : priority == 'media'
            ? Colors.yellow
            : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final userId = _currentUser.uid.toString();
    final date = DateFormat('yyyy-MM-dd').format(widget.selectedDay);

    return StreamBuilder(
      stream: _firestore
          .collection("user_data")
          .doc(userId)
          .collection("tasks")
          .where(
            "date",
            isEqualTo: date,
          )
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Apology(
            message:
                "Lo sentimos, no hemos podido cargar el registro de este día. Inténtalo de nuevo más tarde.",
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text("No hay tareas para este día."),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (ctx, index) {
            final task = docs[index].data();
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => TaskDetailsScreen(
                      taskId: docs[index].id,
                      title: task['title'],
                      description: task['description'],
                      priority: task['priority'],
                      date: DateTime.parse(task['date']),
                      status: task['status'],
                    ),
                  ),
                );

                Navigator.of(context).pop();
              },
              child: ListTile(
                leading: Icon(
                  Icons.circle,
                  color: _getTaskColor(task['priority']),
                ),
                title: Text(task["title"] ?? "Sin título"),
              ),
            );
          },
        );
      },
    );
  }
}
