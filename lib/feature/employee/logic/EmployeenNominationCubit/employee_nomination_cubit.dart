import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ مضاف
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';
import 'package:optialeader/feature/employee/data/repo/NominationRequestRepository/employee_nomination_repo.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_state.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart'; // ✅ مضاف
import 'package:firebase_auth/firebase_auth.dart';
class EmployeeNominationCubit extends Cubit<EmployeeNominationState> {
  final EmployeeNominationRepository repo;
  final NotificationRepo notificationRepo;

  EmployeeNominationCubit({required this.repo, required this.notificationRepo})
      : super(EmployeeNominationInitial());

  // ============================================================
  // Submit Nomination Request
  // ============================================================

  Future<void> submitNominationRequest({
    required AnnouncementModel announcement,
    required String employeeId,
    required String employeeName,
    required String? employeeImageUrl,
    required String? currentJob,
    required String? sectorName,
    required String? departmentName,
    required String? visionStatement,
    required Map<String, File> requiredFiles,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      // 1. رفع جميع الملفات على Supabase وجلب الروابط
      Map<String, String> uploadedUrls = {};

      for (var entry in requiredFiles.entries) {
        final String docType = entry.key;
        final File file = entry.value;

        final String fileUrl = await _uploadFileToStorage(
          file: file,
          uid: employeeId,
          folder: 'nomination_docs',
        );

        uploadedUrls[docType] = fileUrl;
      }

      // 2. تجهيز الـ Model مع وضع روابط الملفات فيه
      final requestModel = EmployeeNominationRequestModel(
        employeeId: employeeId,
        employeeName: employeeName,
        employeeImageUrl: employeeImageUrl,
        applicantType: 'employee',
        currentJob: currentJob,
        sectorName: sectorName,
        departmentName: departmentName,
        announcementId: announcement.id ?? '',
        announcementTitle: announcement.title ?? '',
        targetRole: announcement.targetRole ?? '',
        visionStatement: visionStatement,
        uploadedDocuments: uploadedUrls,
        status: EmployeeNominationRequestModel.statusPendingAdmin,
        createdAt: DateTime.now(),
      );

      // 3. إرسال الـ Model للـ Repo لحفظه في Firestore
      final result = await repo.submitRequest(requestModel);

      result.fold(
        (error) => emit(EmployeeNominationError(error)),
        (docId) async {
          // ✅ إرسال إشعار للأدمن بوجود طلب ترشح جديد
              // ✅✅✅ الكود الصحيح (بيلقي الإشعار لكل أدمن في ملفه الحقيقي)
      await notificationRepo.sendRoleBasedNotification(
        AppNotificationModel(
          id: '',
          title: 'طلب ترشح جديد',
          message: 'تم تقديم طلب ترشح جديد من $employeeName لوظيفة مدير إدارة',
          receiverId: '', // مفيش داعي نكتب حاجة هنا، الدالة هتعملها لوحدها
          target: NotificationTarget.adminOnly, // ✅ نخليه يعرف إن المطلوب أدمن فقط
          type: NotificationType.activityStatusUpdated,
          timestamp: Timestamp.now(),
        ),
      );

          emit( EmployeeNominationActionSuccess('تم إرسال طلب الترشح بنجاح'));
        },
      );
    } 
    // ✅ بلوك معالجة الأخطاء الناقص
    catch (e) {
      emit(EmployeeNominationError('فشل إرسال الطلب: ${e.toString()}'));
    }
  }

  // ============================================================
  // دالة مساعدة لرفع الملفات (نفس المنطق المعتمد عندك)
  // ============================================================

  Future<String> _uploadFileToStorage({
    required File file,
    required String uid,
    required String folder,
  }) async {
    final extension = p.extension(file.path).toLowerCase();
    final bool isPdf = extension == '.pdf';
    Uint8List? fileBytes;

    if (isPdf) {
      fileBytes = await file.readAsBytes();
    } else {
      fileBytes = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 1200,
        minHeight: 1200,
        quality: 80,
      );
    }

    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception('فشل معالجة الملف');
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
    final storagePath = '$folder/$uid/$fileName';

