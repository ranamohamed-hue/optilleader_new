import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model%20.dart';
import 'package:optialeader/feature/employee/data/repo/NominationRequestRepository/employee_nomination_repo.dart';

class EmployeeNominationRepositoryImpl
    implements EmployeeNominationRepository {
  final FirebaseFirestore _firestore;

  EmployeeNominationRepositoryImpl(this._firestore);

  // ============================================================
  // Submit Request
  // ============================================================

  @override
  Future<Either<String, String>> submitRequest(
    EmployeeNominationRequestModel request,
  ) async {
    try {
      final docRef = await _firestore
          .collection('nomination_requests')
          .add(request.toMap());

      return Right(docRef.id);
    } catch (e) {
      print('🔴 EMPLOYEE NOMINATION SUBMIT ERROR: $e');
      return Left(e.toString());
    }
  }

  // ============================================================
  // Admin Requests
  // ============================================================

  @override
  Stream<List<EmployeeNominationRequestModel>> getAdminRequests({
    required String status,
  }) {
    return _firestore
        .collection('nomination_requests')
        .where('applicantType', isEqualTo: 'employee')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map((doc) {
                  try {
                    return EmployeeNominationRequestModel.fromMap(
                      doc.data(),
                      doc.id,
                    );
                  } catch (e) {
                    print(
                      '⚠️ خطأ في قراءة طلب موظف: '
                      '${doc.id} - $e',
                    );
                    return null;
                  }
                })
                .whereType<EmployeeNominationRequestModel>()
                .toList();
          },
        );
  }

  // ============================================================
  // Evaluator Requests
  // ============================================================

  @override
  Stream<List<EmployeeNominationRequestModel>> getEvaluatorRequests(
    String evaluatorId,
  ) {
    return _firestore
        .collection('nomination_requests')
        .where('applicantType', isEqualTo: 'employee')
        .where('evaluatorId', isEqualTo: evaluatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map((doc) {
                  try {
                    return EmployeeNominationRequestModel.fromMap(
                      doc.data(),
                      doc.id,
                    );
                  } catch (e) {
                    print(
                      '⚠️ خطأ في قراءة طلب موظف للمحكم: '
                      '${doc.id} - $e',
                    );
                    return null;
                  }
                })
                .whereType<EmployeeNominationRequestModel>()
                .toList();
          },
        );
  }

  // ============================================================
  // Update Request
  // ============================================================

  @override
  Future<Either<String, Unit>> updateRequest(
    EmployeeNominationRequestModel request,
  ) async {
    try {
      if (request.id == null || request.id!.isEmpty) {
        return const Left('invalid_request_id');
      }

      await _firestore
          .collection('nomination_requests')
          .doc(request.id)
          .update(request.toMap());

      return const Right(unit);
    } catch (e) {
      print('🔴 EMPLOYEE NOMINATION UPDATE ERROR: $e');
      return Left(e.toString());
    }
  }

  // ============================================================
  // Get Evaluators
  // ============================================================

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getEvaluators() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final evaluators = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final role =
            data['role']?.toString().toLowerCase() ?? '';

        if (role == 'evaluator' ||
            role == 'judge' ||
            role == 'محكم') {
          final profile =
              data['profile'] as Map<String, dynamic>?;

          final displayName =
              profile?['display_name']
                  as Map<String, dynamic>?;

          final nameAr =
              displayName?['ar'] ?? 'بدون اسم';

          evaluators.add({
            ...data,
            'id': doc.id,
            'nameAr': nameAr,
          });
        }
      }

      return Right(evaluators);
    } catch (e) {
      print('🔴 GET EMPLOYEE EVALUATORS ERROR: $e');
      return Left(e.toString());
    }
  }
}