import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';

import 'create_habit_custom2.dart'; // Asegúrate de importar tu pantalla aquí

final pages = [
  const PageData(
    icon: Icons.add,
    title:
        "Con Stu-Bit, adquiere nuevos hábitos de forma fácil y efectiva. Elige entre nuestras 7 técnicas y adapta la que mejor se ajuste a ti. ¡Empieza a transformar tu vida hoy!",
    imagePath: "assets/images/habito1.png",
    bgColor: Color.fromRGBO(139, 34, 227, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.hourglass_bottom,
    title: "Técnica Pomodoro",
    resume:
        "La Técnica Pomodoro ayuda a mejorar la productividad dividiendo el trabajo en intervalos de trabajo con descansos cortos.",
    imagePath: "assets/images/pomodoro.png",
    bgColor: Color.fromRGBO(255, 255, 255, 1),
    textColor: Color.fromRGBO(0, 0, 0, 1),
  ),
  const PageData(
    icon: Icons.calendar_month,
    title: "Por cuestionario y frecuencia",
    resume:
        "Recomendado para hábitos en los que es importante definir los días de práctica y, al registrarlos, responder un cuestionario para reflexionar sobre la actividad.",
    imagePath: "assets/images/cuestiofrec.png",
    bgColor: Color.fromRGBO(0, 0, 0, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.watch_later,
    title: "Por tiempo",
    resume:
        "Esta técnica es recomendada para actividades que deben realizarse sí o sí durante el día, donde la única variable es el tiempo, como es el caso de dormir 8 horas al día",
    imagePath: "assets/images/tiempo.png",
    bgColor: Color.fromRGBO(139, 34, 227, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.today,
    title: "Por tiempo y frecuencia",
    resume:
        "Esta técnica es recomendada para actividades en las que es importante definir el tiempo que se quiere dedicar y los días en los que se desea realizarlas.",
    imagePath: "assets/images/frecunciacuest.png",
    bgColor: Color.fromRGBO(255, 255, 255, 1),
    textColor: Color.fromRGBO(0, 0, 0, 1),
  ),
  const PageData(
    icon: Icons.fact_check,
    title: "Por frecuencia y lista",
    resume:
        "Esta técnica es recomendada para actividades que deben realizarse sí o sí durante el día, donde la única variable es el tiempo, como es el caso de dormir 8 horas al día",
    imagePath: "assets/images/lista.png",
    bgColor: Color.fromRGBO(0, 0, 0, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.exposure_plus_1,
    title: "Por frecuencia y cuantitativamente",
    resume:
        "Esta técnica es recomendada para actividades en las que es necesario contar repeticiones por día, como al contabilizar hojas, botellas, entre otros.",
    imagePath: "assets/images/contador.png",
    bgColor: Color.fromRGBO(255, 255, 255, 1),
    textColor: Color.fromRGBO(0, 0, 0, 1),
  ),
  const PageData(
    icon: Icons.watch_later,
    title: "Comencemos",
    bgColor: Color.fromRGBO(139, 34, 227, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  )
];

class ConcentricAnimationOnboarding extends StatelessWidget {
  const ConcentricAnimationOnboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3), // visual center
          child: Icon(
            Icons.navigate_next,
            size: screenWidth * 0.08,
          ),
        ),
        itemBuilder: (index) {
          final page = pages[index % pages.length];

          // Si es el último índice, redirige a la nueva pantalla
          if (index == pages.length - 1) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HeroListPage()),
              );
            });
          }

          return SafeArea(
            child: _Page(page: page),
          );
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final String? resume;
  final IconData? icon;
  final String? imagePath;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.resume,
    this.icon,
    this.imagePath,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.all(12.0),
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: page.textColor),
          child: Icon(
            page.icon,
            size: screenHeight * 0.08, // Ícono más pequeño
            color: page.bgColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            page.title ?? "",
            style: TextStyle(
              color: page.textColor,
              fontSize: screenHeight * 0.025, // Texto más pequeño
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (page.resume != null) // Muestra el resumen solo si existe
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              page.resume!,
              style: TextStyle(
                color: page.textColor.withOpacity(0.7),
                fontSize:
                    screenHeight * 0.02, // Resume más pequeño que el título
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (page.imagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Image.asset(
              page.imagePath!,
              width: screenHeight * 0.2, // Imagen más pequeña
            ),
          ),
      ],
    );
  }
}
