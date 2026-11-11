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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    context.read<DoctorDataCubit>().clearSearch();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() => _hasSearched = false);
      context.read<DoctorDataCubit>().clearSearch();
      return;
    }

    setState(() => _hasSearched = true);
    context.read<DoctorDataCubit>().searchDoctors(query);
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
              controller: _searchController,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: colorScheme.onSurface,
              ), // ✅ واضح في الدارك مود
              decoration: InputDecoration(
                hintText: 'search.hint'.tr(),
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ), // ✅ واضح في الدارك مود
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ), // ✅
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // عنوان القسم (يظهر فقط أثناء البحث)
          if (_hasSearched)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSectionHeader(
                context,
                'search.employee_services'.tr(),
              ),
            ),

          // شاشة البداية (قبل الكتابة)
          if (!_hasSearched) Expanded(child: _buildEmptySearchState(context)),

          // عرض نتائج البحث
          if (_hasSearched)
            Expanded(
              child: BlocBuilder<DoctorDataCubit, DoctorDataState>(
                builder: (context, state) {
                  if (state is DoctorLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (state is DoctorSearchLoaded) {
                    final doctors = state.doctors;

                    if (doctors == null || doctors.isEmpty) {
                      return _buildNoResultsState(context);
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
                        'search.error_message'.tr(
                          args: [state.error.toString()],
                        ),
                        style: TextStyle(color: colorScheme.error),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // حالة الشاشة الفاضية
  // ─────────────────────────────────────────────
  Widget _buildEmptySearchState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80.sp,
            color: colorScheme.onSurfaceVariant.withOpacity(
              0.4,
            ), // ✅ واضح في الدارك مود
          ),
          SizedBox(height: 20.h),
          Text(
            'search.start_searching'.tr(),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(
                0.6,
              ), // ✅ واضح في الدارك مود
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'search.start_searching_desc'.tr(),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(
                0.4,
              ), // ✅ واضح في الدارك مود
              fontSize: 13.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // حالة عدم وجود نتائج
  // ─────────────────────────────────────────────
  Widget _buildNoResultsState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 70.sp,
            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
          SizedBox(height: 20.h),
          Text(
            'search.no_results'.tr(),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'search.no_results_desc'.tr(args: [_searchQuery]),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              fontSize: 13.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // كرت الدكتور (صامت بدون ضغط)
  // ─────────────────────────────────────────────
  Widget _buildDoctorCard(BuildContext context, DoctorProfileModel doctor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = context.locale.languageCode == 'ar';

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: colorScheme.surface, // ✅ لون الكارت ديناميكي
      elevation: theme.brightness == Brightness.dark
          ? 0
          : 1, // ✅ إزالة الظل في الدارك مود
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
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
                          color: colorScheme.onSurface, // ✅ واضح في الدارك مود
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        doctor.currentJobAr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: colorScheme
                              .onSurfaceVariant, // ✅ واضح في الدارك مود
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'search.employee_id_label'.tr(
                          args: [doctor.employeeId],
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: colorScheme.outline, // ✅ بدل Colors.grey
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              height: 25.h,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
            Row(
              mainAxisAlignment: isAr
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    doctor.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      color:
                          colorScheme.onSurfaceVariant, // ✅ واضح في الدارك مود
                    ),
                    overflow: TextOverflow.ellipsis,
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
              color: theme.colorScheme.onSurface, // ✅ واضح في الدارك مود
              size: 20.sp,
            ),
          if (!isAr) SizedBox(width: 8.w),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // ✅ واضح في الدارك مود
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
