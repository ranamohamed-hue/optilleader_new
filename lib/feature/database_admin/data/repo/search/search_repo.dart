import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/database_admin/data/models/search_user_model.dart';

class SearchRepo {
  final FirebaseFirestore _firestore;
  SearchRepo(this._firestore);

  Future<Either<String, List<SearchUserModel>>> searchUsers({
    required String query,
    required String searchField,
  }) async {
    try {
      // 1 جلب كل المستخدمين من الفايرستور مرة واحدة
      final snapshot = await _firestore.collection('users').get();

      // 2 تحويلهم لـ SearchUserModel
      final allUsers = snapshot.docs
          .map((doc) => SearchUserModel.fromFirestore(doc))
          .toList();

      // 3 لو الحقل فاضي، نرجع قائمة فاضية
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      //  [الحل السحري] تحويل كلمة البحث كلها لـ Small Letters
      final lowerQuery = query.toLowerCase();

      final List<SearchUserModel> filteredUsers;

      if (searchField == 'employee_id') {
        // البحث بالرقم الوظيفي
        filteredUsers = allUsers.where((user) {
          return user.employeeId.toLowerCase().contains(lowerQuery);
        }).toList();
      } else {
        // البحث بالاسم (عربي أو إنجليزي)
        filteredUsers = allUsers.where((user) {
          //  [الحل السحري] تحويل الأسماء الموجودة في الداتابيز لـ Small قبل المقارنة
          final nameArLower = user.nameAr.toLowerCase();
          final nameEnLower = user.nameEn.toLowerCase();

          // المقارنة دلوقتي هتتم بين Small و Small
          return nameArLower.contains(lowerQuery) ||
              nameEnLower.contains(lowerQuery);
        }).toList();
      }

      return Right(filteredUsers);
    } catch (e) {
      print(' خطأ في البحث المحلي: $e');
      return Left("حدث خطأ أثناء جلب البيانات");
    }
  }
}
