import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Wallet balance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A3A1A), Color(0xFF0D2A0D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.accent, size: 22),
                    const SizedBox(width: 8),
                    const Text('EcoWallet',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Active', style: TextStyle(color: AppColors.success, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('MK 4,500.00',
                    style: TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 32)),
                const Text('Available balance',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Top Up'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text('History'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // MoMo methods
          const Text('Payment Methods',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _MomoCard(
            provider: 'Airtel Money',
            number: '+265 999 *** 111',
            isDefault: true,
            balance: 'MK 12,400',
            color: const Color(0xFFE53935),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Payment Method'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
          const SizedBox(height: 28),

          // Invoices
          Row(
            children: [
              const Text('Invoices',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Download All',
                    style: TextStyle(color: AppColors.accent, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...invoices.map((inv) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InvoiceRow(invoice: inv),
              )),
          const SizedBox(height: 32),

          // Payment history
          const Text('Recent Transactions',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._mockTransactions.map((t) => _TransactionRow(
                emoji: t[0],
                title: t[1],
                subtitle: t[2],
                amount: t[3],
                positive: t[4] == 'true',
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static const _mockTransactions = [
    ['🚛', 'Pickup #001 – Home', 'Oct 29, 2026', '−MK 1,631', 'false'],
    ['♻️', 'Recycling Credit', 'Oct 25, 2026', '+MK 150', 'true'],
    ['📋', 'Oct Subscription', 'Oct 1, 2026', '−MK 8,500', 'false'],
    ['♻️', 'Recycling Credit', 'Sep 22, 2026', '+MK 90', 'true'],
    ['🚛', 'Pickup #007 – Shop', 'Sep 18, 2026', '−MK 800', 'false'],
    ['📋', 'Sep Subscription', 'Sep 1, 2026', '−MK 8,500', 'false'],
  ];
}

class _MomoCard extends StatelessWidget {
  final String provider;
  final String number;
  final bool isDefault;
  final String balance;
  final Color color;

  const _MomoCard({
    required this.provider,
    required this.number,
    required this.isDefault,
    required this.balance,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDefault ? AppColors.accent.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(provider[0],
                  style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(number, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(balance,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              if (isDefault)
                const Text('Default',
                    style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceRow({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status == 'Paid';
    final isUpcoming = invoice.status == 'Upcoming';
    final statusColor = isPaid
        ? AppColors.success
        : isUpcoming
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPaid ? Icons.receipt_rounded : Icons.receipt_long_rounded,
              color: statusColor, size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.period,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(DateFormat('MMM d, yyyy').format(invoice.date),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('MK ${invoice.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(invoice.status,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, color: AppColors.textMuted, size: 18),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String amount;
  final bool positive;

  const _TransactionRow({
    required this.emoji, required this.title, required this.subtitle,
    required this.amount, required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Text(amount,
                style: TextStyle(
                    color: positive ? AppColors.success : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
