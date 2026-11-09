import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthState {
  final bool isAuthenticated;
  final String? phone;
  final String? name;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.phone,
    this.name,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? phone,
    String? name,
    bool? isLoading,
  }) => AuthState(
    isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    phone: phone ?? this.phone,
    name: name ?? this.name,
    isLoading: isLoading ?? this.isLoading,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> requestOtp(String phone) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isLoading: false);
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    // Mock: any 6-digit OTP works
    if (otp.length == 6) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        phone: '+265 999 000 111',
        name: 'James Banda',
      );
      return true;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  void signOut() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);

// ─── Pickups ──────────────────────────────────────────────────────────────────

final pickupsProvider = StateProvider<List<Pickup>>((ref) => _mockPickups);

final activePickupProvider = Provider<Pickup?>((ref) {
  final pickups = ref.watch(pickupsProvider);
  try {
    return pickups.firstWhere((p) =>
      p.status == PickupStatus.enRoute ||
      p.status == PickupStatus.assigned ||
      p.status == PickupStatus.arrived ||
      p.status == PickupStatus.searching,
    );
  } catch (_) {
    return null;
  }
});

// ─── Locations ────────────────────────────────────────────────────────────────

final locationsProvider = StateProvider<List<ServiceLocation>>((ref) => _mockLocations);

// ─── Subscriptions ────────────────────────────────────────────────────────────

final packagesProvider = Provider<List<SubscriptionPackage>>((_) => _mockPackages);

final activeSubscriptionProvider = StateProvider<SubscriptionPackage?>((ref) {
  return _mockPackages[1]; // Plus plan by default
});

// ─── Invoices ─────────────────────────────────────────────────────────────────

final invoicesProvider = Provider<List<Invoice>>((_) => _mockInvoices);

// ─── Recycling Stats ──────────────────────────────────────────────────────────

final recyclingStatsProvider = Provider<RecyclingStats>((_) => _mockStats);

// ─── Booking Flow State ───────────────────────────────────────────────────────

class BookingState {
  final ServiceLocation? location;
  final List<WasteStream> streams;
  final bool isOnDemand;
  final DateTime? scheduledDate;
  final String notes;
  final int currentStep;

  const BookingState({
    this.location,
    this.streams = const [],
    this.isOnDemand = true,
    this.scheduledDate,
    this.notes = '',
    this.currentStep = 0,
  });

