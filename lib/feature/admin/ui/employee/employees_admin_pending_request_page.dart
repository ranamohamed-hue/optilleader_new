import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';

class EmployeesAdminPendingRequestPage extends StatelessWidget {
  const EmployeesAdminPendingRequestPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلبات ترشح الموظفين',
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('employee_nomination_requests')
            .where(
              'status',
              isEqualTo:
                  EmployeeNominationRequestModel.statusPendingAdmin,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'حدث خطأ أثناء تحميل الطلبات\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return _buildEmptyState();
          }

          final requests = documents.map((doc) {
            return EmployeeNominationRequestModel.fromMap(
              doc.data(),
              doc.id,
            );
          }).toList();

          requests.sort(
            (a, b) => b.createdAt.compareTo(
              a.createdAt,
            ),
          );

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(14.w),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _EmployeeRequestCard(
                  request: requests[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 70.sp,
              color: AppColors.darkGold,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد طلبات ترشح معلقة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ستظهر هنا طلبات الموظفين التي تحتاج إلى مراجعة الإدارة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeRequestCard extends StatelessWidget {
  final EmployeeNominationRequestModel request;

  const _EmployeeRequestCard({
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark =
        theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(
        bottom: 12.h,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20.r),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20.r),

        // ======================================================
        // GO ROUTER
        // ======================================================

        onTap: () {
          context.push(
            'details',
            extra: request,
          );
        },

        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.darkGold
                          .withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color:
                          AppColors.darkGold,
                      size: 25.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.employeeName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          'الرقم الوظيفي: ${request.employeeId}',
                          style: theme
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGold
                          .withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'معلق',
                      style: TextStyle(
                        color:
                            AppColors.darkGold,
                        fontSize: 11.sp,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              Divider(
                color:
                    theme.dividerColor
                        .withOpacity(0.4),
              ),

              SizedBox(height: 8.h),

              _infoRow(
                context,
                Icons.work_outline_rounded,
                'الوظيفة',
                request.currentJob,
              ),

              _infoRow(
                context,
                Icons.account_balance_outlined,
                'القطاع',
                request.sectorName,
              ),

              _infoRow(
                context,
                Icons.business_outlined,
                'الإدارة',
                request.departmentName,
              ),

              SizedBox(height: 6.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.navyDark
                          .withOpacity(0.04),
                  borderRadius:
                      BorderRadius.circular(14.r),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بيانات الترشح',
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppColors.navyDark,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      request.announcementTitle,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .bodyMedium,
                    ),

                    SizedBox(height: 5.h),

                    Text(
                      'الوظيفة المستهدفة: ${request.targetRole}',
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.sp,
                    color:
                        AppColors.darkGold,
                  ),

                  SizedBox(width: 6.w),

                  Expanded(
                    child: Text(
                      _formatDate(
                        request.createdAt,
                      ),
                      style: theme
                          .textTheme
                          .bodySmall,
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15.sp,
                    color:
                        theme.iconTheme.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: AppColors.darkGold,
          ),

          SizedBox(width: 8.w),

          Text(
            '$title: ',
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}