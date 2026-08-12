import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model%20.dart';

abstract class EmployeeNominationRepository {
  // إرسال طلب ترشح الموظف
  Future<Either<String, String>> submitRequest(
    EmployeeNominationRequestModel request,
  );

  // طلبات الموظفين عند الأدمن
  Stream<List<EmployeeNominationRequestModel>> getAdminRequests({
    required String status,
  });

  // طلبات الموظفين عند المحكم
  Stream<List<EmployeeNominationRequestModel>> getEvaluatorRequests(
    String evaluatorId,
  );

  // تحديث الطلب
  Future<Either<String, Unit>> updateRequest(
    EmployeeNominationRequestModel request,
  );

  // جلب المحكمين
  Future<Either<String, List<Map<String, dynamic>>>> getEvaluators();
}