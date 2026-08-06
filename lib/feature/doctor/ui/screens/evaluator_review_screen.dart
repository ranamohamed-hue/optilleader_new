import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';

class EvaluatorReviewScreen extends StatelessWidget {
  final NominationRequestModel request;

  const EvaluatorReviewScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final details = request.scores?.itemsDetails ?? [];
    final researchDetails = details
        .where((item) => item['type'] == 'بحث علمي')
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة بيانات الدكتور
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.doctorName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.grey[600], size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'evaluator_review.doctor_info.college'.tr(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        request.collegeName ?? '-',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // عنوان الأبحاث
          Text(
            'evaluator_review.research.title'.tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),

          if (researchDetails.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'evaluator_review.research.no_research'.tr(),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ...researchDetails.map((item) {
              final breakdown = item['breakdown'] ?? '';
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          color: Colors.purple,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            item['title'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (breakdown.isNotEmpty) ...[
                      Divider(height: 20.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          breakdown,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
