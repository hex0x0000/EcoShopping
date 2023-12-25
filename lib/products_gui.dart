import 'package:flutter/material.dart';
import 'barcode.dart';
import 'products.dart';
import 'data.dart';
import 'utils.dart';

class AlternativesPage extends StatelessWidget {
  final ValueNotifier<Future<List<ProductCardWidget>>> productCards;
  const AlternativesPage({super.key, required this.productCards});

  Widget _buildPage(
    BuildContext context,
    AsyncSnapshot<List<ProductCardWidget>> snapshot,
  ) {
    if (snapshot.hasData) {
      if (snapshot.data!.isNotEmpty) {
        return ListView(
            scrollDirection: Axis.vertical, children: snapshot.data!);
      } else {
        return formatText('Nessuna alternativa trovata.',
            Theme.of(context).textTheme.headlineLarge, Alignment.center);
      }
    } else if (snapshot.hasError) {
      debugPrint("An error occurred: ${snapshot.error}");
      return formatText('Impossibile caricare le alternative.',
          Theme.of(context).textTheme.headlineLarge, Alignment.center);
    } else {
      return formatText('Caricamento...',
          Theme.of(context).textTheme.headlineLarge, Alignment.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: productCards,
          builder: (context, state, child) {
            return FutureBuilder(
              future: getAlternatives(state),
              builder: _buildPage,
            );
          },
        ),
      ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  final ValueNotifier<Future<List<ProductCardWidget>>> productCards;
  const ProductsPage({super.key, required this.productCards});

  @override
  State<ProductsPage> createState() => _ProductsPage();
}

class _ProductsPage extends State<ProductsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Widget _buildPage(
    BuildContext context,
    AsyncSnapshot<List<ProductCardWidget>> snapshot,
  ) {
    if (snapshot.hasData) {
      if (snapshot.data!.isNotEmpty) {
        return ListView(
          scrollDirection: Axis.vertical,
          children: snapshot.data!,
        );
      } else {
        return formatText(
          'La lista dei prodotti è vuota.',
          Theme.of(context).textTheme.headlineLarge,
          Alignment.center,
        );
      }
    } else if (snapshot.hasError) {
      debugPrint("An error occurred: ${snapshot.hasError}");
      return formatText(
        'Impossibile caricare i prodotti salvati.',
        Theme.of(context).textTheme.headlineLarge,
        Alignment.center,
      );
    } else {
      return formatText(
        'Caricamento...',
        Theme.of(context).textTheme.headlineLarge,
        Alignment.center,
      );
    }
  }

  Widget _getProductsPage(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () async {
        widget.productCards.value = getSavedProductCards();
      },
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: widget.productCards,
          builder: (context, state, child) {
            return FutureBuilder(
              future: state,
              builder: _buildPage,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.productCards.value = getSavedProductCards();
    return Scaffold(
      body: _getProductsPage(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BarcodePage(productCards: widget.productCards),
            ),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
