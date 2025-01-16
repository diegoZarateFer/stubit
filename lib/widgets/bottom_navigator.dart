import 'package:flutter/material.dart';

class BottomNavigator extends StatelessWidget {
  const BottomNavigator({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: TabBar(
        controller: tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(
            icon: Icon(Icons.home),
            text: 'Página Principal',
          ),
          Tab(icon: Icon(Icons.calendar_today), text: 'Tablero de Actividades'),
        ],
      ),
    );
  }
}
