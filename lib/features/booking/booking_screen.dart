import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  final _steps = ['Location', 'Waste Streams', 'Schedule', 'Payment'];

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    final locations = ref.watch(locationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Pickup'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(bookingProvider.notifier).reset();
            context.go('/home');
          },
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      color: i ~/ 2 < booking.currentStep
                          ? AppColors.accent
                          : AppColors.card,
                    ),
                  );
                }
                final step = i ~/ 2;
                final done = step < booking.currentStep;
                final active = step == booking.currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.accent
                        : active
                            ? AppColors.primaryLight
                            : AppColors.card,
                    border: active
                        ? Border.all(color: AppColors.accent, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                        : Text('${step + 1}',
                            style: TextStyle(
                              color: active ? AppColors.accent : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            )),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _steps[booking.currentStep],
                style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStep(booking, locations),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BookingState booking, List<ServiceLocation> locations) {
    switch (booking.currentStep) {
      case 0: return _LocationStep(locations: locations);
      case 1: return _StreamsStep();
      case 2: return _ScheduleStep();
      case 3: return _PaymentStep();
      default: return const SizedBox.shrink();
    }
  }
}

// ─── Step 1: Location ─────────────────────────────────────────────────────────

class _LocationStep extends ConsumerWidget {
  final List<ServiceLocation> locations;
  const _LocationStep({required this.locations});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const Text('Select pickup location',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Choose a saved location or pin a new one on the map.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
              const SizedBox(height: 20),
              ...locations.map((loc) {
                final selected = booking.location?.id == loc.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => notifier.setLocation(loc),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryLight.withOpacity(0.2) : AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.accent : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.accent.withOpacity(0.15)
                                  : AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              loc.label.toLowerCase() == 'home'
                                  ? Icons.home_rounded
                                  : Icons.storefront_rounded,
                              color: selected ? AppColors.accent : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.label,
                                    style: TextStyle(
                                        color: selected
                                            ? AppColors.accent
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                                const SizedBox(height: 3),
                                Text(loc.address,
                                    style: const TextStyle(
                                        color: AppColors.textMuted, fontSize: 12)),
                                if (loc.accessNotes != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded,
                                          size: 12, color: AppColors.textMuted),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(loc.accessNotes!,
                                            style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.accent, size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Pin new location on map'),
              ),
            ],
          ),
        ),
        _BottomNav(
          onNext: booking.location != null
              ? () => ref.read(bookingProvider.notifier).nextStep()
              : null,
        ),
      ],
    );
  }
}

// ─── Step 2: Waste Streams ────────────────────────────────────────────────────

