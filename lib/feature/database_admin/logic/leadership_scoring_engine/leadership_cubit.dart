import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_state.dart';

/// ============================================================
/// كوبيت إدارة الترشيحات (المنسق بين المحركات والواجهة)
/// ============================================================
class LeadershipCubit extends Cubit<LeadershipState> {
  final DoctorDataCubit doctorDataCubit;

  LeadershipCubit({required this.doctorDataCubit}) : super(LeadershipInitial());

  /// 1. حساب نقاط الدورات فقط (بعد استيفاء شرط الـ 2 إجبارية + ICDL)
  void calculateLeadershipScore() {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;

      // استدعاء محرك الحساب
      final scores = LeadershipScoringEngine.calculateTotalScore(doctor);
      double totalCoursePoints = scores['coursePoints'] ?? 0.0;

      emit(LeadershipScoreLoaded(coursePoints: totalCoursePoints));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }

  /// 2. حساب نسب المشاركة لكل بحث (مادة 22) لعرضها في التقارير
  void calculateArticle22Percentages() {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;
      Map<String, double> participationMap = {};

      for (var paper in doctor.researchPapers) {
        participationMap[paper.id] = paper.participationPercentage;
      }

      emit(Article22Loaded(participationMap: participationMap));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }

  /// 3. فحص الشروط الإلزامية فقط (من غير ما نحسب الدرجات)
  Future<void> checkMandatoryCriteria({
    required String targetRole,
    String? sector, // ✅ تم إضافة القطاع
  }) async {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;

      // لو الوظيفة "رئيس قسم"، لازم نجيب دكاترة القسم عشان نحسب الأقدم 3
      List<DoctorProfileModel> departmentDoctors = [];
      if (targetRole == 'head_department') {
        try {
          departmentDoctors = await doctorDataCubit.getAllDoctorsOnce();
        } catch (_) {}
      }

      // ✅ تمرير الـ sector للـ Engine
      final criteria = LeadershipCriteriaEngine.checkMandatoryCriteria(
        doctor: doctor,
        targetRole: targetRole,
        sector: sector, // ✅ التعديل هنا
        departmentDoctors: departmentDoctors,
      );

      emit(MandatoryCriteriaLoaded(criteria: criteria));
    } else {
      emit(LeadershipError("بيانات الدكتور غير متاحة"));
    }
  }

  /// 4. الدالة الشاملة: تجلب الدرجات + الشروط مع بعض لصفحة التقديم النهائية
  Future<void> loadNominationData({
    required String targetRole,
    String? sector, // ✅ تم إضافة القطاع
  }) async {
    emit(LeadershipLoading());
    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;

      // جلب دكاترة القسم لو لازمة
      List<DoctorProfileModel> departmentDoctors = [];
      if (targetRole == 'head_department') {
        try {
          departmentDoctors = await doctorDataCubit.getAllDoctorsOnce();
        } catch (_) {}
      }

      // 1. استدعاء محرك حساب الدرجات
      final scores = LeadershipScoringEngine.calculateTotalScore(doctor);

      // 2. استدعاء محرك فحص الشروط
      // ✅ تمرير الـ sector للـ Engine
      final criteria = LeadershipCriteriaEngine.checkMandatoryCriteria(
        doctor: doctor,
        targetRole: targetRole,
        sector: sector, // ✅ التعديل هنا
        departmentDoctors: departmentDoctors,
      );

      // 3. إرسال كل حاجة للواجهة في حالة واحدة
      emit(NominationDataLoaded(scores: scores, criteria: criteria));
    } else {
      emit(LeadershipError("error_fetch_requests"));
    }
  }
}