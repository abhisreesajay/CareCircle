import 'package:flutter/material.dart';

import '../../../services/admin/admin_service.dart';

class AdminOverviewTab extends StatelessWidget {
  final AdminService adminService;

  const AdminOverviewTab({
    super.key,
    required this.adminService,
  });

  static const Color _background = Color(0xFFF5F7FB);
  static const Color _textPrimary = Color(0xFF172033);
  static const Color _textSecondary = Color(0xFF7A8496);
  static const Color _border = Color(0xFFE3E8F0);

  static const Color _blue = Color(0xFF4F7CFF);
  static const Color _green = Color(0xFF2EAD67);
  static const Color _purple = Color(0xFF8067D8);
  static const Color _red = Color(0xFFD9535F);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: StreamBuilder<Map<String, dynamic>>(
        stream: adminService.streamSystemMetrics(),
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

          final data = snapshot.data ?? {};

          final totalElders =
              data['totalElders'] ?? 0;

          final totalCaregivers =
              data['totalCaregivers'] ?? 0;

          final activeCircles =
              data['activeCircles'] ?? 0;

          final pendingAlerts =
              data['pendingAlerts'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              28,
              26,
              28,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 24),

                _buildStatsGrid(
                  context,
                  totalElders: totalElders,
                  totalCaregivers: totalCaregivers,
                  activeCircles: activeCircles,
                  pendingAlerts: pendingAlerts,
                ),

                const SizedBox(height: 24),

                _buildPlatformStatus(
                  context,
                  pendingAlerts: pendingAlerts,
                  activeCircles: activeCircles,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return const Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFEEF3FF),
              borderRadius:
                  BorderRadius.all(
                Radius.circular(14),
              ),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: _blue,
              size: 25,
            ),
          ),
        ),

        SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'System Overview',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Real-time overview of the CareCircle platform.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STAT GRID
  // ============================================================

  Widget _buildStatsGrid(
    BuildContext context, {
    required dynamic totalElders,
    required dynamic totalCaregivers,
    required dynamic activeCircles,
    required dynamic pendingAlerts,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final crossAxisCount = width >= 1100
            ? 4
            : width >= 650
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              width >= 1100 ? 1.65 : 1.8,
          children: [
            _buildStatCard(
              title: 'Elders',
              value: '$totalElders',
              subtitle: 'Registered elders',
              icon: Icons.elderly_rounded,
              color: _blue,
              backgroundColor:
                  const Color(0xFFEEF3FF),
            ),

            _buildStatCard(
              title: 'Caregivers',
              value: '$totalCaregivers',
              subtitle: 'Registered caregivers',
              icon:
                  Icons.health_and_safety_rounded,
              color: _green,
              backgroundColor:
                  const Color(0xFFEFFAF3),
            ),

            _buildStatCard(
              title: 'Active Circles',
              value: '$activeCircles',
              subtitle: 'Connected relationships',
              icon:
                  Icons.diversity_3_rounded,
              color: _purple,
              backgroundColor:
                  const Color(0xFFF3F0FF),
            ),

            _buildStatCard(
              title: 'Active Alerts',
              value: '$pendingAlerts',
              subtitle: pendingAlerts == 0
                  ? 'No unresolved alerts'
                  : 'Require attention',
              icon:
                  Icons.notifications_active_rounded,
              color: _red,
              backgroundColor:
                  const Color(0xFFFFF2F3),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9AA3B1),
                    fontSize: 10.5,
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
  // PLATFORM STATUS
  // ============================================================

  Widget _buildPlatformStatus(
    BuildContext context, {
    required dynamic pendingAlerts,
    required dynamic activeCircles,
  }) {
    final hasAlerts =
        (pendingAlerts is int
            ? pendingAlerts
            : int.tryParse(
                  '$pendingAlerts',
                ) ??
                0) >
        0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
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
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFAF3),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: _green,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Status',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Current operational summary',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFAF3),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: _green,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ONLINE',
                      style: TextStyle(
                        color:
                            Color(0xFF267B4D),
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: _border,
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal =
                  constraints.maxWidth >= 600;

              final items = [
                _statusItem(
                  icon:
                      Icons.security_rounded,
                  title: 'Access Control',
                  value: 'Active',
                  color: _green,
                ),
                _statusItem(
                  icon:
                      Icons.groups_rounded,
                  title: 'Care Networks',
                  value:
                      '$activeCircles active',
                  color: _purple,
                ),
                _statusItem(
                  icon:
                      Icons.warning_amber_rounded,
                  title: 'Alert Monitoring',
                  value: hasAlerts
                      ? 'Attention required'
                      : 'All clear',
                  color: hasAlerts
                      ? _red
                      : _green,
                ),
              ];

              if (horizontal) {
                return Row(
                  children: [
                    Expanded(
                      child: items[0],
                    ),
                    _buildVerticalDivider(),
                    Expanded(
                      child: items[1],
                    ),
                    _buildVerticalDivider(),
                    Expanded(
                      child: items[2],
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  items[0],
                  const SizedBox(height: 14),
                  items[1],
                  const SizedBox(height: 14),
                  items[2],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS ITEM
  // ============================================================

  Widget _statusItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VERTICAL DIVIDER
  // ============================================================

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      color: _border,
    );
  }

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    String error,
  ) {
    return Center(
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 560,
        ),
        margin:
            const EdgeInsets.all(28),
        padding:
            const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFFFD8DB),
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration:
                  const BoxDecoration(
                color: Color(0xFFFFF2F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: _red,
                size: 30,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load system metrics',
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