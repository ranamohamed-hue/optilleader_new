import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/doctor/logic/research_paper/research_paper_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class ResearchCubit extends Cubit<ResearchState> {
  final ResearchPaperRepo researchRepo;
  final NotificationRepo notificationRepo;

  ResearchCubit(this.researchRepo, this.notificationRepo)
      : super(ResearchInitial());

  // ==========================================
  // 1. إضافة بحث جديد (من طرف الدكتور)
  // ==========================================
  Future<void> addNewResearch({
    required String doctorUid,
    required ResearchPaperModel paper,
    required File paperFile,
    File? indexingProofFile,
    File? certifiedReportFile, // ملف التقرير المعتمد (اختياري للأدمن)
  }) async {
    emit(ResearchLoading());
    
    // إرسال البيانات للـ Repo لحفظها في Firestore
    final result = await researchRepo.addResearchPaper(
      doctorUid: doctorUid,
      paper: paper,
      paperFile: paperFile,
      indexingProofFile: indexingProofFile,
      certifiedReportFile: certifiedReportFile,
    );
    
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) async {
        emit(ResearchSuccess());
        
        // ==========================================
        // إرسال إشعار للأدمن (في الخلفية بدون ما يأثر على الـ UI)
        // ==========================================
        try {
          final notification = AppNotificationModel(
            id: '',
            title: 'طلب اعتماد بحث جديد',
            message: 'تم إضافة بحث بعنوان: "${paper.titleAr}" يحتاج موافقتك',
            type: NotificationType.newResearchSubmitted,
            target: NotificationTarget.adminOnly,
            timestamp: Timestamp.now(),
            receiverId: '', 
            relatedId: paper.id,
            doctorUid: doctorUid,
          );

          await notificationRepo.sendRoleBasedNotification(notification);
        } catch (e) {
          // لو الإشعار فشل، البرنامج كمش هيقف، البحث اتحفظ بنجاح
          print("خطأ في إرسال إشعار الأدمن: $e");
        }
      },
    );
  }

  // ==========================================
  // 2. حذف بحث
  // ==========================================
  Future<void> deleteResearch(String doctorUid, String paperId) async {
    emit(ResearchLoading());
    final result = await researchRepo.deleteResearchPaper(doctorUid, paperId);
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  // ==========================================
  // 3. قبول البحث (من طرف الأدمن)
  // ==========================================
  Future<void> approveResearch(
    String doctorUid, 
    String paperId, 
    {double? adminScore} // ✅ يمكن للأدمن إدخال درجته في نفس وقت القبول (اختياري)
  ) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid,
      paperId,
      VerificationStatus.approved,
      adminScore: adminScore, 
    );
    
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  // ==========================================
  // 4. رفض البحث (من طرف الأدمن)
  // ==========================================
  Future<void> rejectResearch(
    String doctorUid,
    String paperId,
    String reason, // سبب الرفض (هيظهر للدكتور)
  ) async {
    emit(ResearchLoading());
    final result = await researchRepo.updatePaperStatus(
      doctorUid,
      paperId,
      VerificationStatus.rejected,
      rejectionReason: reason,
    );
    
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }

  // ==========================================
  // 5. تحديث درجة الأدمن بشكل منفصل (الـ 90 درجة)
  // ==========================================
  /// ملاحظة: الموديل (Model) بيعمل حسابات ذكية:
  /// النقاط النهائية = (نقاط المجلة + نقاط الأدمن دي) × نسبة المشاركة
  /// لذلك درجة الأدمن بتتحفظ هنا، وبعدين الموديل بيزودها على نقاط المجلة الآلية
  Future<void> updateAdminScore({
    required String doctorUid,
    required String paperId,
    required double adminScore,
  }) async {
    emit(ResearchLoading());
    final result = await researchRepo.updateAdminScore(
      doctorUid: doctorUid,
      paperId: paperId,
      adminScore: adminScore,
    );
    result.fold(
      (error) => emit(ResearchError(error: error)),
      (_) => emit(ResearchSuccess()),
    );
  }
}