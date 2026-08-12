class DateCalculationModel {
  final DateTime currentDate;
  final DateTime targetDate;
  final int result;

  DateCalculationModel({
    required this.currentDate,
    required this.targetDate,
    required this.result,
  });

  factory DateCalculationModel.forAge(DateTime birthDate) {
    return _calculate(birthDate);
  }

  factory DateCalculationModel.forHiring(DateTime hiringDate) {
    return _calculate(hiringDate);
  }

  factory DateCalculationModel.forProfessorRank(DateTime rankDate) {
    return _calculate(rankDate);
  }

  // ✅ دالة جديدة: حساب الفرق بين أي تاريخين (للفترات المتقطعة في JobHistory)
  factory DateCalculationModel.betweenDates({
    required DateTime start,
    required DateTime end,
  }) {
    int years = end.year - start.year;
    if (end.month < start.month || (end.month == start.month && end.day < start.day)) {
      years--;
    }
    return DateCalculationModel(
      currentDate: end,
      targetDate: start,
      result: years < 0 ? 0 : years,
    );
  }

  static DateCalculationModel _calculate(DateTime target) {
    DateTime now = DateTime.now();
    
    int years = now.year - target.year;
    if (now.month < target.month || (now.month == target.month && now.day < target.day)) {
      years--;
    }
    
    return DateCalculationModel(
      currentDate: now,
      targetDate: target,
      result: years < 0 ? 0 : years,
    );
  }
}