import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../managers/staff_barista/menu_manager.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = '/menu';

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchTimer;
  int? _expandedItemId;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final menuManager = Provider.of<MenuManager>(context, listen: false);
      menuManager.fetchMenuItems();
      menuManager.fetchCategories();
    });
  }

  void toggleExpand(int itemId) {
    setState(() {
      _expandedItemId = (_expandedItemId == itemId) ? null : itemId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuManager = Provider.of<MenuManager>(context);
    final menuItems = menuManager.menuItems;
    final categories = menuManager.categories;
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: categories.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Danh sách món',
              style: TextStyle(color: colorScheme.onPrimary)),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          bottom: TabBar(
            isScrollable: true,
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.surfaceTint,
            indicatorColor: colorScheme.secondary,
            labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            tabs: [
              const Tab(text: 'Tất cả'),
              ...categories.map((c) => Tab(text: c.name)),
            ],
            onTap: (index) {
              menuManager
                  .selectCategory(index == 0 ? 0 : categories[index - 1].id);
            },
          ),
        ),
        body: Column(
          children: [
            // Ô tìm kiếm
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm món...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  menuManager.searchMenu(value);
                  _searchTimer?.cancel();
                  _searchTimer = Timer(const Duration(seconds: 5), () {
                    if (_searchFocusNode.hasFocus) _searchFocusNode.unfocus();
                  });
                },
              ),
            ),

            // Danh sách món
            Expanded(
              child: menuManager.isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: colorScheme.primary))
                  : (menuItems.isEmpty
                      ? Center(
                          child: Text('Không có món phù hợp',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant)))
                      : ListView.builder(
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuItems[index];
                            bool isExpanded = item.itemId == _expandedItemId;

                            return Card(
                              color: colorScheme.surface,
                              shadowColor: colorScheme.shadow,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Ảnh món ăn
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 90,
                                            height: 80,
                                            child: item.imageUrl
                                                    .startsWith('http')
                                                ? Image.network(item.imageUrl,
                                                    width: 90,
                                                    height: 80,
                                                    fit: BoxFit.cover)
                                                : Icon(
                                                    Icons.image_not_supported,
                                                    color: colorScheme
                                                        .onSurfaceVariant),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Thông tin món ăn
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          colorScheme.primary)),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${item.price.toStringAsFixed(0)} VNĐ',
                                                    style: TextStyle(
                                                        color: colorScheme
                                                            .secondary),
                                                  ),
                                                  // Nút mở rộng
                                                  IconButton(
                                                    icon: Icon(
                                                      isExpanded
                                                          ? Icons.expand_less
                                                          : Icons.expand_more,
                                                      color:
                                                          colorScheme.primary,
                                                      size: 18,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                    onPressed: () =>
                                                        toggleExpand(
                                                            item.itemId),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // (Thay đổi trạng thái có sẵn)
                                        Transform.scale(
                                          scale: 0.8,
                                          child: Switch(
                                            value: item.isAvailable,
                                            activeColor: colorScheme.primary,
                                            onChanged: (newValue) {
                                              Provider.of<MenuManager>(context,
                                                      listen: false)
                                                  .toggleAvailability(
                                                      item.itemId);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Danh sách nguyên liệu
                                    if (isExpanded &&
                                        item.ingredients.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Nguyên liệu:",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                            const SizedBox(height: 4),
                                            Column(
                                              children: item.ingredients
                                                  .map((menuIngredient) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 2),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.circle,
                                                          size: 5,
                                                          color: colorScheme
                                                              .primary),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          '${menuIngredient.ingredient.name} - '
                                                          '${menuIngredient.quantityPerUnit} ${menuIngredient.ingredient.unit}',
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: colorScheme
                                                                  .onSurfaceVariant),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
