import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomination_request_repo.dart';

class NominationRequestRepositoryImpl
    implements NominationRequestRepository {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;

  NominationRequestRepositoryImpl(this._firestore, this._supabase);

  @override
  Future<Either<String, String>> uploadDeclarationFile(
      String filePath) async {
    try {
      final File file = File(filePath);
      final String extension = filePath.split('.').last;
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final String storagePath = 'declarations/$fileName';

      await _supabase.storage.from('files').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      final String publicUrl =
          _supabase.storage.from('files').getPublicUrl(storagePath);

      return Right(publicUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> submitRequest(
    NominationRequestModel request,
  ) async {
    try {
      final docRef = await _firestore
          .collection('nomination_requests')
          .add(request.toMap());
      return Right(docRef.id);
    } catch (e) {
      print("🔴 FIRESTORE SUBMIT ERROR: $e");
      return Left(e.toString());
    }
  }

  @override
  Stream<List<NominationRequestModel>> getAdminRequests({
    required String status,
  }) {
    return _firestore
        .collection('nomination_requests')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              try {
                return NominationRequestModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                print("⚠️ خطأ في قراءة طلب إدمن (تم تخطيه): ${doc.id} - $e");
                return null;
              }
            }).whereType<NominationRequestModel>().toList());
  }

  @override
  Stream<List<NominationRequestModel>> getEvaluatorRequests(
    String evaluatorId,
  ) {
    return _firestore
        .collection('nomination_requests')
        .where('evaluatorId', isEqualTo: evaluatorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              try {
                return NominationRequestModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                print("⚠️ خطأ في قراءة طلب محكم (تم تخطيه): ${doc.id} - $e");
                return null;
              }
            }).whereType<NominationRequestModel>().toList());
  }
  @override
  Future<Either<String, Unit>> updateRequest(
    NominationRequestModel request,
  ) async {
    try {
      await _firestore
          .collection('nomination_requests')
          .doc(request.id)
          .update(request.toMap());
      return const Right(unit);
    } catch (e) {
      return Left(e.toString());
    }
  }

    @override
  Future<Either<String, List<Map<String, dynamic>>>> getEvaluators() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final evaluators = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final role = data['role']?.toString().toLowerCase() ?? '';

        if (role == 'evaluator' || role == 'judge' || role == 'محكم') {
          // ✅ سحب الاسم من مكانه الصحيح
          final profile = data['profile'] as Map<String, dynamic>?;
          final displayName = profile?['display_name'] as Map<String, dynamic>?;
          final nameAr = displayName?['ar'] ?? 'بدون اسم';

          data['id'] = doc.id;
          data['nameAr'] = nameAr; // ✅ ضيفناها هنا عشان الديالوج يلاقيها
          
          evaluators.add(data);
        }
      }

      return Right(evaluators);
    } catch (e) {
      return Left(e.toString());
    }
  }
}