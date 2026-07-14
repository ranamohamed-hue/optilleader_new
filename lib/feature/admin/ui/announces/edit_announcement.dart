import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/logic/announcement_logic/announcement_cubit.dart';
import 'package:intl/intl.dart';

import 'package:optialeader/feature/admin/ui/announces/administrative_roles_data.dart';
import 'package:optialeader/feature/admin/ui/announces/mansoura_universities_data.dart';

class EditAnnouncementPage extends StatefulWidget {
  final AnnouncementModel? announcement;

  const EditAnnouncementPage({super.key, this.announcement});

  @override
  State<EditAnnouncementPage> createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _dateController;
  late String _selectedStatus;
  late String _selectedTargetRole;
  late DateTime _selectedDeadline;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // 🏛️ بيانات الكلية والقسم
  String? _selectedCollegeId;
  String? _selectedCollegeName;
  String? _selectedDepartmentId;
  String? _selectedDepartmentName;

  // 📋 بيانات الإدارات (للـ admin_manager)
  String? _selectedAdminSectorId;
  String? _selectedAdminSectorName;
  String? _selectedAdminSubDeptId;
  String? _selectedAdminSubDeptName;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _bodyController = TextEditingController(text: widget.announcement?.description ?? '');
    _selectedDeadline = widget.announcement?.deadline ?? DateTime.now();
    _selectedStatus = widget.announcement?.status ?? 'Active';
    _selectedTargetRole = widget.announcement?.targetRole ?? 'general';
    _dateController = TextEditingController();

    // 🏛️ استرجاع بيانات الكلية والقسم
    _selectedCollegeId = widget.announcement?.collegeId;
    _selectedCollegeName = widget.announcement?.collegeName;
    _selectedDepartmentId = widget.announcement?.departmentId;
    _selectedDepartmentName = widget.announcement?.departmentName;

