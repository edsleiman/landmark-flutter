import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../services/sales_service.dart';

class SalesStore extends ChangeNotifier {
  final SalesService service;
  SalesStore(this.service);

  List<Sale> sales = [];
  double commissionRate = 0.01;
  bool isLoading = false;
  String? errorMessage;

  double get totalCommissionOwed =>
      sales.fold(0.0, (sum, s) => sum + s.developerCommissionAmount);

  double get totalSalesVolume => sales.fold(0.0, (sum, s) => sum + s.purchasePrice);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      sales = await service.fetchSales();
      commissionRate = await service.commissionRate();
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Sale?> recordSale({
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
    try {
      final sale = await service.recordSale(
        propertyID: propertyID,
        propertyTitle: propertyTitle,
        sellerID: sellerID,
        sellerName: sellerName,
        buyerID: buyerID,
        buyerName: buyerName,
        realtorID: realtorID,
        realtorName: realtorName,
        purchasePrice: purchasePrice,
      );
      await load();
      return sale;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Developer-only: change the standard commission rate going forward.
  /// Past sales keep the rate that was in effect when they closed.
  Future<void> setCommissionRate(double rate) async {
    await service.setCommissionRate(rate);
    commissionRate = rate;
    notifyListeners();
  }
}
