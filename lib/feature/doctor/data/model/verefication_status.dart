enum VerificationStatus {
  pending,   // قيد المراجعة
  approved,  // معتمد
  rejected,  // مرفوض
}

// دالة مساعدة لتحويل النص من الفايرستور إلى Enum
T enumFromString<T>(Iterable<T> values, String? value) {
  return values.firstWhere(
    (type) => type.toString().split('.').last == value,
    orElse: () => values.first,
  );
}

// دالة لحالة الاعتماد
VerificationStatus parseVerificationStatus(String? status) {
  switch (status) {
    case 'approved': return VerificationStatus.approved;
    case 'rejected': return VerificationStatus.rejected;
    default: return VerificationStatus.pending;
  }
}