import 'package:eco_shopping/data.dart';
import 'package:flutter/cupertino.dart';
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

  String getDescription() {
    switch (this) {
      case safe:
        return "Sicuro";
      case low:
        return "Basso";
      case medium:
        return "Medio";
      case high:
        return "Alto";
      case veryHigh:
        return "Molto Alto";
    }
  }
}

class Pesticide {
  final String name;
  final String description;
  final Danger danger;
  final Danger envdanger;
  //final List<String>? sources;

  Pesticide({
    required this.name,
    required this.description,
    required this.danger,
    required this.envdanger,
    //this.sources,
  });

  List<Widget> _cardInfo(BuildContext context) {
    return [
      formatText(
        name,
        Theme.of(context).textTheme.headlineSmall,
        Alignment.topLeft,
      ),
      formatText(
        description,
        Theme.of(context).textTheme.titleMedium,
        Alignment.centerLeft,
      ),
      formatText(
        "\nRischio Salute: ${danger.getDescription()}",
        Theme.of(context).textTheme.titleMedium,
        Alignment.centerLeft,
      ),
      formatText(
        "Rischio per l'Ambiente: ${envdanger.getDescription()}",
        Theme.of(context).textTheme.titleMedium,
        Alignment.centerLeft,
      ),
    ];
  }

  Widget buildGui(BuildContext context) {
    return Card(
      color: Color(
          Danger.fromNum(((danger.value + envdanger.value) / 2).ceil())!
              .getColor()),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: _cardInfo(context),
          ),
        ),
      ),
    );
  }

  Pesticide.fromMap(Map<String, dynamic> map)
      : name = map["name"]!,
        description = map["description"]!,
        danger = Danger.fromNum(map["danger"])!,
        envdanger = Danger.fromNum(map["envdanger"])!;
  //sources = map["sources"];
}

class ProductInfo {
  final ProductCard card;
  final int carbonFootprint;
  final List<Pesticide>? pesticides;

  ProductInfo({
    required this.card,
    required this.carbonFootprint,
    required this.pesticides,
  });

  static List<Pesticide>? _getPesticides(List<dynamic>? list) {
    if (list == null) {
      return null;
    }
    List<Pesticide> pesticides = [];
    for (Map<String, dynamic> map in list) {
      pesticides.add(Pesticide.fromMap(map));
    }
    return pesticides;
  }

  String cfComment() {
    return (carbonFootprint >= 90)
        ? "Super Buono"
        : (carbonFootprint >= 70)
            ? "Buono"
            : (carbonFootprint >= 40)
                ? "Accettabile"
                : (carbonFootprint >= 10)
                    ? "Male"
                    : "Molto Male";
  }

  ProductInfo.fromMap(Map<String, dynamic> map)
      : card = ProductCard.fromMap(map),
        carbonFootprint = map["carbon_footprint"]!,
        pesticides = _getPesticides(map["pesticides"]);
}

class ProductData extends StatelessWidget {
  final String id;
  final int idFormat;
  const ProductData({super.key, required this.id, required this.idFormat});

  List<Widget> _pesticides(BuildContext context, ProductInfo info) {
    if (info.pesticides != null) {
      return info.pesticides!.map((p) => p.buildGui(context)).toList();
    } else {
      return [
        formatText(
          "Nessun fitofarmaco",
          Theme.of(context).textTheme.headlineSmall,
          Alignment.center,
        )
      ];
    }
  }

  Widget _getInfoPage(BuildContext context, ProductInfo info) {
    return Scaffold(
      appBar: AppBar(title: Text(info.card.title)),
      body: ListView(
        children: [
          Image.asset(info.card.image),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: info.card.title,
                style: Theme.of(context).textTheme.headlineLarge),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: '',
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
              children: <TextSpan>[
                const TextSpan(
                  text: 'Descrizione: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: info.card.description),
                const TextSpan(
                  text: "\n\nCarbon footprint: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "${info.carbonFootprint}/100 - ${info.cfComment()}\n",
                ),
                const TextSpan(
                  text: "\n\Punteggio totale: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "${info.card.scoreNum}/100\n",
                ),
              ],
            ),
          ),
          formatText(
            "Fitofarmaci",
            Theme.of(context).textTheme.headlineMedium,
            Alignment.center,
          ),
          Column(
            children: _pesticides(context, info),
          )
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
            return _getInfoPage(context, snapshot.data!);
          } else {
            Fluttertoast.showToast(msg: 'Prodotto non trovato nel database');
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else if (snapshot.hasError) {
          debugPrint(
              'An error occurred in getProductInfo(): ${snapshot.error}');
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
