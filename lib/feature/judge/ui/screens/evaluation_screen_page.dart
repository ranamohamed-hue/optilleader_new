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
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  late InterviewScoringModel _interviewModel;

  DateTime? _selectedInterviewDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _interviewModel = InterviewScoringModel(
      interviewDate: widget.request.interviewDate ?? DateTime.now(),
    );
    _loadExistingEvaluation();
  }

  void _loadExistingEvaluation() {
    final evaluation = widget.request.interviewEvaluation;
    if (evaluation != null && evaluation is Map<String, dynamic>) {
      _interviewModel = InterviewScoringModel.fromMap(evaluation);
      _notesController.text = _interviewModel.combinedNotes;
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

  void _updateCriterionScore(int axisIndex, int critIndex, double newScore) {
    switch (axisIndex) {
      case 0:
        _interviewModel.emotionalBalanceCriteria[critIndex].givenScore =
            newScore;
        break;
      case 1:
        _interviewModel.strategicThinkingCriteria[critIndex].givenScore =
            newScore;
        break;
      case 2:
        _interviewModel.participatoryLeadershipCriteria[critIndex].givenScore =
            newScore;
        break;
      case 3:
        _interviewModel.legalAwarenessCriteria[critIndex].givenScore = newScore;
        break;
      case 4:
        _interviewModel.communityInteractionCriteria[critIndex].givenScore =
            newScore;
        break;
    }
    setState(() {});
  }
////////////////
///////////////
//////////////////
///////////////
  List<Map<String, dynamic>> get _axesData => [
        {
          'title': 'evaluation.axes.axis1_title'.tr(),
          'maxScore': 20.0,
          'color': Colors.blue,
          'criteria': _interviewModel.emotionalBalanceCriteria,
        },
        {
          'title': 'evaluation.axes.axis2_title'.tr(),
          'maxScore': 25.0,
          'color': Colors.green,
          'criteria': _interviewModel.strategicThinkingCriteria,
        },
        {
          'title': 'evaluation.axes.axis3_title'.tr(),
          'maxScore': 20.0,
          'color': Colors.orange,
          'criteria': _interviewModel.participatoryLeadershipCriteria,
        },
        {
          'title': 'evaluation.axes.axis4_title'.tr(),
          'maxScore': 20.0,
          'color': Colors.purple,
          'criteria': _interviewModel.legalAwarenessCriteria,
        },
        {
          'title': 'evaluation.axes.axis5_title'.tr(),
          'maxScore': 15.0,
          'color': Colors.teal,
          'criteria': _interviewModel.communityInteractionCriteria,
        },
      ];

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

    final model = _interviewModel.copyWith(
      interviewDate: _selectedInterviewDate!,
      emotionalBalanceNotes: _notesController.text,
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
    // ✅ تحديد إذا كان الثيم داكن
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('evaluation.title'.tr()),
        backgroundColor: colorScheme.primary,
        // ✅ إضافة لون مناسب للنص في الـ AppBar
        foregroundColor: colorScheme.onPrimary,
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
              _buildScheduleCard(colorScheme, isDark),
              SizedBox(height: 20.h),
              ..._axesData.asMap().entries.map((entry) {
                int axisIndex = entry.key;
                var axis = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: _buildAxisCard(
                    axisIndex: axisIndex,
                    title: axis['title'],
                    maxScore: axis['maxScore'],
                    color: axis['color'],
                    criteria: axis['criteria'],
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                );
              }).toList(),
              SizedBox(height: 20.h),
              _buildTotalCard(colorScheme, isDark),
              SizedBox(height: 20.h),
              _buildNotesCard(colorScheme, isDark),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _submitEvaluation(isDraft: true),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        // ✅ لون النص في الزر
                        foregroundColor: colorScheme.primary,
                      ),
                      child: Text(
                        'evaluation.actions.save_draft'.tr(),
                        overflow: TextOverflow.ellipsis,style: TextStyle(                color: isDark ?Colors.white:Colors.black,
),
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
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                      child: Text(
                        'evaluation.actions.approve'.tr(),
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

  // ✅ كارت المحور الواحد - مصلح للثيم الليلي
  Widget _buildAxisCard({
    required int axisIndex,
    required String title,
    required double maxScore,
    required Color color,
    required List<RubricCriterion> criteria,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    double axisTotal =
        criteria.fold(0.0, (sum, item) => sum + item.givenScore);

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        // ✅ استخدام surface بدل Colors.white
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            // ✅ ظل مناسب للثيم الليلي
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isDark ? 8 : 5,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(isDark ? 0.5 : 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                // ✅ الأيقونة بتاخد لون واضح
                child: Icon(
                  Icons.star,
                  color: color,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    // ✅ لون النص من colorScheme
                    color: color,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '$axisTotal / $maxScore',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          ...criteria.asMap().entries.map((entry) {
            int critIndex = entry.key;
            var criterion = entry.value;
            return _buildCriterionSlider(
              axisIndex: axisIndex,
              critIndex: critIndex,
              title: criterion.titleAr,
              maxScore: criterion.maxScore,
              currentScore: criterion.givenScore,
              color: color,
              colorScheme: colorScheme,
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ ويدجت الـ Slider - مصلح للثيم الليلي
  Widget _buildCriterionSlider({
    required int axisIndex,
    required int critIndex,
    required String title,
    required double maxScore,
    required double currentScore,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  // ✅ استخدام onSurfaceVariant بدل grey[800]
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${currentScore.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.3),
              thumbColor: color,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayColor: color.withOpacity(0.2),
              trackHeight: 3.h,
              // ✅ إضافة مؤشرات واضحة
              tickMarkShape: const RoundSliderTickMarkShape(),
            ),
            child: Slider(
              value: currentScore,
              min: 0,
              max: maxScore,
              divisions: maxScore.toInt() * 2,
              onChanged: (value) {
                double roundedValue = (value * 2).round() / 2;
                _updateCriterionScore(axisIndex, critIndex, roundedValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ كارت بيانات الدكتور - مصلح للثيم الليلي
  Widget _buildDoctorInfoCard(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        // ✅ استخدام surfaceContainerHighest
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: colorScheme.primary.withOpacity(0.2),
            backgroundImage: widget.request.doctorImageUrl != null
                ? NetworkImage(widget.request.doctorImageUrl!)
                : null,
            // ✅ الأيقونة بلون واضح
            child: widget.request.doctorImageUrl == null
                ? Icon(
                    Icons.person,
                    color: colorScheme.primary,
                    size: 28.sp,
                  )
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
                    // ✅ لون واضح لاسم الدكتور
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${'evaluation.doctor_info.job'.tr()}: ${widget.request.targetRole.tr()}',
                  // ✅ استخدام onSurfaceVariant بدل grey[600]
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
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

  // ✅ كارت تحديد الموعد - مصلح للثيم الليلي
  Widget _buildScheduleCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        // ✅ استخدام surface بدل white
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isDark ? 8 : 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available,
                // ✅ لون واضح للأيقونة
                color: isDark ?Colors.white:Colors.black,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'evaluation.schedule.title'.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                color: isDark ?Colors.white:Colors.black,
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
                // ✅ استخدام surfaceContainerHighest
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedInterviewDate == null
                        ? 'evaluation.schedule.pick_date'.tr()
                        : DateFormat('yyyy-MM-dd')
                            .format(_selectedInterviewDate!),
                    // ✅ لون النص واضح
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _selectedInterviewDate == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                color: isDark ?Colors.white:Colors.black,
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
            style: TextStyle(
              // ✅ لون النص في الـ TextField
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'evaluation.schedule.time'.tr(),
              labelStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.access_time,
                color: isDark ?Colors.white:Colors.black,
              ),
              // ✅ تخصيص الـ border للثيم الليلي
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _locationController,
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'evaluation.schedule.location'.tr(),
              labelStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.location_on,
                color: isDark ?Colors.white:Colors.black,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
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
                foregroundColor: colorScheme.onPrimary,
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

  // ✅ كارت المجموع الكلي - مصلح للثيم الليلي
  Widget _buildTotalCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        // ✅ خلفية مناسبة للثيم الليلي
        color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'evaluation.total'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                // ✅ لون النص واضح
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            '${_interviewModel.totalScore.toStringAsFixed(1)} / 100',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
                color: isDark ?Colors.white:Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ كارت الملاحظات - مصلح للثيم الليلي
  Widget _buildNotesCard(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'evaluation.notes.label'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            // ✅ لون العنوان واضح
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: TextStyle(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'evaluation.notes.hint'.tr(),
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            filled: true,
            // ✅ استخدام surfaceContainerHighest
            fillColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}