    await Supabase.instance.client.storage.from('images').uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return Supabase.instance.client.storage.from('images').getPublicUrl(storagePath);
  }
    // ============================================================
  // Submit Evaluation (لتقييم المقابلة من المحكم)
  // ============================================================

    Future<void> submitEvaluation({
    required EmployeeNominationRequestModel request,
    required double points,
    required String? notes,
    required Map<String, dynamic> evaluationData,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      final updatedRequest = request.copyWith(
        evaluatorPoints: points,
        evaluatorNotes: notes,
        interviewEvaluation: evaluationData,
        status: EmployeeNominationRequestModel.statusEvaluated,
        updatedAt: DateTime.now(),
      );

      final result = await repo.updateRequest(updatedRequest);

      result.fold(
        (error) => emit(EmployeeNominationError(error)),
        (_) async {
          // 1. إرسال إشعار للأدمن
          await notificationRepo.sendNotification(
            AppNotificationModel(
              id: '',
              title: 'تقييم مقابلة مكتمل',
              message: 'قام المحكم بإكمال تقييم طلب ترشح الموظف ${request.employeeName} لوظيفة ${request.announcementTitle}',
              receiverId: 'admins',
              target: NotificationTarget.specificUser,
              type: NotificationType.activityStatusUpdated,
              timestamp: Timestamp.now(),
            ),
          );

          // 2. إرسال إشعار للموظف
          await notificationRepo.sendNotification(
            AppNotificationModel(
              id: '',
              title: 'تم تقييم مقابلتك',
              message: 'تم الانتهاء من تقييم المقابلة لطلب الترشح على وظيفة ${request.announcementTitle}',
              receiverId: request.employeeId,
              target: NotificationTarget.specificUser,
              type: NotificationType.activityStatusUpdated,
              timestamp: Timestamp.now(),
            ),
          );

          emit(const EmployeeNominationActionSuccess('تم إرسال التقييم بنجاح'));

          // ✅ 3. إعادة تحميل القائمة بشكل آلي عشان الطلب يختفي فوراً من الشاشة اللي قبلها
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          if (uid.isNotEmpty) {
            await fetchEvaluatorRequests(uid);
          }
        },
      );
    } catch (e) {
      emit(EmployeeNominationError('فشل إرسال التقييم: ${e.toString()}'));
    }
  }
  // Fetch Evaluator Requests (لجلب طلبات الترشح للمحكم)
  // ============================================================

  Future<void> fetchEvaluatorRequests(String evaluatorId) async {
    emit(EmployeeNominationLoading());

    try {
      // استدعاء الـ Stream من الـ Repo وتحويله لـ List مرة واحدة
      final requests = await repo.getEvaluatorRequests(evaluatorId).first;

      emit(EmployeeNominationLoaded(requests: requests));
    } catch (e) {
      emit(EmployeeNominationError('فشل جلب الطلبات: ${e.toString()}'));
    }
  }
    // ============================================================
  // Schedule Interview (تحديد موعد المقابلة)
  // ============================================================

   // ============================================================
  // Schedule Interview (تحديد موعد المقابلة)
  // ============================================================

  Future<void> scheduleInterview({
    required EmployeeNominationRequestModel request,
    required DateTime interviewDate,
    required String location,
    required String time,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      final updatedRequest = request.copyWith(
        interviewDate: interviewDate,
        interviewLocation: location,
        interviewTime: time,
        updatedAt: DateTime.now(),
      );

      final result = await repo.updateRequest(updatedRequest);

      result.fold(
        (error) => emit(EmployeeNominationError(error)),
        (_) async {
          
          // ✅ إرسال إشعار للموظف بتحديد موعد المقابلة (زي نظام الأطباء بالظبط)
          await notificationRepo.sendNotification(
            AppNotificationModel(
              id: '',
              title: 'تحديد موعد مقابلة',
              message: 'تم تحديد موعد مقابلتك لوظيفة ${request.announcementTitle} ليوم ${DateFormat('yyyy-MM-dd').format(interviewDate)} الساعة $time في $location',
              receiverId: request.employeeId,
              target: NotificationTarget.specificUser,
              type: NotificationType.activityStatusUpdated,
              timestamp: Timestamp.now(),
            ),
          );

          emit(const EmployeeNominationActionSuccess('تم تحديد موعد المقابلة بنجاح'));
        },
      );
    } catch (e) {
      emit(EmployeeNominationError('فشل تحديد الموعد: ${e.toString()}'));
    }
  } 


}