import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stubit/screens/auth_wrapper.dart';

final pages = [
  const PageData(
    icon: Icons.add,
    title: "Bienvenido",
    resume:
        "Con Stu-Bit, adquiere nuevos hábitos de forma fácil y efectiva. Elige entre nuestras 7 técnicas y adapta la que mejor se ajuste a ti. ¡Empieza a transformar tu vida hoy!",
    imagePath: "assets/images/habito1.png",
    bgColor: Color.fromRGBO(139, 34, 227, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.local_fire_department,
    title: "Racha",
    resume:
        "No pierdas tu racha. Registra tu hábito según tu objetivo y mantén el progreso día a día. Si la pierdes, podrás recuperarla usando gemas. ¡Sigue avanzando!",
    imagePath: "assets/images/firee.png",
    bgColor: Color.fromRGBO(255, 255, 255, 1),
    textColor: Color.fromRGBO(0, 0, 0, 1),
  ),
  const PageData(
    icon: Icons.diamond_sharp,
    title: "Gemas",
    resume:
        "Al registrar con éxito tus hábitos, obtendrás una cantidad aleatoria de gemas. Úsalas para recuperar rachas perdidas y seguir avanzando.",
    imagePath: "assets/images/cofregemas.png",
    bgColor: Color.fromRGBO(0, 0, 0, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.event,
    title: "Tablero de actividades",
    resume:
        "Te ayuda a organizar tus tareas de forma visual, clasificándolas en Pendientes, En progreso y Terminadas",
    imagePath: "assets/images/tablero.png",
    bgColor: Color.fromRGBO(139, 34, 227, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.accessibility,
    title: "Hábito personalizado",
    resume:
        "Si quieres desarrollar un hábito más enfocado en ti, podrás elegir entre 6 técnicas distintas para adaptarlo a tus necesidades y estilo de vida.",
    imagePath: "assets/images/habitoper.png",
    bgColor: Color.fromRGBO(255, 255, 255, 1),
    textColor: Color.fromRGBO(0, 0, 0, 1),
  ),
  const PageData(
    icon: Icons.rocket_launch,
    title: "¿No sabes por dónde empezar?",
    resume:
        "Explora nuestros 22 hábitos predefinidos que podrían ayudarte a dar ese primer paso hacia una mejor versión de ti.",
    imagePath: "assets/images/habitos.png",
    bgColor: Color.fromRGBO(0, 0, 0, 1),
    textColor: Color.fromARGB(255, 255, 255, 255),
  ),
  const PageData(
    icon: Icons.emoji_people,
    title: "¿Qué esperas?",
    resume:
        "Da el primer paso hacia una versión más enfocada, organizada y saludable de ti. ¡Empieza hoy mismo!",
    imagePath: "assets/images/bandera.png",
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
          padding: const EdgeInsets.only(left: 3),
          child: Icon(
            Icons.navigate_next,
            size: screenWidth * 0.08,
          ),
        ),
        itemBuilder: (index) {
          final page = pages[index % pages.length];

          if (index == pages.length - 1) {
            Future.delayed(const Duration(milliseconds: 2000), () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('hasSeenWelcome', true);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
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
            size: screenHeight * 0.08,
            color: page.bgColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            page.title ?? "",
            style: TextStyle(
              color: page.textColor,
              fontSize: screenHeight * 0.025,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (page.resume != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              page.resume!,
              style: TextStyle(
                color: page.textColor.withOpacity(0.7),
                fontSize: screenHeight * 0.02,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (page.imagePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Image.asset(
              page.imagePath!,
              width: screenHeight * 0.2,
            ),
          ),
      ],
    );
  }
}
