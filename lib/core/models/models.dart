import 'package:flutter/material.dart';

enum PickupStatus {
  requested,
  paymentPending,
  scheduled,
  searching,
  assigned,
  enRoute,
  arrived,
  collected,
  deliveredToHub,
  completed,
  cancelled,
  skipped,
  failed,
  disputed,
}

extension PickupStatusExtension on PickupStatus {
  String get label {
    switch (this) {
      case PickupStatus.requested: return 'Requested';
      case PickupStatus.paymentPending: return 'Payment Pending';
      case PickupStatus.scheduled: return 'Scheduled';
      case PickupStatus.searching: return 'Finding Hauler';
      case PickupStatus.assigned: return 'Hauler Assigned';
      case PickupStatus.enRoute: return 'En Route';
      case PickupStatus.arrived: return 'Arrived';
      case PickupStatus.collected: return 'Collected';
      case PickupStatus.deliveredToHub: return 'At Recycling Hub';
      case PickupStatus.completed: return 'Completed';
      case PickupStatus.cancelled: return 'Cancelled';
      case PickupStatus.skipped: return 'Skipped';
      case PickupStatus.failed: return 'Failed';
      case PickupStatus.disputed: return 'Disputed';
    }
  }

  Color get color {
    switch (this) {
      case PickupStatus.requested: return const Color(0xFF40C4FF);
      case PickupStatus.paymentPending: return const Color(0xFFFFD740);
      case PickupStatus.scheduled: return const Color(0xFF81C784);
      case PickupStatus.searching: return const Color(0xFFFFD740);
      case PickupStatus.assigned: return const Color(0xFF42A5F5);
      case PickupStatus.enRoute: return const Color(0xFFAB47BC);
      case PickupStatus.arrived: return const Color(0xFF26C6DA);
      case PickupStatus.collected: return const Color(0xFF76FF03);
      case PickupStatus.deliveredToHub: return const Color(0xFF66BB6A);
      case PickupStatus.completed: return const Color(0xFF00E676);
      case PickupStatus.cancelled: return const Color(0xFFFF5252);
      case PickupStatus.skipped: return const Color(0xFFFF8A65);
      case PickupStatus.failed: return const Color(0xFFFF5252);
      case PickupStatus.disputed: return const Color(0xFFFF6D00);
    }
  }

  IconData get icon {
    switch (this) {
      case PickupStatus.requested: return Icons.schedule_rounded;
      case PickupStatus.paymentPending: return Icons.payment_rounded;
      case PickupStatus.scheduled: return Icons.event_rounded;
      case PickupStatus.searching: return Icons.search_rounded;
      case PickupStatus.assigned: return Icons.person_pin_rounded;
      case PickupStatus.enRoute: return Icons.local_shipping_rounded;
      case PickupStatus.arrived: return Icons.location_on_rounded;
      case PickupStatus.collected: return Icons.inventory_2_rounded;
      case PickupStatus.deliveredToHub: return Icons.recycling_rounded;
      case PickupStatus.completed: return Icons.check_circle_rounded;
      case PickupStatus.cancelled: return Icons.cancel_rounded;
      case PickupStatus.skipped: return Icons.skip_next_rounded;
      case PickupStatus.failed: return Icons.error_rounded;
      case PickupStatus.disputed: return Icons.report_rounded;
    }
  }
}

enum WasteStream {
  general,
  plastics,
  paper,
  organics,
  glass,
  metal,
}

extension WasteStreamExtension on WasteStream {
  String get label {
    switch (this) {
      case WasteStream.general: return 'General Waste';
      case WasteStream.plastics: return 'Plastics';
      case WasteStream.paper: return 'Paper & Cardboard';
      case WasteStream.organics: return 'Organics';
      case WasteStream.glass: return 'Glass';
      case WasteStream.metal: return 'Metal';
    }
  }

  String get emoji {
    switch (this) {
      case WasteStream.general: return '🗑️';
      case WasteStream.plastics: return '♻️';
      case WasteStream.paper: return '📄';
      case WasteStream.organics: return '🌿';
      case WasteStream.glass: return '🫙';
      case WasteStream.metal: return '⚙️';
    }
  }

  Color get color {
    switch (this) {
      case WasteStream.general: return const Color(0xFF8D6E63);
      case WasteStream.plastics: return const Color(0xFF42A5F5);
      case WasteStream.paper: return const Color(0xFFFFB74D);
      case WasteStream.organics: return const Color(0xFF66BB6A);
      case WasteStream.glass: return const Color(0xFF26C6DA);
      case WasteStream.metal: return const Color(0xFF78909C);
    }
  }
}

class Pickup {
  final String id;
  final PickupStatus status;
  final DateTime scheduledFor;
  final String locationLabel;
  final String address;
  final List<WasteStream> streams;
  final double? totalAmount;
  final String? haulerName;
  final String? haulerPhone;
  final int? etaMinutes;
  final double? haulerLat;
  final double? haulerLng;
  final String? notes;
  final double? rating;

  const Pickup({
    required this.id,
    required this.status,
    required this.scheduledFor,
    required this.locationLabel,
    required this.address,
    required this.streams,
    this.totalAmount,
    this.haulerName,
    this.haulerPhone,
    this.etaMinutes,
    this.haulerLat,
    this.haulerLng,
    this.notes,
    this.rating,
  });
}

class ServiceLocation {
  final String id;
  final String label;
  final String address;
  final double lat;
  final double lng;
  final String? accessNotes;

  const ServiceLocation({
    required this.id,
    required this.label,
    required this.address,
    required this.lat,
    required this.lng,
    this.accessNotes,
  });
}

class SubscriptionPackage {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final int pickupsPerMonth;
  final List<WasteStream> streamsIncluded;
  final String binSize;
  final List<String> features;
  final bool popular;

  const SubscriptionPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.pickupsPerMonth,
    required this.streamsIncluded,
    required this.binSize,
    required this.features,
    this.popular = false,
  });
}

class Invoice {
  final String id;
  final DateTime date;
  final double amount;
  final String status;
  final String period;

  const Invoice({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.period,
  });
}

class RecyclingStats {
  final double totalKgDiverted;
  final double co2Saved;
  final int creditsEarned;
  final Map<WasteStream, double> byStream;
  final List<MonthlyData> monthlyData;

  const RecyclingStats({
    required this.totalKgDiverted,
    required this.co2Saved,
    required this.creditsEarned,
    required this.byStream,
    required this.monthlyData,
  });
}

class MonthlyData {
  final String month;
  final double kgDiverted;
  final double kgGeneral;

  const MonthlyData({
    required this.month,
    required this.kgDiverted,
    required this.kgGeneral,
  });
}
