import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';

class EmployeeEvaluatorsPage extends StatefulWidget {
  final EmployeeNominationRequestModel request;

  const EmployeeEvaluatorsPage({
    super.key,
    required this.request,
  });

  @override
  State<EmployeeEvaluatorsPage> createState() =>
      _EmployeeEvaluatorsPageState();
}

class _EmployeeEvaluatorsPageState
    extends State<EmployeeEvaluatorsPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'employee_evaluators.select_evaluator'.tr(),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // SEARCH
            // ==================================================

            Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                10.h,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      'employee_evaluators.search'.tr(),

                  prefixIcon: const Icon(
                    Icons.search_rounded,
                  ),

                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                          ),
                        )
                      : null,

                  filled: true,

                  fillColor:
                      theme.cardTheme.color ??
                          theme.cardColor,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ==================================================
            // TITLE
            // ==================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 6.h,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'employee_evaluators.available_evaluators'
                      .tr(),

                  style:
                      theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkText
                        : AppColors.navyDark,
                  ),
                ),
              ),
            ),

            // ==================================================
            // EVALUATORS
            // ==================================================

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      'role',
                      isEqualTo: 'judge',
                    )
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(
                      context,
                      snapshot.error.toString(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final evaluators =
                      snapshot.data!.docs.where((doc) {
                    final data =
                        doc.data()
                            as Map<String, dynamic>;

                    return _matchesSearch(data);
                  }).toList();

                  if (evaluators.isEmpty) {
                    return _buildNoSearchResults(
                      context,
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      8.h,
                      16.w,
                      25.h,
                    ),

                    itemCount: evaluators.length,

                    separatorBuilder: (_, __) =>
                        SizedBox(height: 10.h),

                    itemBuilder: (context, index) {
                      final doc =
                          evaluators[index];

                      final data =
                          doc.data()
                              as Map<String, dynamic>;

                      return _buildEvaluatorCard(
                        context,
                        doc.id,
                        data,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EVALUATOR CARD
  // ============================================================

  Widget _buildEvaluatorCard(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    final name = _getEvaluatorName(data);

    final email =
        _getString(data, 'universityEmail') ??
        _getString(data, 'email');

    final employeeId =
        _getString(data, 'employeeId');

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius:
            BorderRadius.circular(22.r),

        onTap: () {
          _selectEvaluator(
            context,
            uid,
            name,
            data,
          );
        },

        child: Container(
          padding: EdgeInsets.all(16.w),

          decoration: BoxDecoration(
            color:
                theme.cardTheme.color ??
                    theme.cardColor,

            borderRadius:
                BorderRadius.circular(22.r),

            border: Border.all(
              color:
                  AppColors.darkGold.withOpacity(
                0.18,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  isDark ? 0.10 : 0.05,
                ),

                blurRadius: 10,

                offset:
                    const Offset(0, 3),
              ),
            ],
          ),

          child: Row(
            children: [
              // =================================================
              // AVATAR
              // =================================================

              Container(
                width: 55.w,
                height: 55.w,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color:
                      AppColors.darkGold
                          .withOpacity(0.12),

                  border: Border.all(
                    color:
                        AppColors.darkGold
                            .withOpacity(0.35),
                  ),
                ),

                child: Icon(
                  Icons.person_rounded,
                  size: 28.sp,
                  color:
                      AppColors.darkGold,
                ),
              ),

              SizedBox(width: 14.w),

              // =================================================
              // DATA
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style: theme.textTheme.titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    if (employeeId != null) ...[
                      SizedBox(height: 5.h),

                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 16.sp,
                            color:
                                AppColors.darkGold,
                          ),

                          SizedBox(width: 5.w),

                          Expanded(
                            child: Text(
                              employeeId,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (email != null) ...[
                      SizedBox(height: 4.h),

                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 15.sp,
                            color:
                                theme
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                          ),

                          SizedBox(width: 5.w),

                          Expanded(
                            child: Text(
                              email,

                              maxLines: 1,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style: theme
                                  .textTheme
                                  .bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // =================================================
              // SELECT ICON
              // =================================================

              Container(
                width: 40.w,
                height: 40.w,

                decoration: BoxDecoration(
                  color:
                      AppColors.navyDark
                          .withOpacity(0.08),

                  borderRadius:
                      BorderRadius.circular(12.r),
                ),

                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 17.sp,
                  color:
                      AppColors.navyDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SELECT EVALUATOR
  // ============================================================

  Future<void> _selectEvaluator(
    BuildContext context,
    String uid,
    String name,
    Map<String, dynamic> data,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(
            'employee_evaluators.confirm_title'
                .tr(),
          ),

          content: Text(
            '${'employee_evaluators.confirm_message'.tr()}\n\n$name',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: Text(
                'common.cancel'.tr(),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: Text(
                'common.confirm'.tr(),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    // ==========================================================
    // RETURN SELECTED EVALUATOR
    // ==========================================================

    Navigator.pop(
      context,
      {
        'uid': uid,
        'name': name,
        'email':
            _getString(
              data,
              'universityEmail',
            ) ??
            _getString(
              data,
              'email',
            ),
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  bool _matchesSearch(
    Map<String, dynamic> data,
  ) {
    if (_searchText.isEmpty) {
      return true;
    }

    final name =
        _getEvaluatorName(data)
            .toLowerCase();

    final email =
        (_getString(
              data,
              'universityEmail',
            ) ??
            _getString(
              data,
              'email',
            ) ??
            '')
            .toLowerCase();

    final employeeId =
        (_getString(
              data,
              'employeeId',
            ) ??
            '')
            .toLowerCase();

    return name.contains(_searchText) ||
        email.contains(_searchText) ||
        employeeId.contains(_searchText);
  }

  // ============================================================
  // GET NAME
  // ============================================================

  String _getEvaluatorName(
    Map<String, dynamic> data,
  ) {
    final nameAr =
        _getString(data, 'nameAr');

    final nameEn =
        _getString(data, 'nameEn');

    final username =
        _getString(data, 'username');

    final name =
        _getString(data, 'name');

    if (context.locale.languageCode == 'ar') {
      return nameAr ??
          name ??
          username ??
          nameEn ??
          '---';
    }

    return nameEn ??
        name ??
        username ??
        nameAr ??
        '---';
  }

  // ============================================================
  // GET STRING
  // ============================================================

  String? _getString(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) {
      return null;
    }

    final result =
        value.toString().trim();

    return result.isEmpty
        ? null
        : result;
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 70.sp,
              color: AppColors.darkGold,
            ),

            SizedBox(height: 15.h),

            Text(
              'employee_evaluators.no_evaluators'
                  .tr(),

              textAlign: TextAlign.center,

              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NO SEARCH RESULTS
  // ============================================================

  Widget _buildNoSearchResults(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.search_off_rounded,
              size: 65.sp,
              color: AppColors.darkGold,
            ),

            SizedBox(height: 14.h),

            Text(
              'employee_evaluators.no_search_results'
                  .tr(),

              textAlign: TextAlign.center,

              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    BuildContext context,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(25.w),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60.sp,
              color: AppColors.error,
            ),

            SizedBox(height: 15.h),

            Text(
              'employee_evaluators.load_error'
                  .tr(),

              textAlign: TextAlign.center,

              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            SizedBox(height: 8.h),

            Text(
              error,

              maxLines: 3,

              overflow:
                  TextOverflow.ellipsis,

              textAlign: TextAlign.center,

              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}