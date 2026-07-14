import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_cubit.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';
import 'package:optialeader/feature/doctor/ui/widgets/file_picker_field.dart';

class AddResearchPaperPage extends StatefulWidget {
  final String doctorUid;
  const AddResearchPaperPage({super.key, required this.doctorUid});

  @override
  State<AddResearchPaperPage> createState() => _AddResearchPaperPageState();
}

class _AddResearchPaperPageState extends State<AddResearchPaperPage> {
  final _formKey = GlobalKey<FormState>();

  // 1 بيانات التعريف الأساسية
  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _journalNameController = TextEditingController();
  final _issnController = TextEditingController();
  final _publicationYearController = TextEditingController();
  final _journalUrlController = TextEditingController();

  // 2 بيانات المحرك الحسابي (المؤثرة على النقاط)
  final _authorOrderController = TextEditingController();
  final _totalAuthorsController = TextEditingController();
  final _authorsInSameSpecialtyController = TextEditingController();

  // ❌ تم حذف _isTopTierJournal بالكامل

  // 3 متغيرات التصنيف
  JournalScope _selectedJournalScope = JournalScope.specialized;
  JournalLevel _selectedJournalLevel = JournalLevel.international;
  IndexingDatabase _selectedIndexDatabase = IndexingDatabase.scopus;

  String? _selectedQuartile;

  // 4 معايير المجلات المحلية
  bool _peerReviewed = false;
  bool _indexedDatabase = false;
  bool _electronicPublishing = false;
  bool _knownEditorialBoard = false;
  bool _regularPublication = false;
  bool _externalReviewers = false;
  bool _specializedJournal = false;
  bool _externalAuthors = false;

  // 5 ملفات الإثبات
  PickedFileData? _paperFile;
  PickedFileData? _indexingProofFile;

  // دوال مساعدة
  String _getDbName(IndexingDatabase db) {
    switch (db) {
      case IndexingDatabase.scopus:
        return 'addResearch.dbScopus'.tr();
      case IndexingDatabase.webOfScience:
        return 'addResearch.dbWebOfScience'.tr();
      case IndexingDatabase.local:
        return 'addResearch.dbLocal'.tr();
      case IndexingDatabase.other:
        return 'common.other'.tr();
    }
  }

  bool get _isInternational =>
      _selectedIndexDatabase == IndexingDatabase.scopus ||
      _selectedIndexDatabase == IndexingDatabase.webOfScience;

  bool get _isLocal => _selectedIndexDatabase == IndexingDatabase.local;

  void _resetLocalCriteria() {
    _peerReviewed = false;
    _indexedDatabase = false;
    _electronicPublishing = false;
    _knownEditorialBoard = false;
    _regularPublication = false;
    _externalReviewers = false;
    _specializedJournal = false;
    _externalAuthors = false;
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _journalNameController.dispose();
    _issnController.dispose();
    _publicationYearController.dispose();
    _authorOrderController.dispose();
    _totalAuthorsController.dispose();
    _journalUrlController.dispose();
    _authorsInSameSpecialtyController.dispose();
    super.dispose();
  }

