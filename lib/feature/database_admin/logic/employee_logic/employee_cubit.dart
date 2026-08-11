import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart'; 

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

      // ═══════════════════════════════════════════════════════
      // ✅ القائمة الكاملة للشروط (12 شرط)
      // ═══════════════════════════════════════════════════════
      final criteria = <CriterionStatus>[

        // ── 1. خبرة إدارية موثقة ──
        CriterionStatus(
          titleAr: "خبرة موثقة في مجال العمل الإداري بالجامعات",
          titleEn: "Documented university administrative experience",
          isMet: employee.hasAdminExperience ?? false,
          isAutoChecked: false,
          needsDocument: true,
          documentType: 'admin_experience',
          uploadedDocs: employee.adminExperienceDocUrls,
          details: "يرفق: السيرة الذاتية + خطابات الخبرة",
        ),

        // ── 2. ICDL ──
        CriterionStatus(
          titleAr: "إجادة التعامل مع برمجيات الحاسب ونظم التحول الرقمي (ICDL)",
          titleEn: "Proficiency in computer software & digital transformation (ICDL)",
          isMet: employee.hasICDL ?? false,
          isAutoChecked: true,
          needsDocument: true,
          documentType: 'icdl',
          uploadedDocs: employee.icdlCertificateUrl != null
              ? [employee.icdlCertificateUrl!]
              : [],
          details: "يرفق: صورة شهادة ICDL",
        ),

        // ── 3. مؤهل جامعي عالٍ ──
        CriterionStatus(
          titleAr: "الحصول على مؤهل جامعي عالٍ مناسب",
          titleEn: "Appropriate higher university degree",
          isMet: employee.degree.isNotEmpty,
          isAutoChecked: true,
          needsDocument: false,
          details: employee.degree.isNotEmpty
              ? "المؤهل: ${employee.degree} - ${employee.graduationYear}"
              : "⚠️ غير محدد",
        ),

        // ── 4. تقارير أداء ممتاز ──
        CriterionStatus(
          titleAr: "تقدير (امتياز) في تقارير الأداء السنوية عن آخر 4 سنوات",
          titleEn: "Excellent rating in annual performance reports (last 4 years)",
          isMet: employee.hasExcellentPerformanceReports,
          isAutoChecked: true,
          needsDocument: true,
          documentType: 'performance_reports',
          uploadedDocs: employee.performanceReportUrls,
          details: "يرفق: صور تقارير الأداء",
        ),

        // ── 5. خلو السجل من الجزاءات ──
        CriterionStatus(
          titleAr: "خلو السجل الوظيفي من الجزاءات التأديبية",
          titleEn: "Clean disciplinary record",
          isMet: employee.disciplinaryClearance,
          isAutoChecked: true,
          needsDocument: false,
          details: employee.disciplinaryClearance ? "✅ مستوفي" : "❌ يوجد جزاءات",
        ),

        // ── 6. مشاركة في تطوير العمل الإداري ──
        CriterionStatus(
          titleAr: "مشاركة إيجابية في تطوير منظومة العمل الإداري (آخر 3 سنوات)",
          titleEn: "Positive participation in developing admin systems (last 3 years)",
          isMet: employee.hasParticipationProof ?? false,
          isAutoChecked: false,
          needsDocument: true,
          documentType: 'participation',
          uploadedDocs: employee.participationDocUrls,
          details: "يرفق: شهادات المشاركة أو خطابات تكليف",
        ),

        // ── 7. دورات تدريبية إدارية ──
        CriterionStatus(
          titleAr: "دورات تدريبية: (إدارة حديثة، إدارة وقت وأزمات، إدارة موارد بشرية ومالية)",
          titleEn: "Training: (Modern mgmt, Time/Crisis mgmt, HR/Financial mgmt)",
          isMet: employee.hasAdminTraining ?? false,
          isAutoChecked: true,
          needsDocument: true,
          documentType: 'admin_training',
          uploadedDocs: employee.adminTrainingCertUrls,
          details: (employee.hasAdminTraining ?? false)
              ? "✅ يوجد ${employee.adminTrainingCertUrls.length} شهادة"
              : "⚠️ لم يتم العثور على دورات مطابقة",
        ),

        // ── 8. عدم وجود سجل جنائي ──
        CriterionStatus(
          titleAr: "عدم الإدانة في جرائم مخلة بالشرف والأمانة",
          titleEn: "No criminal record for dishonorable offenses",
          isMet: !(employee.hasCriminalRecord),
          isAutoChecked: true,
          needsDocument: false,
          details: !employee.hasCriminalRecord ? "✅ مستوفي" : "❌ يوجد سجل جنائي",
        ),

        // ── 9. عدم شغل مناصب حزبية ──
        CriterionStatus(
          titleAr: "عدم شغل مناصب حزبية خلال آخر 5 سنوات",
          titleEn: "No political party positions in the last 5 years",
          isMet: !(employee.holdsPartyPosition),
          isAutoChecked: true,
          needsDocument: false,
          details: !employee.holdsPartyPosition ? "✅ مستوفي" : "❌ يوجد منصب حزبي",
        ),

        // ── 10. عدم وجود إجازة ──
        CriterionStatus(
          titleAr: "عدم وجود إجازة حالية تمنع الترشيح",
          titleEn: "Not currently on leave that prevents nomination",
          isMet: !(employee.isOnVacation),
          isAutoChecked: true,
          needsDocument: false,
          details: !employee.isOnVacation ? "✅ مستوفي" : "❌ الموظف في إجازة",
        ),

        // ── 11. الشهادة الصحية ──
        CriterionStatus(
          titleAr: "اجتياز الكشف الطبي وتقديم شهادة صحية",
          titleEn: "Passing medical examination & health certificate",
          isMet: employee.hasHealthCertificate ?? false,
          isAutoChecked: true,
          needsDocument: true,
          documentType: 'health',
          uploadedDocs: employee.healthCertificateUrl != null
              ? [employee.healthCertificateUrl!]
              : [],
          details: "يرفق: صورة الشهادة الصحية",
        ),

        // ── 12. سنوات الخبرة الإدارية ──
        CriterionStatus(
          titleAr: "الحد الأدنى من سنوات الخبرة الإدارية (5 سنوات)",
          titleEn: "Minimum administrative experience (5 years)",
          isMet: employee.yearsOfAdminExperience >= 5,
          isAutoChecked: true,
          needsDocument: false,
          details: "السنوات الحالية: ${employee.yearsOfAdminExperience}",
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
    // ═══════════════════════════════════════════════════════
  // ✅ رفع مستند ثبوتي (شهادة / صورة)
  // ═══════════════════════════════════════════════════════
  Future<Either<String, String>> uploadProofDocument({
    required File file,
    required String uid,
    required String docType,
  }) async {
    try {
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            file.absolute.path,
            minWidth: 1200,
            minHeight: 1200,
            quality: 80,
          );

      if (compressedBytes == null) {
        return left("فشل ضغط الملف");
      }

      final String fileExtension = p.extension(file.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String storagePath =
          'proofs/$uid/$docType/${timestamp}$fileExtension';

      return await employeeRepo.uploadFile(
        compressedBytes,
        storagePath,
        bucketName: 'images',
      );
    } catch (e) {
      return left("فشل رفع المستند: ${e.toString()}");
    }
  }
    // ═══════════════════════════════════════════════════════
  // ✅ دالة رفع ملفات الأرشيف (صور + PDF) للموظفين
  // ═══════════════════════════════════════════════════════
  Future<void> uploadArchiveFile({
    required String uid,
    required File file,
    required String title,
    required String description,
    required String category,
  }) async {
    emit(EmployeeLoading());
    try {
      String storagePath;
      Uint8List fileBytes;

      // التحقق مما إذا كان الملف صورة أم PDF
      final ext = p.extension(file.path).toLowerCase();
      final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext);
      
      if (isImage) {
        // ضغط الصورة لتقليل حجمها
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: 1200,
          minHeight: 1200,
          quality: 80,
        );
        if (compressedBytes == null) {
          emit(EmployeeError(error: "فشل ضغط الصورة"));
          return;
        }
        fileBytes = compressedBytes;
        storagePath = 'archives/$uid/images/${DateTime.now().millisecondsSinceEpoch}$ext';
      } else {
        // قراءة ملف PDF كـ بايتات بدون ضغط
        fileBytes = await file.readAsBytes();
        storagePath = 'archives/$uid/pdfs/${DateTime.now().millisecondsSinceEpoch}$ext';
      }

      // رفع الملف للـ Firebase Storage
      final uploadResult = await employeeRepo.uploadFile(
        fileBytes,
        storagePath,
        bucketName: 'images', // تأكد أن هذا هو اسم الباكت الخاص بك
      );

           uploadResult.fold(
        (error) => emit(EmployeeError(error: error)),
        (fileUrl) async {
          
          // 1. جلب بيانات الموظف الحالية من Firestore
          final empResult = await employeeRepo.getEmployeeProfile(uid);
          empResult.fold(
            (error) => emit(EmployeeError(error: error)),
            (employee) async {
              if (employee == null) {
                emit(EmployeeError(error: "الموظف غير موجود"));
                return;
              }

              // ملف الأرشيف الجديد (رابط السوبابيز + البيانات)
              final newArchiveEntry = {
                'url': fileUrl,
                'title': title,
                'description': description,
                'category': category,
                'uploadedAt': DateTime.now().toIso8601String(),
              };

              // 2. تجهيز القائمة القديمة (تأكد أن هذا الحقل موجود في EmployeeModel)
              // إذا لم يكن موجوداً في الموديل، اجعلها قائمة فارغة []
              List<dynamic> currentFiles = employee.archiveFiles ?? [];

              // 3. إضافة الملف الجديد
              currentFiles.add(newArchiveEntry);

              // 4. تحديث قاعدة البيانات بالقائمة الكاملة
              final updateResult = await employeeRepo.updateEmployeeProfileData(
                uid, 
                {'archiveFiles': currentFiles}, // حفظ القائمة المحدثة
              );

              updateResult.fold(
                (error) => emit(EmployeeError(error: error)),
                (_) => getEmployeeProfile(uid), // تحديث الواجهة
              );
            },
          );
        },
      );
   
   
   
   
    } catch (e) {
      emit(EmployeeError(error: "فشل رفع الملف: ${e.toString()}"));
    }
  }
}
