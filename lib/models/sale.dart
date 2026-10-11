class Sale {
  final String id;
  final String propertyID;
  final String propertyTitle;
  final String sellerID;
  final String sellerName;
  final String buyerID;
  final String buyerName;
  final String realtorID;
  final String realtorName;
  final DateTime dateOfSale;
  final double purchasePrice;
  /// Captured at the time of the sale — never recalculated later, even if
  /// the developer's standard rate changes afterwards.
  final double developerCommissionRate;

  Sale({
    required this.id,
    required this.propertyID,
    required this.propertyTitle,
    required this.sellerID,
    required this.sellerName,
    required this.buyerID,
    required this.buyerName,
    required this.realtorID,
    required this.realtorName,
    required this.dateOfSale,
    required this.purchasePrice,
    required this.developerCommissionRate,
  });

  double get developerCommissionAmount => purchasePrice * developerCommissionRate;
}
