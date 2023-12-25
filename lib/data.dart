import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'products.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'product_info.dart';

Future<List<dynamic>> _readJsonAssetList(String filename) async {
  var jsonFile = await rootBundle.loadString(filename);
  return jsonDecode(jsonFile);
}

void _writeJsonList(List<dynamic> json, String filepath) async {
  var dir = await getApplicationDocumentsDirectory();
  File jsonFile = File('${dir.path}/$filepath');
  if (!await jsonFile.exists()) {
    jsonFile.create(recursive: true);
  }
  await jsonFile.writeAsString(const JsonEncoder().convert(json));
}

Future<List<dynamic>> _readJsonList(String filepath) async {
  var dir = await getApplicationDocumentsDirectory();
  File jsonFile = File('${dir.path}/$filepath');
  if (await jsonFile.exists()) {
    return jsonDecode(await jsonFile.readAsString());
  } else {
    await jsonFile.create(recursive: true);
    jsonFile.writeAsString("[]");
    return [];
  }
}

Future<List<ProductCardWidget>> getSavedProductCards() async =>
    (await _readJsonList("saved.json"))
        .map((m) => ProductCardWidget(productCard: ProductCard.fromMap(m)))
        .toList();

Future<ProductInfo?> getProductInfo(String id, int idFormat) async {
  var jsonDb = await _readJsonAssetList("assets/data/database.json");
  for (Map<String, dynamic> product in jsonDb) {
    if (product["id"] == id && product["id_format"] == idFormat) {
      return ProductInfo.fromMap(product);
    }
  }
  return null;
}

bool _contains(List<ProductCardWidget> cardsList, ProductCardWidget card) {
  for (var c in cardsList) {
    if (c.equals(card)) {
      return true;
    }
  }
  return false;
}

Future<List<ProductCardWidget>> addToSavedProductCards(
  Future<List<ProductCardWidget>> cardsListFuture,
  Future<ProductCard?> newCardFuture,
) async {
  List<ProductCardWidget> cardsList = await cardsListFuture;
  ProductCard? newCard = await newCardFuture;
  if (newCard == null) {
    Fluttertoast.showToast(msg: "Prodotto non trovato");
    return cardsList;
  }
  ProductCardWidget newCardWidget = ProductCardWidget(productCard: newCard);
  if (_contains(cardsList, newCardWidget)) {
    Fluttertoast.showToast(msg: "Prodotto già salvato");
    return cardsList;
  }
  cardsList.add(newCardWidget);
  List<Map<String, dynamic>> json =
      cardsList.map((cardWidget) => cardWidget.productCard.intoMap()).toList();
  _writeJsonList(json, "saved.json");
  Fluttertoast.showToast(msg: "Prodotto salvato");
  return cardsList;
}

Future<ProductCard?> getCardFromId(String? id, int idFormat) async {
  var jsonDb = await _readJsonAssetList("assets/data/database.json");
  for (Map<String, dynamic> product in jsonDb) {
    if (product["id"] == id && product["id_format"] == idFormat) {
      return ProductCard.fromMap(product);
    }
  }
  return null;
}

Future<List<ProductCardWidget>> getAlternatives(
    Future<List<ProductCardWidget>> cardsListFuture) async {
  var savedProducts = await cardsListFuture;
  List<ProductCard> db = (await _readJsonAssetList("assets/data/database.json"))
      .map((product) => ProductCard.fromMap(product))
      .toList();
  List<ProductCard> alternatives = [];
  for (var product in db) {
    for (var savedProduct in savedProducts) {
      if (product.type == savedProduct.productCard.type) {
        if (product.scoreNum > savedProduct.productCard.scoreNum) {
          alternatives.add(
            ProductCard(
              id: product.id,
              idFormat: product.idFormat,
              title: product.title,
              price: product.price,
              currency: product.currency,
              type: product.type,
              image: product.image,
              scoreNum: product.scoreNum,
              description: product.description,
              alternativeOf: savedProduct.productCard,
            ),
          );
        }
      }
    }
  }
  alternatives
      .sort((a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
  return alternatives
      .map((product) => ProductCardWidget(productCard: product))
      .toList();
}
