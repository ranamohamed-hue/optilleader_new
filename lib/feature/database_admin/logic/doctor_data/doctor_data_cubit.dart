import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/data/repo/doctor_repository/doctor_repo.dart';
import 'package:optialeader/feature/database_admin/logic/doctor_data/doctor_data_state.dart';
import 'package:optialeader/firebase_options.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';

class DoctorDataCubit extends Cubit<DoctorDataState> {
  final DoctorRepo doctorRepo;
  StreamSubscription? _doctorsSubscription;

  DoctorDataCubit(this.doctorRepo) : super(DoctorInitial());

  Future<void> getDoctorProfile(String uid) async {
    emit(DoctorLoading());
    final result = await doctorRepo.getDoctorProfile(uid);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (doctor) => emit(DoctorLoaded(doctor: doctor)),
    );
  }

  Future<(bool isEligible, List<CriterionStatus> unmetCriteria)>
  checkEligibility({
    required String targetRole,
    String? uid,
    String? sector,
  }) async {
    final currentUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return (false, <CriterionStatus>[]);

    final result = await doctorRepo.getDoctorProfile(currentUid);
    DoctorProfileModel? doctor;
    result.fold((error) => null, (d) => doctor = d);

    if (doctor == null) return (false, <CriterionStatus>[]);

    List<DoctorProfileModel> departmentDoctors = [];
    if (targetRole == 'head_department') {
      try {
        departmentDoctors = await doctorRepo.watchAllDoctors().first;
      } catch (_) {}
    }

    final criteria = LeadershipCriteriaEngine.checkMandatoryCriteria(
      doctor: doctor!,
      targetRole: targetRole,
      sector: sector,
      departmentDoctors: departmentDoctors,
    );

    final unmetCriteria = criteria.where((c) => !c.isMet).toList();
    return (unmetCriteria.isEmpty, unmetCriteria);
  }

  Future<Either<String, void>> saveDoctorData(DoctorProfileModel doctor) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(doctor.uid)
          .set(doctor.toMap(), SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> updateDoctorProfile(
    String uid,
    Map<String, dynamic> updatedFields,
  ) async {
    final result = await doctorRepo.updateDoctorProfileData(uid, updatedFields);
    result.fold((error) => emit(DoctorError(error: error)), (_) {
      getDoctorProfile(uid);
    });
  }

  Future<void> uploadAndSetProfileImage(String uid, File imageFile) async {
    emit(DoctorLoading());
    try {
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
            imageFile.absolute.path,
            minWidth: 1024,
            minHeight: 1024,
            quality: 85,
          );
      if (compressedBytes == null) {
        emit(DoctorError(error: "فشل ضغط الصورة"));
        return;
      }
      final String fileExtension = p.extension(imageFile.path);
      final String storagePath = 'profiles/$uid/profile$fileExtension';

      final uploadResult = await doctorRepo.uploadFile(
        compressedBytes,
        storagePath,
        bucketName: 'images',
      );
      uploadResult.fold((error) => emit(DoctorError(error: error)), (
        imageUrl,
      ) async {
        final updateResult = await doctorRepo.updateDoctorImage(uid, imageUrl);
        updateResult.fold((error) => emit(DoctorError(error: error)), (_) {
          getDoctorProfile(uid);
        });
      });
    } catch (e) {
      emit(DoctorError(error: e.toString()));
    }
  }

  Future<void> uploadArchiveFile({
    required String uid,
    required File file,
    required String title,
    required String description,
    required String category,
  }) async {
    emit(DoctorLoading());
    try {
      final fileBytes = await file.readAsBytes();
      final String fileExtension = p.extension(file.path);
      final String storagePath =
          'archives/$uid/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      final uploadResult = await doctorRepo.uploadFile(
        fileBytes,
        storagePath,
        bucketName: 'files',
      );
      await uploadResult.fold(
        (error) async {
          emit(DoctorError(error: error));
        },
        (fileUrl) async {
          final newFileData = {
            'title': title,
            'description': description,
            'category': category,
            'file_url': fileUrl,
            'uploaded_at': DateTime.now().toIso8601String(),
          };
          final updateResult = await doctorRepo.updateDoctorProfileData(uid, {
            'digital_archive': FieldValue.arrayUnion([newFileData]),
          });
          updateResult.fold(
            (error) => emit(DoctorError(error: error)),
            (_) => getDoctorProfile(uid),
          );
        },
      );
    } catch (e) {
      emit(DoctorError(error: e.toString()));
    }
  }

  Future<void> updateAccountStatus(String uid, bool isActive) async {
    emit(DoctorLoading());
    final result = await doctorRepo.updateAccountStatus(uid, isActive);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  void watchAllDoctors() {
    emit(DoctorLoading());
    _doctorsSubscription?.cancel();
    _doctorsSubscription = doctorRepo.watchAllDoctors().listen(
      (doctorsList) {
        emit(AllDoctorLoaded(doctors: doctorsList));
      },
      onError: (error) {
        emit(DoctorError(error: error.toString()));
      },
    );
  }

  // ✅✅✅ الدالة المعدلة لقبول الصورة ورفعها ✅✅✅
  Future<void> createNewDoctor(
    DoctorProfileModel doctor, {
    File? profileImageFile,
  }) async {
    emit(DoctorLoading());
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
        email: doctor.email.trim(),
        password: doctor.nationalId.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(DoctorError(error: "ERROR_USER_CREATION_FAILED"));
        return;
      }

      final String newUid = firebaseUser.uid;
      final updatedDoctor = doctor.copyWith(uid: newUid);
      final result = await doctorRepo.saveDoctorData(updatedDoctor);

      result.fold(
        (error) async {
          try {
            await firebaseUser.delete();
          } catch (_) {}
          emit(DoctorError(error: error));
        },
        (_) async {
          // ✅ رفع الصورة لو موجودة
          if (profileImageFile != null) {
            try {
              final Uint8List? compressedBytes =
                  await FlutterImageCompress.compressWithFile(
                    profileImageFile.absolute.path,
                    minWidth: 1024,
                    minHeight: 1024,
                    quality: 85,
                  );
              if (compressedBytes != null) {
                final String fileExtension = p.extension(profileImageFile.path);
                final String storagePath =
                    'profiles/$newUid/profile$fileExtension';
                final uploadResult = await doctorRepo.uploadFile(
                  compressedBytes,
                  storagePath,
                  bucketName: 'images',
                );
                uploadResult.fold((error) => print("فشل رفع الصورة: $error"), (
                  imageUrl,
                ) async {
                  await doctorRepo.updateDoctorImage(newUid, imageUrl);
                });
              }
            } catch (e) {
              print("خطأ في ضغط الصورة: $e");
            }
          }
          emit(DoctorSuccess());
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
      emit(DoctorError(error: errorCode));
    } catch (e) {
      try {
        await credential?.user?.delete();
      } catch (_) {}
      emit(DoctorError(error: e.toString()));
    } finally {
      try {
        final secondaryApp = Firebase.app('SecondaryApp');
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        await secondaryAuth.signOut();
      } catch (_) {}
    }
  }

  Future<void> deleteDoctor(String uid) async {
    emit(DoctorDeleting());
    final result = await doctorRepo.deleteDoctorAccount(uid);
    result.fold(
      (error) => emit(DoctorError(error: error)),
      (_) => emit(DoctorSuccess()),
    );
  }

  Future<List<DoctorProfileModel>> getAllDoctorsOnce() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      return snapshot.docs
          .map((doc) => DoctorProfileModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> close() {
    _doctorsSubscription?.cancel();
    return super.close();
  }
}
