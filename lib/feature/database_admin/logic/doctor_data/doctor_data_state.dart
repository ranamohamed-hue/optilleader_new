import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

abstract class DoctorDataState {}

class DoctorInitial extends DoctorDataState {}

class DoctorLoading extends DoctorDataState {}
class DoctorUploadingFile extends DoctorDataState {}
class DoctorSuccess extends DoctorDataState {}

//لعرض بيانات كل الدكاترة ر 
class AllDoctorLoaded extends DoctorDataState {
  final List< DoctorProfileModel>? doctors;
  AllDoctorLoaded({this.doctors});
}
//لعرض بيانات دكتور معين 
class DoctorLoaded extends DoctorDataState{
  final DoctorProfileModel? doctor;
  DoctorLoaded({this.doctor});
}


class DoctorError extends DoctorDataState {
  final String? error;
  DoctorError({this.error});
}
//لرفع البيانات والصور
class DoctorUploading extends DoctorDataState {}
class DoctorDeleting extends DoctorDataState{}
