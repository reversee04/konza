import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final activePickup = ref.watch(activePickupProvider);
    final pickups = ref.watch(pickupsProvider);
    final stats = ref.watch(recyclingStatsProvider);

    final recentPickups = pickups
        .where((p) => p.status == PickupStatus.completed)
        .toList()
        ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D2B0D), AppColors.background],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            auth.name ?? 'Welcome',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                            child: Text(
                              (auth.name ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              width: 12, height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.success, shape: BoxShape.circle,
                                border: Border.fromBorderSide(BorderSide(color: AppColors.background, width: 2)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick stats bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryLight.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        _StatChip(
                          icon: Icons.recycling_rounded,
                          label: '${stats.totalKgDiverted.toStringAsFixed(0)} kg',
                          sublabel: 'Diverted',
                          color: AppColors.accent,
                        ),
                        _Divider(),
                        _StatChip(
                          icon: Icons.eco_rounded,
                          label: '${stats.co2Saved.toStringAsFixed(0)} kg',
                          sublabel: 'CO₂ saved',
                          color: AppColors.success,
                        ),
                        _Divider(),
                        _StatChip(
                          icon: Icons.stars_rounded,
                          label: '${stats.creditsEarned}',
                          sublabel: 'Credits',
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active Pickup Card
                if (activePickup != null) ...[
                  _ActivePickupCard(pickup: activePickup),
                  const SizedBox(height: 20),
                ],

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_box_rounded,
                        label: 'Book Pickup',
                        sublabel: 'On-demand or schedule',
                        color: AppColors.accent,
                        onTap: () => context.go('/book'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'My Impact',
                        sublabel: 'Recycling dashboard',
                        color: AppColors.info,
                        onTap: () => context.go('/recycling'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.subscriptions_rounded,
                        label: 'Subscription',
                        sublabel: 'Manage your plan',
                        color: AppColors.accentDim,
                        onTap: () => context.go('/subscriptions'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Payments',
                        sublabel: 'Invoices & history',
                        color: AppColors.warning,
                        onTap: () => context.go('/payments'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Upcoming pickup
                const _SectionHeader(title: 'Upcoming Pickups'),
                const SizedBox(height: 12),
                ...pickups
                    .where((p) => p.status == PickupStatus.scheduled || p.status == PickupStatus.assigned)
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PickupListTile(pickup: p),
                        )),

                const SizedBox(height: 20),
                const _SectionHeader(title: 'Recent Pickups'),
                const SizedBox(height: 12),
                ...recentPickups.take(3).map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PickupListTile(pickup: p),
                    )),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/book'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book Pickup', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 🌅';
    if (h < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36, width: 1, color: AppColors.primaryLight.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _StatChip({
    required this.icon, required this.label,
    required this.sublabel, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          Text(sublabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon, required this.label,
    required this.sublabel, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            Text(sublabel,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ActivePickupCard extends StatelessWidget {
  final Pickup pickup;
  const _ActivePickupCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/tracking'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight.withOpacity(0.3), AppColors.card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pickup.status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: pickup.status.color.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(pickup.status.icon, color: pickup.status.color, size: 14),
                      const SizedBox(width: 6),
                      Text(pickup.status.label,
                          style: TextStyle(
                              color: pickup.status.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('ETA ${pickup.etaMinutes} min',
                      style: const TextStyle(
                          color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.local_shipping_rounded, color: AppColors.accent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pickup.haulerName ?? 'Hauler',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text(pickup.locationLabel,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...pickup.streams.take(3).map((s) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: s.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(s.label.split(' ')[0],
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                          ],
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: AppColors.accent, size: 16),
                  const SizedBox(width: 8),
                  const Text('Tap to track live location',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.textMuted, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupListTile extends StatelessWidget {
  final Pickup pickup;
  const _PickupListTile({required this.pickup});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, MMM d • h:mm a');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: pickup.status.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(pickup.status.icon, color: pickup.status.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pickup.locationLabel,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(fmt.format(pickup.scheduledFor),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: pickup.streams.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(s.emoji,
                        style: const TextStyle(fontSize: 12)),
                  )).toList(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pickup.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(pickup.status.label,
                    style: TextStyle(
                        color: pickup.status.color, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              if (pickup.totalAmount != null) ...[
                const SizedBox(height: 4),
                Text('MK ${pickup.totalAmount!.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
