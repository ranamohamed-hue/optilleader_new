import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/logic/app_notification_cubit.dart';
import 'package:optialeader/feature/notification/logic/app_notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text('notifications.title'.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'notifications.clear_read'.tr(),
            onPressed: () {
              context.read<NotificationCubit>().clearAllNotifications();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.secondary),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  state.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'notifications.empty_state'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _buildNotificationCard(context, notification);
              },
            );
          }

          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext mainContext,
    AppNotificationModel notification,
  ) {
    final theme = Theme.of(mainContext);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        // ✅ تعديل: استخدام centerEnd بدل centerRight عشان يدعم الاتجاهين (عربي/إنجليزي)
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsets.only(right: 20.w, left: 20.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        context.read<NotificationCubit>().deleteNotification(notification.id);
      },
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        margin: EdgeInsets.only(bottom: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: notification.isRead
            ? colorScheme.surface
            : colorScheme.secondaryContainer.withOpacity(0.15),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getColorForType(
              notification.type,
            ).withOpacity(0.1),
            child: Icon(
              _getIconForType(notification.type),
              color: _getColorForType(notification.type),
            ),
          ),
          title: Text(
            notification.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Text(
            notification.message,
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            _formatTimestamp(notification.timestamp),
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
          ),
          onTap: () {
            if (!notification.isRead) {
              mainContext.read<NotificationCubit>().markAsRead(notification.id);
            }

            // ✅ تعديل: استخدام push بدل go عشان لما يعمل back يرجع لصفحة الإشعارات
            // ✅ إضافة: توجيه المحكم لصفحة الطلبات لما يضغط على الإشعار
            if (notification.type == NotificationType.newArbitrationRequest) {
              mainContext.push(Routes.ordersList);
            } else if (notification.type ==
                    NotificationType.newResearchSubmitted ||
                notification.type == NotificationType.newActivitySubmitted) {
              mainContext.push('/admin/pending-requests');
            } else if (notification.type ==
                NotificationType.announcementCreated) {
              mainContext.push(
                '${Routes.announcementsDetailsDoctor}?id=${notification.relatedId}',
              );
            } else if (notification.type ==
                NotificationType.competitionResult) {
              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
              mainContext.push(
                Routes.competitionResultsView,
                extra: {
                  'announcementId': notification.relatedId,
                  'currentDoctorId': uid,
                },
              );
            }
          },
        ),
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.userLogin:
        return Icons.login;
      case NotificationType.userLogout:
        return Icons.logout;
      case NotificationType.profileDataUpdated:
        return Icons.edit_note;
      case NotificationType.accountSuspended:
        return Icons.block;
      case NotificationType.welcomeAdmin:
        return Icons.waving_hand;
      case NotificationType.announcementCreated:
        return Icons.campaign;
      case NotificationType.announcementExpired:
        return Icons.notifications_off_outlined;
      case NotificationType.newDoctorRequest:
        return Icons.add_task;
      case NotificationType.judgeRequestCompleted:
        return Icons.gavel;
      case NotificationType.welcomeDoctor:
        return Icons.waving_hand;
      case NotificationType.newCompetition:
        return Icons.emoji_events_outlined;
      case NotificationType.competitionResult:
        return Icons.bar_chart;
      case NotificationType.requestStatusUpdate:
        return Icons.receipt_long;
      case NotificationType.welcomeJudge:
        return Icons.waving_hand;
      case NotificationType.newArbitrationRequest:
        return Icons.assignment_ind;
      case NotificationType.newResearchSubmitted:
        return Icons.science_outlined;
      case NotificationType.newActivitySubmitted:
        return Icons.military_tech_outlined;
      case NotificationType.researchStatusUpdated:
        return Icons.fact_check;
      case NotificationType.activityStatusUpdated:
        return Icons.fact_check;
      case NotificationType.general:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.userLogin:
        return Colors.green;
      case NotificationType.userLogout:
        return Colors.blueGrey;
      case NotificationType.profileDataUpdated:
        return Colors.indigo;
      case NotificationType.accountSuspended:
        return Colors.red;
      case NotificationType.welcomeAdmin:
        return Colors.teal;
      case NotificationType.announcementCreated:
        return Colors.blue;
      case NotificationType.announcementExpired:
        return Colors.orange;
      case NotificationType.newDoctorRequest:
        return Colors.lightBlue;
      case NotificationType.judgeRequestCompleted:
        return AppColors.darkGold;
      case NotificationType.welcomeDoctor:
        return Colors.teal;
      case NotificationType.newCompetition:
        return Colors.purple;
      case NotificationType.competitionResult:
        return Colors.green;
      case NotificationType.requestStatusUpdate:
        return Colors.deepOrange;
      case NotificationType.welcomeJudge:
        return Colors.teal;
      case NotificationType.newArbitrationRequest:
        return AppColors.darkGold;
      case NotificationType.newResearchSubmitted:
        return AppColors.darkGold;
      case NotificationType.newActivitySubmitted:
        return Colors.blueAccent;
      case NotificationType.researchStatusUpdated:
        return Colors.orange;
      case NotificationType.activityStatusUpdated:
        return Colors.orange;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      String hour = date.hour.toString().padLeft(2, '0');
      String minute = date.minute.toString().padLeft(2, '0');
      return 'notifications.time.today'.tr(args: ['$hour:$minute']);
    } else if (diff.inDays == 1) {
      return 'notifications.time.yesterday'.tr();
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
