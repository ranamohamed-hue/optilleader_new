import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';

abstract class NominationRequestRepository {
  // إنشاء طلب جديد (من الدكتور)
  Future<Either<String, String>> submitRequest(NominationRequestModel request);

  // جلب الطلبات للإدارة (فلترة حسب الحالة)
  Stream<List<NominationRequestModel>> getAdminRequests({
    required String status,
  });

  // جلب الطلبات للمحكم
  Stream<List<NominationRequestModel>> getEvaluatorRequests(String evaluatorId);

  // تحديث الطلب (تغيير الحالة، إضافة ملاحظات، تحديد موعد...)
  Future<Either<String, Unit>> updateRequest(NominationRequestModel request);

  // رفع إقرارات الدكتور (صور/PDF)
  Future<Either<String, String>> uploadDeclarationFile(String filePath);

  // ✅ جلب قائمة المحكمين المتاحين
  Future<Either<String, List<Map<String, dynamic>>>> getEvaluators();
}