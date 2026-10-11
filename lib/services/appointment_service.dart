import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/viewing.dart';

class AppointmentService {
  static const _apptKey = 'landmark.appointments';
  static const _offerKey = 'landmark.offers';
  final _uuid = const Uuid();

  Future<List<ViewingAppointment>> fetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_apptKey);
    if (raw == null) {
      final seeded = _seedAppointments();
      await _saveAppointments(prefs, seeded);
      return seeded;
    }
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(_apptFromJson)
        .toList();
  }

  Future<List<Offer>> fetchOffers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_offerKey);
    if (raw == null) {
      final seeded = _seedOffers();
      await _saveOffers(prefs, seeded);
      return seeded;
    }
    return (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(_offerFromJson)
        .toList();
  }

  Future<ViewingAppointment> requestViewing({
    required String propertyID,
    required String buyerID,
    required DateTime preferredDate,
    required String notes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAppointments();
    final appt = ViewingAppointment(
      id: _uuid.v4(),
      propertyID: propertyID,
      buyerID: buyerID,
      requestedAt: DateTime.now(),
      scheduledAt: preferredDate,
      notes: notes,
      status: ViewingStatus.requested,
    );
    list.add(appt);
    await _saveAppointments(prefs, list);
    return appt;
  }

  Future<void> assign({required String appointmentID, required String realtorID, required DateTime scheduledAt}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAppointments();
    final a = list.firstWhere((x) => x.id == appointmentID);
    a.realtorID = realtorID;
    a.scheduledAt = scheduledAt;
    a.status = ViewingStatus.assigned;
    await _saveAppointments(prefs, list);
  }

  Future<void> cancel(String appointmentID) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAppointments();
    final a = list.firstWhere((x) => x.id == appointmentID);
    a.status = ViewingStatus.cancelled;
    await _saveAppointments(prefs, list);
  }

  /// Buyer signs on the realtor's screen to confirm they viewed the unit.
  Future<void> verifyWithSignature({required String appointmentID, required String signaturePNGBase64}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAppointments();
    final a = list.firstWhere((x) => x.id == appointmentID);
    a.status = ViewingStatus.verified;
    a.verificationMethod = VerificationMethod.signature;
    a.signaturePNGBase64 = signaturePNGBase64;
    a.verifiedAt = DateTime.now();
    await _saveAppointments(prefs, list);
  }

  /// Realtor sends the buyer a one-time verification link instead of an
  /// in-person signature. Returns the token to embed in the link.
  Future<String> sendVerificationLink(String appointmentID) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAppointments();
    final a = list.firstWhere((x) => x.id == appointmentID);
    final token = _uuid.v4();
    a.status = ViewingStatus.completed;
    a.verificationMethod = VerificationMethod.link;
    a.verificationToken = token;
    await _saveAppointments(prefs, list);
    return token;
  }

  /// Called when the buyer taps the verification link / deep link.
  Future<ViewingAppointment> verifyWithToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchAppointments();
    final a = list.firstWhere((x) => x.verificationToken == token,
        orElse: () => throw Exception('This verification link is invalid or has expired.'));
    a.status = ViewingStatus.verified;
    a.verifiedAt = DateTime.now();
    await _saveAppointments(prefs, list);
    return a;
  }

  Future<void> submitOffer(Offer offer) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchOffers();
    list.add(offer);
    await _saveOffers(prefs, list);
  }

  Future<void> updateOfferStatus({required String offerID, required OfferStatus status}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await fetchOffers();
    final o = list.firstWhere((x) => x.id == offerID);
    o.status = status;
    o.updatedAt = DateTime.now();
    await _saveOffers(prefs, list);
  }

  // --- persistence helpers ---

  Future<void> _saveAppointments(SharedPreferences prefs, List<ViewingAppointment> list) async {
    await prefs.setString(_apptKey, jsonEncode(list.map(_apptToJson).toList()));
  }

  Future<void> _saveOffers(SharedPreferences prefs, List<Offer> list) async {
    await prefs.setString(_offerKey, jsonEncode(list.map(_offerToJson).toList()));
  }

  Map<String, dynamic> _apptToJson(ViewingAppointment a) => {
        'id': a.id,
        'propertyID': a.propertyID,
        'buyerID': a.buyerID,
        'realtorID': a.realtorID,
        'requestedAt': a.requestedAt.toIso8601String(),
        'scheduledAt': a.scheduledAt?.toIso8601String(),
        'notes': a.notes,
        'status': a.status.name,
        'verificationMethod': a.verificationMethod?.name,
        'signaturePNGBase64': a.signaturePNGBase64,
        'verificationToken': a.verificationToken,
        'verifiedAt': a.verifiedAt?.toIso8601String(),
      };

  ViewingAppointment _apptFromJson(Map<String, dynamic> j) => ViewingAppointment(
        id: j['id'],
        propertyID: j['propertyID'],
        buyerID: j['buyerID'],
        realtorID: j['realtorID'],
        requestedAt: DateTime.parse(j['requestedAt']),
        scheduledAt: j['scheduledAt'] != null ? DateTime.parse(j['scheduledAt']) : null,
        notes: j['notes'] ?? '',
        status: ViewingStatus.values.byName(j['status']),
        verificationMethod: j['verificationMethod'] != null
            ? VerificationMethod.values.byName(j['verificationMethod'])
            : null,
        signaturePNGBase64: j['signaturePNGBase64'],
        verificationToken: j['verificationToken'],
        verifiedAt: j['verifiedAt'] != null ? DateTime.parse(j['verifiedAt']) : null,
      );

  Map<String, dynamic> _offerToJson(Offer o) => {
        'id': o.id,
        'propertyID': o.propertyID,
        'realtorID': o.realtorID,
        'buyerID': o.buyerID,
        'sellerID': o.sellerID,
        'amount': o.amount,
        'status': o.status.name,
        'createdAt': o.createdAt.toIso8601String(),
        'updatedAt': o.updatedAt.toIso8601String(),
        'notes': o.notes,
      };

  Offer _offerFromJson(Map<String, dynamic> j) => Offer(
        id: j['id'],
        propertyID: j['propertyID'],
        realtorID: j['realtorID'],
        buyerID: j['buyerID'],
        sellerID: j['sellerID'],
        amount: (j['amount'] as num).toDouble(),
        status: OfferStatus.values.byName(j['status']),
        createdAt: DateTime.parse(j['createdAt']),
        updatedAt: DateTime.parse(j['updatedAt']),
        notes: j['notes'] ?? '',
      );

  List<ViewingAppointment> _seedAppointments() => [
        ViewingAppointment(
          id: 'a1',
          propertyID: 'p1',
          buyerID: 'u-buyer-1',
          realtorID: 'u-realtor-1',
          requestedAt: DateTime.now().subtract(const Duration(days: 3)),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          notes: 'Prefers a weekend morning viewing.',
          status: ViewingStatus.assigned,
        ),
      ];

  List<Offer> _seedOffers() => [
        Offer(
          id: 'o1',
          propertyID: 'p1',
          realtorID: 'u-realtor-1',
          buyerID: 'u-buyer-1',
          sellerID: 'u-seller-1',
          amount: 405000,
          status: OfferStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          notes: 'Buyer open to negotiating closing costs.',
        ),
      ];
}
