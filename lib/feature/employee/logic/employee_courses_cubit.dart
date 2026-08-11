import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:optialeader/feature/employee/data/repo/employee_courses_repo.dart';
import 'package:optialeader/feature/employee/logic/employee_courses_state.dart';

class EmployeeCoursesCubit extends Cubit<EmployeeCoursesState> {
  final EmployeeCoursesRepo _repo;
  String? _currentUid;
  StreamSubscription? _coursesSubscription;

  EmployeeCoursesCubit({EmployeeCoursesRepo? repo})
      : _repo = repo ?? EmployeeCoursesRepo(),
        super(EmployeeCoursesInitial());

  void loadCourses(String uid) {
    _currentUid = uid;
    emit(EmployeeCoursesLoading());

    _coursesSubscription?.cancel();
    _coursesSubscription = _repo.getCoursesStream(uid).listen(
      (snapshot) {
        final courses = snapshot.docs
            .map((doc) => EmployeeCourseModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        emit(EmployeeCoursesLoaded(courses));
      },
      onError: (error) {
        emit(EmployeeCoursesError(error.toString()));
      },
    );
  }

  // ✅ أضف uid كمتطلب إجباري
  Future<void> addCourse({
    required String uid, 
    required EmployeeCourseModel course,
    required File certificateFile,
  }) async {
    // ✅ تم إزالة الجملة التي كانت توقف كل شيء بصمت
    
    emit(EmployeeCoursesUploading());

    final result = await _repo.addCourse(
      uid: uid, // ✅ استخدام الـ uid الممرر مباشرة
      course: course,
      certificateFile: certificateFile,
    );

    result.fold(
      (error) => emit(EmployeeCoursesError(error)),
      (_) => emit(EmployeeCoursesActionSuccess('employee_courses.success_added')),
    );
  }
  Future<void> deleteCourse(EmployeeCourseModel course) async {
    if (_currentUid == null) return;

    final result = await _repo.deleteCourse(
      uid: _currentUid!,
      course: course,
    );

    result.fold(
      (error) => emit(EmployeeCoursesError(error)),
      (_) {}, // نجاح بدون رسالة
    );
  }

  @override
  Future<void> close() {
    _coursesSubscription?.cancel();
    return super.close();
  }
}