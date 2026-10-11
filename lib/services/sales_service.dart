import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sale.dart';

class SalesService {
  static const _storeKey = 'landmark.sales';
  static const _rateKey = 'landmark.commissionRate';
  final _uuid = const Uuid();

  Future<List<Sale>> fetchSales() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    if (raw == null) {
      final seeded = _seed();
      await _save(prefs, seeded);
      return seeded;
    }
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>().map(_fromJson).toList();
  }

  Future<Sale> recordSale({
    required String propertyID,
    required String propertyTitle,
    required String sellerID,
    required String sellerName,
    required String buyerID,
    required String buyerName,
    required String realtorID,
    required String realtorName,
    required double purchasePrice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rate = await commissionRate();
    final sale = Sale(
      id: _uuid.v4(),
      propertyID: propertyID,
      propertyTitle: propertyTitle,
      sellerID: sellerID,
      sellerName: sellerName,
      buyerID: buyerID,
      buyerName: buyerName,
      realtorID: realtorID,
      realtorName: realtorName,
      dateOfSale: DateTime.now(),
      purchasePrice: purchasePrice,
      developerCommissionRate: rate,
    );
    final list = await fetchSales();
    list.insert(0, sale);
    await _save(prefs, list);
    return sale;
  }

  /// Developer's standard commission rate (default 1%, i.e. 0.01).
  /// Stored so only the developer role can change it, and every recorded
  /// sale freezes its own rate at the time of the sale.
  Future<double> commissionRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_rateKey) ?? 0.01;
  }

  Future<void> setCommissionRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_rateKey, rate);
  }

  Future<void> _save(SharedPreferences prefs, List<Sale> list) async {
    await prefs.setString(_storeKey, jsonEncode(list.map(_toJson).toList()));
  }

  Map<String, dynamic> _toJson(Sale s) => {
        'id': s.id,
        'propertyID': s.propertyID,
        'propertyTitle': s.propertyTitle,
        'sellerID': s.sellerID,
        'sellerName': s.sellerName,
        'buyerID': s.buyerID,
        'buyerName': s.buyerName,
        'realtorID': s.realtorID,
        'realtorName': s.realtorName,
        'dateOfSale': s.dateOfSale.toIso8601String(),
        'purchasePrice': s.purchasePrice,
        'developerCommissionRate': s.developerCommissionRate,
      };

  Sale _fromJson(Map<String, dynamic> j) => Sale(
        id: j['id'],
        propertyID: j['propertyID'],
        propertyTitle: j['propertyTitle'],
        sellerID: j['sellerID'],
        sellerName: j['sellerName'],
        buyerID: j['buyerID'],
        buyerName: j['buyerName'],
        realtorID: j['realtorID'],
        realtorName: j['realtorName'],
        dateOfSale: DateTime.parse(j['dateOfSale']),
        purchasePrice: (j['purchasePrice'] as num).toDouble(),
        developerCommissionRate: (j['developerCommissionRate'] as num).toDouble(),
      );

  List<Sale> _seed() => [
        Sale(
          id: 's1',
          propertyID: 'p4',
          propertyTitle: 'Commercial Office Space in Downtown Beirut (prior tenancy buyout)',
          sellerID: 'u-seller-1',
          sellerName: 'Rami Abboud',
          buyerID: 'u-both-1',
          buyerName: 'Layla Haddad',
          realtorID: 'u-realtor-1',
          realtorName: 'Karim Fares',
          dateOfSale: DateTime.now().subtract(const Duration(days: 30)),
          purchasePrice: 610000,
          developerCommissionRate: 0.01,
        ),
      ];
}
