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

  // ✅ بدء الاستماع للدورات
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

  // ✅ إضافة دورة (نرسل المفتاح من غير ترجمة)
  Future<void> addCourse({
    required EmployeeCourseModel course,
    required File certificateFile,
  }) async {
    if (_currentUid == null) return;

    emit(EmployeeCoursesUploading());
    try {
      await _repo.addCourse(
        uid: _currentUid!,
        course: course,
        certificateFile: certificateFile,
      );
      // نرسل المفتاح زي ما هو، والـ UI هيتولى الترجمة
      emit( EmployeeCoursesActionSuccess('employee_courses.success_added'));
    } catch (e) {
      emit( EmployeeCoursesError('employee_courses.error_upload'));
    }
  }

  // ✅ حذف دورة
  Future<void> deleteCourse(EmployeeCourseModel course) async {
    if (_currentUid == null) return;

    try {
      await _repo.deleteCourse(uid: _currentUid!, course: course);
    } catch (e) {
      emit( EmployeeCoursesError('employee_courses.error_delete'));
    }
  }

  @override
  Future<void> close() {
    _coursesSubscription?.cancel();
    return super.close();
  }
}