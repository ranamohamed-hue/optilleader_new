import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_cubit.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_state.dart';

class EmployeeNominationPage extends StatefulWidget {
  final AnnouncementModel announcement;
  final EmployeeModel employee;

  const EmployeeNominationPage({
    super.key,
    required this.announcement,
    required this.employee,
  });

  @override
  State<EmployeeNominationPage> createState() =>
      _EmployeeNominationPageState();
}

class _EmployeeNominationPageState
    extends State<EmployeeNominationPage> {
  final TextEditingController _visionController =
      TextEditingController();

  bool _isSubmitting = false;

  // ============================================================
  // إرسال طلب الترشح
  // ============================================================

  Future<void> _submitNomination() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    await context
        .read<EmployeeNominationCubit>()
        .submitNominationRequest(
          announcement: widget.announcement,
          employeeId: widget.employee.employeeId,
          employeeName: widget.employee.nameAr,
          employeeImageUrl: null,
          currentJob: widget.employee.currentJobAr,
          sectorName: widget.employee.adminSectorName,
          departmentName: widget.employee.adminSubDeptName,
          visionStatement:
              _visionController.text.trim().isEmpty
                  ? null
                  : _visionController.text.trim(),
        );
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _visionController.dispose();
    super.dispose();
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<EmployeeNominationCubit,
        EmployeeNominationState>(
      listener: (context, state) {
        // --------------------------------------------------------
        // Loading
        // --------------------------------------------------------

        if (state is EmployeeNominationLoading) {
          if (mounted) {
            setState(() {
              _isSubmitting = true;
            });
          }
        }

        // --------------------------------------------------------
        // Success
        // --------------------------------------------------------

        else if (state is EmployeeNominationActionSuccess) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'employee_nomination_page.nomination.success'
                      .tr(),
                ),
                backgroundColor: Colors.green,
              ),
            );

            context.pop();
          }
        }

        // --------------------------------------------------------
        // Error
        // --------------------------------------------------------

        else if (state is EmployeeNominationError) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });

            String message = state.message;

            // لو الرسالة Translation Key
            if (state.message.contains('.') ||
                state.message.contains('_')) {
              final translated =
                  state.message.tr();

              if (translated != state.message) {
                message = translated;
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'employee_nomination_page.nomination.title'
                .tr(),
          ),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // بيانات الموظف
              // ==================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),

                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(16.r),
                  border: Border.all(
                    color:
                        colorScheme.outlineVariant,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'employee_nomination_page.nomination.applicant_data'
                          .tr(),
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    _buildDataRow(
                      context,
                      'employee_nomination_page.nomination.name'
                          .tr(),
                      widget.employee.nameAr,
                    ),

                    _buildDataRow(
                      context,
                      'employee_nomination_page.nomination.current_job'
                          .tr(),
                      widget.employee.currentJobAr,
                    ),

                    if (widget.employee.adminSectorName !=
                            null &&
                        widget.employee.adminSectorName!
                            .trim()
                            .isNotEmpty)
                      _buildDataRow(
                        context,
                        'employee_nomination_page.nomination.sector'
                            .tr(),
                        widget.employee
                            .adminSectorName!,
                      ),

                    if (widget.employee.adminSubDeptName !=
                            null &&
                        widget.employee.adminSubDeptName!
                            .trim()
                            .isNotEmpty)
                      _buildDataRow(
                        context,
                        'employee_nomination_page.nomination.department'
                            .tr(),
                        widget.employee
                            .adminSubDeptName!,
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // ==================================================
              // بيانات الإعلان
              // ==================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),

                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer
                      .withOpacity(0.3),

                  borderRadius:
                      BorderRadius.circular(16.r),

                  border: Border.all(
                    color: colorScheme.primary
                        .withOpacity(0.3),
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'employee_nomination_page.nomination.job_applied_for'
                          .tr(),
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            colorScheme.primary,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    _buildDataRow(
                      context,
                      'employee_nomination_page.nomination.job_title'
                          .tr(),
                      widget.announcement.title,
                    ),

                    _buildDataRow(
                      context,
                      'employee_nomination_page.nomination.target_role'
                          .tr(),
                      widget.announcement.targetRole,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // ==================================================
              // الرؤية
              // ==================================================

              Text(
                'employee_nomination_page.nomination.development_vision'
                    .tr(),
                style:
                    theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10.h),

              TextField(
                controller: _visionController,
                maxLines: 4,

                decoration: InputDecoration(
                  hintText:
                      'employee_nomination_page.nomination.vision_hint'
                          .tr(),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12.r),
                  ),

                  alignLabelWithHint: true,

                  contentPadding:
                      EdgeInsets.all(14.w),
                ),
              ),

              SizedBox(height: 20.h),

              // ==================================================
              // رسالة توضيحية
              // ==================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),

                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer
                      .withOpacity(0.35),

                  borderRadius:
                      BorderRadius.circular(12.r),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color:
                          colorScheme.primary,
                      size: 22.sp,
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Text(
                        'employee_nomination_page.nomination.info_message'
                            .tr(),
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // ==================================================
              // زر الإرسال
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55.h,

                child: ElevatedButton(
                  onPressed:
                      _isSubmitting
                          ? null
                          : _submitNomination,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        colorScheme.primary,

                    disabledBackgroundColor:
                        colorScheme.primary
                            .withOpacity(0.5),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15.r,
                      ),
                    ),
                  ),

                  child: _isSubmitting
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,

                          child:
                              const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons
                                  .send_rounded,
                              color:
                                  Colors.white,
                              size: 22.sp,
                            ),

                            SizedBox(
                              width: 10.w,
                            ),

                            Text(
                              'employee_nomination_page.nomination.submit'
                                  .tr(),
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Data Row
  // ============================================================

  Widget _buildDataRow(
    BuildContext context,
    String title,
    String? value,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.h,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            '$title: ',

            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: theme
                  .colorScheme
                  .onSurfaceVariant,

              fontWeight:
                  FontWeight.w600,

              fontSize: 13.sp,
            ),
          ),

          Expanded(
            child: Text(
              value?.trim().isNotEmpty == true
                  ? value!
                  : '-',

              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                fontSize: 13.sp,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}