import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:optialeader/feature/database_admin/logic/employee_logic/employee_state.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/employee_repository/employee_repo.dart';
import 'package:optialeader/firebase_options.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';

class EmployeeDataCubit extends Cubit<EmployeeDataState> {
  final EmployeeRepo employeeRepo;
  StreamSubscription? _employeesSubscription;

  EmployeeDataCubit(this.employeeRepo) : super(EmployeeInitial());

  Future<void> getEmployeeProfile(String uid) async {
    emit(EmployeeLoading());
    final result = await employeeRepo.getEmployeeProfile(uid);
    result.fold((error) => emit(EmployeeError(error: error)), (employee) {
      if (employee != null) {
        emit(EmployeeLoaded(employee: employee));
      } else {
        emit(EmployeeError(error: "الموظف غير موجود"));
      }
    });
  }

  Future<(bool isEligible, List<CriterionStatus> unmetCriteria)>
  checkEmployeeEligibility({required String targetRole, String? uid}) async {
    final currentUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return (false, <CriterionStatus>[]);
    }

    final result = await employeeRepo.getEmployeeProfile(currentUid);

    return result.fold((error) => (false, <CriterionStatus>[]), (employee) {
      if (employee == null) {
        return (false, <CriterionStatus>[]);
      }

      final criteria = <CriterionStatus>[
        CriterionStatus(
          titleAr: "خبرة موثقة في مجال العمل الإداري بالجامعات",
          titleEn: "Documented university administrative experience",
          isMet: employee.hasAdminExperience ?? false,
          isAutoChecked: false,
          details: "يتطلب مراجعة السيرة الذاتية",
        ),
        CriterionStatus(
          titleAr: "إجادة التعامل مع برمجيات الحاسب ونظم التحول الرقمي",
          titleEn: "Proficiency in computer software & digital transformation",
          isMet: employee.hasICDL ?? false,
          isAutoChecked: true,
        ),
        CriterionStatus(
          titleAr: "الحصول على مؤهل جامعي عالٍ مناسب",
          titleEn: "Appropriate higher university degree",
          isMet: true,
          isAutoChecked: true,
          details: "مستوفي",
        ),
        CriterionStatus(
          titleAr: "تقدير (امتياز) في تقارير الأداء السنوية عن آخر 4 سنوات",
          titleEn:
              "Excellent rating in annual performance reports (last 4 years)",
          isMet: employee.hasExcellentPerformanceReports,
          isAutoChecked: true,
        ),
        CriterionStatus(
          titleAr: "خلو السجل الوظيفي من الجزاءات التأديبية",
          titleEn: "Clean disciplinary record",
          isMet: employee.disciplinaryClearance,
          isAutoChecked: true,
        ),
        CriterionStatus(
          titleAr: "مشاركة إيجابية في تطوير منظومة العمل الإداري (آخر 3 سنوات)",
          titleEn:
              "Positive participation in developing admin systems (last 3 years)",
          isMet: true,
          isAutoChecked: false,
          details: "يتطلب تقديم أوراق ثبوتية للأدمن",
        ),
        CriterionStatus(
          titleAr:
              "دورات تدريبية: (إدارة حديثة، إدارة وقت وأزمات، إدارة موارد بشرية ومالية)",
          titleEn:
              "Training: (Modern mgmt, Time/Crisis mgmt, HR/Financial mgmt)",
          isMet: employee.hasAdminTraining ?? false,
          isAutoChecked: true,
          details: (employee.hasAdminTraining ?? false)
              ? "✅ يوجد دورات مطابقة"
              : "⚠️ لم يتم العثور على دورات مطابقة",
        ),
      ];

      final unmetCriteria = criteria.where((c) => !c.isMet).toList();
      return (unmetCriteria.isEmpty, unmetCriteria);
    });
  }

  Future<void> saveEmployeeData(EmployeeModel employee) async {
    emit(EmployeeLoading());
    final result = await employeeRepo.saveEmployeeData(employee);
    result.fold(
      (error) => emit(EmployeeError(error: error)),
      (_) => emit(EmployeeSuccess()),
    );
  }

  Future<void> updateEmployeeProfile(
    String uid,
    Map<String, dynamic> updatedFields,
  ) async {
    final result = await employeeRepo.updateEmployeeProfileData(
      uid,
      updatedFields,
    );
    result.fold((error) => emit(EmployeeError(error: error)), (_) {
      getEmployeeProfile(uid);
    });
  }

  Future<void> uploadAndSetProfileImage(String uid, File imageFile) async {
    emit(EmployeeLoading());

    try {
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            imageFile.absolute.path,
            minWidth: 1024,
            minHeight: 1024,
            quality: 85,
          );

      if (compressedBytes == null) {
        emit(EmployeeError(error: "فشل ضغط الصورة"));
        return;
      }

      final String fileExtension = p.extension(imageFile.path);
      final String storagePath = 'profiles/$uid/profile$fileExtension';

      final uploadResult = await employeeRepo.uploadFile(
        compressedBytes,
        storagePath,
        bucketName: 'images',
      );

      uploadResult.fold((error) => emit(EmployeeError(error: error)), (
        imageUrl,
      ) async {
        final updateResult = await employeeRepo.updateEmployeeImage(
          uid,
          imageUrl,
        );
        updateResult.fold((error) => emit(EmployeeError(error: error)), (_) {
          getEmployeeProfile(uid);
        });
      });
    } catch (e) {
      emit(EmployeeError(error: e.toString()));
    }
  }

  Future<void> updateAccountStatus(String uid, bool isActive) async {
    emit(EmployeeLoading());
    final result = await employeeRepo.updateAccountStatus(uid, isActive);
    result.fold(
      (error) => emit(EmployeeError(error: error)),
      (_) => emit(EmployeeSuccess()),
    );
  }

  void watchAllEmployees() {
    emit(EmployeeLoading());
    _employeesSubscription?.cancel();
    _employeesSubscription = employeeRepo.watchAllEmployees().listen(
      (employeesList) {
        emit(AllEmployeesLoaded(employees: employeesList));
      },
      onError: (error) {
        emit(EmployeeError(error: error.toString()));
      },
    );
  }

  // ✅ تم تعديل الدالة عشان تقبل الصورة
  Future<void> createNewEmployee(
    EmployeeModel employee, {
    File? profileImageFile,
  }) async {
    emit(EmployeeLoading());
    UserCredential? credential;

    try {
      FirebaseApp secondaryApp;
      final isSecondaryAppInitialized = Firebase.apps.any(
        (app) => app.name == 'SecondaryApp',
      );

      if (isSecondaryAppInitialized) {
        secondaryApp = Firebase.app('SecondaryApp');
      } else {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: employee.email.trim(),
        password: employee.nationalId.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(EmployeeError(error: "ERROR_USER_CREATION_FAILED"));
        return;
      }

      final String newUid = firebaseUser.uid;
      final updatedEmployee = employee.copyWith(uid: newUid);
      final result = await employeeRepo.saveEmployeeData(updatedEmployee);

      result.fold(
        (error) async {
          try {
            await firebaseUser.delete();
          } catch (_) {}
          emit(EmployeeError(error: error));
        },
        (_) async {
          // ✅ لو في صورة، ارفعها، وبعدين اطلع نجاح
          if (profileImageFile != null) {
            await uploadAndSetProfileImage(newUid, profileImageFile);
          } else {
            emit(EmployeeSuccess());
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorCode = "ERROR_AUTH_UNKNOWN";
      if (e.code == 'email-already-in-use') {
        errorCode = "ERROR_EMAIL_ALREADY_IN_USE";
      } else if (e.code == 'weak-password') {
        errorCode = "ERROR_WEAK_PASSWORD";
      } else if (e.code == 'invalid-email') {
        errorCode = "ERROR_INVALID_EMAIL";
      }
      emit(EmployeeError(error: errorCode));
    } catch (e) {
      try {
        await credential?.user?.delete();
      } catch (_) {}
      emit(EmployeeError(error: e.toString()));
    } finally {
      try {
        final secondaryApp = Firebase.app('SecondaryApp');
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        await secondaryAuth.signOut();
      } catch (_) {}
    }
  }

  Future<void> deleteEmployee(String uid) async {
    emit(EmployeeDeleting());
    final result = await employeeRepo.deleteEmployeeAccount(uid);
    result.fold(
      (error) => emit(EmployeeError(error: error)),
      (_) => emit(EmployeeSuccess()),
    );
  }

  @override
  Future<void> close() {
    _employeesSubscription?.cancel();
    return super.close();
  }
}
