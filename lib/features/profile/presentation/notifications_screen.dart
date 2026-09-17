import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/customer_notification.dart';

/// Screen displaying customer notification history streamed securely from Firestore
class NotificationsScreen extends StatelessWidget {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  const NotificationsScreen({
    super.key,
    this.firestore,
    this.auth,
  });

  @override
  Widget build(BuildContext context) {
    User? currentUser;
    FirebaseFirestore? effectiveFirestore;

    try {
      final effectiveAuth = auth ?? FirebaseAuth.instance;
      currentUser = effectiveAuth.currentUser;
    } catch (_) {
      currentUser = null;
    }

    try {
      effectiveFirestore = firestore ?? FirebaseFirestore.instance;
    } catch (_) {
      effectiveFirestore = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: currentUser == null || effectiveFirestore == null
          ? _buildEmptyState(context)
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: effectiveFirestore
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('notifications')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF166534),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildEmptyState(context);
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final notification = CustomerNotification.fromMap(doc.id, doc.data());
                    return _buildNotificationCard(context, notification, effectiveFirestore!, currentUser!.uid);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF93C5FD),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Notifications Yet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Notifications will appear here when you receive delivery alerts, morning harvest updates, and special offers.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(
                  'Back to Profile',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF166534),
                  side: const BorderSide(color: Color(0xFF166534)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    CustomerNotification item,
    FirebaseFirestore firestore,
    String uid,
  ) {
    final iconData = _getNotificationIcon(item.type);
    final iconColor = _getNotificationColor(item.type);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        if (!item.isRead) {
          try {
            await firestore
                .collection('users')
                .doc(uid)
                .collection('notifications')
                .doc(item.id)
                .update({'read': true});
          } catch (_) {}
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead ? const Color(0xFFF1F5F9) : const Color(0xFFBBF7D0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                  if (item.orderId != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Order: ${item.orderId}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderPlaced:
      case NotificationType.paymentSuccess:
        return Icons.check_circle_outline_rounded;
      case NotificationType.paymentFailed:
      case NotificationType.refundFailed:
        return Icons.error_outline_rounded;
      case NotificationType.orderPreparing:
        return Icons.inventory_2_outlined;
      case NotificationType.orderOutForDelivery:
        return Icons.delivery_dining_outlined;
      case NotificationType.orderDelivered:
        return Icons.home_outlined;
      case NotificationType.orderCancelled:
        return Icons.cancel_outlined;
      case NotificationType.refundPending:
      case NotificationType.refundProcessed:
        return Icons.currency_rupee_rounded;
      case NotificationType.morningHarvest:
        return Icons.eco_outlined;
      case NotificationType.promo:
        return Icons.local_offer_outlined;
      case NotificationType.general:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderPlaced:
      case NotificationType.paymentSuccess:
      case NotificationType.orderDelivered:
      case NotificationType.morningHarvest:
        return const Color(0xFF166534);
      case NotificationType.paymentFailed:
      case NotificationType.refundFailed:
      case NotificationType.orderCancelled:
        return const Color(0xFFDC2626);
      case NotificationType.orderPreparing:
      case NotificationType.orderOutForDelivery:
        return const Color(0xFF2563EB);
      case NotificationType.refundPending:
      case NotificationType.refundProcessed:
        return const Color(0xFF9333EA);
      case NotificationType.promo:
        return const Color(0xFFD97706);
      case NotificationType.general:
        return const Color(0xFF64748B);
    }
  }
}
