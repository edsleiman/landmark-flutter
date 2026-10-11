import 'package:flutter/foundation.dart';
import '../models/viewing.dart';
import '../services/appointment_service.dart';

class AppointmentStore extends ChangeNotifier {
  final AppointmentService service;
  AppointmentStore(this.service);

  List<ViewingAppointment> appointments = [];
  List<Offer> offers = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      appointments = await service.fetchAppointments();
      offers = await service.fetchOffers();
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // Buyer actions

  Future<void> requestViewing({
    required String propertyID,
    required String buyerID,
    required DateTime preferredDate,
    required String notes,
  }) async {
    try {
      await service.requestViewing(
          propertyID: propertyID, buyerID: buyerID, preferredDate: preferredDate, notes: notes);
      await load();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  List<ViewingAppointment> viewingsForBuyer(String buyerID) =>
      appointments.where((a) => a.buyerID == buyerID).toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  // Realtor actions

  List<ViewingAppointment> viewingsForRealtor(String realtorID) =>
      appointments.where((a) => a.realtorID == realtorID).toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  List<ViewingAppointment> get unassignedRequests =>
      appointments.where((a) => a.realtorID == null && a.status == ViewingStatus.requested).toList();

  Future<void> assign({required String appointmentID, required String realtorID, required DateTime scheduledAt}) async {
    try {
      await service.assign(appointmentID: appointmentID, realtorID: realtorID, scheduledAt: scheduledAt);
      await load();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> cancel(String appointmentID) async {
    try {
      await service.cancel(appointmentID);
      await load();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> verifyWithSignature({required String appointmentID, required String signaturePNGBase64}) async {
    try {
      await service.verifyWithSignature(appointmentID: appointmentID, signaturePNGBase64: signaturePNGBase64);
      await load();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Returns a shareable verification URL the realtor can text/email/AirDrop to the buyer.
  Future<Uri?> sendVerificationLink(String appointmentID) async {
    try {
      final token = await service.sendVerificationLink(appointmentID);
      await load();
      return Uri.parse('landmarkapp://verify?token=$token');
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Called from the app's deep-link handler when the buyer taps the link they were sent.
  Future<ViewingAppointment?> verify(String token) async {
    try {
      final updated = await service.verifyWithToken(token);
      await load();
      return updated;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Negotiation

  List<Offer> offersForProperty(String propertyID) =>
      offers.where((o) => o.propertyID == propertyID).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Offer> offersForRealtor(String realtorID) =>
      offers.where((o) => o.realtorID == realtorID).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> submitOffer(Offer offer) async {
    try {
      await service.submitOffer(offer);
      await load();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateOfferStatus({required String offerID, required OfferStatus status}) async {
    try {
      await service.updateOfferStatus(offerID: offerID, status: status);
      await load();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Admin

  List<ViewingAppointment> get allAppointmentsSorted =>
      [...appointments]..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
}
