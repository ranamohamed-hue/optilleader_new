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

  // ✅ متغير واحد فقط بدل الـ 5 controllers القديمة
  late InterviewScoringModel _interviewModel;

  DateTime? _selectedInterviewDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // تهيئة الاستبيان الفاضي بالمحاور الجديدة
    _interviewModel = InterviewScoringModel(
      interviewDate: widget.request.interviewDate ?? DateTime.now(),
    );
    _loadExistingEvaluation();
  }

  void _loadExistingEvaluation() {
    final evaluation = widget.request.interviewEvaluation;
    if (evaluation != null && evaluation is Map<String, dynamic>) {
      // لو فيه تقييم قديم محفوظ، نحمله مباشرة
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

  // ✅ دالة تحديث درجة معينة من الـ Slider
  void _updateCriterionScore(int axisIndex, int critIndex, double newScore) {
    // لأن givenScore مش final في الموديل، نقدر نعدلها مباشرة بدل ما نعمل copyWith
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

    // عمل rebuild للواجهة عشان الـ Slider والمجموع يتحدثوا
    setState(() {});
  }

    //  بيانات المحاور الخمسة الجديدة للعرض (مترجمة)
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

    // تحضير الموديل النهائي
    final model = _interviewModel.copyWith(
      interviewDate: _selectedInterviewDate!,
      emotionalBalanceNotes:
          _notesController.text, // نحفظ الملاحظات في أول محور كمرجع عام
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

              // ✅ بناء كروت المحاور ديناميكياً من الـ Data
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
                  ),
                );
              }).toList(),

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

  // ✅ كارت المحور الواحد (بيحتوي على المعايير الفرعية والـ Sliders)
  Widget _buildAxisCard({
    required int axisIndex,
    required String title,
    required double maxScore,
    required Color color,
    required List<RubricCriterion> criteria,
  }) {
    // حساب مجموع المحور
    double axisTotal = criteria.fold(0.0, (sum, item) => sum + item.givenScore);

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
          // هيدر المحور (الاسم + مجموعه)
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
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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

          // بناء Sliders للمعايير الفرعية
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
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ ويدجت الـ Slider للمعيار الفرعي
  Widget _buildCriterionSlider({
    required int axisIndex,
    required int critIndex,
    required String title,
    required double maxScore,
    required double currentScore,
    required Color color,
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
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[800],
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
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              overlayColor: color.withOpacity(0.1),
              trackHeight: 3.h,
            ),
            child: Slider(
              value: currentScore,
              min: 0,
              max: maxScore,
              divisions: maxScore.toInt() * 2, // للسماح بنصف درجات (0.5)
              onChanged: (value) {
                // تقريب لأقرب نصف درجة عشان ميبقىش رقم عشري طويل
                double roundedValue = (value * 2).round() / 2;
                _updateCriterionScore(axisIndex, critIndex, roundedValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ كارت بيانات الدكتور
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

  // ✅ كارت تحديد الموعد (بدون تغيير)
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

  // ✅ كارت المجموع الكلي (بيجمع المجموع من الموديل تلقائياً)
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
            '${_interviewModel.totalScore.toStringAsFixed(1)} / 100',
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
