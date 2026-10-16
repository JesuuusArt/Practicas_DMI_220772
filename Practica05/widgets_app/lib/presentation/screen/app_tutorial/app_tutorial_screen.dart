import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTutorialScreen extends StatelessWidget {
  static const String name = 'app_tutorial_screen';

  const AppTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introducción a la aplicación'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido a la app de widgets',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'En esta aplicación puedes explorar diferentes widgets, estilos y patrones de Flutter. '
                'Usa el menú lateral para navegar entre las pantallas.',
              ),
              SizedBox(height: 24),
              Text(
                'Ideas para probar:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text('• Botones y acciones'),
              Text('• Indicadores de progreso'),
              Text('• Tarjetas y layouts'),
              Text('• Snackbars y diálogos'),
              Text('• Listas infinitas y temas'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () {
          context.pop();
        },
      ),
    );
  }
}
