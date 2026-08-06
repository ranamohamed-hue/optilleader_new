import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ✅ إضافة الكاش
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_state.dart';
import 'package:optialeader/feature/database_admin/data/models/search_user_model.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchField = 'username';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      context.read<SearchCubit>().searchUsers(
        query: _searchController.text.trim(),
        searchField: _currentSearchField,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ✅ استخدام الترجمة في الأزرار
            Row(
              children: [
                ChoiceChip(
                  label: Text(
                    "search.by_name".tr(),
                  ), // لو مضاف في الـ JSON، لو لأ استخدم "بحث بالاسم"
                  selected: _currentSearchField == 'username',
                  selectedColor: colorScheme.secondary,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => _currentSearchField = 'username');
                      _performSearch();
                    }
                  },
                ),
                SizedBox(width: 10.w),
                ChoiceChip(
                  label: Text(
                    "search.by_id".tr(),
                  ), // لو مضاف في الـ JSON، لو لأ استخدم "بحث بالرقم الوظيفي"
                  selected: _currentSearchField == 'employee_id',
                  selectedColor: colorScheme.secondary,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => _currentSearchField = 'employee_id');
                      _performSearch();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 15.h),

            // ✅ استخدام الترجمة في حقل البحث
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search.hint'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchCubit>().searchUsers(
                      query: '',
                      searchField: _currentSearchField,
                    );
                  },
                ),
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _performSearch();
                } else if (value.isEmpty) {
                  context.read<SearchCubit>().searchUsers(
                    query: '',
                    searchField: _currentSearchField,
                  );
                }
              },
            ),
            SizedBox(height: 20.h),

            // ✅ استخدام الترجمة في حالة عدم وجود نتائج
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(child: Text('search.loading'.tr()));
                  }

                  if (state is SearchSuccess) {
                    final users = state.users;

                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'search.no_users'.tr(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(context, users[index]);
                      },
                    );
                  }

                  if (state is SearchError) {
                    return Center(
                      child: Text('search.error_message'.tr(args: [''])),
                    );
                  }

                  return Center(
                    child: Text(
                      'search.hint'.tr(),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, SearchUserModel user) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAr = context.locale.languageCode == 'ar';

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () {
          String route = '';
          if (user.role == 'doctor') {
            route = Routes.addDoctorPage;
          } else if (user.role == 'judge') {
            route = Routes.addJudgePage;
          } else if (user.role == 'admin') {
            route = Routes.addAdminPage;
          }

          if (route.isNotEmpty) {
            context.push(
              route,
              extra: {'existingUid': user.uid, 'isViewMode': true},
            );
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              _buildProfileImage(colorScheme, user.profileImage),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? user.nameAr : user.nameEn,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Chip(
                      padding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      label: Text(
                        user.role,
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                      backgroundColor: colorScheme.primary,
                    ),
                    SizedBox(height: 5.h),
                    // ✅ استخدام الترجمة للرقم الوظيفي
                    Text(
                      'search.employee_id_label'.tr(args: [user.employeeId]),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.email_outlined,
                color: colorScheme.secondary,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ استخدام CachedNetworkImage بدل NetworkImage
  Widget _buildProfileImage(ColorScheme colorScheme, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 2),
      ),
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: ClipOval(
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 60.r,
                  height: 60.r,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Icon(
                    Icons.person,
                    color: colorScheme.primary,
                    size: 30.sp,
                  ),
                  errorWidget: (_, __, ___) => Icon(
                    Icons.person,
                    color: colorScheme.primary,
                    size: 30.sp,
                  ),
                )
              : Icon(Icons.person, color: colorScheme.primary, size: 30.sp),
        ),
      ),
    );
  }
}
