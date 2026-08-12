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

  const AddActivityPage({
    super.key,
    required this.doctorUid,
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  // ==========================================================
  // 1. Form
  // ==========================================================

  final _formKey = GlobalKey<FormState>();

  // ==========================================================
  // 2. الحقول المشتركة
  // ==========================================================

  final _titleController = TextEditingController();
  final _organizationController = TextEditingController();
  final _dateController = TextEditingController();
  final _durationHoursController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'conference';

  // ==========================================================
  // 3. المؤتمرات
  // ==========================================================

  bool _isInternational = true;
  bool _isSpecialized = true;
  bool _isPublished = true;

  ParticipationType _participationType =
      ParticipationType.paperPresentation;

  // ==========================================================
  // 4. المعارض
  // ==========================================================

  ExhibitionVenue _selectedVenue = ExhibitionVenue.artFaculties;

  int _numberOfWorks = 5;

  // ==========================================================
  // 5. الدورات العادية
  // ==========================================================

  CourseCategory _selectedCategory =
      CourseCategory.administrative;

  CourseScope _selectedScope =
      CourseScope.international;

  CourseType _courseType = CourseType.graded;

  // ==========================================================
  // 6. الدورات الإلزامية السبعة
  // ==========================================================

  final List<Map<String, String>> _mandatoryCoursesList =
      MandatoryLeadershipData.courses;

  /// الـ keys الخاصة بالدورات التي اختارها الدكتور
  final Set<String> _selectedMandatoryCourses = {};

  /// ملف كل دورة مختارة
  final Map<String, PickedFileData?> _mandatoryCourseFiles = {};

  // ==========================================================
  // 7. ملف الإثبات للنشاط العادي
  // ==========================================================

  PickedFileData? _proofFile;

  // ==========================================================
  // Dispose
  // ==========================================================

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _dateController.dispose();
    _durationHoursController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ==========================================================
  // Submit
  // ==========================================================

  void _submit() {
    final hasNormalActivity =
        _titleController.text.trim().isNotEmpty ||
        _organizationController.text.trim().isNotEmpty ||
        _dateController.text.trim().isNotEmpty;

    // ========================================================
    // التحقق من النشاط العادي
    // ========================================================

    if (hasNormalActivity) {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_proofFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'addActivity.fileRequired'.tr(),
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }
    }

    // ========================================================
    // التحقق من ملفات الدورات الإلزامية
    // ========================================================

    if (_selectedMandatoryCourses.isNotEmpty) {
      for (final courseData in _mandatoryCoursesList) {
        final key = courseData['key']!;

        if (!_selectedMandatoryCourses.contains(key)) {
          continue;
        }

        if (_mandatoryCourseFiles[key] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${courseData['titleAr']} - '
                '${'addActivity.fileRequired'.tr()}',
              ),
              backgroundColor: Colors.red,
            ),
          );

          return;
        }
      }
    }

    // ========================================================
    // لازم يكون فيه نشاط عادي أو دورة إلزامية واحدة على الأقل
    // ========================================================

    if (!hasNormalActivity &&
        _selectedMandatoryCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'validation.required'.tr(),
          ),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    _submitAllActivities();
  }

  // ==========================================================
  // إرسال جميع الأنشطة
  // ==========================================================

  Future<void> _submitAllActivities() async {
    final cubit = context.read<ActivityCubit>();

    final hasNormalActivity =
        _titleController.text.trim().isNotEmpty ||
        _organizationController.text.trim().isNotEmpty ||
        _dateController.text.trim().isNotEmpty;

    await cubit.submitActivities(() async {
      // ======================================================
      // 1. النشاط العادي
      // ======================================================

      if (hasNormalActivity) {
        // ----------------------------------------------------
        // مؤتمر
        // ----------------------------------------------------

        if (_selectedType == 'conference') {
          if (_proofFile == null) {
            throw Exception(
              'ملف إثبات المؤتمر مطلوب',
            );
          }

          final conference = ConferenceModel(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            isInternational: _isInternational,
            isSpecialized: _isSpecialized,
            isPublished: _isPublished,
            participationType: _participationType,
            certificateUrl: '',
            status: VerificationStatus.pending,
          );

          await cubit.addConference(
            doctorUid: widget.doctorUid,
            conference: conference,
            certFile: _proofFile!.file,
          );
        }

        // ----------------------------------------------------
        // معرض
        // ----------------------------------------------------

        else if (_selectedType == 'exhibition') {
          if (_proofFile == null) {
            throw Exception(
              'ملف إثبات المعرض مطلوب',
            );
          }

          final exhibition = ArtExhibitionModel(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            venue: _selectedVenue,
            numberOfWorks: _numberOfWorks,
            researcherNotes: _notesController.text.trim(),
            proofFileUrl: '',
            proofFileType: '',
            status: VerificationStatus.pending,
          );

          await cubit.addExhibition(
            doctorUid: widget.doctorUid,
            exhibition: exhibition,
            proofFile: _proofFile!.file,
          );
        }

        // ----------------------------------------------------
        // دورة عادية
        // ----------------------------------------------------

        else if (_selectedType == 'course') {
          if (_proofFile == null) {
            throw Exception(
              'ملف إثبات الدورة مطلوب',
            );
          }

          final course = CourseModel(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            organization: _organizationController.text.trim(),
            date: _dateController.text.trim(),
            durationHours: int.tryParse(
              _durationHoursController.text.trim(),
            ),

            // دورة عادية
            type: CourseType.graded,

            courseCategory: _selectedCategory,
            courseScope: _selectedScope,

            // ليست دورة من السبعة
            mandatoryKey: null,

            certificateUrl: '',

            // تنتظر موافقة الأدمن
            status: VerificationStatus.pending,
          );

          await cubit.addCourse(
            doctorUid: widget.doctorUid,
            course: course,
            certFile: _proofFile!.file,
          );
        }
      }

      // ======================================================
      // 2. الدورات الإلزامية المختارة
      // ======================================================

      for (final courseData in _mandatoryCoursesList) {
        final key = courseData['key']!;

        if (!_selectedMandatoryCourses.contains(key)) {
          continue;
        }

        final file = _mandatoryCourseFiles[key];

        if (file == null) {
          throw Exception(
            '${courseData['titleAr']} - '
            '${'addActivity.fileRequired'.tr()}',
          );
        }

        final mandatoryCourse = CourseModel(
          id: const Uuid().v4(),

          // الاسم الموجود في القائمة
          title: courseData['titleAr']!,

          organization: '',
          date: '',
          durationHours: null,

          // ✅ دورة إلزامية
          type: CourseType.mandatory,

          courseCategory: CourseCategory.none,
          courseScope: CourseScope.none,

          // ✅ ربطها بالدورة المحددة
          mandatoryKey: key,

          certificateUrl: '',

          // ✅ الدكتور يرفعها -> الأدمن يعتمدها
          status: VerificationStatus.pending,
        );

        await cubit.addCourse(
          doctorUid: widget.doctorUid,
          course: mandatoryCourse,
          certFile: file.file,
        );
      }
    });
  }

  // ==========================================================
  // Build
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityCubit, ActivityState>(
      listener: (context, state) {
        // ====================================================
        // نجاح
        // ====================================================

        if (state is ActivitySuccess) {
          context.pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'addActivity.success'.tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        // ====================================================
        // خطأ
        // ====================================================

        else if (state is ActivityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      builder: (context, state) {
        final isLoading = state is ActivityLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'addActivity.title'.tr(),
            ),
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // الدورات الإلزامية
                  // ==================================================

                  _buildMandatoryCoursesSection(),

                  SizedBox(height: 20.h),

                  // ==================================================
                  // نوع النشاط العادي
                  // ==================================================

                  _buildActivityTypeSelector(),

                  SizedBox(height: 20.h),

                  // ==================================================
                  // الحقول المشتركة
                  // ==================================================

                  _buildCommonFields(),

                  SizedBox(height: 20.h),

                  // ==================================================
                  // المؤتمر
                  // ==================================================

                  if (_selectedType == 'conference')
                    _buildConferenceFields(),

                  // ==================================================
                  // المعرض
                  // ==================================================

                  if (_selectedType == 'exhibition')
                    _buildExhibitionFields(),

                  // ==================================================
                  // الدورة العادية
                  // ==================================================

                  if (_selectedType == 'course')
                    _buildCourseFields(),

                  SizedBox(height: 20.h),

                  // ==================================================
                  // الملف والحفظ
                  // ==================================================

                  _buildProofAndSubmitSection(
                    isLoading,
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // اختيار نوع النشاط
  // ==========================================================

  Widget _buildActivityTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedType,

      decoration: InputDecoration(
        labelText: 'addActivity.type'.tr(),
      ),

      items: [
        DropdownMenuItem(
          value: 'conference',
          child: Text(
            'addActivity.typeConferenceWorkshop'.tr(),
          ),
        ),

        DropdownMenuItem(
          value: 'exhibition',
          child: Text(
            'addActivity.typeExhibition'.tr(),
          ),
        ),

        DropdownMenuItem(
          value: 'course',
          child: Text(
            'addActivity.typeCourse'.tr(),
          ),
        ),
      ],

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedType = value;

          if (value == 'course') {
            _courseType = CourseType.graded;
          }
        });
      },
    );
  }

  // ==========================================================
  // الحقول المشتركة
  // ==========================================================

  Widget _buildCommonFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,

          decoration: InputDecoration(
            labelText:
                'addActivity.activityTitle'.tr(),
          ),

          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'validation.required'.tr();
            }

            return null;
          },
        ),

        SizedBox(height: 12.h),

        TextFormField(
          controller: _organizationController,

          decoration: InputDecoration(
            labelText:
                'addActivity.organization'.tr(),
          ),

          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'validation.required'.tr();
            }

            return null;
          },
        ),

        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              flex: 2,

              child: TextFormField(
                controller: _dateController,

                decoration: InputDecoration(
                  labelText:
                      'addActivity.date'.tr(),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'validation.required'.tr();
                  }

                  return null;
                },
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              flex: 1,

              child: TextFormField(
                controller:
                    _durationHoursController,

                decoration: InputDecoration(
                  labelText:
                      'addActivity.durationHours'.tr(),
                ),

                keyboardType:
                    TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // حقول المؤتمر
  // ==========================================================

  Widget _buildConferenceFields() {
    return Column(
      children: [
        _buildSwitchTile(
          title:
              'addActivity.isInternational'.tr(),
          value: _isInternational,
          onChanged: (value) {
            setState(() {
              _isInternational = value;
            });
          },
        ),

        _buildSwitchTile(
          title:
              'addActivity.isSpecialized'.tr(),
          value: _isSpecialized,
          onChanged: (value) {
            setState(() {
              _isSpecialized = value;
            });
          },
        ),

        _buildSwitchTile(
          title:
              'addActivity.isPublished'.tr(),
          value: _isPublished,
          onChanged: (value) {
            setState(() {
              _isPublished = value;
            });
          },
        ),

        DropdownButtonFormField<ParticipationType>(
          value: _participationType,

          decoration: InputDecoration(
            labelText:
                'addActivity.participationType'.tr(),
          ),

          items: [
            DropdownMenuItem(
              value:
                  ParticipationType.paperPresentation,
              child: Text(
                'addActivity.partPaperPresentation'
                    .tr(),
              ),
            ),

            DropdownMenuItem(
              value:
                  ParticipationType.abstractPresentation,
              child: Text(
                'addActivity.partAbstractPresentation'
                    .tr(),
              ),
            ),

            DropdownMenuItem(
              value:
                  ParticipationType.attendanceOnly,
              child: Text(
                'addActivity.partAttendanceOnly'
                    .tr(),
              ),
            ),
          ],

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _participationType = value;
            });
          },
        ),
      ],
    );
  }

  // ==========================================================
  // حقول المعرض
  // ==========================================================

  Widget _buildExhibitionFields() {
    return Column(
      children: [
        SizedBox(height: 12.h),

        DropdownButtonFormField<ExhibitionVenue>(
          value: _selectedVenue,

          decoration: InputDecoration(
            labelText:
                'addActivity.exhibitionVenue'.tr(),
          ),

          items: ExhibitionVenue.values.map(
            (venue) {
              String label;

              switch (venue) {
                case ExhibitionVenue.internationalAbroad:
                  label =
                      'addActivity.venueAbroad'.tr();
                  break;

                case ExhibitionVenue.internationalEgypt:
                  label =
                      'addActivity.venueEgypt'.tr();
                  break;

                case ExhibitionVenue.artFaculties:
                  label =
                      'addActivity.venueArtFaculties'
                          .tr();
                  break;

                case ExhibitionVenue.fineArtsSector:
                  label =
                      'addActivity.venueFineArtsSector'
                          .tr();
                  break;

                case ExhibitionVenue.foreignCulturalCenters:
                  label =
                      'addActivity.venueForeignCenters'
                          .tr();
                  break;

                case ExhibitionVenue.artSyndicates:
                  label =
                      'addActivity.venueSyndicates'
                          .tr();
                  break;

                case ExhibitionVenue.culturePalaces:
                  label =
                      'addActivity.venueCulturePalaces'
                          .tr();
                  break;

                case ExhibitionVenue.ateliersCairoAlex:
                  label =
                      'addActivity.venueAteliers'.tr();
                  break;

                case ExhibitionVenue.privateGalleries:
                  label =
                      'addActivity.venuePrivateGalleries'
                          .tr();
                  break;
              }

              return DropdownMenuItem(
                value: venue,
                child: Text(label),
              );
            },
          ).toList(),

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedVenue = value;
            });
          },
        ),

        SizedBox(height: 12.h),

        TextFormField(
          initialValue:
              _numberOfWorks.toString(),

          decoration: InputDecoration(
            labelText:
                'addActivity.numberOfWorks'.tr(),

            hintText:
                'addActivity.exhibitionWorksHint'.tr(),

            hintStyle: TextStyle(
              fontSize: 11.sp,
              color: Colors.orange,
            ),
          ),

          keyboardType: TextInputType.number,

          onChanged: (value) {
            final parsed =
                int.tryParse(value);

            if (parsed != null &&
                parsed >= 1) {
              setState(() {
                _numberOfWorks = parsed;
              });
            }
          },

          validator: (value) {
            final parsed =
                int.tryParse(value ?? '');

            if (parsed == null ||
                parsed < 1) {
              return
                  'addActivity.validationMinWorks'
                      .tr();
            }

            return null;
          },
        ),

        SizedBox(height: 12.h),

        TextFormField(
          controller: _notesController,
          maxLines: 3,

          decoration: InputDecoration(
            labelText:
                'addActivity.researcherNotes'.tr(),

            alignLabelWithHint: true,

            hintText:
                'addActivity.researcherNotesHint'
                    .tr(),

            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // حقول الدورة العادية
  // ==========================================================

  Widget _buildCourseFields() {
    return Column(
      children: [
        DropdownButtonFormField<CourseCategory>(
          value: _selectedCategory,

          decoration: InputDecoration(
            labelText:
                'addActivity.courseCategory'.tr(),
          ),

          items: [
            DropdownMenuItem(
              value:
                  CourseCategory.administrative,
              child: Text(
                'addActivity.catAdmin'.tr(),
              ),
            ),

            DropdownMenuItem(
              value:
                  CourseCategory.specialized,
              child: Text(
                'addActivity.catSpec'.tr(),
              ),
            ),

            DropdownMenuItem(
              value:
                  CourseCategory.general,
              child: Text(
                'addActivity.catGeneral'.tr(),
              ),
            ),
          ],

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedCategory = value;
            });
          },
        ),

        SizedBox(height: 12.h),

        DropdownButtonFormField<CourseScope>(
          value: _selectedScope,

          decoration: InputDecoration(
            labelText:
                'addActivity.courseScope'.tr(),
          ),

          items: [
            DropdownMenuItem(
              value: CourseScope.international,
              child: Text(
                'addActivity.scopeInt'.tr(),
              ),
            ),

            DropdownMenuItem(
              value: CourseScope.local,
              child: Text(
                'addActivity.scopeLocal'.tr(),
              ),
            ),
          ],

          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedScope = value;
            });
          },
        ),
      ],
    );
  }

  // ==========================================================
  // ملف الإثبات + زر الحفظ
  // ==========================================================

  Widget _buildProofAndSubmitSection(
    bool isLoading,
  ) {
    return Column(
      children: [
        // ملف النشاط العادي
        //
        // لو الدكتور بيرفع دورات إلزامية فقط،
        // الملف ده مش مستخدم.
        FilePickerField(
          label:
              'addActivity.proofFile'.tr(),

          selectedFile: _proofFile,

          onFileSelected: (file) {
            setState(() {
              _proofFile = file;
            });
          },
        ),

        SizedBox(height: 30.h),

        SizedBox(
          width: double.infinity,
          height: 50.h,

          child: ElevatedButton(
            onPressed:
                isLoading ? null : _submit,

            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.purple,

              foregroundColor:
                  Colors.white,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12.r),
              ),
            ),

            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    'addActivity.submit'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // Switch
  // ==========================================================

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ==========================================================
  // الدورات الإلزامية
  // ==========================================================

  Widget _buildMandatoryCoursesSection() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 20.h,
      ),

      padding: EdgeInsets.all(16.w),

      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,

        borderRadius:
            BorderRadius.circular(16.r),

        border: Border.all(
          color: Colors.deepPurple,
          width: 1.5,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ====================================================
          // العنوان
          // ====================================================

          Row(
            children: [
              Icon(
                Icons
                    .playlist_add_check_rounded,
                color:
                    Colors.deepPurple,
                size: 22.sp,
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'addActivity.'
                      'mandatory_courses_title'
                          .tr(),

                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Colors.deepPurple
                                .shade900,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'addActivity.'
                      'mandatory_courses_subtitle'
                          .tr(),

                      style: TextStyle(
                        fontSize: 11.sp,
                        color:
                            Colors.deepPurple
                                .shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 15.h),

          // ====================================================
          // الدورات السبعة
          // ====================================================

          ..._mandatoryCoursesList.map(
            (courseData) {
              final key =
                  courseData['key']!;

              final titleAr =
                  courseData['titleAr']!;

              final isSelected =
                  _selectedMandatoryCourses
                      .contains(key);

              return Container(
                margin:
                    EdgeInsets.only(
                  bottom: 12.h,
                ),

                padding:
                    EdgeInsets.all(12.w),

                decoration:
                    BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    12.r,
                  ),

                  border: Border.all(
                    color: isSelected
                        ? Colors.deepPurple
                        : Colors.grey
                            .shade300,

                    width:
                        isSelected
                            ? 1.5
                            : 1,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    // ========================================
                    // الاختيار
                    // ========================================

                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedMandatoryCourses
                                .remove(key);

                            _mandatoryCourseFiles
                                .remove(key);
                          } else {
                            _selectedMandatoryCourses
                                .add(key);
                          }
                        });
                      },

                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons
                                    .check_box_rounded
                                : Icons
                                    .check_box_outline_blank,

                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey,
                          ),

                          SizedBox(width: 10.w),

                          Expanded(
                            child: Text(
                              titleAr,

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,

                                fontSize: 13.sp,

                                color: isSelected
                                    ? Colors
                                        .deepPurple
                                    : Colors
                                        .black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ========================================
                    // ملف الدورة
                    // ========================================

                    if (isSelected) ...[
                      SizedBox(height: 10.h),

                      FilePickerField(
                        label:
                            '$titleAr - '
                            '${'addActivity.proofFile'.tr()}',

                        selectedFile:
                            _mandatoryCourseFiles[
                                key],

                        onFileSelected: (file) {
                          setState(() {
                            _mandatoryCourseFiles[
                                key] = file;
                          });
                        },
                      ),

                      SizedBox(height: 6.h),

                      // توضيح للدكتور
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14.sp,
                            color:
                                Colors.deepPurple,
                          ),

                          SizedBox(width: 5.w),

                          Expanded(
                            child: Text(
                              'addActivity.'
                              'admin_review_required'
                                  .tr(),

                              style: TextStyle(
                                fontSize: 10.sp,
                                color:
                                    Colors.deepPurple
                                        .shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}