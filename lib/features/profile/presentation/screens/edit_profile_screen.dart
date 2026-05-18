import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _bioCtrl;
  late String _selectedGoal;

  final List<String> _goals = [
    'بناء العضلات',
    'خسارة الوزن',
    'تحسين اللياقة',
    'زيادة القوة',
    'تحسين المرونة',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _ageCtrl = TextEditingController(text: widget.user.age.toString());
    _weightCtrl =
        TextEditingController(text: widget.user.weight.toString());
    _heightCtrl =
        TextEditingController(text: widget.user.height.toString());
    _bioCtrl = TextEditingController(text: widget.user.bio);
    _selectedGoal = _goals.contains(widget.user.fitnessGoal)
        ? widget.user.fitnessGoal
        : _goals.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileCubit>().saveProfile(
          current: widget.user,
          name: _nameCtrl.text,
          age: int.parse(_ageCtrl.text),
          weight: double.parse(_weightCtrl.text),
          height: double.parse(_heightCtrl.text),
          fitnessGoal: _selectedGoal,
          bio: _bioCtrl.text,
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
          'تعديل البيانات',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSaved) {
            // Sync auth cubit
            context.read<AuthCubit>().updateProfile(state.user);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ البيانات بنجاح ✓'),
                backgroundColor: AppColors.accentGreen,
              ),
            );
            Navigator.pop(context);
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSaving = state is ProfileSaving;
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
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'أدخل اسمك' : null,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _bioCtrl,
                    label: 'نبذة شخصية',
                    icon: Icons.info_outline_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          controller: _weightCtrl,
                          label: 'الوزن (كجم)',
                          icon: Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (double.tryParse(v) == null) return 'رقم';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: _heightCtrl,
                          label: 'الطول (سم)',
                          icon: Icons.height_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (double.tryParse(v) == null) return 'رقم';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: _ageCtrl,
                          label: 'العمر',
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            if (int.tryParse(v) == null) return 'رقم';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الهدف الرياضي',
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
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'حفظ التغييرات',
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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
          textDirection: TextDirection.rtl,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
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
