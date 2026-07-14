import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/judge/data/model/interview_scoring_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomination_request_cubit.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';

class InterviewEvaluationScreen extends StatefulWidget {
  final String requestId;
  final NominationRequestModel request;

  const InterviewEvaluationScreen({
    super.key,
    required this.requestId,
    required this.request,
  });

  @override
  State<InterviewEvaluationScreen> createState() =>
      _InterviewEvaluationScreenState();
}

class _InterviewEvaluationScreenState extends State<InterviewEvaluationScreen> {
  final TextEditingController _scientificController = TextEditingController();
  final TextEditingController _leadershipController = TextEditingController();
  final TextEditingController _studentActivitiesController =
      TextEditingController();
  final TextEditingController _communityActivitiesController =
      TextEditingController();
  final TextEditingController _humanRelationsController =
      TextEditingController();

  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? _selectedInterviewDate;
  TimeOfDay? _selectedTime;

  final Map<String, double> _maxScores = {
    'scientific': 40,
    'leadership': 25,
    'studentActivities': 15,
    'communityActivities': 10,
    'humanRelations': 10,
  };

  @override
  void initState() {
    super.initState();
    _loadExistingEvaluation();
  }

  void _loadExistingEvaluation() {
    final evaluation = widget.request.interviewEvaluation;
    if (evaluation != null) {
      _scientificController.text = (evaluation['scientificScore'] ?? 0)
          .toString();
      _leadershipController.text = (evaluation['leadershipScore'] ?? 0)
          .toString();
      _studentActivitiesController.text =
          (evaluation['studentActivitiesScore'] ?? 0).toString();
      _communityActivitiesController.text =
          (evaluation['communityActivitiesScore'] ?? 0).toString();
      _humanRelationsController.text = (evaluation['humanRelationsScore'] ?? 0)
          .toString();

      _notesController.text = [
        evaluation['scientificNotes'],
        evaluation['leadershipNotes'],
        evaluation['studentActivitiesNotes'],
        evaluation['communityActivitiesNotes'],
        evaluation['humanRelationsNotes'],
      ].where((n) => n != null && n.toString().isNotEmpty).join(' | ');
    }

    if (widget.request.interviewDate != null) {
      _selectedInterviewDate = widget.request.interviewDate;
    }
    if (widget.request.interviewLocation != null) {
      _locationController.text = widget.request.interviewLocation!;
    }
    if (widget.request.interviewTime != null) {
      _timeController.text = widget.request.interviewTime!;
    }
  }

  @override
  void dispose() {
    _scientificController.dispose();
    _leadershipController.dispose();
    _studentActivitiesController.dispose();
    _communityActivitiesController.dispose();
    _humanRelationsController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedInterviewDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedInterviewDate = picked);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text =
            '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  double _parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }

  double get _currentTotal {
    return _parseDouble(_scientificController.text) +
        _parseDouble(_leadershipController.text) +
        _parseDouble(_studentActivitiesController.text) +
        _parseDouble(_communityActivitiesController.text) +
        _parseDouble(_humanRelationsController.text);
  }

