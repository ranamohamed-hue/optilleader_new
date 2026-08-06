import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ إضافة الترجمة
import 'package:cached_network_image/cached_network_image.dart';

class CompetitionResultsSheet extends StatefulWidget {
  final String announcementId;
  final String announcementTitle;
  final VoidCallback onConfirmAnnounce;

  const CompetitionResultsSheet({
    super.key,
    required this.announcementId,
    required this.announcementTitle,
    required this.onConfirmAnnounce,
  });

  @override
  State<CompetitionResultsSheet> createState() =>
      _CompetitionResultsSheetState();
}

class _CompetitionResultsSheetState extends State<CompetitionResultsSheet> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  String? _error;

  final List<Color> _medalColors = [
    const Color(0xFFFFD700),
    const Color(0xFFC0C0C0),
    const Color(0xFFCD7F32),
  ];
  final List<IconData> _medalIcons = [
    Icons.emoji_events,
    Icons.military_tech,
    Icons.workspace_premium,
  ];

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('nomination_requests')
          .where('announcementId', isEqualTo: widget.announcementId)
          .where('status', whereIn: ['evaluated', 'final_approved'])
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _error = 'results_sheet.no_evaluated'.tr(); // ✅ ترجمة
          _isLoading = false;
        });
        return;
      }

      final rows = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final scores = data['scores'] as Map<String, dynamic>?;
        final achievementsTotal =
            (scores?['achievementsTotal'] as num?)?.toDouble() ?? 0.0;

        // ✅ ترابط آمن: يقرأ الحقل القديم، لو ملقاهش بيجيب المجموع من موديل المقابلة الجديد
        double interviewPoints =
            (data['evaluatorPoints'] as num?)?.toDouble() ?? 0.0;
        if (interviewPoints == 0.0 && data['interviewEvaluation'] != null) {
          final interviewData =
              data['interviewEvaluation'] as Map<String, dynamic>;
          interviewPoints =
              (interviewData['totalScore'] as num?)?.toDouble() ?? 0.0;
        }

        rows.add({
          'id': doc.id,
          'doctorName': data['doctorName'] ?? 'بدون اسم',
          'doctorImageUrl': data['doctorImageUrl'],
          'collegeName': data['collegeName'],
          'departmentName': data['departmentName'],
          'achievementsTotal': achievementsTotal,
          'interviewPoints': interviewPoints,
          'totalScore': achievementsTotal + interviewPoints,
        });
      }

      rows.sort(
        (a, b) =>
            (b['totalScore'] as double).compareTo(a['totalScore'] as double),
      );

      setState(() {
        _results = rows;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'results_sheet.error_occurred'.tr(); // ✅ ترجمة
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'results_sheet.title'.tr(), // ✅ ترجمة
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.announcementTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'results_sheet.participants_info'.tr(
                          args: ['${_results.length}'],
                        ), // ✅ ترجمة مع متغير
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorState()
                : _buildResultsList(theme, colorScheme),
          ),
          if (!_isLoading && _error == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onConfirmAnnounce();
                },
                icon: const Icon(Icons.announcement, color: Colors.white),
                label: Text(
                  'results_sheet.confirm_button'.tr(), // ✅ ترجمة
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 55, color: Colors.red.shade300),
            const SizedBox(height: 15),
            Text(
              _error ?? 'results_sheet.error_occurred'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final row = _results[index];
        final isTop3 = index < 3;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isTop3 ? Colors.amber.shade50 : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isTop3 ? Colors.amber.shade300 : Colors.grey.shade200,
              width: isTop3 ? 1.5 : 0.8,
            ),
            boxShadow: isTop3
                ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (isTop3)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _medalColors[index],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _medalColors[index].withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _medalIcons[index],
                        color: index == 0 ? Colors.white : Colors.grey[800],
                        size: 20,
                      ),
                    )
                  else
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    child:
                        row['doctorImageUrl'] != null &&
                            (row['doctorImageUrl'] as String).isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: row['doctorImageUrl'],
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Icon(Icons.person),
                            ),
                          )
                        : const Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row['doctorName'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (row['collegeName'] != null)
                          Text(
                            row['collegeName'],
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isTop3
                          ? Colors.amber.shade600
                          : colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(row['totalScore'] as double).toStringAsFixed(1)}',
                      style: TextStyle(
                        color: isTop3 ? Colors.white : colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildScoreChip(
                      label: 'results_sheet.achievements'.tr(),
                      value: (row['achievementsTotal'] as double)
                          .toStringAsFixed(1),
                      color: Colors.blue,
                    ), // ✅ ترجمة
                    const SizedBox(width: 8),
                    _buildScoreChip(
                      label: 'results_sheet.interview'.tr(),
                      value: (row['interviewPoints'] as double).toStringAsFixed(
                        1,
                      ),
                      color: Colors.green,
                    ), // ✅ ترجمة
                    const Spacer(),
                    if (isTop3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'results_sheet.winner'.tr(),
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ), // ✅ ترجمة
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
