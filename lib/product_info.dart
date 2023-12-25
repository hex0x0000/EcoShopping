import 'package:eco_shopping/data.dart';
import 'utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'products.dart';
import 'package:flutter/material.dart';

enum Danger {
  veryHigh(1),
  high(2),
  medium(3),
  low(4),
  safe(5);

  final int value;
  const Danger(this.value);

  static Danger? fromNum(int? d) {
    switch (d) {
      case 1:
        return Danger.veryHigh;
      case 2:
        return Danger.high;
      case 3:
        return Danger.medium;
      case 4:
        return Danger.low;
      case 5:
        return Danger.safe;
      default:
        return null;
    }
  }

  int getColor() {
    switch (this) {
      case safe:
        return 0xFFD2F29C;
      case low:
        return 0xFFE7EC90;
      case medium:
        return 0xFFF4D491;
      case high:
        return 0xFFF3B196;
      case veryHigh:
        return 0xFFFFA59C;
    }
  }
}

class Pesticide {
  final String name;
  final String description;
  final Danger danger;
  final num quantity;
  final List<String>? sources;

  Pesticide({
    required this.name,
    required this.description,
    required this.danger,
    required this.quantity,
    this.sources,
  });

  Pesticide.fromMap(Map<String, dynamic> map)
      : name = map["name"]!,
        description = map["description"]!,
        danger = Danger.fromNum(map["danger"])!,
        quantity = map["quantity"]!,
        sources = map["sources"];
}

class ProductInfo {
  final ProductCard card;
  final int carbonFootprint;
  final List<Pesticide> pesticides;

  ProductInfo({
    required this.card,
    required this.carbonFootprint,
    required this.pesticides,
  });
  
  static List<Pesticide> _getPesticides(List<dynamic> list) {
    List<Pesticide> pesticides = [];
    for (Map<String, dynamic> map in list) {
      pesticides.add(Pesticide.fromMap(map));
    }
    return pesticides;
  }
  
  ProductInfo.fromMap(Map<String, dynamic> map)
      : card = ProductCard.fromMap(map),
        carbonFootprint = map["carbon_footprint"]!,
        pesticides = _getPesticides(map["pesticides"]!);
}

class ProductData extends StatelessWidget {
  final String id;
  final int idFormat;
  const ProductData({super.key, required this.id, required this.idFormat});

  Widget _getInfoPage(ProductInfo info) {
    return Scaffold(
      appBar: AppBar(title: Text(info.card.title)),
      body: ListView(
        children: [
          // TODO: Finish page
          Image.asset(info.card.image)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getProductInfo(id, idFormat),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return _getInfoPage(snapshot.data!);
          } else {
            Fluttertoast.showToast(msg: 'Prodotto non trovato nel database');
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else if (snapshot.hasError) {
          debugPrint('An error occurred in getProductInfo(): ${snapshot.error}');
          Fluttertoast.showToast(msg: 'Errore durante il caricamento dei dati');
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        return formatText(
          'Caricamento...',
          Theme.of(context).textTheme.headlineLarge,
          Alignment.center,
        );
      },
    );
  }
}
