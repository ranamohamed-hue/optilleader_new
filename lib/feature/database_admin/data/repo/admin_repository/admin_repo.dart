import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';

abstract class AdminRepo {
  //حفظ بيانات الادمن
  Future<Either<String, Unit>> saveAdminData(AdminProfileModel admin);
  //جلب بيانات ادمن معين
  Future<Either<String, AdminProfileModel>> getAdminProfile(String uid);
  //عرض جميع الادمنز
  Stream<List<AdminProfileModel>> watchAllAdmins();
  //تحديث حالة الحساب
  Future<Either<String, Unit>> updateAccountStatus(String uid, bool isActive);
//تحديث صورة الادمن
  Future<Either<String, Unit>> updateAdminImage(String uid, String imageUrl);
  //رفع صورة الادمن الي الفايربيز
    Future<Either<String, String>> uploadImageToSupabase(String uid, String filePath);
//حذف حساب الادمن
  Future<Either<String, Unit>> deleteAdminAccount(String uid);
  //الاحضائيات
    Future<Map<String, int>> getAdminDashboardCounts(); 

}

