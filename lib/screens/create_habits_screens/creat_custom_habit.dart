import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:stubit/widgets/user_button.dart';

class CreatCustomHabit extends StatelessWidget {
  const CreatCustomHabit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
        actions: [
          ImageButton(
            imagePath: "assets/images/book.png",
            onPressed: () {},
          ),
          Text(
            '0',
            style: GoogleFonts.dmSans(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Escoge tu técnica",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SecondPage(heroTag: index),
                          ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Hero(
                                tag: index,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    _images[index],
                                    width: 200,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _titles[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final int heroTag;

  const SecondPage({super.key, required this.heroTag});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _activityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
        actions: [
          ImageButton(
            imagePath: "assets/images/book.png",
            onPressed: () {},
          ),
          Text(
            '0',
            style: GoogleFonts.dmSans(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      _images[widget.heroTag],
                      width: 250,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _titles[widget.heroTag],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    _resume[widget.heroTag],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Escribe el nombre de tu actividad:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _activityController,
                      maxLength: 30,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la actividad',
                        hintText: 'Ej. Reunión semanal',
                        counterText: '',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obligatorio';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        print(
                            "Nombre de la actividad para bd ${_activityController.text}");
                      }
                    },
                    child: const Text("CREAR"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final List<String> _images = [
  'assets/images/Tec_POM.png',
  'assets/images/Tec_CyF.png',
  'assets/images/Tec_FyC.png',
  'assets/images/Tec_FyL.png',
  'assets/images/Tec_T.png',
  'assets/images/Tec_TyF.png'
];

final List<String> _titles = [
  'Técnica Pomodoro',
  'Tiempo y frecuencia',
  'Tiempo',
  'Cuestionario y frecuencia',
  'Frecuencia y lista',
  'Frecuencia y cuantitativo',
];

final List<String> _resume = [
  'La Técnica Pomodoro ayuda a mejorar la productividad dividiendo el trabajo en intervalos de trabajo con descansos cortos.',
  'Esta técnica es recomendada para definir tiempo y días específicos.',
  'Se enfoca en actividades que deben realizarse sí o sí.',
  'Define los días de práctica con cuestionarios.',
  'Lista actividades diarias obligatorias.',
  'Cuenta repeticiones diarias.',
];
