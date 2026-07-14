import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:uuid/uuid.dart';
import 'package:optialeader/feature/doctor/logic/activities/mandatory_leadership_data.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/logic/activities/activity_cubit.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';

class AddActivityPage extends StatefulWidget {
  final String doctorUid;
  const AddActivityPage({super.key, required this.doctorUid});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  // ==========================================
  // 1. متغيرات الحالة الأساسية (State Variables)
  // ==========================================

  final _formKey = GlobalKey<FormState>(); // مفتاح التحقق من صحة النموذج كله

  // كنترولرات الحقول المشتركة بين كل الأنواع (مؤتمر، معرض، دورة)
  final _titleController = TextEditingController(); // عنوان النشاط
  final _organizationController = TextEditingController(); // الجهة المنظمة
  final _dateController = TextEditingController(); // التاريخ
  final _durationHoursController =
      TextEditingController(); // عدد الساعات (خاص بالدورات أكثر)
  final _notesController =
      TextEditingController(); // ✅ حقل الإنقاذ: ملاحظات الباحث للمعارض الفنية فقط

  // المتغير اللي بيتحكم في إيه الحقول اللي هتظهر للمستخدم
  String _selectedType = 'conference';

  // ==========================================
  // 2. متغيرات المؤتمرات / الأبحاث (المحرك الحسابي للمؤتمرات)
  // ==========================================
  bool _isInternational =
      true; // نطاق المؤتمر: العامل الأقوى في تحديد نقاط المؤتمر (دولي ولا محلي)
  bool _isSpecialized =
      true; // تخصص المؤتمر: هل المؤتمر في صلب تخصص الدكتور أم عام؟ (بيأثر في الدرجات)
  bool _isPublished =
      true; // حالة النشر: هل تم نشر ورقة بحثية بناءً عليه؟ (مهم جداً لأن النشر يضيف نقاط إضافية)
  ParticipationType _participationType = ParticipationType
      .paperPresentation; // نوع المشاركة: بحث كامل نقاطه أعلى من حضور فقط

  // ==========================================
  // 3. متغيرات المعارض الفنية (المحرك الحسابي للمعارض)
  // ==========================================
  ExhibitionVenue _selectedVenue = ExhibitionVenue
      .artFaculties; // نوع القاعة: ده الحقل رقم 1 في حساب درجات المعرض (بيحدد الأساس: 8، 7، 6.5، أو 5)
  int _numberOfWorks =
      5; // عدد الأعمال الفنية: عشان الـ Model يتأكد من شرط الـ 5 أعمال (إذا كانت القاعة دولية)
  // ✅ ملاحظة: قمنا بحذف المتغير (isInternationalExhibition) لأن نوع القاعة نفسه هو اللي بيحدد لو دولي ولا لا، مش محتاجين مفتاح زيادة نلعب فيها.

  // ==========================================
  // 4. متغيرات الدورات العادية (المحرك الحسابي للدورات)
  // ==========================================
  CourseCategory _selectedCategory = CourseCategory
      .administrative; // فئة الدورة: (إدارية/تخصصية/عامة) كل فئة ليها وزن نقاط مختلف
  CourseScope _selectedScope =
      CourseScope.international; // نطاق الدورة: (دولي/محلي) الدولي أعلى نقاطاً
  CourseType _courseType = CourseType
      .graded; // نوع الدورة: عشان نميز بين الدورة العادية اللي عليها درجات، وبين الدورات الإلزامية

  // ==========================================
  // 5. بيانات الدورات الإلزامية (بدون درجات - شرط ترشح فقط)
  // ==========================================
  final List<Map<String, String>> _mandatoryCoursesList =
      MandatoryLeadershipData.courses; // لستة الدورات الجاهزة
  final Set<String> _selectedMandatoryCourses =
      {}; // اللي هيحفظ الـ keys بتاعة الدورات اللي المستخدم أشر عليها
  final Map<String, PickedFileData?> _mandatoryCourseFiles =
      {}; // اللي هيحفظ ملفات الشهادات لكل دورة إلزامية

