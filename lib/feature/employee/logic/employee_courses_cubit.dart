import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:optialeader/feature/employee/data/repo/employee_courses_repo.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_state.dart';

class EmployeeCoursesCubit
    extends Cubit<EmployeeCoursesState> {
  final EmployeeCoursesRepo _repo;

  String? _currentUid;

  StreamSubscription? _coursesSubscription;

  EmployeeCoursesCubit({
    EmployeeCoursesRepo? repo,
  })  : _repo = repo ?? EmployeeCoursesRepo(),
        super(EmployeeCoursesInitial());

  // ============================================================
  // Load Courses
  // ============================================================

  void loadCourses(String uid) {
    _currentUid = uid;

    emit(EmployeeCoursesLoading());

    // إلغاء الـ Stream القديم
    _coursesSubscription?.cancel();

    _coursesSubscription =
        _repo.getCoursesStream(uid).listen(
      (snapshot) {
        try {
          final courses = snapshot.docs
              .map(
                (doc) => EmployeeCourseModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList();

          emit(
            EmployeeCoursesLoaded(courses),
          );
        } catch (e) {
          emit(
            EmployeeCoursesError(
              'حدث خطأ أثناء قراءة الدورات: ${e.toString()}',
            ),
          );
        }
      },
      onError: (error) {
        emit(
          EmployeeCoursesError(
            error.toString(),
          ),
        );
      },
    );
  }

  // ============================================================
  // Add Course
  // ============================================================

  Future<void> addCourse({
    required String uid,
    required EmployeeCourseModel course,
    required File certificateFile,
  }) async {
    try {
      emit(EmployeeCoursesUploading());

      final result = await _repo.addCourse(
        uid: uid,
        course: course,
        certificateFile: certificateFile,
      );

      result.fold(
        (error) {
          emit(
            EmployeeCoursesError(error),
          );
        },
        (_) {
          emit(
            const EmployeeCoursesActionSuccess(
              'employee_courses.success_added',
            ),
          );

          // الـ Stream هيرجع يعمل Loaded تلقائيًا
        },
      );
    } catch (e) {
      emit(
        EmployeeCoursesError(
          'فشل إضافة الدورة: ${e.toString()}',
        ),
      );
    }
  }

  // ============================================================
  // Delete Course
  // ============================================================

  Future<void> deleteCourse(
    EmployeeCourseModel course,
  ) async {
    if (_currentUid == null) {
      emit(
        const EmployeeCoursesError(
          'لم يتم تحديد الموظف',
        ),
      );

      return;
    }

    try {
      final result =
          await _repo.deleteCourse(
        uid: _currentUid!,
        course: course,
      );

      result.fold(
        (error) {
          emit(
            EmployeeCoursesError(error),
          );
        },
        (_) {
          // لا نحتاج Emit هنا
          // لأن Firestore Stream سيحدث تلقائيًا
        },
      );
    } catch (e) {
      emit(
        EmployeeCoursesError(
          'فشل حذف الدورة: ${e.toString()}',
        ),
      );
    }
  }

  // ============================================================
  // Close
  // ============================================================

  @override
  Future<void> close() async {
    await _coursesSubscription?.cancel();

    return super.close();
  }
}