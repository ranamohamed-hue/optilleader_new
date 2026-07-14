import 'package:optialeader/feature/admin/data/model/announcement_model.dart';

abstract class AnnouncementState {}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<AnnouncementModel> announcements;
  AnnouncementLoaded(this.announcements);
}

class AnnouncementError extends AnnouncementState {
  final String message;
  AnnouncementError(this.message);
}

class AnnouncementActionSuccess extends AnnouncementState {
  final String message;
  AnnouncementActionSuccess(this.message);
}