    // 📋 استرجاع بيانات الإدارات
    _selectedAdminSectorId = widget.announcement?.adminSectorId;
    _selectedAdminSectorName = widget.announcement?.adminSectorName;
    _selectedAdminSubDeptId = widget.announcement?.adminSubDeptId;
    _selectedAdminSubDeptName = widget.announcement?.adminSubDeptName;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dateController.text.isEmpty) {
      _dateController.text = DateFormat.yMd(context.locale.languageCode).format(_selectedDeadline);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
    if (pickedFile != null) setState(() => _pickedImage = pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 🧠 التحكم الذكي في إظهار الحقول
    final bool showCollege = MansouraUniversitiesData.targetRoleRequiresFaculty(_selectedTargetRole);
    final bool showDepartment = MansouraUniversitiesData.targetRoleRequiresDepartment(_selectedTargetRole);
    final bool showAdminDept = _selectedTargetRole == 'admin_manager';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            pinned: true,
            backgroundColor: colorScheme.primary,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                "edit_announcement.title".tr(),
                style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: colorScheme.primary.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel("edit_announcement.field_title".tr(), Icons.title_rounded, colorScheme),
                    _buildCustomTextField(_titleController, colorScheme, hint: "edit_announcement.hint_title".tr()),
                    const SizedBox(height: 25),

                    _buildFieldLabel("edit_announcement.field_target_role".tr(), Icons.military_tech, colorScheme),
                    _buildTargetRoleDropdown(colorScheme),
                    const SizedBox(height: 25),

                    // =============================================
                    // 🏛️ كلية وأقسام الأكاديميين
                    // =============================================
                    if (showCollege) ...[
                      _buildFieldLabel("edit_announcement.field_college".tr(), Icons.domain, colorScheme),
                      _buildCollegeDropdown(colorScheme),
                      const SizedBox(height: 25),
                    ],

                    if (showDepartment) ...[
                      _buildFieldLabel("edit_announcement.field_department".tr(), Icons.meeting_room, colorScheme),
                      _buildDepartmentDropdown(colorScheme),
                      const SizedBox(height: 25),
                    ],

                    // =============================================
                    // 📋 قطاعات وإدارات الوظائف الإدارية
                    // =============================================
                    if (showAdminDept) ...[
                      _buildFieldLabel("edit_announcement.field_admin_sector".tr(), Icons.account_balance, colorScheme),
                      _buildAdminSectorDropdown(colorScheme),
                      const SizedBox(height: 25),

                      _buildFieldLabel("edit_announcement.field_admin_sub_dept".tr(), Icons.corporate_fare, colorScheme),
                      _buildAdminSubDeptDropdown(colorScheme),
                      const SizedBox(height: 25),
                    ],

                    _buildFieldLabel("edit_announcement.field_desc".tr(), Icons.subject_rounded, colorScheme),
                    _buildCustomTextField(_bodyController, colorScheme, hint: "edit_announcement.hint_desc".tr(), maxLines: 4),
                    const SizedBox(height: 25),

                    _buildFieldLabel("edit_announcement.field_image".tr(), Icons.image_outlined, colorScheme),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: _pickedImage != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
                            : (widget.announcement?.imageUrl != null && widget.announcement!.imageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.announcement!.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => Center(child: CircularProgressIndicator(color: colorScheme.secondary)),
                                      errorWidget: (_, _, _) => Icon(Icons.broken_image, color: colorScheme.error, size: 40),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, size: 45, color: colorScheme.secondary.withOpacity(0.7)),
                                      const SizedBox(height: 8),
                                      Text("edit_announcement.hint_image".tr(), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("edit_announcement.field_date".tr(), Icons.calendar_month_rounded, colorScheme),
                              _buildDateField(colorScheme),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("edit_announcement.field_status".tr(), Icons.info_outline_rounded, colorScheme),
                              _buildStatusDropdown(colorScheme),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: Text("common.cancel".tr(), style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => _handleUpdate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text("edit_announcement.save_button".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏛️ دروب داون الكلية (من الكلاس الجديد)
  // ============================================================
  Widget _buildCollegeDropdown(ColorScheme colorScheme) {
    final isArabic = context.locale.languageCode == 'ar';
    final colleges = MansouraUniversitiesData.faculties;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCollegeId,
          isExpanded: true,
          hint: Text("edit_announcement.hint_college".tr()),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            final college = MansouraUniversitiesData.getFacultyById(val!);
            setState(() {
              _selectedCollegeId = val;
              _selectedCollegeName = isArabic ? college!.nameAr : college!.nameEn;
              // مسح القسم لما يغير الكلية
              _selectedDepartmentId = null;
              _selectedDepartmentName = null;
            });
          },
          items: colleges.map((c) => DropdownMenuItem(
            value: c.id,
            child: Text(isArabic ? c.nameAr : c.nameEn),
          )).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // 🏢 دروب داون القسم (ديناميكي حسب الكلية)
  // ============================================================
  Widget _buildDepartmentDropdown(ColorScheme colorScheme) {
    final isArabic = context.locale.languageCode == 'ar';
    final departments = MansouraUniversitiesData.getDepartmentsByFacultyId(_selectedCollegeId ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: departments.any((d) => d.id == _selectedDepartmentId) ? _selectedDepartmentId : null,
          isExpanded: true,
          hint: Text("edit_announcement.hint_department".tr()),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            final dept = departments.firstWhere((d) => d.id == val);
            setState(() {
              _selectedDepartmentId = val;
              _selectedDepartmentName = isArabic ? dept.nameAr : dept.nameEn;
            });
          },
          items: departments.map((d) => DropdownMenuItem(
            value: d.id,
            child: Text(isArabic ? d.nameAr : d.nameEn),
          )).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // 📋 دروب داون القطاع/الإدارة العامة
  // ============================================================
  Widget _buildAdminSectorDropdown(ColorScheme colorScheme) {
    final isArabic = context.locale.languageCode == 'ar';
    final sectors = AdministrativeRolesData.departments;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAdminSectorId,
          isExpanded: true,
          hint: Text("edit_announcement.hint_admin_sector".tr()),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            final sector = AdministrativeRolesData.getDepartmentById(val!);
            setState(() {
              _selectedAdminSectorId = val;
              _selectedAdminSectorName = isArabic ? sector!.nameAr : sector!.nameEn;
              // مسح الإدارة الفرعية لما يغير القطاع
              _selectedAdminSubDeptId = null;
              _selectedAdminSubDeptName = null;
            });
          },
          items: sectors.map((s) => DropdownMenuItem(
            value: s.id,
            child: Text(isArabic ? s.nameAr : s.nameEn),
          )).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // 📁 دروب داون الإدارة الفرعية (ديناميكي حسب القطاع)
  // ============================================================
  Widget _buildAdminSubDeptDropdown(ColorScheme colorScheme) {
    final isArabic = context.locale.languageCode == 'ar';
    final subDepts = AdministrativeRolesData.getSubDepartmentsByDepartmentId(_selectedAdminSectorId ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: subDepts.any((s) => s.id == _selectedAdminSubDeptId) ? _selectedAdminSubDeptId : null,
          isExpanded: true,
          hint: Text("edit_announcement.hint_admin_sub_dept".tr()),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            final subDept = subDepts.firstWhere((s) => s.id == val);
            setState(() {
              _selectedAdminSubDeptId = val;
              _selectedAdminSubDeptName = isArabic ? subDept.nameAr : subDept.nameEn;
            });
          },
          items: subDepts.map((s) => DropdownMenuItem(
            value: s.id,
            child: Text(isArabic ? s.nameAr : s.nameEn),
          )).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // 🎯 دروب داون نوع المسابقة
  // ============================================================
  Widget _buildTargetRoleDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTargetRole,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) {
            setState(() {
              _selectedTargetRole = val!;
              // ✅ مسح كل الحقول الاختيارية لما يغير النوع
              _selectedCollegeId = null;
              _selectedCollegeName = null;
              _selectedDepartmentId = null;
              _selectedDepartmentName = null;
              _selectedAdminSectorId = null;
              _selectedAdminSectorName = null;
              _selectedAdminSubDeptId = null;
              _selectedAdminSubDeptName = null;
            });
          },
          items: AnnouncementModel.targetRoleList.map((v) => DropdownMenuItem(value: v, child: Text(v.tr()))).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // 🧩 عناصر الـ UI المساعدة
  // ============================================================
  Widget _buildFieldLabel(String label, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.secondary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, ColorScheme colorScheme, {int maxLines = 1, required String hint}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: colorScheme.secondary, width: 1.5)),
      ),
    );
  }

  Widget _buildDateField(ColorScheme colorScheme) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDeadline,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDeadline = pickedDate;
            _dateController.text = DateFormat.yMd(context.locale.languageCode).format(pickedDate);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_dateController.text, style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
            Icon(Icons.calendar_today_rounded, size: 16, color: colorScheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.secondary),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (val) => setState(() => _selectedStatus = val!),
          items: AnnouncementModel.statusList.map((v) => DropdownMenuItem(value: v, child: Text("announce.$v".tr()))).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // 💾 حفظ/تحديث البيانات
  // ============================================================
  void _handleUpdate(BuildContext context) async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("edit_announcement.error_title_desc_required".tr())));
      return;
    }

    // ✅ تحقق ذكي حسب نوع المسابقة
    final showCollege = MansouraUniversitiesData.targetRoleRequiresFaculty(_selectedTargetRole);
    final showDepartment = MansouraUniversitiesData.targetRoleRequiresDepartment(_selectedTargetRole);
    final showAdminDept = _selectedTargetRole == 'admin_manager';

    if (showAdminDept) {
      if (_selectedAdminSectorId == null || _selectedAdminSubDeptId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("edit_announcement.error_sector_subdept_required".tr())));
        return;
      }
    } else if (showCollege || showDepartment) {
      if (showCollege && _selectedCollegeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("edit_announcement.error_college_required".tr())));
        return;
      }
      if (showDepartment && _selectedDepartmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("edit_announcement.error_dept_required".tr())));
        return;
      }
    }

    if (widget.announcement != null) {
      final updatedModel = widget.announcement!.copyWith(
        title: _titleController.text,
        description: _bodyController.text,
        status: _selectedStatus,
        deadline: _selectedDeadline,
        targetRole: _selectedTargetRole,
        collegeId: _selectedCollegeId,
        collegeName: _selectedCollegeName,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
        adminSectorId: _selectedAdminSectorId,
        adminSectorName: _selectedAdminSectorName,
        adminSubDeptId: _selectedAdminSubDeptId,
        adminSubDeptName: _selectedAdminSubDeptName,
      );
      await context.read<AnnouncementCubit>().updateAnnouncement(updatedModel, imagePath: _pickedImage?.path);
    } else {
      final newAnnouncement = AnnouncementModel(
        title: _titleController.text,
        description: _bodyController.text,
        status: _selectedStatus,
        deadline: _selectedDeadline,
        targetRole: _selectedTargetRole,
        createdAt: DateTime.now(),
        collegeId: _selectedCollegeId,
        collegeName: _selectedCollegeName,
        departmentId: _selectedDepartmentId,
        departmentName: _selectedDepartmentName,
        adminSectorId: _selectedAdminSectorId,
        adminSectorName: _selectedAdminSectorName,
        adminSubDeptId: _selectedAdminSubDeptId,
        adminSubDeptName: _selectedAdminSubDeptName,
      );
      await context.read<AnnouncementCubit>().addAnnouncement(newAnnouncement, imagePath: _pickedImage?.path);
    }

    if (context.mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("edit_announcement.success_msg".tr()), backgroundColor: Theme.of(context).colorScheme.primary),
      );
    }
  }
}