import 'package:flutter/material.dart';
import 'package:mesasnsps/screens/config_screen.dart';
import 'package:mesasnsps/screens/list_reserved_table_screen.dart';
import 'package:mesasnsps/screens/table_map_screen.dart';
// Importe aqui seus arquivos de tela
// import 'table_map_screen.dart';
// import 'admin_list_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  // Variável em inglês: controla o índice da aba selecionada
  int selectedIndex = 0;

  // Lista de widgets das telas (em inglês)
  final List<Widget> screens = [
    ListReservedTableScreen(),
    TableMapScreen(),
    ConfigsScreen(),
  ];

  // Função para mudar de aba (em inglês)
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Exibe a tela baseada no índice selecionado
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Color(0xFF3F51B5),
        unselectedItemColor: Colors.grey,
        // Textos de exibição em PORTUGUÊS
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Mapa de Mesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Lista de Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuração',
          ),
        ],
      ),
    );
  }
}
