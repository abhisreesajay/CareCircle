import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/admin/admin_service.dart';

class AdminAlertsTab extends StatelessWidget {
  final AdminService adminService;

  const AdminAlertsTab({
    super.key,
    required this.adminService,
  });

  static const Color _background = Color(0xFFF5F7FB);
  static const Color _textPrimary = Color(0xFF172033);
  static const Color _textSecondary = Color(0xFF7A8496);
  static const Color _border = Color(0xFFE3E8F0);
  static const Color _danger = Color(0xFFD9535F);
  static const Color _dangerDark = Color(0xFFB93845);
  static const Color _dangerLight = Color(0xFFFFF2F3);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          28,
          26,
          28,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<Map<String, dynamic>>>(
                stream: adminService.streamActiveAlerts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(
                      snapshot.error.toString(),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildAlertsList(
                    context,
                    docs,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _dangerLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            color: _danger,
            size: 25,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Alerts',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Monitor and resolve active emergency alerts from elders.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: adminService.streamActiveAlerts(),
          builder: (context, snapshot) {
            final count = snapshot.data?.docs.length ?? 0;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: count > 0
                    ? _dangerLight
                    : const Color(0xFFF0F3F7),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: count > 0
                      ? const Color(0xFFFFD6D9)
                      : _border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    count > 0
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 17,
                    color: count > 0
                        ? _danger
                        : const Color(0xFF2EAD67),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '$count Active',
                    style: TextStyle(
                      color: count > 0
                          ? _dangerDark
                          : const Color(0xFF267B4D),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // ALERT LIST
  // ============================================================

  Widget _buildAlertsList(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();

        final alertId = doc.id;

        final elderId =
            data['elderId']?.toString() ?? '';

        final title =
            data['title']?.toString() ??
                'Emergency Alert';

        final message =
            data['message']?.toString() ?? '';

        final type =
            data['type']?.toString() ??
                'Emergency';

        return _buildAlertCard(
          context,
          alertId: alertId,
          elderId: elderId,
          title: title,
          message: message,
          type: type,
        );
      },
    );
  }

  // ============================================================
  // ALERT CARD
  // ============================================================

  Widget _buildAlertCard(
    BuildContext context, {
    required String alertId,
    required String elderId,
    required String title,
    required String message,
    required String type,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD8DB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ----------------------------------------------------
            // ALERT ACCENT
            // ----------------------------------------------------

            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: _danger,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildAlertIcon(),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  _buildTypeBadge(type),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 18),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FB),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Color(0xFF4D586B),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 17,
                          color: _textSecondary,
                        ),

                        const SizedBox(width: 7),

                        Expanded(
                          child: Text(
                            elderId.isEmpty
                                ? 'Elder ID unavailable'
                                : 'Elder ID: $elderId',
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        _buildResolveButton(
                          context,
                          elderId: elderId,
                          alertId: alertId,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ALERT ICON
  // ============================================================

  Widget _buildAlertIcon() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _dangerLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(
        Icons.warning_amber_rounded,
        color: _danger,
        size: 25,
      ),
    );
  }

  // ============================================================
  // TYPE BADGE
  // ============================================================

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F6),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: Color(0xFF596579),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVE BADGE
  // ============================================================

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _dangerLight,
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: _danger,
          ),
          SizedBox(width: 5),
          Text(
            'ACTIVE',
            style: TextStyle(
              color: _dangerDark,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESOLVE BUTTON
  // ============================================================

  Widget _buildResolveButton(
    BuildContext context, {
    required String elderId,
    required String alertId,
  }) {
    return FilledButton.icon(
      onPressed: elderId.isEmpty
          ? null
          : () => _resolveAlert(
                context,
                elderId: elderId,
                alertId: alertId,
              ),
      icon: const Icon(
        Icons.check_rounded,
        size: 17,
      ),
      label: const Text(
        'Resolve',
      ),
      style: FilledButton.styleFrom(
        backgroundColor: _danger,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            const Color(0xFFE5E8ED),
        disabledForegroundColor:
            const Color(0xFF9299A5),
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // RESOLVE ALERT
  // ============================================================

  Future<void> _resolveAlert(
    BuildContext context, {
    required String elderId,
    required String alertId,
  }) async {
    try {
      await adminService.resolveEmergencyAlert(
        elderId: elderId,
        alertId: alertId,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF267B4D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'Emergency alert resolved.',
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _dangerDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            'Failed to resolve alert: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _border,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(width: 14),
            Text(
              'Loading alerts...',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFFAF3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2EAD67),
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'All Clear',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'There are currently no unresolved emergency alerts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 560,
        ),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFFD8DB),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _danger,
                size: 30,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load system alerts',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}