  PickedFileData?
  _proofFile; // ملف الإثبات العام (الشهادة أو الكتالوج) - شرط أساسي لاعتماد أي نشاط

  @override
  void dispose() {
    // تنظيف الكنترولرات عشان نتجنب Memory Leak
    _titleController.dispose();
    _organizationController.dispose();
    _dateController.dispose();
    _durationHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ==========================================
  // 6. دالة الحفظ والإرسال (Submit Logic)
  // ==========================================
  void _submit() {
    // التحقق الأول: هل المستخدم دخل بيانات في النشاط العادي؟
    final hasNormalActivity =
        _titleController.text.trim().isNotEmpty ||
        _organizationController.text.trim().isNotEmpty;

    // لو دخل بيانات، نتأكد إن الحقول المطلوبة مكتوبة صح
    if (hasNormalActivity && !_formKey.currentState!.validate()) return;

    // لو دخل بيانات نشاط عادي، لازم يرفع ملف الإثبات (شرط الاعتماد)
    if (hasNormalActivity && _proofFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('addActivity.fileRequired'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // التحقق من الدورات الإلزامية: لو أشار على دورة إلزامية، لازم يرفع شهادتها
    if (_selectedMandatoryCourses.isNotEmpty) {
      for (var courseData in _mandatoryCoursesList) {
        final key = courseData['key']!;
        if (!_selectedMandatoryCourses.contains(key)) continue;
        if (_mandatoryCourseFiles[key] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${courseData['titleAr']} - ${'addActivity.fileRequired'.tr()}',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    // لو مادخلش حاجة ولا أشار على دورة إلزامية، نلغي عملية الحفظ
    if (!hasNormalActivity && _selectedMandatoryCourses.isEmpty) return;

    final cubit = context.read<ActivityCubit>();

    // ==========================================
    // حفظ بيانات المؤتمر / البحث في الـ Cubit
    // ==========================================
    if (_selectedType == 'conference') {
      final conf = ConferenceModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        isInternational: _isInternational,
        isSpecialized: _isSpecialized,
        isPublished: _isPublished,
        participationType: _participationType,
        certificateUrl: '',
        status: VerificationStatus.pending,
      );
      cubit.addConference(
        doctorUid: widget.doctorUid,
        conference: conf,
        certFile: _proofFile!.file,
      );
    }
    // ==========================================
    // حفظ بيانات المعرض الفني في الـ Cubit
    // ✅ تعديل: شلنا المتغير القديم (isInternationalType)، وضفنا إرسال (researcherNotes)
    // ==========================================
    else if (_selectedType == 'exhibition') {
      final exhibition = ArtExhibitionModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        venue: _selectedVenue,
        numberOfWorks: _numberOfWorks,
        researcherNotes: _notesController.text
            .trim(), // ✅ إرسال ملاحظات الباحث للداتا بيز
        proofFileUrl: '',
        proofFileType: '',
        status: VerificationStatus.pending,
      );
      cubit.addExhibition(
        doctorUid: widget.doctorUid,
        exhibition: exhibition,
        proofFile: _proofFile?.file,
      );
    }
    // ==========================================
    // حفظ بيانات الدورة العادية (المقيمة) في الـ Cubit
    // ==========================================
    else if (_courseType == CourseType.graded) {
      final course = CourseModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        organization: _organizationController.text.trim(),
        date: _dateController.text.trim(),
        durationHours: int.tryParse(_durationHoursController.text.trim()),
        type: _courseType,
        courseCategory: _selectedCategory,
        courseScope: _selectedScope,
        certificateUrl: '',
        status: VerificationStatus.pending,
      );
      cubit.addCourse(
        doctorUid: widget.doctorUid,
        course: course,
        certFile: _proofFile!.file,
      );
    }

    // ==========================================
    // حفظ الدورات الإلزامية (حالة اعتماد تلقائية Approved لأنها مجرد شرط ترشح)
    // ==========================================
    if (_selectedMandatoryCourses.isNotEmpty) {
      for (var courseData in _mandatoryCoursesList) {
        final key = courseData['key']!;
        if (!_selectedMandatoryCourses.contains(key)) continue;
        final file = _mandatoryCourseFiles[key]!;
        final mandatoryCourse = CourseModel(
          id: const Uuid().v4(),
          title: courseData['titleAr']!,
          organization: '',
          date: '',
          type: CourseType.mandatory,
          courseCategory: CourseCategory.none,
          courseScope: CourseScope.none,
          certificateUrl: '',
          status: VerificationStatus.approved,
        );
        cubit.addCourse(
          doctorUid: widget.doctorUid,
          course: mandatoryCourse,
          certFile: file.file,
        );
      }
    }
  }

  // ==========================================
  // 7. بناء واجهة المستخدم الرئيسية (UI Build)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityCubit, ActivityState>(
      listener: (context, state) {
        // الاستماع لنتيجة الحفظ
        if (state is ActivitySuccess) {
          context.pop(); // رجوع للصفحة اللي قبلها
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('addActivity.success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ActivityError) {
          // عرض خطأ في حال فشل الحفظ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ActivityLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text('addActivity.title'.tr()),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. قسم الدورات الإلزامية (اللي فوق كل حاجة)
                  _buildMandatoryCoursesSection(),
                  SizedBox(height: 20.h),

                  // 2. قائمة منسدلة لاختيار نوع النشاط (مؤتمر، معرض، دورة)
                  _buildActivityTypeSelector(),
                  SizedBox(height: 20.h),

                  // 3. الحقول المشتركة (الاسم، الجهة، التاريخ، الساعات)
                  _buildCommonFields(),
                  SizedBox(height: 20.h),

                  // 4. حقول ديناميكية بتتغير حسب النوع المختار (المحركات الحسابية)
                  if (_selectedType == 'conference') _buildConferenceFields(),
                  if (_selectedType == 'exhibition') _buildExhibitionFields(),
                  if (_selectedType == 'course' &&
                      _courseType == CourseType.graded)
                    _buildCourseFields(),

                  SizedBox(height: 20.h),

                  // 5. رفع ملف الإثبات وزر الحفظ النهائي
                  _buildProofAndSubmitSection(isLoading),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 8. الويدجات الفرعية (Extracted Widgets)
  // ==========================================

  /// ويدجت: قائمة اختيار نوع النشاط (بتتحكم في إيه اللي هيظهر تحت)
  Widget _buildActivityTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: InputDecoration(labelText: 'addActivity.type'.tr()),
      items: [
        DropdownMenuItem(
          value: 'conference',
          child: Text('addActivity.typeConferenceWorkshop'.tr()),
        ),
        DropdownMenuItem(
          value: 'exhibition',
          child: Text('addActivity.typeExhibition'.tr()),
        ),
        DropdownMenuItem(
          value: 'course',
          child: Text('addActivity.typeCourse'.tr()),
        ),
      ],
      onChanged: (v) => setState(() {
        _selectedType = v!;
        // تصفية الدورة كعادية مقيمة لو اختار دورة
        if (v == 'course') _courseType = CourseType.graded;
      }),
    );
  }

  /// ويدجت: الحقول المشتركة بين كل الأنشطة (بيانات التعريف والتوثيق الأساسية)
  Widget _buildCommonFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'addActivity.activityTitle'.tr(),
          ),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _organizationController,
          decoration: InputDecoration(
            labelText: 'addActivity.organization'.tr(),
          ),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // حقل التاريخ (أخذ مساحة أكبر)
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'addActivity.date'.tr()),
                validator: (v) =>
                    v!.isEmpty ? 'validation.required'.tr() : null,
              ),
            ),
            SizedBox(width: 10.w),
            // حقل الساعات (أخذ مساحة أقل)
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _durationHoursController,
                decoration: InputDecoration(
                  labelText: 'addActivity.durationHours'.tr(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ويدجت: حقول المؤتمرات (اللي بتحدد الدرجات بناءً على: النطاق، التخصص، النشر، ونوع المشاركة)
  Widget _buildConferenceFields() {
    return Column(
      children: [
        _buildSwitchTile(
          title: 'addActivity.isInternational'.tr(),
          value: _isInternational,
          onChanged: (v) => setState(() => _isInternational = v),
        ),
        _buildSwitchTile(
          title: 'addActivity.isSpecialized'.tr(),
          value: _isSpecialized,
          onChanged: (v) => setState(() => _isSpecialized = v),
        ),
        _buildSwitchTile(
          title: 'addActivity.isPublished'.tr(),
          value: _isPublished,
          onChanged: (v) => setState(() => _isPublished = v),
        ),
        DropdownButtonFormField<ParticipationType>(
          value: _participationType,
          decoration: InputDecoration(
            labelText: 'addActivity.participationType'.tr(),
          ),
          items: [
            DropdownMenuItem(
              value: ParticipationType.paperPresentation,
              child: Text('addActivity.partPaperPresentation'.tr()),
            ),
            DropdownMenuItem(
              value: ParticipationType.abstractPresentation,
              child: Text('addActivity.partAbstractPresentation'.tr()),
            ),
            DropdownMenuItem(
              value: ParticipationType.attendanceOnly,
              child: Text('addActivity.partAttendanceOnly'.tr()),
            ),
          ],
          onChanged: (v) => setState(() => _participationType = v!),
        ),
      ],
    );
  }

  /// ويدجت: حقول المعارض الفنية (المحرك الأساسي للدرجات هو نوع القاعة + عدد الأعمال + ملاحظات الإنقاذ)
  /// ✅ ملاحظة: تم إزالة الـ Switch الخاص بـ "دولي" لأن القاعة نفسها هي اللي بتحدد كده في الجدول الرسمي.
  Widget _buildExhibitionFields() {
    return Column(
      children: [
        SizedBox(height: 12.h),

        // قائمة نوع القاعة (تحتوي على الأصناف التسعة من الجدول الرسمي)
        DropdownButtonFormField<ExhibitionVenue>(
          value: _selectedVenue,
          decoration: InputDecoration(
            labelText: 'addActivity.exhibitionVenue'.tr(),
          ),
          items: ExhibitionVenue.values.map((v) {
            String label;
            switch (v) {
              // المحافل الدولية
              case ExhibitionVenue.internationalAbroad:
                label = 'addActivity.venueAbroad'.tr();
                break;
              case ExhibitionVenue.internationalEgypt:
                label = 'addActivity.venueEgypt'.tr();
                break;

              // القاعات المعتمدة (6.5 نقطة)
              case ExhibitionVenue.artFaculties:
                label = 'addActivity.venueArtFaculties'.tr();
                break;
              case ExhibitionVenue.fineArtsSector:
                label = 'addActivity.venueFineArtsSector'.tr();
                break;
              case ExhibitionVenue.foreignCulturalCenters:
                label = 'addActivity.venueForeignCenters'.tr();
                break;
              case ExhibitionVenue.artSyndicates:
                label = 'addActivity.venueSyndicates'.tr();
                break;

              // القاعات العامة (5 نقاط)
              case ExhibitionVenue.culturePalaces:
                label = 'addActivity.venueCulturePalaces'.tr();
                break;
              case ExhibitionVenue.ateliersCairoAlex:
                label = 'addActivity.venueAteliers'.tr();
                break;
              case ExhibitionVenue.privateGalleries:
                label = 'addActivity.venuePrivateGalleries'.tr();
                break;
            }
            return DropdownMenuItem(value: v, child: Text(label));
          }).toList(),
          onChanged: (v) => setState(() => _selectedVenue = v!),
        ),
        SizedBox(height: 12.h),

        // عدد الأعمال الفنية
        TextFormField(
          initialValue: _numberOfWorks.toString(),
          decoration: InputDecoration(
            labelText: 'addActivity.numberOfWorks'.tr(),
            hintText: 'في حالة المحافل الدولية يجب ألا تقل عن 5 أعمال',
            hintStyle: TextStyle(fontSize: 11.sp, color: Colors.orange),
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final parsed = int.tryParse(v);
            if (parsed != null && parsed >= 1) {
              setState(() => _numberOfWorks = parsed);
            }
          },
          validator: (v) {
            final parsed = int.tryParse(v ?? '');
            if (parsed == null || parsed < 1) {
              return 'addActivity.validationMinWorks'.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 12.h),

        // حقل "الإنقاذ" - ملاحظات الباحث
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'addActivity.researcherNotes'.tr(),
            alignLabelWithHint: true,
            hintText: 'addActivity.researcherNotesHint'.tr(),
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  /// ويدجت: حقول الدورات العادية (اللي بتحدد الدرجات بناءً على: الفئة، والنطاق)
  Widget _buildCourseFields() {
    return Column(
      children: [
        DropdownButtonFormField<CourseCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'addActivity.courseCategory'.tr(),
          ),
          items: [
            DropdownMenuItem(
              value: CourseCategory.administrative,
              child: Text('addActivity.catAdmin'.tr()),
            ),
            DropdownMenuItem(
              value: CourseCategory.specialized,
              child: Text('addActivity.catSpec'.tr()),
            ),
            DropdownMenuItem(
              value: CourseCategory.general,
              child: Text('addActivity.catGeneral'.tr()),
            ),
          ],
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
        SizedBox(height: 12.h),
        DropdownButtonFormField<CourseScope>(
          value: _selectedScope,
          decoration: InputDecoration(
            labelText: 'addActivity.courseScope'.tr(),
          ),
          items: [
            DropdownMenuItem(
              value: CourseScope.international,
              child: Text('addActivity.scopeInt'.tr()),
            ),
            DropdownMenuItem(
              value: CourseScope.local,
              child: Text('addActivity.scopeLocal'.tr()),
            ),
          ],
          onChanged: (v) => setState(() => _selectedScope = v!),
        ),
      ],
    );
  }

  /// ويدجت: رفع ملف الإثبات وزر الحفظ النهائي (شرط الاعتماد لكل الأنشطة)
  Widget _buildProofAndSubmitSection(bool isLoading) {
    return Column(
      children: [
        FilePickerField(
          label: 'addActivity.proofFile'.tr(),
          selectedFile: _proofFile,
          onFileSelected: (file) => setState(() => _proofFile = file),
        ),
        SizedBox(height: 30.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit, // تعطيل الزر أثناء التحميل
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'addActivity.submit'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// ويدجت مساعدة: لإنشاء Switch موحد الشكل (عشان الكود يبقى نظيف)
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero, // إزالة المسافات الزائدة
    );
  }

  /// ويدجت: قسم الدورات الإلزامية (قائمة جاهزة للإشراك عليها ورفق التوثيق فقط بدون درجات)
  Widget _buildMandatoryCoursesSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.deepPurple, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم وشرحه
          Row(
            children: [
              Icon(
                Icons.playlist_add_check_rounded,
                color: Colors.deepPurple,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'addActivity.mandatory_courses_title'.tr(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'addActivity.mandatory_courses_subtitle'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // عمل Loop لعرض الدورات ديناميكياً من الملف الخارجي
          ..._mandatoryCoursesList.map((courseData) {
            final key = courseData['key']!;
            final titleAr = courseData['titleAr']!;
            final isSelected = _selectedMandatoryCourses.contains(key);

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الدورة والـ Checkbox بتاعها
                  InkWell(
                    onTap: () => setState(() {
                      if (isSelected) {
                        _selectedMandatoryCourses.remove(key);
                        _mandatoryCourseFiles.remove(
                          key,
                        ); // مسح الشهادة لو غيّر رأيه
                      } else {
                        _selectedMandatoryCourses.add(key);
                      }
                    }),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.deepPurple : Colors.grey,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            titleAr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // يظهر حقل رفع الشهادة فقط إذا تم الإشراك على الدورة
                  if (isSelected) ...[
                    SizedBox(height: 10.h),
                    FilePickerField(
                      label: '$titleAr - ${'addActivity.proofFile'.tr()}',
                      selectedFile: _mandatoryCourseFiles[key],
                      onFileSelected: (file) =>
                          setState(() => _mandatoryCourseFiles[key] = file),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
