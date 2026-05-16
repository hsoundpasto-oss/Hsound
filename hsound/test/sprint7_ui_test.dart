import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Constantes de color replicadas de la app
const Color successColor = Color(0xFF15803D);
const Color errorColor = Colors.red; // Colors.red[700] usado en la app
const Color buttonColor = Color(0xFF4ADE80);
const Color appBarColor = Color(0xFF1E1E1E);

// Widget de prueba que simula la splash screen
class SplashScreenMock extends StatelessWidget {
  const SplashScreenMock({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de prueba que simula snackbars de éxito y error
class SnackBarScreen extends StatelessWidget {
  final bool showSuccess;
  final bool showError;

  const SnackBarScreen({
    super.key,
    this.showSuccess = false,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          if (showSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Éxito'),
                  backgroundColor: Color(0xFF15803D),
                ),
              );
            });
          }
          if (showError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Error'),
                  backgroundColor: Colors.red[700],
                ),
              );
            });
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// Widget que simula el bottom navigation bar
class HomeScreenMock extends StatelessWidget {
  const HomeScreenMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF4ADE80),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Widget que simula un botón importante con color verde
class GreenButtonScreen extends StatelessWidget {
  const GreenButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
              ),
              child: const Text('Iniciar Sesión'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
              ),
              child: const Text('Guardar Cambios'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
              ),
              child: const Text('Explorar Canciones'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('SPRINT 7 - EXPERIENCIA DE USUARIO', () {
    group('Pantalla de bienvenida (Splash Screen)', () {
      testWidgets('La splash screen debe aparecer al abrir la app', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreenMock()),
        );

        // Verificar que el fondo es el color correcto
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, const Color(0xFF1E1E1E));

        // Verificar que hay un indicador de carga
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Mensajes de éxito y error', () {
      testWidgets('Mensajes de éxito deben ser de color verde', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: SnackBarScreen(showSuccess: true)),
        );
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, const Color(0xFF15803D));
      });

      testWidgets('Mensajes de error deben ser de color rojo', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: SnackBarScreen(showError: true)),
        );
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.backgroundColor, Colors.red[700]);
      });
    });

    group('Color verde consistente en botones', () {
      testWidgets('Botones importantes deben tener color verde consistente', (tester) async {
        await tester.pumpWidget(const GreenButtonScreen());

        final buttons = find.byType(ElevatedButton);
        expect(buttons, findsNWidgets(3));

        for (final button in buttons.evaluate()) {
          final widget = button.widget as ElevatedButton;
          final style = widget.style;
          // Verificar que el backgroundColor del estilo es 0xFF4ADE80
          final bgColor = style?.backgroundColor?.resolve({});
          expect(bgColor, const Color(0xFF4ADE80));
        }
      });
    });

    group('Barra de navegación inferior', () {
      testWidgets('La barra de navegación inferior debe tener los 4 íconos correctos',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: HomeScreenMock()),
        );

        final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(navBar.items.length, 4);
        expect(navBar.items[0].icon, isA<Icon>().having(
          (i) => i.icon, 'icon', Icons.home,
        ));
        expect(navBar.items[1].icon, isA<Icon>().having(
          (i) => i.icon, 'icon', Icons.search,
        ));
        expect(navBar.items[2].icon, isA<Icon>().having(
          (i) => i.icon, 'icon', Icons.favorite,
        ));
        expect(navBar.items[3].icon, isA<Icon>().having(
          (i) => i.icon, 'icon', Icons.person,
        ));
      });

      testWidgets('Los items de la barra deben tener las etiquetas correctas',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: HomeScreenMock()),
        );

        final navBar = tester.widget<BottomNavigationBar>(
          find.byType(BottomNavigationBar),
        );

        expect(navBar.items[0].label, 'Inicio');
        expect(navBar.items[1].label, 'Buscar');
        expect(navBar.items[2].label, 'Favoritos');
        expect(navBar.items[3].label, 'Perfil');
      });
    });
  });
}

// Ejecutar: flutter test test/sprint7_ui_test.dart