  // دالة الحفظ والإرسال
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_paperFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('addResearch.fileRequired'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedIndexDatabase != IndexingDatabase.other &&
        _indexingProofFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('addResearch.indexingProofRequired'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final paper = ResearchPaperModel(
      id: const Uuid().v4(),
      titleAr: _titleArController.text.trim(),
      titleEn: _titleEnController.text.trim(),
      journalName: _journalNameController.text.trim(),
      issn: _issnController.text.trim(),
      impactFactor: '',
      publicationYear:
          int.tryParse(_publicationYearController.text.trim()) ?? 0,
      authorOrder: int.tryParse(_authorOrderController.text.trim()) ?? 1,
      totalAuthors: int.tryParse(_totalAuthorsController.text.trim()) ?? 1,
      authorsInSameSpecialty:
          int.tryParse(_authorsInSameSpecialtyController.text.trim()) ?? 1,
      // ❌ تم حذف isTopTierJournal من هنا
      journalScope: _selectedJournalScope,
      journalLevel: _selectedJournalLevel,
      indexingDatabase: _selectedIndexDatabase,
      journalUrl: _journalUrlController.text.trim(),
      quartile: _isInternational ? _selectedQuartile : null,
      isLocalJournal: _isLocal,
      peerReviewed: _peerReviewed,
      indexedDatabase: _indexedDatabase,
      electronicPublishing: _electronicPublishing,
      knownEditorialBoard: _knownEditorialBoard,
      regularPublication: _regularPublication,
      externalReviewers: _externalReviewers,
      specializedJournal: _specializedJournal,
      externalAuthors: _externalAuthors,
      paperFileUrl: '',
      paperFileType: _paperFile!.type == UploadedFileType.image
          ? 'image'
          : 'pdf',
      status: VerificationStatus.pending,
    );

    context.read<ResearchCubit>().addNewResearch(
      doctorUid: widget.doctorUid,
      paper: paper,
      paperFile: _paperFile!.file,
      indexingProofFile: _indexingProofFile?.file,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResearchCubit, ResearchState>(
      listener: (context, state) {
        if (state is ResearchSuccess) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('addResearch.success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ResearchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ResearchLoading;
        return Scaffold(
          appBar: AppBar(
            title: Text('addResearch.title'.tr()),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoFields(),
                  SizedBox(height: 16.h),
                  _buildClassificationDropdowns(),
                  SizedBox(height: 16.h),
                  if (_isInternational) ...[
                    _buildInternationalFields(),
                    SizedBox(height: 16.h),
                  ],
                  if (_isLocal) ...[
                    _buildLocalCriteriaSection(),
                    SizedBox(height: 16.h),
                  ],
                  if (_selectedIndexDatabase == IndexingDatabase.other) ...[
                    _buildIssnField(),
                    SizedBox(height: 16.h),
                  ],
                  _buildRemainingStatsFields(),
                  SizedBox(height: 16.h),

                  // ✅ بقت حقل الرابط بس من غير الـ Switch بتاع المجلة المصنفة
                  _buildJournalUrlField(),
                  SizedBox(height: 20.h),
                  _buildProofFilesSection(isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleArController,
          decoration: InputDecoration(labelText: 'addResearch.titleAr'.tr()),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _titleEnController,
          decoration: InputDecoration(labelText: 'addResearch.titleEn'.tr()),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _journalNameController,
          decoration: InputDecoration(
            labelText: 'addResearch.journalName'.tr(),
          ),
          validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
        ),
      ],
    );
  }

  Widget _buildClassificationDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<JournalScope>(
          value: _selectedJournalScope,
          decoration: InputDecoration(
            labelText: 'addResearch.journalScopeLabel'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: JournalScope.specialized,
              child: Text('addResearch.scopeSpecialized'.tr()),
            ),
            DropdownMenuItem(
              value: JournalScope.nonSpecialized,
              child: Text('addResearch.scopeNonSpecialized'.tr()),
            ),
          ],
          onChanged: (val) => setState(() => _selectedJournalScope = val!),
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        DropdownButtonFormField<JournalLevel>(
          value: _selectedJournalLevel,
          decoration: InputDecoration(
            labelText: 'addResearch.journalLevelLabel'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: JournalLevel.international,
              child: Text('addResearch.levelInternational'.tr()),
            ),
            DropdownMenuItem(
              value: JournalLevel.local,
              child: Text('addResearch.levelLocal'.tr()),
            ),
          ],
          onChanged: (val) => setState(() => _selectedJournalLevel = val!),
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        ),
        SizedBox(height: 12.h),
        DropdownButtonFormField<IndexingDatabase>(
          value: _selectedIndexDatabase,
          decoration: InputDecoration(
            labelText: 'addResearch.indexingDatabaseLabel'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: IndexingDatabase.scopus,
              child: Text('addResearch.dbScopus'.tr()),
            ),
            DropdownMenuItem(
              value: IndexingDatabase.webOfScience,
              child: Text('addResearch.dbWebOfScience'.tr()),
            ),
            DropdownMenuItem(
              value: IndexingDatabase.local,
              child: Text('addResearch.dbLocal'.tr()),
            ),
            DropdownMenuItem(
              value: IndexingDatabase.other,
              child: Text('common.other'.tr()),
            ),
          ],
          onChanged: (val) => setState(() {
            _selectedIndexDatabase = val!;
            _selectedQuartile = null;
            _resetLocalCriteria();
          }),
          validator: (v) => v == null ? 'validation.required'.tr() : null,
        ),
      ],
    );
  }

