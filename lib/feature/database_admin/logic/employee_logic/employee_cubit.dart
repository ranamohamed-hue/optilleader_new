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

class EmployeeDataCubit extends Cubit<EmployeeDataState> {
  final EmployeeRepo employeeRepo;
  StreamSubscription? _employeesSubscription;

  EmployeeDataCubit(this.employeeRepo) : super(EmployeeInitial());

  Future<void> getEmployeeProfile(String uid) async {
    emit(EmployeeLoading());
    final result = await employeeRepo.getEmployeeProfile(uid);
    result.fold(
      (error) => emit(EmployeeError(error: error)),
      (employee) {
        if (employee != null) {
           emit(EmployeeLoaded(employee: employee));
        } else {
          emit(EmployeeError(error: "الموظف غير موجود"));
        }
      },
    );
  }

  // ✅ التحقق من الأهلية (للموظف الإداري)
  Future<(bool isEligible, List<dynamic> unmetCriteria)> checkEmployeeEligibility({
    required String targetRole,
    String? uid,
  }) async {
    final currentUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      return (false, []);
    }

    final result = await employeeRepo.getEmployeeProfile(currentUid);

    return result.fold(
      (error) => (false, []),
      (employee) {
        if (employee == null) {
          return (false, []);
        }

        // تحقق من الشروط الإدارية
        final unmetCriteria = <Map<String, dynamic>>[];
        
        if (employee.yearsOfAdminExperience < 10) {
          unmetCriteria.add({'titleAr': 'خبرة إدارية أقل من 10 سنوات'});
        }
        if (!employee.hasExcellentPerformanceReports) {
          unmetCriteria.add({'titleAr': 'لا يوجد تقدير امتياز في آخر 4 تقارير'});
        }
        if (!employee.disciplinaryClearance) {
          unmetCriteria.add({'titleAr': 'يوجد جزاءات تأديبية'});
        }
        if (employee.hasCriminalRecord) {
          unmetCriteria.add({'titleAr': 'يوجد سجل جنائي'});
        }
        if (employee.holdsPartyPosition) {
          unmetCriteria.add({'titleAr': 'يتولى منصب حزبي'});
        }
        if (employee.hasICDL != true) {
          unmetCriteria.add({'titleAr': 'لا يوجد ICDL'});
        }

        return (unmetCriteria.isEmpty, unmetCriteria);
      },
    );
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
    final result = await employeeRepo.updateEmployeeProfileData(uid, updatedFields);
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
        final updateResult = await employeeRepo.updateEmployeeImage(uid, imageUrl);
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

  Future<void> createNewEmployee(EmployeeModel employee) async {
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

      result.fold((error) async {
        try {
          await firebaseUser.delete();
        } catch (_) {}
        emit(EmployeeError(error: error));
      }, (_) => emit(EmployeeSuccess()));
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