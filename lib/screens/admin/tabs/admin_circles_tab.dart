import 'package:flutter/material.dart';

import '../../../services/admin/admin_service.dart';

class AdminCirclesTab extends StatelessWidget {
  final AdminService adminService;

  const AdminCirclesTab({
    super.key,
    required this.adminService,
  });

  static const Color _background = Color(0xFFF5F7FB);
  static const Color _textPrimary = Color(0xFF172033);
  static const Color _textSecondary = Color(0xFF7A8496);
  static const Color _border = Color(0xFFE3E8F0);
  static const Color _primary = Color(0xFF4F7CFF);
  static const Color _primaryDark = Color(0xFF315FD4);
  static const Color _primaryLight = Color(0xFFEEF3FF);

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
            // ----------------------------------------------------
            // STREAM
            // ----------------------------------------------------

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: adminService.streamCareCircles(),
                builder: (context, snapshot) {
                  final circles = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                        circleCount: circles.length,
                      ),

                      const SizedBox(height: 22),

                      Expanded(
                        child: _buildContent(
                          context,
                          snapshot,
                          circles,
                        ),
                      ),
                    ],
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

  Widget _buildHeader({
    required int circleCount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.diversity_3_rounded,
            color: _primary,
            size: 25,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Care Circles',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'View the current elder-caregiver relationships.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: _primaryLight,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: const Color(0xFFDCE6FF),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.groups_rounded,
                size: 17,
                color: _primary,
              ),
              const SizedBox(width: 7),
              Text(
                '$circleCount Connected',
                style: const TextStyle(
                  color: _primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
    List<Map<String, dynamic>> circles,
  ) {
    if (snapshot.hasError) {
      return _buildErrorState(
        snapshot.error.toString(),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingState();
    }

    if (circles.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      itemCount: circles.length,
      itemBuilder: (context, index) {
        return _buildCircleCard(
          context,
          circles[index],
        );
      },
    );
  }

  // ============================================================
  // CARE CIRCLE CARD
  // ============================================================

  Widget _buildCircleCard(
    BuildContext context,
    Map<String, dynamic> circle,
  ) {
    final elderId =
        circle['elderId']?.toString() ?? '';

    final elderName =
        circle['elderName']?.toString() ??
            'Unnamed Elder';

    final caregivers =
        circle['caregivers'] is List
            ? List<Map<String, dynamic>>.from(
                (circle['caregivers'] as List).map(
                  (caregiver) =>
                      Map<String, dynamic>.from(
                    caregiver as Map,
                  ),
                ),
              )
            : <Map<String, dynamic>>[];

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: _primary.withValues(
            alpha: 0.04,
          ),
          highlightColor: _primary.withValues(
            alpha: 0.03,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 7,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          // ------------------------------------------------------
          // ELDER ICON
          // ------------------------------------------------------

          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.elderly_rounded,
              color: _primary,
              size: 25,
            ),
          ),

          // ------------------------------------------------------
          // ELDER DETAILS
          // ------------------------------------------------------

          title: Text(
            elderName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(
              top: 5,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 14,
                  color: _textSecondary,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    elderId.isEmpty
                        ? 'Elder ID unavailable'
                        : elderId,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // CAREGIVER COUNT
          // ------------------------------------------------------

          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_alt_outlined,
                  size: 16,
                  color: _textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${caregivers.length}',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // CAREGIVERS
          // ------------------------------------------------------

          children: [
            if (caregivers.isEmpty)
              _buildNoCaregivers()
            else ...[
              Row(
                children: [
                  const Text(
                    'Connected Caregivers',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${caregivers.length}',
                      style: const TextStyle(
                        color: _primaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ...caregivers.map(
                (caregiver) => _buildCaregiverCard(
                  caregiver,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CAREGIVER CARD
  // ============================================================

  Widget _buildCaregiverCard(
    Map<String, dynamic> caregiver,
  ) {
    final name =
        caregiver['name']?.toString() ??
            'Unnamed Caregiver';

    final email =
        caregiver['email']?.toString() ?? '';

    final uid =
        caregiver['uid']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE9EDF3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: _primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (email.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],

                if (uid.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'ID: $uid',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9AA3B1),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFAF3),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 6,
                  color: Color(0xFF2EAD67),
                ),
                SizedBox(width: 5),
                Text(
                  'CONNECTED',
                  style: TextStyle(
                    color: Color(0xFF267B4D),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO CAREGIVERS
  // ============================================================

  Widget _buildNoCaregivers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF5E3C5),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: Color(0xFFC98A2E),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No caregivers connected to this elder.',
              style: TextStyle(
                color: Color(0xFF8B682F),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
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
              'Loading care circles...',
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
              decoration: const BoxDecoration(
                color: _primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: _primary,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Care Circles Yet',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'No elders currently have connected caregivers.',
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
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFD9535F),
                size: 30,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load care circles',
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