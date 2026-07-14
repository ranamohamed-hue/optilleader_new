import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CompetitionResultsViewPage extends StatelessWidget {
  final String announcementId;
  final String? currentDoctorId;

  const CompetitionResultsViewPage({
    super.key,
    required this.announcementId,
    this.currentDoctorId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('announcements')
            .doc(announcementId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildErrorScaffold(
              context,
              colorScheme,
              icon: Icons.error_outline,
              message: 'results.error_loading'.tr(),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isResultAnnounced = data['isResultAnnounced'] ?? false;
          final announcementTitle = data['title'] ?? '';

          if (!isResultAnnounced) {
            return _buildErrorScaffold(
              context,
              colorScheme,
              icon: Icons.hourglass_top_rounded,
              message: 'results.not_announced_yet'.tr(),
              iconColor: Colors.orange,
            );
          }

          final winners = List<Map<String, dynamic>>.from(
            data['winners'] ?? [],
          );
          final allResults = List<Map<String, dynamic>>.from(
            data['allResultsSorted'] ?? [],
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: colorScheme.primary,
                automaticallyImplyLeading: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade700, colorScheme.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  // ✅ هنا التعديل
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const Spacer(),
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'results.appbar_title'.tr(),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              announcementTitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (winners.isNotEmpty) ...[
                      _buildSectionTitle(
                        context,
                        'results.top_three_title'.tr(),
                        Colors.amber,
                      ),
                      const SizedBox(height: 14),
                      _buildTopThreeCard(
                        context,
                        winners: winners,
                        currentDoctorId: currentDoctorId,
                      ),
                      const SizedBox(height: 30),
                    ],
                    if (currentDoctorId != null &&
                        currentDoctorId!.isNotEmpty) ...[
                      _buildMyResultCard(
                        context,
                        allResults: allResults,
                        doctorId: currentDoctorId!,
                      ),
                      const SizedBox(height: 30),
                    ],
                    if (allResults.isNotEmpty) ...[
                      _buildSectionTitle(
                        context,
                        'results.all_participants_title'.tr(),
                        colorScheme.primary,
                      ),
                      const SizedBox(height: 14),
                      _buildAllResultsTable(
                        context,
                        allResults: allResults,
                        currentDoctorId: currentDoctorId,
                      ),
                    ],
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTopThreeCard(
    BuildContext context, {
    required List<Map<String, dynamic>> winners,
    required String? currentDoctorId,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    winners.sort(
      (a, b) =>
          (a['rank'] as num).toInt().compareTo((b['rank'] as num).toInt()),
    );
    final medalColors = [
      Colors.amber.shade600,
      Colors.grey.shade500,
      Colors.brown.shade400,
    ];
    final medalLabels = ['🥇', '🥈', '🥉'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(winners.length, (index) {
          final winner = winners[index];
          final isMe = winner['doctorId'] == currentDoctorId;
          final score = (winner['totalScore'] as num?)?.toDouble() ?? 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.green.shade50
                  : medalColors[index].withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isMe
                    ? Colors.green.shade300
                    : medalColors[index].withOpacity(0.25),
                width: isMe ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Text(medalLabels[index], style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: medalColors[index].withOpacity(0.15),
                  child:
                      winner['doctorImageUrl'] != null &&
                          (winner['doctorImageUrl'] as String).isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: winner['doctorImageUrl'] as String,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Icon(Icons.person, color: medalColors[index]),
                          ),
                        )
                      : Icon(Icons.person, color: medalColors[index]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        winner['doctorName'] as String? ?? '—',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isMe
                              ? Colors.green.shade800
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (isMe)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'results.its_you'.tr(),
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                    color: medalColors[index],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${score.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMyResultCard(
    BuildContext context, {
    required List<Map<String, dynamic>> allResults,
    required String doctorId,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final myResult = allResults.cast<Map<String, dynamic>?>().firstWhere(
      (r) => r?['doctorId'] == doctorId,
      orElse: () => null,
    );
    if (myResult == null) return const SizedBox.shrink();

    final isWinner = myResult['isWinner'] as bool? ?? false;
    final score = (myResult['totalScore'] as num?)?.toDouble() ?? 0.0;
    final totalParticipants = allResults.length;

    int myRank = 0;
    final sorted = List<Map<String, dynamic>>.from(allResults);
    sorted.sort(
      (a, b) => ((b['totalScore'] as num?)?.toDouble() ?? 0).compareTo(
        (a['totalScore'] as num?)?.toDouble() ?? 0,
      ),
    );
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i]['doctorId'] == doctorId) {
        myRank = i + 1;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWinner ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWinner ? Colors.green.shade300 : Colors.red.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWinner
                    ? Icons.celebration_rounded
                    : Icons.sentiment_dissatisfied_rounded,
                color: isWinner ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isWinner
                      ? 'results.congrats_winner'.tr()
                      : 'results.sorry_not_winner'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWinner
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMyStatCard(
                label: 'results.your_rank'.tr(),
                value: '$myRank',
                subtitle: 'results.out_of'.tr(args: ['$totalParticipants']),
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _buildMyStatCard(
                label: 'results.total_score'.tr(),
                value: score.toStringAsFixed(1),
                subtitle: isWinner
                    ? 'results.winner_status'.tr()
                    : 'results.not_qualified'.tr(),
                color: isWinner ? Colors.green : Colors.red,
              ),
            ],
          ),
          if (!isWinner)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                'results.encouragement_msg'.tr(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMyStatCard({
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllResultsTable(
    BuildContext context, {
    required List<Map<String, dynamic>> allResults,
    required String? currentDoctorId,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sorted = List<Map<String, dynamic>>.from(allResults);
    sorted.sort(
      (a, b) => ((b['totalScore'] as num?)?.toDouble() ?? 0).compareTo(
        (a['totalScore'] as num?)?.toDouble() ?? 0,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 40,
                  child: Text(
                    '#',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'results.table_name'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'results.table_status'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(sorted.length, (index) {
            final row = sorted[index];
            final isMe = row['doctorId'] == currentDoctorId;
            final isWinner = row['isWinner'] as bool? ?? false;
            final isLast = index == sorted.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.blue.shade50
                    : (index % 2 == 0
                          ? Colors.transparent
                          : Colors.grey.shade50),
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade200, width: 0.5),
                ),
                borderRadius: isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(20))
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isWinner
                            ? Colors.amber.shade700
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row['doctorName'] as String? ?? '—',
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                        color: isMe
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: isWinner
                        ? const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Text(
                              'results.not_qualified_table'.tr(),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorScaffold(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String message,
    Color? iconColor,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          // ✅ هنا التعديل
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('results.page_title'.tr()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: iconColor ?? Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
