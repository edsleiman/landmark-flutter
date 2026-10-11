enum ViewingStatus { requested, assigned, completed, verified, cancelled }

extension ViewingStatusLabel on ViewingStatus {
  String get label {
    switch (this) {
      case ViewingStatus.requested:
        return 'Requested';
      case ViewingStatus.assigned:
        return 'Scheduled';
      case ViewingStatus.completed:
        return 'Completed';
      case ViewingStatus.verified:
        return 'Verified';
      case ViewingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum VerificationMethod { signature, link }

class ViewingAppointment {
  final String id;
  final String propertyID;
  final String buyerID;
  String? realtorID;
  final DateTime requestedAt;
  DateTime? scheduledAt;
  final String notes;
  ViewingStatus status;
  VerificationMethod? verificationMethod;
  String? signaturePNGBase64; // base64 PNG of the buyer's signature
  String? verificationToken; // one-time token embedded in the verify link
  DateTime? verifiedAt;

  ViewingAppointment({
    required this.id,
    required this.propertyID,
    required this.buyerID,
    this.realtorID,
    required this.requestedAt,
    this.scheduledAt,
    this.notes = '',
    this.status = ViewingStatus.requested,
    this.verificationMethod,
    this.signaturePNGBase64,
    this.verificationToken,
    this.verifiedAt,
  });
}

enum OfferStatus { pending, countered, accepted, declined, withdrawn }

extension OfferStatusLabel on OfferStatus {
  String get label {
    switch (this) {
      case OfferStatus.pending:
        return 'Pending';
      case OfferStatus.countered:
        return 'Countered';
      case OfferStatus.accepted:
        return 'Accepted';
      case OfferStatus.declined:
        return 'Declined';
      case OfferStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

class Offer {
  final String id;
  final String propertyID;
  final String realtorID;
  final String buyerID;
  final String? sellerID;
  double amount;
  OfferStatus status;
  final DateTime createdAt;
  DateTime updatedAt;
  String notes;

  Offer({
    required this.id,
    required this.propertyID,
    required this.realtorID,
    required this.buyerID,
    this.sellerID,
    required this.amount,
    this.status = OfferStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
  });
}
