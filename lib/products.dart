import 'product_info.dart';
import 'utils.dart';
import 'package:flutter/material.dart';

enum Score { superGood, good, ok, bad, reallyBad }

Score _getScore(int scoreNum) {
  return (scoreNum >= 90)
      ? Score.superGood
      : (scoreNum >= 70)
          ? Score.good
          : (scoreNum >= 40)
              ? Score.ok
              : (scoreNum >= 10)
                  ? Score.bad
                  : Score.reallyBad;
}

class ProductCard {
  final String id;
  final int idFormat;
  final String title;
  final String price;
  final String currency;
  final String type;
  final String description;
  final String image;
  final int scoreNum;
  final Score score;
  final ProductCard? alternativeOf;

  @override
  bool operator ==(Object other) =>
      other is ProductCard && other.id == id && other.idFormat == idFormat;

  Map<String, dynamic> intoMap() {
    return {
      "id": id,
      "id_format": idFormat,
      "title": title,
      "currency": currency,
      "price": price,
      "type": type,
      "description": description,
      "image": image,
      "score": scoreNum,
    };
  }

  ProductCard({
    required this.id,
    required this.idFormat,
    required this.title,
    required this.price,
    required this.currency,
    required this.type,
    required this.image,
    required this.scoreNum,
    required this.description,
    this.alternativeOf,
  }) : score = _getScore(scoreNum);

  ProductCard.fromMap(Map<String, dynamic> map)
      : id = map["id"]!,
        idFormat = map["id_format"]!,
        title = map["title"]!,
        price = map["price"]!,
        type = map["type"]!,
        currency = map["currency"]!,
        description = map["description"]!,
        image = map["image"]!,
        scoreNum = map["score"]!,
        score = _getScore(map["score"]!),
        alternativeOf = null;
}

class ProductCardWidget extends StatelessWidget {
  final ProductCard productCard;
  const ProductCardWidget({super.key, required this.productCard});

  int _getColor(Score score) {
    switch (score) {
      case Score.superGood:
        return 0xFFD2F29C;
      case Score.good:
        return 0xFFE7EC90;
      case Score.ok:
        return 0xFFF4D491;
      case Score.bad:
        return 0xFFF3B196;
      case Score.reallyBad:
        return 0xFFFFA59C;
    }
  }

  List<Widget> _cardInfo(BuildContext context) {
    List<Widget> cardsInfo = [
      formatText(
        '${productCard.title} - ${productCard.currency}${productCard.price}',
        Theme.of(context).textTheme.headlineSmall,
        Alignment.topLeft,
      ),
      formatText(
        productCard.description,
        Theme.of(context).textTheme.titleMedium,
        Alignment.centerLeft,
      ),
    ];
    if (productCard.alternativeOf != null) {
      cardsInfo.add(
        formatText(
          'Alternativa di: ${productCard.alternativeOf!.title}',
          Theme.of(context).textTheme.titleMedium,
          Alignment.centerLeft,
        ),
      );
    }
    cardsInfo.add(
      formatText(
        '${productCard.scoreNum}/100',
        Theme.of(context).textTheme.labelLarge,
        Alignment.bottomLeft,
      ),
    );
    return cardsInfo;
  }

  bool equals(ProductCardWidget card) {
    return card.productCard == productCard;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(_getColor(productCard.score)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductData(
                id: productCard.id,
                idFormat: productCard.idFormat,
              ),
            ),
          );
        },
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(flex: 4, child: Image.asset(productCard.image)),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: _cardInfo(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
