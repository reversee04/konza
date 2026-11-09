import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(packagesProvider);
    final active = ref.watch(activeSubscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subscription Plans'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (active != null) ...[
            _ActivePlanBanner(plan: active),
            const SizedBox(height: 24),
          ],
          const Text('Available Plans',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Billed monthly. Cancel or pause anytime.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          ...packages.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _PlanCard(plan: p, isActive: active?.id == p.id),
              )),
          const SizedBox(height: 24),

          // FAQ
          const Text('Frequently Asked',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => _FaqTile(question: faq[0], answer: faq[1])),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static const _faqs = [
    ['Can I pause my subscription?', 'Yes. You can pause for up to 2 months per year from your subscription settings.'],
    ['What happens if a pickup is missed?', 'We will re-dispatch within 4 hours and credit your account for the inconvenience.'],
    ['Can I change plans anytime?', 'Yes. Changes take effect at the start of your next billing cycle.'],
    ['How is sorted waste verified?', 'Haulers photo-document each stream. Hub operators confirm and weigh loads on arrival.'],
  ];
}

class _ActivePlanBanner extends StatelessWidget {
  final SubscriptionPackage plan;
  const _ActivePlanBanner({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A4A1A), Color(0xFF0D2A0D)],
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
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                ),
                child: const Text('ACTIVE', style: TextStyle(
                    color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
              ),
              const Spacer(),
              const Icon(Icons.stars_rounded, color: AppColors.warning, size: 18),
              const SizedBox(width: 4),
              const Text('Plus Plan', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next pickup', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text('Tuesday, Nov 5', style: TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Monthly', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text('MK ${plan.monthlyPrice.toStringAsFixed(0)}', style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 20)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    side: const BorderSide(color: AppColors.textMuted),
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Pause'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                  child: const Text('Manage'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final SubscriptionPackage plan;
  final bool isActive;

  const _PlanCard({required this.plan, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.popular
              ? AppColors.accent.withOpacity(0.5)
              : isActive
                  ? AppColors.accentDim.withOpacity(0.5)
                  : Colors.transparent,
          width: plan.popular ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.popular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text('⭐ Most Popular',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 20)),
                        Text(plan.description,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('MK ${plan.monthlyPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 22)),
                        const Text('/month',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Waste streams
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: plan.streamsIncluded.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${s.emoji} ${s.label}',
                        style: TextStyle(color: s.color, fontSize: 11, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
                const SizedBox(height: 14),

                // Features
                ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.accentDim, size: 16),
                      const SizedBox(width: 8),
                      Text(f, style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                )),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: isActive ? null : () {
                    ref.read(activeSubscriptionProvider.notifier).state = plan;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to ${plan.name} plan!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: isActive
                      ? ElevatedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          foregroundColor: AppColors.textMuted,
                        )
                      : null,
                  child: Text(isActive ? '✓ Current Plan' : 'Choose ${plan.name}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(question,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        iconColor: AppColors.accent,
        collapsedIconColor: AppColors.textMuted,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
