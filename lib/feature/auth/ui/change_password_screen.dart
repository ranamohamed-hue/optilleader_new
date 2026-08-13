import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isObscure = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackBar("validation.password_mismatch".tr());
      return;
    }

    context.read<AuthCubit>().completeFirstLogin(
      newPassword: passwordController.text.trim(),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("change_password.title".tr()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            // ==============================
            // فشل تغيير كلمة المرور
            // ==============================
            if (state is UpdatePasswordErrorState) {
              _showErrorSnackBar(state.error);
            }
            // ==============================
            // نجاح تغيير كلمة المرور
            // ==============================
            else if (state is UpdatePasswordSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("change_password.success_msg".tr()),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              // نرجع لصفحة تسجيل الدخول
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go('/login');
                }
              });
            }
          },

          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 30.h),

                    // ==============================
                    // Icon
                    // ==============================
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 80.sp,
                      color: const Color(0xFF000080),
                    ),

                    SizedBox(height: 20.h),

                    // ==============================
                    // Header
                    // ==============================
                    Text(
                      "change_password.header".tr(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF000080),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12.h),

                    // ==============================
                    // Subtitle
                    // ==============================
                    Text(
                      "change_password.subtitle".tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40.h),

                    // ==============================
                    // New Password
                    // ==============================
                    _buildPasswordField(
                      controller: passwordController,
                      label: "fields.new_password".tr(),
                      isObscure: isObscure,
                      onToggle: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                    ),

                    SizedBox(height: 20.h),

                    // ==============================
                    // Confirm Password
                    // ==============================
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: "fields.confirm_password".tr(),
                      isObscure: isObscure,
                      onToggle: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                    ),

                    SizedBox(height: 50.h),

                    // ==============================
                    // Save Button / Loading
                    // ==============================
                    state is UpdatePasswordLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF000080),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                "change_password.submit".tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // Password Field
  // ============================================================

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,

      obscureText: isObscure,

      keyboardType: TextInputType.text,

      inputFormatters: [LengthLimitingTextInputFormatter(14)],

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF000080)),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),

        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),

      validator: (v) {
        if (v == null || v.isEmpty) {
          return "validation.required".tr();
        }

        if (v.length > 14) {
          return "الحد الأقصى لكلمة المرور 14 حرف";
        }

        if (v.length < 6) {
          return "validation.password_short".tr();
        }

        return null;
      },
    );
  }
}
