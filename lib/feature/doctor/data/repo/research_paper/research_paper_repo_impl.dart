import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:optialeader/core/helper/file_halper.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';

class ResearchPaperRepoImpl extends ResearchPaperRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client; 
  
  CollectionReference get _usersCollection =>
      firebaseFirestore.collection('users');

  Future<({String url, String fileType})> _uploadFileToSupabase(
    File file,
    String doctorUid,
    String folderName,
  ) async {
    final fileType = FileHelper.getFileType(file);
    final extension = FileHelper.getExtension(file);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storagePath = 'research_papers/$doctorUid/$folderName/$fileName';

    final fileBytes = await file.readAsBytes();

    await _supabase.storage
        .from('files')
        .uploadBinary(storagePath, fileBytes, fileOptions: const FileOptions(upsert: true));

    final url = _supabase.storage.from('files').getPublicUrl(storagePath);
    
    return (
      url: url,
      fileType: fileType == UploadedFileType.image ? 'image' : 'pdf',
    );
  }

  @override
  Future<Either<String, Unit>> addResearchPaper({
    required String doctorUid,
    required ResearchPaperModel paper,
    required File paperFile,
    File? indexingProofFile,
    File? certifiedReportFile, // ✅ الجديد
  }) async {
    try {
      // 1. رفع ملف البحث
      final paperUpload = await _uploadFileToSupabase(paperFile, doctorUid, 'paper');

      // 2. رفع إثبات التفهرس (لو موجود)
      String? indexingProofUrl;
      String? indexingProofType;
      if (indexingProofFile != null) {
        final indexingUpload = await _uploadFileToSupabase(indexingProofFile, doctorUid, 'indexing_proof');
        indexingProofUrl = indexingUpload.url;
        indexingProofType = indexingUpload.fileType;
      }

      // ✅ 3. رفع التقرير المعتمد (لو موجود)
      String? certifiedReportUrl;
      String? certifiedReportType;
      if (certifiedReportFile != null) {
        final reportUpload = await _uploadFileToSupabase(certifiedReportFile, doctorUid, 'certified_report');
        certifiedReportUrl = reportUpload.url;
        certifiedReportType = reportUpload.fileType;
      }

      // 4. تحديث الموديل بالروابط الحقيقية
      final paperWithFiles = paper.copyWith(
        paperFileUrl: paperUpload.url,
        paperFileType: paperUpload.fileType,
        indexingProofUrl: indexingProofUrl,
        indexingProofType: indexingProofType,
        certifiedReportFileUrl: certifiedReportUrl, // ✅
      );

      // 5. حفظ في Firestore
      await _usersCollection.doc(doctorUid).update({
        'scientific_work.research_papers': FieldValue.arrayUnion([paperWithFiles.toMap()]),
      });

      return right(unit);
    } catch (e) {
      return left("فشل إضافة البحث: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deleteResearchPaper(String doctorUid, String paperId) async {
    try {
      final docRef = _usersCollection.doc(doctorUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> papers = List.from(data['scientific_work']?['research_papers'] ?? []);

        final paperToDelete = papers.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p?['id'] == paperId,
          orElse: () => null,
        );

        if (paperToDelete != null) {
          // حذف الملفات من Supabase
          try {
            if (paperToDelete['paperFileUrl'] != null) {
              final uri = Uri.parse(paperToDelete['paperFileUrl']);
              final filePath = uri.pathSegments.sublist(uri.pathSegments.indexOf('files') + 1).join('/');
              await _supabase.storage.from('files').remove([filePath]);
            }
          } catch (_) {}
          try {
            if (paperToDelete['indexingProofUrl'] != null) {
              final uri = Uri.parse(paperToDelete['indexingProofUrl']);
              final filePath = uri.pathSegments.sublist(uri.pathSegments.indexOf('files') + 1).join('/');
              await _supabase.storage.from('files').remove([filePath]);
            }
          } catch (_) {}
          // ✅ حذف التقرير المعتمد
          try {
            if (paperToDelete['certifiedReportFileUrl'] != null) {
              final uri = Uri.parse(paperToDelete['certifiedReportFileUrl']);
              final filePath = uri.pathSegments.sublist(uri.pathSegments.indexOf('files') + 1).join('/');
              await _supabase.storage.from('files').remove([filePath]);
            }
          } catch (_) {}
        }

        papers.removeWhere((paper) => paper['id'] == paperId);
        await docRef.update({'scientific_work.research_papers': papers});
      }
      return right(unit);
    } catch (e) {
      return left("فشل حذف البحث: ${e.toString()}");
    }
  }

 
    @override
  Future<Either<String, Unit>> updatePaperStatus(
    String doctorUid, 
    String paperId, 
    VerificationStatus status, 
    {String? rejectionReason, double? adminScore} 
  ) async {
    try {
      final docRef = _usersCollection.doc(doctorUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> papers = List.from(data['scientific_work']?['research_papers'] ?? []);

        for (int i = 0; i < papers.length; i++) {
          if (papers[i]['id'] == paperId) {
            papers[i]['status'] = status.name;
            
            if (adminScore != null) {
              papers[i]['adminScore'] = adminScore;
            }

            if (rejectionReason != null) {
              papers[i]['rejectionReason'] = rejectionReason;
            } else {
              papers[i].remove('rejectionReason');
            }
            break;
          }
        }
        await docRef.update({'scientific_work.research_papers': papers});
      }
      return right(unit);
    } catch (e) {
      return left("فشل تحديث حالة البحث: ${e.toString()}");
    }
  }
  @override
  Future<Either<String, Unit>> updateAdminScore({
    required String doctorUid,
    required String paperId,
    required double adminScore,
  }) async {
    try {
      final docRef = _usersCollection.doc(doctorUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final List<dynamic> papers = List.from(data['scientific_work']?['research_papers'] ?? []);

        for (int i = 0; i < papers.length; i++) {
          if (papers[i]['id'] == paperId) {
            papers[i]['adminScore'] = adminScore;
            break;
          }
        }
        await docRef.update({'scientific_work.research_papers': papers});
      }
      return right(unit);
    } catch (e) {
      return left("فشل تحديث درجة الأدمن: ${e.toString()}");
    }
  }
}