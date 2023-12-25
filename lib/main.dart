import 'package:flutter/material.dart';
import 'products.dart';
import 'products_gui.dart';

const title = 'EcoShopping';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF787E5C),
          //secondary: const Color(0xFFD1D7BD),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: TabsView(),
    );
  }
}

class TabsView extends StatefulWidget {
  final ValueNotifier<Future<List<ProductCardWidget>>> productCards =
      ValueNotifier(Future(() => []));
  TabsView({super.key});

  @override
  State<TabsView> createState() => _TabsView();
}

class _TabsView extends State<TabsView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Image.asset('assets/images/EcoShopping.png'),
          ),
          bottom: const TabBar(tabs: [
            Tab(text: 'Prodotti Salvati', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Alternative', icon: Icon(Icons.compare_arrows))
          ]),
        ),
        body: TabBarView(children: [
          ProductsPage(productCards: widget.productCards),
          AlternativesPage(productCards: widget.productCards)
        ]),
      ),
    );
  }

  @override
  void dispose() {
    widget.productCards.dispose();
    super.dispose();
  }
}
