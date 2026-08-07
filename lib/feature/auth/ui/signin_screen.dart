import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_state.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(">>> SignInView build");
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Logo inside an elevated card with rounded corners
                  Container(
                    height: 180.h,
                    width: 180.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Image.asset(
                        'assets/images/logoscreen.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  /// App Name - بني غامق
                  Text(
                    "OptiLeader",
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723), // ← بني غامق فخم
                    ),
                  ),

                  SizedBox(height: 8.h),

                  /// Subtitle - بني فاتح شوية
                  Text(
                    "login.subtitle".tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF3E2723).withOpacity(0.7), // ← بني غامق أخف للعنوان الفرعي
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),

                  /// Email Field
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "fields.email".tr(),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "validation.required".tr();
                      if (!v.contains('@')) return "validation.invalid_email".tr();
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  /// Password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: isObscure,
                    decoration: InputDecoration(
                      labelText: "كلمة المرور (الرقم القومي لأول مرة)",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => isObscure = !isObscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "validation.required".tr();
                      if (v.length < 6) return "validation.password_short".tr();
                      return null;
                    },
                  ),

                  SizedBox(height: 40.h),

                  /// Login Button
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is LoginErrorState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is LoginLoadingState) {
                        return const CircularProgressIndicator();
                      }

                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 48, 33, 20),      // ← زر أسود يليق مع البني
                          foregroundColor: Colors.white,      // ← نص أبيض
                          elevation: 5,                       // ← ظل بارز
                          minimumSize: Size(double.infinity, 52.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "login.button".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}