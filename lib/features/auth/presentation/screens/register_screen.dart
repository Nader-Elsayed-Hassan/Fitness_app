import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/screens/main_shell.dart';
import '../cubit/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedGoal = 'بناء العضلات';

  final List<String> _goals = [
    'بناء العضلات',
    'خسارة الوزن',
    'تحسين اللياقة',
    'زيادة القوة',
    'تحسين المرونة',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passCtrl.text,
          age: int.parse(_ageCtrl.text),
          weight: double.parse(_weightCtrl.text),
          height: double.parse(_heightCtrl.text),
          fitnessGoal: _selectedGoal,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'إنشاء حساب',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (ctx, animation, secondaryAnimation) =>
                    const MainShell(),
                transitionsBuilder:
                    (ctx, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 16),
                  _field(
                    controller: _nameCtrl,
                    label: 'الاسم الكامل',
                    hint: 'أحمد محمد',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'أدخل اسمك' : null,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _emailCtrl,
                    label: 'البريد الإلكتروني',
                    hint: 'example@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'أدخل البريد';
                      if (!v.contains('@')) return 'بريد غير صحيح';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _passCtrl,
                    label: 'كلمة المرور',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                      if (v.length < 6) return 'على الأقل 6 أحرف';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: _weightCtrl,
                          label: 'الوزن (كجم)',
                          hint: '75',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (double.tryParse(v) == null) return 'رقم فقط';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: _heightCtrl,
                          label: 'الطول (سم)',
                          hint: '175',
                          icon: Icons.height_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (double.tryParse(v) == null) return 'رقم فقط';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: _ageCtrl,
                          label: 'العمر',
                          hint: '25',
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (int.tryParse(v) == null) return 'رقم فقط';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Goal selector
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'هدفك الرياضي',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGoal,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceVariant,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted),
                        items: _goals
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g,
                                      textDirection: TextDirection.rtl),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedGoal = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'إنشاء الحساب',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