  void _scheduleInterview() {
    if (_selectedInterviewDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('evaluation.schedule.date_required'.tr())),
      );
      return;
    }
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('evaluation.schedule.location_required'.tr())),
      );
      return;
    }
    if (_timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('evaluation.schedule.time_required'.tr())),
      );
      return;
    }

    context.read<NominationRequestCubit>().scheduleInterview(
      request: widget.request,
      interviewDate: _selectedInterviewDate!,
      location: _locationController.text.trim(),
      time: _timeController.text.trim(),
    );
  }

  void _submitEvaluation({bool isDraft = false}) {
    if (_selectedInterviewDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('evaluation.interview_date.required'.tr())),
      );
      return;
    }

    final model = InterviewScoringModel(
      interviewDate: _selectedInterviewDate!,
      scientificScore: _parseDouble(_scientificController.text),
      leadershipScore: _parseDouble(_leadershipController.text),
      studentActivitiesScore: _parseDouble(_studentActivitiesController.text),
      communityActivitiesScore: _parseDouble(
        _communityActivitiesController.text,
      ),
      humanRelationsScore: _parseDouble(_humanRelationsController.text),
      scientificNotes: _notesController.text,
      isDraft: isDraft,
    );

    if (!model.isValid && !isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('evaluation.errors.invalid_scores'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<NominationRequestCubit>().submitInterviewEvaluation(
      request: widget.request,
      evaluationModel: model,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('evaluation.title'.tr()),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
      ),
      body: BlocListener<NominationRequestCubit, NominationRequestState>(
        listener: (context, state) {
          if (state is NominationRequestActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }

          if (state is NominationRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorInfoCard(colorScheme),
              SizedBox(height: 20.h),
              _buildScheduleCard(colorScheme),
              SizedBox(height: 20.h),

              _buildScoreCard(
                title: 'evaluation.scores.scientific'.tr(),
                criteria: 'evaluation.criteria.scientific'.tr(),
                maxScore: _maxScores['scientific']!,
                controller: _scientificController,
                color: Colors.blue,
              ),
              SizedBox(height: 15.h),
              _buildScoreCard(
                title: 'evaluation.scores.leadership'.tr(),
                criteria: 'evaluation.criteria.leadership'.tr(),
                maxScore: _maxScores['leadership']!,
                controller: _leadershipController,
                color: Colors.green,
              ),
              SizedBox(height: 15.h),
              _buildScoreCard(
                title: 'evaluation.scores.studentActivities'.tr(),
                criteria: 'evaluation.criteria.studentActivities'.tr(),
                maxScore: _maxScores['studentActivities']!,
                controller: _studentActivitiesController,
                color: Colors.orange,
              ),
              SizedBox(height: 15.h),
              _buildScoreCard(
                title: 'evaluation.scores.communityActivities'.tr(),
                criteria: 'evaluation.criteria.communityActivities'.tr(),
                maxScore: _maxScores['communityActivities']!,
                controller: _communityActivitiesController,
                color: Colors.purple,
              ),
              SizedBox(height: 15.h),
              _buildScoreCard(
                title: 'evaluation.scores.humanRelations'.tr(),
                criteria: 'evaluation.criteria.humanRelations'.tr(),
                maxScore: _maxScores['humanRelations']!,
                controller: _humanRelationsController,
                color: Colors.teal,
              ),

              SizedBox(height: 20.h),
              _buildTotalCard(colorScheme),
              SizedBox(height: 20.h),
              _buildNotesCard(colorScheme),
              SizedBox(height: 40.h),

              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _submitEvaluation(isDraft: true),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text(
                        'evaluation.actions.save_draft'.tr(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _submitEvaluation(isDraft: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text(
                        'evaluation.actions.approve'.tr(),
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ كارت بيانات الدكتور (تم إزالة الدرجة الآلية منه)
  Widget _buildDoctorInfoCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            backgroundImage: widget.request.doctorImageUrl != null
                ? NetworkImage(widget.request.doctorImageUrl!)
                : null,
            child: widget.request.doctorImageUrl == null
                ? Icon(Icons.person, color: colorScheme.primary)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.doctorName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${'evaluation.doctor_info.job'.tr()}: ${widget.request.targetRole.tr()}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ كارت تحديد الموعد
  Widget _buildScheduleCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available,
                color: colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'evaluation.schedule.title'.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedInterviewDate == null
                        ? 'evaluation.schedule.pick_date'.tr()
                        : DateFormat(
                            'yyyy-MM-dd',
                          ).format(_selectedInterviewDate!),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _timeController,
            readOnly: true,
            onTap: _pickTime,
            decoration: InputDecoration(
              labelText: 'evaluation.schedule.time'.tr(),
              prefixIcon: Icon(Icons.access_time, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'evaluation.schedule.location'.tr(),
              prefixIcon: Icon(Icons.location_on, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scheduleInterview,
              icon: Icon(Icons.send, size: 18.sp),
              label: Flexible(
                child: Text(
                  'evaluation.schedule.submit_btn'.tr(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ كارت إدخال الدرجات
  Widget _buildScoreCard({
    required String title,
    required String criteria,
    required double maxScore,
    required TextEditingController controller,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.star, color: color, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.h, right: 34.w),
            child: Text(
              criteria,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'evaluation.scores.score_label'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Text(
                '/ $maxScore',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ كارت المجموع الكلي
  Widget _buildTotalCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'evaluation.total'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
          Text(
            '${_currentTotal.toStringAsFixed(1)} / 100',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ كارت الملاحظات
  Widget _buildNotesCard(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'evaluation.notes.label'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'evaluation.notes.hint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }
}
