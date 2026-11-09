import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickup = ref.watch(activePickupProvider);

    if (pickup == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Live Tracking')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🚛', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              Text('No active pickup',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Book a pickup to track it here',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Simulated map background
          _MapPlaceholder(pulseController: _pulseController),

          // Bottom sheet overlay
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: pickup.status.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(pickup.status.icon,
                              color: pickup.status.color, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pickup.status.label,
                                  style: TextStyle(
                                      color: pickup.status.color,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18)),
                              Text('ETA: ${pickup.etaMinutes} minutes',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                        _EtaCircle(minutes: pickup.etaMinutes ?? 0),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status stepper
                    _StatusStepper(currentStatus: pickup.status),
                    const SizedBox(height: 24),

                    // Hauler card
                    if (pickup.haulerName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                              child: Text(
                                pickup.haulerName![0],
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pickup.haulerName!,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16)),
                                  const Text('Certified Hauler • ⭐ 4.8',
                                      style: TextStyle(
                                          color: AppColors.textMuted, fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.accent.withOpacity(0.15),
                              ),
                              icon: const Icon(Icons.phone_rounded, color: AppColors.accent),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () {},
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.info.withOpacity(0.15),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded,
                                  color: AppColors.info),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Pickup details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pickup Details',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: AppColors.accent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(pickup.address,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.textMuted, size: 16),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 6,
                                children: pickup.streams.map((s) => Text(
                                    '${s.emoji} ${s.label}',
                                    style: TextStyle(
                                        color: s.color, fontSize: 12, fontWeight: FontWeight.w600)),
                                ).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Report issue
                    OutlinedButton.icon(
                      onPressed: () => _showReportDialog(context),
                      icon: const Icon(Icons.report_outlined, color: AppColors.warning),
                      label: const Text('Report an Issue',
                          style: TextStyle(color: AppColors.warning)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.warning),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: AppColors.surface.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary, size: 18),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report an Issue',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...['Hauler is late', 'Hauler skipped my location',
                'Wrong waste collected', 'Rude behaviour', 'Other']
                .map((reason) => ListTile(
                      leading: const Icon(Icons.report_outlined, color: AppColors.warning),
                      title: Text(reason, style: const TextStyle(color: AppColors.textPrimary)),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Issue reported. Support will contact you shortly.'),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      },
                    )),
          ],
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final AnimationController pulseController;
  const _MapPlaceholder({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A2A1A),
      child: CustomPaint(
        size: Size.infinite,
        painter: _MapPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Pulsing hauler marker
              AnimatedBuilder(
                animation: pulseController,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 0; i < 3; i++)
                        Transform.scale(
                          scale: 1 + (pulseController.value + i * 0.33) % 1 * 1.5,
                          child: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accent.withOpacity(
                                    (1 - (pulseController.value + i * 0.33) % 1) * 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        width: 48, height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_shipping_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF243024)
      ..strokeWidth = 1;

    // Grid lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Road lines
    final roadPaint = Paint()
      ..color = const Color(0xFF2D3E2D)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(0, size.height * 0.4),
        Offset(size.width, size.height * 0.4),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.35, 0),
        Offset(size.width * 0.35, size.height),
        roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.7, 0),
        Offset(size.width * 0.7, size.height * 0.6),
        roadPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _EtaCircle extends StatelessWidget {
  final int minutes;
  const _EtaCircle({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent.withOpacity(0.1),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$minutes',
              style: const TextStyle(
                  color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 20)),
          const Text('min', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final PickupStatus currentStatus;
  const _StatusStepper({required this.currentStatus});

  static const _steps = [
    PickupStatus.assigned,
    PickupStatus.enRoute,
    PickupStatus.arrived,
    PickupStatus.collected,
    PickupStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(currentStatus);

    return Column(
      children: List.generate(_steps.length, (i) {
        final step = _steps[i];
        final done = i < currentIndex;
        final active = i == currentIndex;
        final isLast = i == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.accent
                        : active
                            ? AppColors.accent.withOpacity(0.2)
                            : AppColors.card,
                    border: active
                        ? Border.all(color: AppColors.accent, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                        : Icon(step.icon,
                            color: active ? AppColors.accent : AppColors.textMuted, size: 18),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2, height: 28,
                    color: done ? AppColors.accent : AppColors.card,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                step.label,
                style: TextStyle(
                  color: done || active ? AppColors.textPrimary : AppColors.textMuted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: active ? 15 : 14,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
