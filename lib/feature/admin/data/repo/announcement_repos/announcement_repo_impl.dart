import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/repo/announcement_repos/announcement_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnnouncementRepositoryImpl implements IAnnouncementRepository {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase = Supabase.instance.client;

  AnnouncementRepositoryImpl(this._firestore);

  CollectionReference get _collection => _firestore.collection('announcements');
  CollectionReference get _usersCollection => _firestore.collection('users');

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ دالة ذكية تستخرج المفاتيح من أي Map ✅✅✅
  // ═══════════════════════════════════════════════════════
  List<String> _extractMatchKeysFromMap(Map<String, dynamic> data) {
    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    final adminData = data['admin_data'] as Map<String, dynamic>? ?? {};
    
    final role = data['role']?.toString() ?? '';
    final jobAr = profile['current_job_ar'] ?? '';
    final facultyAr = profile['faculty_ar'] ?? '';
    final deptAr = profile['department_ar'] ?? '';
    final sectorName = adminData['sector_name'] ?? '';

    final keys = <String>['general'];

    // هل هو دكتور؟
    final isDoctor = jobAr.contains('دكتور') ||
        jobAr.contains('أ.د') ||
        jobAr.contains('د.') ||
        jobAr.contains('بروفيسور') ||
        jobAr.contains('أستاذ') ||
        jobAr.contains('استاذ');

    if (isDoctor) {
      keys.add('doctor');
      if (facultyAr.isNotEmpty) {
        keys.add('doctor:$facultyAr');
        if (deptAr.isNotEmpty) {
          keys.add('doctor:$facultyAr:$deptAr');
        }
      }
    }

    // ✅✅✅ أي دور تاني (vice_president, vice_dean, admin_manager, إلخ) ✅✅✅
    if (role.isNotEmpty) {
      keys.add('role:$role');
      
      if (role == 'admin_manager' && sectorName.toString().isNotEmpty) {
        keys.add('admin_manager:$sectorName');
      }
    }

    return keys;
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ جلب مفاتيح المستخدم الحالي ✅✅✅
  // ═══════════════════════════════════════════════════════
  Future<List<String>> _getCurrentUserMatchKeys() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return ['general'];

    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return ['general'];

      final data = doc.data() as Map<String, dynamic>;
      
      // ✅ لو المستخدم عنده match_keys محفوظة، استخدمها مباشرة
      if (data['match_keys'] != null) {
        final savedKeys = List<String>.from(data['match_keys']);
        print('🔑 User saved match keys: $savedKeys');
        return savedKeys;
      }

      // ✅ لو مفيش، احسبها من البيانات
      final keys = _extractMatchKeysFromMap(data);
      print('🔑 User computed match keys: $keys');
      return keys;
    } catch (e) {
      print('❌ Error getting user match keys: $e');
      return ['general'];
    }
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ إضافة إعلان مع حساب matchKeys تلقائياً ✅✅✅
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<String, String>> addAnnouncement(AnnouncementModel announcement) async {
    try {
      final computedKeys = announcement.computeMatchKeys();
      final data = announcement.toMap();
      data['match_keys'] = computedKeys;

      print('📝 Adding announcement with match_keys: $computedKeys');
      final docRef = await _collection.add(data);
      return Right(docRef.id);
    } catch (e) {
      print('❌ Error adding announcement: $e');
      return const Left("ERROR_ADD_ANNOUNCEMENT");
    }
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ جلب الإعلانات الموجهة للمستخدم الحالي (للمستخدم العادي) ✅✅✅
  // ═══════════════════════════════════════════════════════
  @override
  Stream<List<AnnouncementModel>> getAnnouncements() async* {
    try {
      final userKeys = await _getCurrentUserMatchKeys();
      print('🔥 GET ANNOUNCEMENTS for user keys: $userKeys');

      yield* _collection
          .where('match_keys', arrayContainsAny: userKeys)
          .snapshots()
          .map((snapshot) {
        final announcements = <AnnouncementModel>[];
        for (final doc in snapshot.docs) {
          try {
            final data = Map<String, dynamic>.from(doc.data() as Map);
            final ann = AnnouncementModel.fromMap(data, doc.id);
            if (_validateMatch(ann, userKeys)) {
              announcements.add(ann);
            }
          } catch (e) {
            print('❌ Error parsing ${doc.id}: $e');
          }
        }
        announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return announcements;
      });
    } catch (e) {
      print('❌ Error in getAnnouncements: $e');
      // ✅ إصلاح: arrayContains بتاخد string مش list
      yield* _collection
          .where('match_keys', arrayContains: 'general')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => AnnouncementModel.fromMap(
                  Map<String, dynamic>.from(doc.data() as Map), doc.id))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    }
  }

  // ═════════════════════════════════════════════════════════════════
  // ✅✅✅ جلب كل الإعلانات بدون فلترة (للأدمن) ✅✅✅
  // ═════════════════════════════════════════════════════════════════
  @override
  Stream<List<AnnouncementModel>> getAllAnnouncements() {
    print('🔥 ADMIN: Fetching ALL announcements');
    
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final announcements = <AnnouncementModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = Map<String, dynamic>.from(doc.data() as Map);
          announcements.add(AnnouncementModel.fromMap(data, doc.id));
        } catch (e) {
          print('❌ Error parsing ${doc.id}: $e');
        }
      }
      print('🔥 ADMIN: Found ${announcements.length} announcements');
      return announcements;
    });
  }

  bool _validateMatch(AnnouncementModel ann, List<String> userKeys) {
    if (ann.matchKeys.contains('general') && userKeys.contains('general')) return true;
    for (final annKey in ann.matchKeys) {
      if (annKey == 'general') continue;
      if (userKeys.contains(annKey)) return true;
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ جلب المستخدمين المستهدفين (للإشعارات) ✅✅✅
  // ═══════════════════════════════════════════════════════
  Future<Either<String, List<String>>> getTargetUserUids(AnnouncementModel announcement) async {
    try {
      final matchKeys = announcement.computeMatchKeys();
      List<String> targetUids = [];

      if (matchKeys.contains('general')) {
        final snapshot = await _usersCollection.where('is_active', isEqualTo: true).get();
        targetUids = snapshot.docs.map((d) => d.id).toList();
      } else {
        for (final key in matchKeys) {
          if (key == 'general') continue;

          // ✅✅✅ إصلاح: استخدام match_keys للمستخدمين أيضاً ✅✅✅
          Query query = _usersCollection.where('match_keys', arrayContains: key);

          // ✅ استثناء: لو المفتاح بس "doctor" من غير كلية
          if (key == 'doctor') {
            query = _usersCollection.where('match_keys', arrayContains: 'doctor');
          }

          final snapshot = await query.get();
          targetUids.addAll(snapshot.docs.map((d) => d.id));
        }
        targetUids = targetUids.toSet().toList();
      }
      print('🎯 Found ${targetUids.length} target users for keys: $matchKeys');
      return Right(targetUids);
    } catch (e) {
      print('❌ Error finding target users: $e');
      return const Left("ERROR_FIND_TARGET_USERS");
    }
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ تحديث إعلان مع إعادة حساب matchKeys ✅✅✅
  // ═══════════════════════════════════════════════════════
  @override
  Future<Either<String, Unit>> updateAnnouncement(AnnouncementModel announcement) async {
    try {
      if (announcement.id != null) {
        final computedKeys = announcement.computeMatchKeys();
        final updatedAnn = announcement.copyWith(matchKeys: computedKeys);
        await _collection.doc(announcement.id).update(updatedAnn.toMap());
        return const Right(unit);
      }
      return const Left("ERROR_ANNOUNCEMENT_NO_ID");
    } catch (e) {
      return const Left("ERROR_UPDATE_ANNOUNCEMENT");
    }
  }

  Future<int> getTargetUserCount(AnnouncementModel announcement) async {
    final result = await getTargetUserUids(announcement);
    return result.fold((_) => 0, (uids) => uids.length);
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ هجرة: إضافة match_keys للإعلانات القديمة ✅✅✅
  // ═══════════════════════════════════════════════════════
  Future<Either<String, int>> migrateOldAnnouncements() async {
    try {
      final snapshot = await _collection.get();
      int updated = 0;
      WriteBatch batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        if (data['match_keys'] != null) continue;

        final ann = AnnouncementModel.fromMap(data, doc.id);
        final keys = ann.computeMatchKeys();

        batch.update(doc.reference, {'match_keys': keys});
        updated++;

        if (updated % 500 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      if (updated % 500 != 0) await batch.commit();
      print('✅ Migrated $updated announcements');
      return Right(updated);
    } catch (e) {
      print('❌ Migration error: $e');
      return const Left("ERROR_MIGRATION");
    }
  }

  // ═══════════════════════════════════════════════════════
  // ✅✅✅ هجرة: إضافة match_keys لمستخدمين بلا مفاتيح ✅✅✅
  // ═══════════════════════════════════════════════════════
  Future<Either<String, int>> migrateUserMatchKeys() async {
    try {
      final snapshot = await _usersCollection.get();
      int updated = 0;
      WriteBatch batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data() as Map);

        if (data['match_keys'] != null) continue;

        final keys = _extractMatchKeysFromMap(data);

        batch.update(doc.reference, {'match_keys': keys});
        updated++;

        if (updated % 500 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      if (updated > 0) await batch.commit();
      print('✅ Migrated $updated users');
      return Right(updated);
    } catch (e) {
      print('❌ User migration error: $e');
      return const Left("ERROR_USER_MIGRATION");
    }
  }

  // ═══════════════════════════════════════════════════════
  // باقي الدوال بدون تغيير
  // ═══════════════════════════════════════════════════════

  @override
  Future<Either<String, Unit>> deleteAnnouncement(String id, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.contains('supabase.co')) {
        try {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('images');
          if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
            final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
            await _supabase.storage.from('images').remove([storagePath]);
          }
        } catch (storageError) {
          print('Failed to delete image: $storageError');
        }
      }
      await _collection.doc(id).delete();
      return const Right(unit);
    } catch (e) {
      return const Left("ERROR_DELETE_ANNOUNCEMENT");
    }
  }

  @override
  Future<Either<String, String>> uploadAnnouncementImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return const Left('ERROR_IMAGE_FILE_NOT_FOUND');

      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) return const Left('ERROR_IMAGE_EMPTY');

      final storagePath = 'announcements/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage.from('images').uploadBinary(
            storagePath,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );

      final imageUrl = _supabase.storage.from('images').getPublicUrl(storagePath);
      return Right(imageUrl);
    } catch (e) {
      return Left('ERROR_IMAGE_UPLOAD_SUPABASE: $e');
    }
  }

  @override
  Future<void> deleteAnnouncementImage(String imageUrl) async {
    if (imageUrl.contains('supabase.co')) {
      try {
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        final bucketIndex = pathSegments.indexOf('images');
        if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
          final storagePath = pathSegments.sublist(bucketIndex + 1).join('/');
          await _supabase.storage.from('images').remove([storagePath]);
        }
      } catch (e) {
        print('Failed to delete old image: $e');
      }
    }
  }

  @override
  Future<Either<String, Unit>> autoCloseExpiredAnnouncements(List<AnnouncementModel> announcements) async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (final ann in announcements) {
        if (ann.status == 'Active' && ann.deadline.isBefore(now)) {
          batch.update(_collection.doc(ann.id), {'status': 'Closed'});
          hasUpdates = true;
        }
      }

      if (hasUpdates) await batch.commit();
      return const Right(unit);
    } catch (e) {
      return const Left("ERROR_AUTO_CLOSE");
    }
  }
}