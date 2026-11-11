import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';

class EmployeesAdminPendingRequestPage extends StatelessWidget {
  const EmployeesAdminPendingRequestPage({super.key});

  String _tr(String key) {
    return 'employee_pending_request.$key'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('pending_requests_title')),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('employee_nomination_requests')
            .where(
              'status',
              isEqualTo: EmployeeNominationRequestModel.statusPendingAdmin,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  '${_tr('load_error')}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return _buildEmptyState(colorScheme, theme);
          }

          final requests = documents.map((doc) {
            return EmployeeNominationRequestModel.fromMap(doc.data(), doc.id);
          }).toList();

          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(12.w),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _EmployeeRequestCard(request: requests[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.sp,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _tr('no_pending_requests'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeRequestCard extends StatelessWidget {
  final EmployeeNominationRequestModel request;

  const _EmployeeRequestCard({required this.request});

  String _tr(String key) {
    return 'employee_pending_request.$key'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String initial =
        request.employeeName.isNotEmpty ? request.employeeName[0] : '?';

    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(
            Routes.employeePendingRequestDetails,
            extra: request,
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.employeeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          '${_tr('employee_id')}: ${request.employeeId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _tr('pending_status'),
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              _infoRow(
                Icons.work_outline_rounded,
                _tr('current_job'),
                request.currentJob,
                colorScheme,
              ),

              _infoRow(
                Icons.account_balance_outlined,
                _tr('sector'),
                request.sectorName,
                colorScheme,
              ),

              _infoRow(
                Icons.business_outlined,
                _tr('department'),
                request.departmentName,
                colorScheme,
              ),

              SizedBox(height: 8.h),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      _formatDate(request.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
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
    IconData icon,
    String title,
    String? value,
    ColorScheme colorScheme,
  ) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: colorScheme.onSurfaceVariant),
          SizedBox(width: 8.w),
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}