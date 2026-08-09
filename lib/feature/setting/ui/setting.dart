import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/core/theming/logic/theme_cubit.dart';
import 'package:optialeader/core/theming/logic/theme_state.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart'; 
import 'package:optialeader/feature/setting/data/models/user_setting_model.dart';
import 'package:optialeader/feature/setting/logic/setting_cubit.dart';
import 'package:optialeader/feature/setting/logic/setting_state.dart';

class SettingsScreen extends StatefulWidget {
  final String uid;
  final String role;
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    required this.uid,
    required this.role,
    this.onBack,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController addressArController;
  late TextEditingController addressEnController;
  late TextEditingController phoneController;
  bool isInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    addressArController = TextEditingController();
    addressEnController = TextEditingController();
    phoneController = TextEditingController();

    context.read<SettingCubit>().getUserData(
      uid: widget.uid,
      role: widget.role,
    );
  }

  @override
  void dispose() {
    addressArController.dispose();
    addressEnController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _onSavePressed(UserSettingsModel? user) {
    if (user != null) {
      final updatedData = user.copyWith(
        addressAr: addressArController.text.trim(),
        addressEn: addressEnController.text.trim(),
        phone: phoneController.text.trim(),
      );

      context.read<SettingCubit>().updateUserData(
        user: updatedData,
        role: widget.role,
      );
    }
  }

    String _getHomeRoute() {
    switch (widget.role) {
      case 'admin':
        return Routes.admin;
      case 'database_admin':
        return Routes.databaseAdmin;
      case 'judge':
        return Routes.judge;
      case 'employee': 
        return Routes.adminManager;
      default:
        return Routes.user;
    }
  }

  //  دالة عرض رسالة التأكيد قبل تسجيل الخروج
  void _showLogoutDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('settings.logout'.tr()),
          content: Text('settings.logout_confirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'settings.cancel'.tr(),
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // نقفل الـ Dialog الأول
                _performLogout(); // نسجل الخروج
              },
              child: Text(
                'settings.logout'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  //  دالة تسجيل الخروج الفعلي
  void _performLogout() {
    if (!context.mounted) return;
   
    context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<SettingCubit, SettingState>(
      listener: (context, state) {
        if (!context.mounted) return;

        if (state is SettingFetchSuccess && !isInitialized) {
          addressArController.text = state.user.addressAr;
          addressEnController.text = state.user.addressEn;
          phoneController.text = state.user.phone;
          isInitialized = true;
        }

        if (state is SettingUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state is SettingImageUploadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.image_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (state is SettingError) {
          String errorMessage = state.message;
          if (state.message == "ERROR_USER_NOT_FOUND") {
            errorMessage = "settings.error_user_not_found".tr();
          } else if (state.message == "ERROR_DB_CONNECTION" ||
              state.message == "ERROR_DB_UPDATE") {
            errorMessage = "settings.error_db".tr();
          } else if (state.message == "ERROR_UNKNOWN") {
            errorMessage = "settings.error_unknown".tr();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
                child: PopScope(
        // ✅ لو مفيش onBack مخصص، وهناك شاشات في الـ Stack، يسمح للنظام بالرجوع تلقائي
        canPop: widget.onBack == null && context.canPop(),
        onPopInvokedWithResult: (didPop, result) {
          // لو النظام قدر يرجع فعلاً، مكملش الكود ده
          if (didPop) return;
          
          if (widget.onBack != null) {
            // لو الشاشة جوه BottomNav أو فيه action مخصص
            widget.onBack!();
          } else if (!context.mounted) {
            return;
          } else {
            // لو مفيش شاشات قبل كده (جينا عن طريق go)، روح للصفحة الرئيسية
            context.go(_getHomeRoute());
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 30.sp),
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (!context.mounted) {
                  return;
                } else if (context.canPop()) {
                  // لو جينا عن طريق push، ارجع خطوة واحدة للوراء
                  context.pop();
                } else {
                  // لو جينا عن طريق go والـ Stack فاضي، روح للهوم
                  context.go(_getHomeRoute());
                }
              },
            ),
            title: Text('settings.title'.tr()),
            centerTitle: true,
          ),
          body: BlocBuilder<SettingCubit, SettingState>(
                        builder: (context, state) {
              final UserSettingsModel? user;
              final bool isUploading;

              if (state is SettingFetchSuccess) {
                user = state.user;
                isUploading = false;
              } else if (state is SettingImageUploading) {
                user = state.user;
                isUploading = true;
              } else if (state is SettingUpdateSuccess) {
                user = state.user;
                isUploading = false;
              } else if (state is SettingImageUploadSuccess) {
                user = state.user;
                isUploading = false;
              } else if (state is SettingError) {
                user = state.user;
                isUploading = false;
              } else {
                user = null;
                isUploading = false;
              }

              if (state is SettingLoading && !isInitialized) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, user, isUploading),
                    SizedBox(height: 60.h),

                    // قسم البيانات الشخصية
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'settings.personal_info'.tr(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _buildInputField(
                            context: context,
                            label: 'settings.name_ar'.tr(),
                            icon: Icons.person_outline,
                            initialValue: user?.nameAr ?? "...",
                            enabled: false,
                          ),
                          _buildInputField(
                            context: context,
                            label: 'settings.name_en'.tr(),
                            icon: Icons.person_outline,
                            initialValue: user?.nameEn ?? "...",
                            enabled: false,
                          ),
                          _buildInputField(
                            context: context,
                            label: 'settings.university_email'.tr(),
                            icon: Icons.email_outlined,
                            initialValue: user?.email ?? "...",
                            enabled: false,
                          ),
                          Divider(color: colorScheme.primary.withOpacity(0.3)),
                          SizedBox(height: 10.h),
                          _buildInputField(
                            context: context,
                            label: 'settings.address_ar'.tr(),
                            icon: Icons.location_on_outlined,
                            controller: addressArController,
                          ),
                          _buildInputField(
                            context: context,
                            label: 'settings.address_en'.tr(),
                            icon: Icons.location_on_outlined,
                            controller: addressEnController,
                          ),
                          _buildInputField(
                            context: context,
                            label: 'settings.phone'.tr(),
                            icon: Icons.phone_android_outlined,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 20.h),
                          state is SettingLoading && isInitialized
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                  ),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _onSavePressed(user),
                                    child: Text("settings.save".tr()),
                                  ),
                                ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),

                    // قسم إعدادات التطبيق
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'settings.app_settings'.tr(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _buildSettingsCard(context),
                          SizedBox(height: 30.h),

                          //  زر تسجيل الخروج
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showLogoutDialog,
                              icon: const Icon(Icons.logout, color: Colors.red),
                              label: Text(
                                'settings.logout'.tr(),
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDarkMode = themeCubit.state.isDarkMode;
    final currentLocale = context.locale;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          SwitchListTile(
            title: Text('settings.change_language'.tr()),
            subtitle: Text(
              currentLocale.languageCode == 'ar' ? 'العربية' : 'English',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            secondary: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.secondary,
            ),
            value: currentLocale.languageCode == 'ar',
            onChanged: (val) {
              if (currentLocale.languageCode == 'ar') {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('ar'));
              }
            },
          ),
          Divider(height: 0, indent: 15.w, endIndent: 15.w),
          SwitchListTile(
            title: Text('settings.dark_mode'.tr()),
            subtitle: Text(
              isDarkMode ? 'settings.enabled'.tr() : 'settings.disabled'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            value: isDarkMode,
            onChanged: (val) {
              themeCubit.toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserSettingsModel? user,
    bool isUploading,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final String imageUrl = user?.profileImage ?? "";

    return Container(
      height: 100.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.r)),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -45.h,
            child: GestureDetector(
              onTap: isUploading || user == null
                  ? null
                  : () async {
                      final XFile? pickedFile = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        requestFullMetadata: false,
                      );

                      if (pickedFile != null && context.mounted) {
                        context.read<SettingCubit>().uploadProfileImage(
                          uid: widget.uid,
                          imageFile: File(pickedFile.path),
                          currentUser: user,
                          role: widget.role,
                        );
                      }
                    },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.secondary,
                        width: 3.w,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: colorScheme.surface,
                      child: CircleAvatar(
                        radius: 47.r,
                        backgroundColor: colorScheme.surface,
                        child: isUploading
                            ? CircularProgressIndicator(
                                color: colorScheme.secondary,
                              )
                            : ClipOval(
                                child: imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 94.r,
                                        height: 94.r,
                                        fit: BoxFit.cover,
                                        placeholder: (_, _) => Icon(
                                          Icons.person,
                                          size: 45.sp,
                                          color: colorScheme.primary,
                                        ),
                                        errorWidget: (_, _, _) => Icon(
                                          Icons.person,
                                          size: 45.sp,
                                          color: colorScheme.primary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 45.sp,
                                        color: colorScheme.primary,
                                      ),
                              ),
                      ),
                    ),
                  ),
                  if (!isUploading)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required IconData icon,
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22.sp),
        ),
      ),
    );
  }
}
