import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../models/connection_model.dart';
import '../providers/connections_provider.dart';
import '../widgets/neuron_card.dart';
import '../widgets/app_dialogs.dart';

class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connProv = context.watch<ConnectionsProvider>();
    final connections = connProv.connections;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        leading: !isDesktop
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, size: 24),
                  tooltip: 'Open Menu',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        title: const Text(
          'Connected Integrations',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: connProv.isSyncingAll
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync, size: 22),
            tooltip: 'Sync All Integrations',
            onPressed: connProv.isSyncingAll
                ? null
                : () async {
                    await connProv.syncAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All active integrations synchronized successfully.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Banner explaining integration status
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security, size: 20, color: AppColors.primaryLight),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zero-Compromise Integration Security',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NEURON connects via standard OAuth 2.0. If live credentials are not yet provisioned in Google Cloud or GitHub, you can test with fully functional Demo Mode.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Cards for all 7 integrations
          ...connections.map((conn) {
            return _buildIntegrationCard(context, conn, connProv);
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIntegrationCard(
    BuildContext context,
    ConnectionModel conn,
    ConnectionsProvider provider,
  ) {
    String statusLabel;
    Color statusColor;

    switch (conn.status) {
      case ConnectionStatus.connectedLive:
        statusLabel = 'Connected (Live OAuth)';
        statusColor = AppColors.success;
        break;
      case ConnectionStatus.connectedDemo:
        statusLabel = 'Connected (Demo Mode)';
        statusColor = AppColors.primaryLight;
        break;
      case ConnectionStatus.setupRequired:
        statusLabel = 'Setup Required';
        statusColor = AppColors.warning;
        break;
      case ConnectionStatus.disconnected:
        statusLabel = 'Disconnected';
        statusColor = Colors.grey;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeuronCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: conn.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(conn.icon, size: 22, color: conn.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conn.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20),
                  tooltip: 'View OAuth Details',
                  onPressed: () => AppDialogs.showConnectionSetupDialog(context, conn),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              conn.description,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppTheme.secondaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            if (conn.isConnected && conn.accountDetail.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardElevated(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border(context)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        conn.accountDetail,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Synced: ${conn.lastSyncTime}',
                      style: TextStyle(fontSize: 10, color: AppTheme.secondaryText(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (conn.isConnected) ...[
                  OutlinedButton.icon(
                    onPressed: () => provider.syncService(conn.id),
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Sync', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      AppDialogs.showConfirmDialog(
                        context,
                        title: 'Disconnect ${conn.name}?',
                        message:
                            'Are you sure you want to disconnect ${conn.name}? Cached items will remain but live synchronization will stop.',
                        confirmLabel: 'Disconnect',
                        isDestructive: true,
                        onConfirm: () => provider.disconnect(conn.id),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Disconnect', style: TextStyle(fontSize: 12)),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () => AppDialogs.showConnectionSetupDialog(context, conn),
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('Connect', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