class _StreamsStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const Text('What are you disposing?',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Select all waste types for this pickup. Sorted waste earns recycling credits.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: WasteStream.values.map((stream) {
                  final selected = booking.streams.contains(stream);
                  return GestureDetector(
                    onTap: () => notifier.toggleStream(stream),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? stream.color.withOpacity(0.2)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? stream.color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(stream.emoji, style: const TextStyle(fontSize: 28)),
                              if (selected)
                                Icon(Icons.check_circle_rounded,
                                    color: stream.color, size: 20),
                            ],
                          ),
                          const Spacer(),
                          Text(stream.label,
                              style: TextStyle(
                                  color: selected ? stream.color : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (booking.streams.isEmpty) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Text('Select at least one waste type',
                      style: TextStyle(color: AppColors.warning, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
        _BottomNav(
          onBack: () => ref.read(bookingProvider.notifier).prevStep(),
          onNext: booking.streams.isNotEmpty
              ? () => ref.read(bookingProvider.notifier).nextStep()
              : null,
        ),
      ],
    );
  }
}

// ─── Step 3: Schedule ─────────────────────────────────────────────────────────

class _ScheduleStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ScheduleStep> createState() => _ScheduleStepState();
}

class _ScheduleStepState extends ConsumerState<_ScheduleStep> {
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const Text('When do you need it?',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),

              // On-demand vs Scheduled toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _ToggleOption(
                      label: '⚡ Right Now',
                      sublabel: 'On-demand',
                      selected: booking.isOnDemand,
                      onTap: () => notifier.setOnDemand(true),
                    ),
                    _ToggleOption(
                      label: '📅 Schedule',
                      sublabel: 'Pick a date',
                      selected: !booking.isOnDemand,
                      onTap: () => notifier.setOnDemand(false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (!booking.isOnDemand) ...[
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.dark(primary: AppColors.accent),
                        ),
                        child: child!,
                      ),
                    );
                    if (date != null) notifier.setScheduledDate(date);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: booking.scheduledDate != null
                            ? AppColors.accent.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.accent, size: 22),
                        const SizedBox(width: 14),
                        Text(
                          booking.scheduledDate != null
                              ? '${booking.scheduledDate!.day}/${booking.scheduledDate!.month}/${booking.scheduledDate!.year}'
                              : 'Select pickup date',
                          style: TextStyle(
                            color: booking.scheduledDate != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.textMuted, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (booking.isOnDemand) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.accent, size: 22),
                          SizedBox(width: 10),
                          Text('On-demand pickup',
                              style: TextStyle(
                                  color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('A hauler will be assigned within 15–30 minutes. '
                          'You\'ll receive a push notification when confirmed.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              TextField(
                controller: _notesController,
                maxLines: 3,
                onChanged: (v) => notifier.setNotes(v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Access notes (gate code, bin location, dog on premises…)',
                  prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
        _BottomNav(
          onBack: () => notifier.prevStep(),
          onNext: (booking.isOnDemand || booking.scheduledDate != null)
              ? () => notifier.nextStep()
              : null,
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label, required this.sublabel,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      color: selected ? AppColors.accent : AppColors.textMuted,
                      fontWeight: FontWeight.w700, fontSize: 14)),
              Text(sublabel,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 4: Payment ──────────────────────────────────────────────────────────

class _PaymentStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final pickupsNotifier = ref.read(pickupsProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const Text('Confirm & Pay',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Review your pickup and authorise payment.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 20),

              // Summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: booking.location?.label ?? '—',
                    ),
                    const Divider(height: 20),
                    _SummaryRow(
                      icon: Icons.delete_outline_rounded,
                      label: 'Waste',
                      value: booking.streams.map((s) => s.emoji).join(' '),
                    ),
                    const Divider(height: 20),
                    _SummaryRow(
                      icon: Icons.schedule_rounded,
                      label: 'When',
                      value: booking.isOnDemand ? 'On-demand (ASAP)' : 'Scheduled',
                    ),
                    if (booking.notes.isNotEmpty) ...[
                      const Divider(height: 20),
                      _SummaryRow(
                        icon: Icons.notes_rounded,
                        label: 'Notes',
                        value: booking.notes,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Price breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pickup fee', style: TextStyle(color: AppColors.textSecondary)),
                        Text('MK 1,200', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sorting surcharge', style: TextStyle(color: AppColors.textSecondary)),
                        Text('MK 200', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('VAT (16.5%)', style: TextStyle(color: AppColors.textSecondary)),
                        Text('MK 231', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('MK 1,631',
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment method
              const Text('Payment Method',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              ...['Airtel Money', 'TNM Mpamba', 'M-Pesa'].asMap().entries.map((e) {
                final selected = e.key == 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? AppColors.accent : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent),
                            color: selected ? AppColors.accent : Colors.transparent,
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(e.value,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        const Icon(Icons.phone_android_rounded,
                            color: AppColors.textMuted, size: 18),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        _BottomNav(
          onBack: () => ref.read(bookingProvider.notifier).prevStep(),
          nextLabel: '📱 Pay with MoMo',
          onNext: () => _confirmBooking(context, ref),
        ),
      ],
    );
  }

  void _confirmBooking(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) Navigator.pop(context);
    // Reset booking and go home
    ref.read(bookingProvider.notifier).reset();
    if (context.mounted) {
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Pickup booked! We\'re finding a hauler near you.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String nextLabel;

  const _BottomNav({
    this.onNext,
    this.onBack,
    this.nextLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.card)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(nextLabel),
            ),
          ),
        ],
      ),
    );
  }
}