  BookingState copyWith({
    ServiceLocation? location,
    List<WasteStream>? streams,
    bool? isOnDemand,
    DateTime? scheduledDate,
    String? notes,
    int? currentStep,
  }) => BookingState(
    location: location ?? this.location,
    streams: streams ?? this.streams,
    isOnDemand: isOnDemand ?? this.isOnDemand,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    notes: notes ?? this.notes,
    currentStep: currentStep ?? this.currentStep,
  );
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  void setLocation(ServiceLocation loc) => state = state.copyWith(location: loc);
  void toggleStream(WasteStream stream) {
    final list = List<WasteStream>.from(state.streams);
    list.contains(stream) ? list.remove(stream) : list.add(stream);
    state = state.copyWith(streams: list);
  }
  void setOnDemand(bool v) => state = state.copyWith(isOnDemand: v);
  void setScheduledDate(DateTime d) => state = state.copyWith(scheduledDate: d);
  void setNotes(String n) => state = state.copyWith(notes: n);
  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() => state = state.copyWith(currentStep: state.currentStep - 1);
  void reset() => state = const BookingState();
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>(
  (_) => BookingNotifier(),
);

// ─── Mock Data ────────────────────────────────────────────────────────────────

final _mockLocations = [
  const ServiceLocation(
    id: 'loc1',
    label: 'Home',
    address: '14 Kamuzu Road, Area 3, Lilongwe',
    lat: -13.9669,
    lng: 33.7873,
    accessNotes: 'Green gate, bins behind the wall',
  ),
  const ServiceLocation(
    id: 'loc2',
    label: 'Shop',
    address: 'Old Town Market, Stall B7, Lilongwe',
    lat: -13.9622,
    lng: 33.7859,
  ),
];

final _mockPickups = [
  Pickup(
    id: 'pick-001',
    status: PickupStatus.enRoute,
    scheduledFor: DateTime.now().add(const Duration(minutes: 18)),
    locationLabel: 'Home',
    address: '14 Kamuzu Road, Area 3',
    streams: [WasteStream.plastics, WasteStream.organics],
    totalAmount: 1500,
    haulerName: 'David Mwale',
    haulerPhone: '+265 888 123 456',
    etaMinutes: 18,
    haulerLat: -13.9650,
    haulerLng: 33.7840,
  ),
  Pickup(
    id: 'pick-002',
    status: PickupStatus.completed,
    scheduledFor: DateTime.now().subtract(const Duration(days: 7)),
    locationLabel: 'Home',
    address: '14 Kamuzu Road, Area 3',
    streams: [WasteStream.general, WasteStream.paper],
    totalAmount: 1200,
    rating: 4.5,
  ),
  Pickup(
    id: 'pick-003',
    status: PickupStatus.completed,
    scheduledFor: DateTime.now().subtract(const Duration(days: 14)),
    locationLabel: 'Shop',
    address: 'Old Town Market, Stall B7',
    streams: [WasteStream.general],
    totalAmount: 800,
    rating: 5.0,
  ),
  Pickup(
    id: 'pick-004',
    status: PickupStatus.scheduled,
    scheduledFor: DateTime.now().add(const Duration(days: 3)),
    locationLabel: 'Home',
    address: '14 Kamuzu Road, Area 3',
    streams: [WasteStream.plastics, WasteStream.glass, WasteStream.metal],
    totalAmount: 2000,
  ),
];

final _mockPackages = [
  const SubscriptionPackage(
    id: 'basic',
    name: 'Basic',
    description: 'Essential waste collection for small households',
    monthlyPrice: 4500,
    pickupsPerMonth: 4,
    streamsIncluded: [WasteStream.general],
    binSize: '120L bin',
    features: [
      '4 pickups per month',
      'General waste only',
      '120L bin included',
      'SMS notifications',
    ],
  ),
  SubscriptionPackage(
    id: 'plus',
    name: 'Plus',
    description: 'Sorted waste collection with recycling tracking',
    monthlyPrice: 8500,
    pickupsPerMonth: 8,
    streamsIncluded: WasteStream.values,
    binSize: '240L bin',
    features: [
      '8 pickups per month',
      'All waste streams',
      '240L bin + sorting bags',
      'Live GPS tracking',
      'Recycling dashboard',
      'Priority support',
    ],
    popular: true,
  ),
  const SubscriptionPackage(
    id: 'pro',
    name: 'Pro Business',
    description: 'High-volume collection for businesses & multiple sites',
    monthlyPrice: 22000,
    pickupsPerMonth: 20,
    streamsIncluded: WasteStream.values,
    binSize: '660L dumpster',
    features: [
      '20 pickups per month',
      'All waste streams',
      '660L dumpster rental',
      'Multiple sites (up to 3)',
      'Consolidated invoice',
      'Dedicated account manager',
      'Carbon impact reports',
    ],
  ),
];

final _mockInvoices = [
  Invoice(
    id: 'inv-2026-10',
    date: DateTime(2026, 10, 1),
    amount: 8500,
    status: 'Paid',
    period: 'October 2026',
  ),
  Invoice(
    id: 'inv-2026-09',
    date: DateTime(2026, 9, 1),
    amount: 8500,
    status: 'Paid',
    period: 'September 2026',
  ),
  Invoice(
    id: 'inv-2026-08',
    date: DateTime(2026, 8, 1),
    amount: 8500,
    status: 'Paid',
    period: 'August 2026',
  ),
  Invoice(
    id: 'inv-2026-11',
    date: DateTime(2026, 11, 1),
    amount: 8500,
    status: 'Upcoming',
    period: 'November 2026',
  ),
];

final _mockStats = RecyclingStats(
  totalKgDiverted: 127.4,
  co2Saved: 89.2,
  creditsEarned: 340,
  byStream: {
    WasteStream.plastics: 38.5,
    WasteStream.paper: 29.1,
    WasteStream.organics: 42.3,
    WasteStream.glass: 11.2,
    WasteStream.metal: 6.3,
  },
  monthlyData: [
    const MonthlyData(month: 'May', kgDiverted: 14.2, kgGeneral: 22.1),
    const MonthlyData(month: 'Jun', kgDiverted: 16.8, kgGeneral: 20.5),
    const MonthlyData(month: 'Jul', kgDiverted: 19.1, kgGeneral: 18.9),
    const MonthlyData(month: 'Aug', kgDiverted: 21.5, kgGeneral: 17.8),
    const MonthlyData(month: 'Sep', kgDiverted: 24.3, kgGeneral: 16.2),
    const MonthlyData(month: 'Oct', kgDiverted: 31.5, kgGeneral: 14.6),
  ],
);
