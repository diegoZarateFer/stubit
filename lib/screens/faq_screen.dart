import 'package:flutter/material.dart';
import 'package:stubit/widgets/books_counter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/user_button.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
        actions: [
          const BooksCounter(),
          const Spacer(),
          Text(
            'Stu - Bit',
            style: GoogleFonts.satisfy(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 40,
              ),
            ),
          ),
          const Spacer(),
          const UserButton(),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(139, 34, 227, 1),
              Colors.black,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PREGUNTAS',
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  'FRECUENTES',
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 30), // Espaciado antes de las preguntas

                _buildExpandableTile(
                  '¿Qué debo hacer si no recuerdo mi contraseña?',
                  [
                    'Si olvidaste tu contraseña no te preocupes, dirígete a la sección de "Recuperar contraseña" presionando en "Olvidé mi contraseña" en el inicio de sesión.',
                    'En esa sección solo te solicitaremos el correo electrónico de tu cuenta y nosotros nos encargaremos de enviarte un enlace para restablecer tu contraseña.',
                  ],
                ),
                _buildExpandableTile(
                  '¿Cómo puedo crear más de un hábito?',
                  [
                    'Si deseas crear más de un hábito dentro de la aplicación, es posible, pero considera que el máximo número de hábitos activos permitidos es 5.',
                    'Para crear un hábito, solo debes hacer clic en el botón "+" en la pantalla principal y llenar el formulario con la información requerida.',
                  ],
                ),
                _buildExpandableTile(
                  '¿Cómo puedo cambiar mi correo electrónico asociado a mi cuenta?',
                  [
                    'Para modificar tu correo electrónico, accede a la sección "Editar Perfil", donde encontrarás todos tus datos personales.',
                    'Solo debes dar clic en tu perfil de usuario y actualizar la información deseada.',
                  ],
                ),
                _buildExpandableTile(
                  '¿Por qué la aplicación me pide mis datos personales?',
                  [
                    'Solicitamos tu nombre, apellidos y correo electrónico para ofrecerte un servicio eficiente y personalizado.',
                    'También es necesario para sincronizar tu progreso y permitirte recuperar tu cuenta si lo necesitas.',
                  ],
                ),
                _buildExpandableTile(
                  '¿Cómo puedo agregar actividades en mi tablero?',
                  [
                    'Para agregar una actividad, simplemente llena el formulario correspondiente, donde debes ingresar el nombre, detalles y prioridad de la actividad.',
                    'Una vez guardada, la actividad aparecerá en tu tablero y podrás gestionarla desde allí.',
                  ],
                ),
                _buildExpandableTile(
                  '¿Cómo puedo recuperar mi racha en un hábito?',
                  [
                    'Si perdiste tu racha, puedes recuperarla haciendo clic en "Recuperar Racha" dentro del hábito que deseas restaurar.',
                    'El costo de recuperación dependerá del número de días consecutivos de tu racha y se pagará con gemas.',
                    'Si no tienes suficientes gemas, lamentablemente no podrás recuperar tu racha en ese momento.',
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    "Regresar",
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      decorationColor: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableTile(String title, List<String> paragraphs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ExpansionTile(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: paragraphs
                      .map(
                        (paragraph) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            paragraph,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.dmSans(
                              textStyle: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Espaciado entre preguntas
        ],
      ),
    );
  }
}
