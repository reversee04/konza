import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  String _selectedCountry = '+265';
  final _formKey = GlobalKey<FormState>();

  final _countries = [
    (code: '+265', flag: '🇲🇼', name: 'Malawi'),
    (code: '+254', flag: '🇰🇪', name: 'Kenya'),
    (code: '+255', flag: '🇹🇿', name: 'Tanzania'),
    (code: '+256', flag: '🇺🇬', name: 'Uganda'),
    (code: '+27', flag: '🇿🇦', name: 'South Africa'),
    (code: '+234', flag: '🇳🇬', name: 'Nigeria'),
    (code: '+233', flag: '🇬🇭', name: 'Ghana'),
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authProvider.notifier);
    final phone = '$_selectedCountry ${_phoneController.text.trim()}';
    await auth.requestOtp(phone);
    if (mounted) context.go('/auth/otp', extra: phone);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final country = _countries.firstWhere((c) => c.code == _selectedCountry);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.recycling_rounded,
                      color: AppColors.accent, size: 32),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Enter your\nphone number',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "We'll send a one-time code to verify your number.",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Country + Phone input
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      // Country picker
                      GestureDetector(
                        onTap: () => _showCountryPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Color(0xFF2D3A2D))),
                          ),
                          child: Row(
                            children: [
                              Text(country.flag, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Text(country.code,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: AppColors.textMuted, size: 20),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: '999 000 111',
                            border: InputBorder.none,
                            fillColor: Colors.transparent,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().length < 7) return 'Enter a valid number';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Your data is encrypted and never shared',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.7)),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                        )
                      : const Text('Send OTP Code'),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: AppColors.accent.withOpacity(0.8)),
                        ),
                        const TextSpan(text: ' & '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: AppColors.accent.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted, borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Country', style: TextStyle(
            color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _countries.length,
              itemBuilder: (_, i) {
                final c = _countries[i];
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 28)),
                  title: Text(c.name, style: const TextStyle(color: AppColors.textPrimary)),
                  trailing: Text(c.code, style: const TextStyle(color: AppColors.textMuted)),
                  onTap: () {
                    setState(() => _selectedCountry = c.code);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
