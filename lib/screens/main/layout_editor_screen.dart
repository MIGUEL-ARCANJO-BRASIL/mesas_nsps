import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/model/obstacle.dart';
import 'package:uuid/uuid.dart';

class LayoutEditorScreen extends StatefulWidget {
  const LayoutEditorScreen({super.key});

  @override
  State<LayoutEditorScreen> createState() => _LayoutEditorScreenState();
}

class _LayoutEditorScreenState extends State<LayoutEditorScreen> {
  late List<TableModel> _editableTables;
  late List<LayoutObstacleModel> _editableObstacles;
  late int _columns;
  late int _rows;

  @override
  void initState() {
    super.initState();
    // Copy the current state to allow editing without immediate DB saves
    final provider = Provider.of<TableProvider>(context, listen: false);
    final event = provider.selectedEvent!;
    
    // Deep copy tables
    _editableTables = event.tables.map((t) => TableModel(
      number: t.number,
      userName: t.userName,
      phoneNumber: t.phoneNumber,
      paymentMethod: t.paymentMethod,
      receiptPath: t.receiptPath,
      status: t.status,
      price: t.price,
      x: t.x,
      y: t.y,
    )).toList();

    // Deep copy obstacles
    _editableObstacles = event.obstacles.map((o) => LayoutObstacleModel(
      id: o.id,
      type: o.type,
      label: o.label,
      x: o.x,
      y: o.y,
      width: o.width,
      height: o.height,
    )).toList();

    _columns = event.gridColumns;
    _rows = event.gridRows;
  }

  void _saveLayout() {
    final provider = Provider.of<TableProvider>(context, listen: false);
    provider.saveLayout(
      updatedTables: _editableTables,
      updatedObstacles: _editableObstacles,
      columns: _columns,
      rows: _rows,
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layout salvo com sucesso!')),
      );
      Navigator.pop(context);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar layout: $e')),
      );
    });
  }

  void _addObstacle(String type, String label) {
    setState(() {
      _editableObstacles.add(
        LayoutObstacleModel(
          id: const Uuid().v4(),
          type: type,
          label: label,
          x: 0,
          y: 0,
          width: 2,
          height: 2,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Editor Visual de Layout', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2D3250),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            tooltip: 'Adicionar Obstrução',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => _buildObstacleSelector(ctx),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.greenAccent),
            tooltip: 'Salvar Layout',
            onPressed: _saveLayout,
          ),
        ],
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 3.0,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildGrid(),
        ),
      ),
    );
  }


  Widget _buildGrid() {
    return Container(
      width: _columns * 60.0,
      height: _rows * 60.0,
      decoration: BoxDecoration(
        color: const Color(0xFF252A40),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Draw grid lines
          ...List.generate(_columns + 1, (x) => Positioned(
            left: x * 60.0,
            top: 0,
            bottom: 0,
            child: Container(width: 1, color: Colors.white10),
          )),
          ...List.generate(_rows + 1, (y) => Positioned(
            top: y * 60.0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.white10),
          )),
          
          // Draw drop targets for every cell
          ..._buildGridDropTargets(),
          
          // Draw tables
          ..._editableTables.where((t) => t.x != null && t.y != null).map((t) {
            return Positioned(
              left: t.x! * 60.0,
              top: t.y! * 60.0,
              width: 60,
              height: 60,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    t.x = null;
                    t.y = null;
                  });
                },
                child: Draggable<TableModel>(
                  data: t,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildTableWidget(t, isDragging: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildTableWidget(t),
                  ),
                  child: _buildTableWidget(t),
                ),
              ),
            );
          }),

          // Draw obstacles
          ..._editableObstacles.map((o) {
            return Positioned(
              left: o.x * 60.0,
              top: o.y * 60.0,
              width: o.width * 60.0,
              height: o.height * 60.0,
              child: Draggable<LayoutObstacleModel>(
                data: o,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildObstacleWidget(o, isDragging: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildObstacleWidget(o),
                ),
                child: _buildObstacleWidget(o),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildGridDropTargets() {
    List<Widget> targets = [];
    for (int y = 0; y < _rows; y++) {
      for (int x = 0; x < _columns; x++) {
        targets.add(
          Positioned(
            left: x * 60.0,
            top: y * 60.0,
            width: 60,
            height: 60,
            child: GestureDetector(
              onTap: () {
                // Tenta encontrar uma mesa na posição (x,y)
                final existingTableIndex = _editableTables.indexWhere((t) => t.x == x && t.y == y);
                if (existingTableIndex != -1) {
                  // Remove a mesa atual
                  setState(() {
                    _editableTables[existingTableIndex].x = null;
                    _editableTables[existingTableIndex].y = null;
                  });
                  return;
                }
                
                // Se o espaço estiver vazio, procura uma mesa livre
                final unassignedIndex = _editableTables.indexWhere((t) => t.x == null || t.y == null);
                if (unassignedIndex != -1) {
                  setState(() {
                    _editableTables[unassignedIndex].x = x;
                    _editableTables[unassignedIndex].y = y;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Não há mais mesas livres!')),
                  );
                }
              },
              child: DragTarget<Object>(
                onAcceptWithDetails: (details) {
                  final data = details.data;
                  if (data is TableModel) {
                    setState(() {
                      data.x = x;
                      data.y = y;
                    });
                  } else if (data is LayoutObstacleModel) {
                    setState(() {
                      data.x = x;
                      data.y = y;
                    });
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    color: candidateData.isNotEmpty ? Colors.white24 : Colors.transparent,
                  );
                },
              ),
            ),
          ),
        );
      }
    }
    return targets;
  }

  Widget _buildTableWidget(TableModel table, {bool isDragging = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      width: isDragging ? 52 : 52,
      height: isDragging ? 52 : 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF0A500),
        shape: BoxShape.circle,
        boxShadow: isDragging ? [
          BoxShadow(color: const Color(0xFFF0A500).withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
        ] : [],
      ),
      alignment: Alignment.center,
      child: Text(
        table.number.toString(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildObstacleWidget(LayoutObstacleModel obstacle, {bool isDragging = false}) {
    return GestureDetector(
      onDoubleTap: () {
        // Rotacionar
        setState(() {
          int temp = obstacle.width;
          obstacle.width = obstacle.height;
          obstacle.height = temp;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        width: (obstacle.width * 60.0) - 4,
        height: (obstacle.height * 60.0) - 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white38, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          obstacle.label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildObstacleSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3250),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Adicionar Estrutura", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _obstacleButton(context, 'stage', 'Palco', Icons.stadium),
              _obstacleButton(context, 'bar', 'Bar/Bebidas', Icons.local_bar),
              _obstacleButton(context, 'cashier', 'Caixa', Icons.point_of_sale),
              _obstacleButton(context, 'wc', 'Banheiro', Icons.wc),
              _obstacleButton(context, 'sound', 'Mesa de Som', Icons.speaker),
            ],
          )
        ],
      ),
    );
  }

  Widget _obstacleButton(BuildContext context, String type, String label, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white12,
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: () {
        _addObstacle(type, label);
        Navigator.pop(context);
      },
    );
  }
}
