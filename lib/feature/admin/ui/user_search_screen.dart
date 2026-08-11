import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'dart:ui' as ui;

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  @override
  void initState() {
    super.initState();
    // تفعيل مراقبة البيانات فور دخول الشاشة
    context.read<DoctorDataCubit>().watchAllDoctors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('search.app_bar_title'.tr()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.admin);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.h),
          child: Container(color: colorScheme.secondary, height: 2.h),
        ),
      ),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                hintText: 'search.hint'.tr(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                // هنا ممكن مستقبلاً تضيفي Search logic في الـ Cubit
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildSectionHeader(
              context,
              'search.employee_services'.tr(),
            ),
          ),

          // عرض البيانات المربوطة بالكيوبيت
          Expanded(
            child: BlocBuilder<DoctorDataCubit, DoctorDataState>(
              builder: (context, state) {
                if (state is DoctorLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AllDoctorLoaded) {
                  final doctors = state.doctors;

                  if (doctors == null || doctors.isEmpty) {
                    return Center(child: Text('search.no_users'.tr()));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return _buildDoctorCard(context, doctors[index]);
                    },
                  );
                }

                if (state is DoctorError) {
                  return Center(
                    child: Text(
                      'search.error_message'.tr(args: [state.error.toString()]),
                    ),
                  );
                }

                return Center(child: Text('search.loading'.tr()));
              },
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildDoctorCard(BuildContext context, DoctorProfileModel doctor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = context.locale.languageCode == 'ar';

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () {
          // ✅ الانتقال لصفحة العرض والتعديل الخاصة بالدكتور
          context.push(
            Routes.addDoctorPage,
            extra: {
              'existingUid': doctor.uid ?? '', // تأكدي إن الـ UID مش null
              'isViewMode': true, // ✅ تفعيل وضع العرض المجمد
            },
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                // تغيير اتجاه الـ Row بناءً على اللغة
                textDirection: isAr
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                children: [
                  _buildProfileImage(colorScheme, doctor.profileImage),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isAr
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(
                          doctor.nameAr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          doctor.currentJobAr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          'search.employee_id_label'.tr(
                            args: [doctor.employeeId],
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 25.h, thickness: 0.5),
              Row(
                mainAxisAlignment: isAr
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Text(
                    doctor.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.email_outlined,
                    color: colorScheme.secondary,
                    size: 18.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(ColorScheme colorScheme, String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 2),
      ),
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? NetworkImage(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Icon(Icons.person, color: colorScheme.primary, size: 30.sp)
            : null,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isAr = context.locale.languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark; // ✅ ضيف السطر ده
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isAr
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isAr)
            Icon(
              Icons.label_important_outline,
              color: isDark?Colors.white:Colors.black,
              size: 20.sp,
            ),
          if (!isAr) SizedBox(width: 8.w),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isAr) SizedBox(width: 8.w),
          if (isAr)
            Icon(
              Icons.label_important_outline,
              color: theme.colorScheme.secondary,
              size: 20.sp,
            ),
        ],
      ),
    );
  }
}