  Widget _buildInternationalFields() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, color: Colors.deepPurple, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'addResearch.internationalFieldsTitle'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          DropdownButtonFormField<String>(
            value: _selectedQuartile,
            decoration: InputDecoration(
              labelText: 'addResearch.quartile'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.bar_chart, color: Colors.deepPurple),
            ),
            items: ['q1', 'q2', 'q3', 'q4']
                .map(
                  (q) =>
                      DropdownMenuItem(value: q, child: Text(q.toUpperCase())),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedQuartile = val),
            validator: (v) => v == null ? 'validation.required'.tr() : null,
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _issnController,
            decoration: InputDecoration(
              labelText: 'addResearch.issn'.tr(),
              prefixIcon: Icon(Icons.tag, color: Colors.deepPurple),
            ),
            validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
          ),
        ],
      ),
    );
  }

  //  شروط المجلة المحلية بدون أي نقاط متكتبة (مجرد اختيارات)
  Widget _buildLocalCriteriaSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_city, color: Colors.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'addResearch.localCriteria'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'addResearch.localCriteriaHint'.tr(),
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),

          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria1'.tr(),
            value: _peerReviewed,
            onChanged: (v) => setState(() => _peerReviewed = v),
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria2'.tr(),
            value: _indexedDatabase,
            onChanged: (v) => setState(() => _indexedDatabase = v),
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria3'.tr(),
            value: _electronicPublishing,
            onChanged: (v) => setState(() => _electronicPublishing = v),
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria4'.tr(),
            value: _knownEditorialBoard,
            onChanged: (v) => setState(() => _knownEditorialBoard = v),
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria5'.tr(),
            value: _regularPublication,
            onChanged: (v) => setState(() => _regularPublication = v),
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria6'.tr(),
            value: _externalReviewers,
            onChanged: (v) => setState(() => _externalReviewers = v),
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria7'.tr(),
            value: _specializedJournal,
            onChanged: (v) => setState(() => _specializedJournal = v),
          ),
          _buildCriteriaCheckbox(
            label: 'localJournalCriteria.criteria8'.tr(),
            value: _externalAuthors,
            onChanged: (v) => setState(() => _externalAuthors = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      dense: true,
      title: Text(label, style: TextStyle(fontSize: 13.sp)),
      value: value,
      activeColor: Colors.orange,
      contentPadding: EdgeInsets.zero,
      onChanged: (v) => onChanged(v ?? false),
    );
  }

  Widget _buildIssnField() {
    return TextFormField(
      controller: _issnController,
      decoration: InputDecoration(labelText: 'addResearch.issn'.tr()),
      validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
    );
  }

  Widget _buildRemainingStatsFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _publicationYearController,
                decoration: InputDecoration(
                  labelText: 'addResearch.publicationYear'.tr(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'validation.required'.tr() : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _authorOrderController,
                decoration: InputDecoration(
                  labelText: 'addResearch.authorOrder'.tr(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'validation.required'.tr() : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _totalAuthorsController,
                decoration: InputDecoration(
                  labelText: 'addResearch.totalAuthors'.tr(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'validation.required'.tr() : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _authorsInSameSpecialtyController,
          decoration: InputDecoration(
            labelText: 'addResearch.authorsInSameSpecialty'.tr(),
            helperText: 'addResearch.authorsInSameSpecialtyHint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'validation.required'.tr();
            }

            final sameSpecialty = int.tryParse(v) ?? 0;
            final totalAuthors =
                int.tryParse(_totalAuthorsController.text) ?? 0;

            if (sameSpecialty > totalAuthors) {
              return 'لا يمكن أن يكون أكبر من إجمالي الباحثين';
            }

            return null;
          },
        ),
      ],
    );
  }

  Widget _buildJournalUrlField() {
    return TextFormField(
      controller: _journalUrlController,
      decoration: InputDecoration(labelText: 'addResearch.journalUrl'.tr()),
      validator: (v) => v!.isEmpty ? 'validation.required'.tr() : null,
    );
  }

  Widget _buildProofFilesSection(bool isLoading) {
    return Column(
      children: [
        FilePickerField(
          label: 'addResearch.paperFile'.tr(),
          selectedFile: _paperFile,
          onFileSelected: (file) => setState(() => _paperFile = file),
          isRequired: true,
        ),
        SizedBox(height: 12.h),
        FilePickerField(
          label: _selectedIndexDatabase == IndexingDatabase.other
              ? 'addResearch.indexingProof'.tr()
              : '${'addResearch.indexingProofLabelDynamic'.tr()} (${_getDbName(_selectedIndexDatabase)}) - ${'common.required'.tr()}',
          selectedFile: _indexingProofFile,
          onFileSelected: (file) => setState(() => _indexingProofFile = file),
          isRequired: _selectedIndexDatabase != IndexingDatabase.other,
        ),
        SizedBox(height: 30.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'addResearch.submit'.tr(),
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
}
