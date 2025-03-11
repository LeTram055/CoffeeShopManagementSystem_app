import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../managers/staff_serve/order_manager.dart';
import 'order_screen.dart';
import '../../../models/order.dart';
import 'order_details_screen.dart';

class TableScreen extends StatefulWidget {
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    Future.delayed(Duration.zero, () {
      Provider.of<OrderServeManager>(context, listen: false).loadTables();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchTimer?.cancel();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo_nbg.png',
                height: 60,
              ),
              const SizedBox(width: 8),
              const Text(
                'Đặt hàng',
                style: TextStyle(fontFamily: 'Prata'),
              ),
            ],
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.surfaceTint,
            indicatorColor: theme.colorScheme.secondary,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            labelStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Trống"),
              Tab(text: "Đang sử dụng"),
              Tab(text: "Đang sửa"),
              Tab(text: "Tất cả"),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStatusLegend(),
            Expanded(
              child: Consumer<OrderServeManager>(
                builder: (context, tableManager, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTableGrid(_filterTables(tableManager.tables
                          .where((table) => table.status.name == "Trống")
                          .toList())),
                      _buildTableGrid(_filterTables(tableManager.tables
                          .where((table) => table.status.name == "Đang sử dụng")
                          .toList())),
                      _buildTableGrid(_filterTables(tableManager.tables
                          .where((table) => table.status.name == "Đang sửa")
                          .toList())),
                      _buildTableGrid(_filterTables(tableManager.tables)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bàn theo số',
          prefixIcon:
              Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _searchTimer?.cancel();

          _searchTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) {
              _searchFocusNode.unfocus();
            }
          });
        },
      ),
    );
  }

  List<dynamic> _filterTables(List<dynamic> tables) {
    if (_searchQuery.isEmpty) {
      return tables;
    }
    return tables
        .where((table) => table.tableNumber.toString().contains(_searchQuery))
        .toList();
  }

  Widget _buildTableGrid(List<dynamic> tables) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        final statusName = table.status.name;

        return GestureDetector(
          onTap: () async {
            if (statusName == "Trống") {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderServeScreen(table: table)),
              );
              if (result == true) {
                Provider.of<OrderServeManager>(context, listen: false)
                    .loadTables();
              }
            } else if (statusName == "Đang sử dụng") {
              final order = await _fetchOrderForTable(context, table.tableId);
              if (order != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(order: order)),
                );

                if (result == true) {
                  Provider.of<OrderServeManager>(context, listen: false)
                      .loadTables();
                }
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: _getStatusColor(statusName),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              "Bàn ${table.tableNumber}",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusLegend() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem("Trống", Colors.green),
          _buildLegendItem("Đang sử dụng", Colors.blue),
          _buildLegendItem("Đang sửa", Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Trống":
        return Colors.green;
      case "Đang sửa":
        return Colors.grey;
      case "Đang sử dụng":
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Future<Order?> _fetchOrderForTable(BuildContext context, int tableId) async {
    try {
      final orderManager =
          Provider.of<OrderServeManager>(context, listen: false);
      return await orderManager.getOrderByTableId(tableId);
    } catch (e) {
      print("Lỗi khi lấy đơn hàng: $e");
      return null;
    }
  }
}
