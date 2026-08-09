import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_state.dart';
class LeadershipCubit extends Cubit<LeadershipState> {
  final DoctorDataCubit doctorDataCubit;

  LeadershipCubit({
    required this.doctorDataCubit,
  }) : super(LeadershipInitial());

  /// ============================================================
  /// 1. حساب نقاط الدورات
  /// ============================================================
  void calculateLeadershipScore() {
    emit(LeadershipLoading());

    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;

      final scores =
          LeadershipScoringEngine.calculateTotalScore(doctor);

      final double totalCoursePoints =
          scores['coursePoints'] ?? 0.0;

      emit(
        LeadershipScoreLoaded(
          coursePoints: totalCoursePoints,
        ),
      );
    } else {
      emit(
        LeadershipError("بيانات الدكتور غير متاحة"),
      );
    }
  }

  /// ============================================================
  /// 2. حساب نسب المشاركة للأبحاث
  /// ============================================================
  void calculateArticle22Percentages() {
    emit(LeadershipLoading());

    final doctorState = doctorDataCubit.state;

    if (doctorState is DoctorLoaded) {
      final DoctorProfileModel doctor = doctorState.doctor!;

      final Map<String, double> participationMap = {};

      for (final paper in doctor.researchPapers) {
        participationMap[paper.id] =
            paper.participationPercentage;
      }

      emit(
        Article22Loaded(
          participationMap: participationMap,
        ),
      );
    } else {
      emit(
        LeadershipError("بيانات الدكتور غير متاحة"),
      );
    }
  }

  /// ============================================================
  /// 3. فحص الشروط الإلزامية
  /// ============================================================
  Future<void> checkMandatoryCriteria({
    required String targetRole,
    String? sector,
  }) async {
    emit(LeadershipLoading());

    final doctorState = doctorDataCubit.state;

    if (doctorState is! DoctorLoaded) {
      emit(
        LeadershipError("بيانات الدكتور غير متاحة"),
      );
      return;
    }

    final DoctorProfileModel doctor = doctorState.doctor!;

    List<DoctorProfileModel> departmentDoctors = [];

    // رئيس القسم يحتاج معرفة أقدم 3 أساتذة
    if (targetRole == 'head_department') {
      try {
        final allDoctors =
            await doctorDataCubit.getAllDoctorsOnce();

        departmentDoctors = allDoctors
            .where(
              (doc) =>
                  doc.departmentAr.trim() ==
                  doctor.departmentAr.trim(),
            )
            .toList();
      } catch (_) {
        departmentDoctors = [];
      }
    }

    final criteria =
        LeadershipCriteriaEngine.checkMandatoryCriteria(
      doctor: doctor,
      targetRole: targetRole,
      sector: sector,
      departmentDoctors: departmentDoctors,
    );

    emit(
      MandatoryCriteriaLoaded(
        criteria: criteria,
      ),
    );
  }

  /// ============================================================
  /// 4. تحميل بيانات الترشح كاملة
  /// ============================================================
  Future<void> loadNominationData({
    required String targetRole,
    String? sector,
  }) async {
    emit(LeadershipLoading());

    final doctorState = doctorDataCubit.state;

    if (doctorState is! DoctorLoaded) {
      emit(
        LeadershipError("بيانات الدكتور غير متاحة"),
      );
      return;
    }

    final DoctorProfileModel doctor = doctorState.doctor!;

    List<DoctorProfileModel> departmentDoctors = [];

    // رئيس القسم فقط يحتاج بيانات دكاترة القسم
    if (targetRole == 'head_department') {
      try {
        final allDoctors =
            await doctorDataCubit.getAllDoctorsOnce();

        departmentDoctors = allDoctors
            .where(
              (doc) =>
                  doc.departmentAr.trim() ==
                  doctor.departmentAr.trim(),
            )
            .toList();
      } catch (_) {
        departmentDoctors = [];
      }
    }

    // حساب الدرجات
    final scores =
        LeadershipScoringEngine.calculateTotalScore(doctor);

    // فحص الشروط
    final criteria =
        LeadershipCriteriaEngine.checkMandatoryCriteria(
      doctor: doctor,
      targetRole: targetRole,
      sector: sector,
      departmentDoctors: departmentDoctors,
    );

    // إرسال النتيجة للواجهة
    emit(
      NominationDataLoaded(
        scores: scores,
        criteria: criteria,
      ),
    );
  }
}