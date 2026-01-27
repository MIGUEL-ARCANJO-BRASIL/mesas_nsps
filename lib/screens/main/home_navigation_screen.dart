import 'package:flutter/material.dart';
import 'package:mesasnsps/screens/auxs/config_screen.dart';
import 'package:mesasnsps/screens/events/event_history_screen.dart';
import 'package:mesasnsps/screens/events/events_selection_screen.dart';
import 'package:mesasnsps/screens/main/list_reserved_table_screen.dart';
import 'package:mesasnsps/screens/main/table_map_screen.dart';

// Importe aqui seus arquivos de tela
// import 'table_map_screen.dart';
// import 'admin_list_screen.dart';
class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int selectedIndex = 0;
  Color mantoBlue = Color(0xFF0F1A44);

  final List<Widget> screens = [
    const EventSelectionScreen(),
    const ListReservedTableScreen(),
    const TableMapScreen(),
    const ConfigsScreen(),
    const EventHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos extendBody para a barra ficar bonita com o botão flutuante
      extendBody: true,
      body: IndexedStack(index: selectedIndex, children: screens),

      // Botão Flutuante Centralizado para o Mapa (Destaque total)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37), // Dourado
        onPressed: () => setState(() => selectedIndex = 2),
        child: Icon(Icons.grid_view, color: mantoBlue),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Recorte para o botão
        notchMargin: 8.0,
        color: mantoBlue,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Lado Esquerdo
              _bottomAction(Icons.event, "Eventos", 0),
              _bottomAction(Icons.people, "Reservas", 1),

              const SizedBox(width: 40), // Espaço para o botão central
              // Lado Direito
              _bottomAction(
                Icons.history,
                "Histórico",
                4,
              ), // Exemplo de nova aba
              _bottomAction(Icons.settings, "Ajustes", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
