import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/doctor/data/model/research_paper_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';

abstract class ResearchPaperRepo {

  Future<Either<String, Unit>> deleteResearchPaper(
    String doctorUid,
    String paperId,
  );

   Future<Either<String, Unit>> updatePaperStatus(
    String doctorUid, 
    String paperId, 
    VerificationStatus status, 
    {String? rejectionReason, double? adminScore} // ✅ أضف السطر ده
  );
   Future<Either<String, Unit>> updateAdminScore({
    required String doctorUid,
    required String paperId,
    required double adminScore,
  });
 Future<Either<String, Unit>> addResearchPaper({
    required String doctorUid,
    required ResearchPaperModel paper,
    required File paperFile,
    File? indexingProofFile,
    File? certifiedReportFile, // ✅
  });
}