import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';

class DigitalArchivePage extends StatelessWidget {
  final String doctorUid;

  const DigitalArchivePage({super.key, required this.doctorUid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<DoctorDataCubit, DoctorDataState>(
      builder: (context, state) {
        DoctorProfileModel? doctor;
        if (state is DoctorLoaded) {
          doctor = state.doctor;
        }

        final List<Map<String, dynamic>> archivedFiles =
            (doctor != null && doctor.toMap().containsKey('digital_archive'))
            ? List<Map<String, dynamic>>.from(
                doctor.toMap()['digital_archive'] ?? [],
              )
            : [];

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              elevation: 0,
              toolbarHeight: 80.h,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 30.sp,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(Routes.user);
                  }
                },
              ),
              title: Row(
                children: [
                  Text(
                    'archive.title'.tr(),
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  const Spacer(),
                  _buildAppBarProfile(colorScheme, doctor?.profileImage),
                  SizedBox(width: 12.w),
                ],
              ),
              bottom: TabBar(
                indicatorColor: colorScheme.secondary,
                indicatorWeight: 3,
                labelColor: colorScheme.secondary,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
                tabs: [
                  Tab(text: "archive.tabs.research".tr()),
                  Tab(text: "archive.tabs.conferences".tr()),
                  Tab(text: "archive.tabs.others".tr()),
                ],
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _buildSearchAndSortBar(colorScheme),
                  SizedBox(height: 20.h),
                  Expanded(
                    // ✅ تم إضافة TabBarView عشان التبويبات تشتغل بشكل صحيح
                    child: archivedFiles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 60.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "archive.no_files".tr(),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : TabBarView(
                            children: [
                              // في كل تبويب نعرض نفس القائمة (لأن الفلترة لم تطبق بعد)
                              _buildFilesGrid(
                                context,
                                archivedFiles,
                                colorScheme,
                              ),
                              _buildFilesGrid(
                                context,
                                archivedFiles,
                                colorScheme,
                              ),
                              _buildFilesGrid(
                                context,
                                archivedFiles,
                                colorScheme,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.push('/user/uploadFiles?uid=$doctorUid');
              },
              backgroundColor: colorScheme.secondary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(Icons.add, size: 28.sp, color: colorScheme.primary),
            ),
          ),
        );
      },
    );
  }

  // ✅ تم فصل الـ GridView في دالة منفصلة عشان نستخدمها في الـ TabBarView
  Widget _buildFilesGrid(
    BuildContext context,
    List<Map<String, dynamic>> archivedFiles,
    ColorScheme colorScheme,
  ) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 0.85,
      ),
      itemCount: archivedFiles.length,
      itemBuilder: (context, index) {
        final file = archivedFiles[index];
        return _buildFileCard(context, {
          'name': file['title'] ?? 'archive.unknown_file'.tr(),
          'url': file['file_url'] ?? '',
          'type': _getExtensionFromUrl(file['file_url'] ?? ''),
        });
      },
    );
  }

  String _getExtensionFromUrl(String url) {
    if (url.isEmpty) return 'pdf';
    final uri = Uri.parse(url);
    final path = uri.path;
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png')) {
      return 'image';
    }
    if (path.endsWith('.pdf')) return 'pdf';
    if (path.endsWith('.doc') || path.endsWith('.docx')) return 'doc';
    return 'pdf';
  }

  Widget _buildAppBarProfile(ColorScheme colorScheme, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.secondary, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: colorScheme.secondary.withOpacity(0.2),
        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: (imageUrl == null || imageUrl.isEmpty)
            ? Icon(Icons.person, color: Colors.white, size: 18.sp)
            : null,
      ),
    );
  }

  Widget _buildSearchAndSortBar(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.sort_rounded, color: colorScheme.primary, size: 22.sp),
        SizedBox(width: 10.w),
        Text(
          "archive.sort_by_date".tr(),
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: colorScheme.primary, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(BuildContext context, Map<String, String> file) {
    final colorScheme = Theme.of(context).colorScheme;
    String fileName = file['name'] ?? 'Unknown File';
    String fileUrl = file['url'] ?? '';
    String fileType = file['type'] ?? 'pdf';

    IconData fileIcon = Icons.picture_as_pdf;
    Color iconColor = Colors.red.shade400;
    if (fileType == 'image') {
      fileIcon = Icons.image_outlined;
      iconColor = Colors.blue.shade400;
    } else if (fileType == 'doc') {
      fileIcon = Icons.description_outlined;
      iconColor = Colors.blue.shade700;
    }

    return InkWell(
      onTap: () => _openFile(fileUrl),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: colorScheme.primary.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  fileIcon,
                  size: 65.sp,
                  color: iconColor.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                fileType.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.download_rounded,
                  size: 18.sp,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }
}
