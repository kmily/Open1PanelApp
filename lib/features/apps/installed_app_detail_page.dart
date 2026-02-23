import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/theme/app_theme.dart';
import 'package:onepanelapp_app/data/models/app_models.dart';
import 'package:onepanelapp_app/features/apps/app_service.dart';
import 'package:onepanelapp_app/features/apps/providers/installed_apps_provider.dart';
import 'package:onepanelapp_app/l10n/generated/app_localizations.dart';

class InstalledAppDetailPage extends StatefulWidget {
  final String appId;

  const InstalledAppDetailPage({
    super.key,
    required this.appId,
  });

  @override
  State<InstalledAppDetailPage> createState() => _InstalledAppDetailPageState();
}

class _InstalledAppDetailPageState extends State<InstalledAppDetailPage> {
  final AppService _appService = AppService();
  
  AppInstallInfo? _appInfo;
  List<AppServiceResponse>? _services;
  Map<String, dynamic>? _appConfig;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final info = await _appService.getAppInstallInfo(widget.appId);
      List<AppServiceResponse> services = [];
      Map<String, dynamic>? config;

      if (info.appKey != null) {
        try {
          services = await _appService.getAppServices(info.appKey!);
        } catch (e) {
          debugPrint('Failed to load services: $e');
        }
      }

      if (info.name != null && info.appKey != null) {
        try {
          config = await _appService.getAppInstallConfig(info.name!, info.appKey!);
        } catch (e) {
          debugPrint('Failed to load config: $e');
        }
      }

      if (mounted) {
        setState(() {
          _appInfo = info;
          _services = services;
          _appConfig = config;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleAction(String operation) async {
    if (_appInfo == null) return;

    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<InstalledAppsProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      if (operation == 'uninstall') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.appActionUninstall),
            content: Text(l10n.appUninstallConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.commonConfirm),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        await provider.uninstallApp(widget.appId);
        if (mounted) {
          Navigator.pop(context); // Close detail page
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.appOperateSuccess)),
          );
        }
      } else {
        await provider.operateApp(widget.appId, operation);
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.appOperateSuccess)),
        );
        // Refresh data
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(l10n.appOperateFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appDetailTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.appTabInfo),
              Tab(text: l10n.appTabConfig),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildBody(l10n),
            _buildConfigTab(l10n),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(l10n),
      ),
    );
  }

  Widget _buildConfigTab(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.commonLoadFailedTitle),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadData,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    if (_appConfig == null || _appConfig!.isEmpty) {
      return Center(child: Text(l10n.commonEmpty));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _appConfig!.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        e.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SelectableText(e.value?.toString() ?? ''),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.commonLoadFailedTitle),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadData,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    if (_appInfo == null) {
      return Center(child: Text(l10n.commonEmpty));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(l10n),
          const SizedBox(height: 24),
          _buildBasicInfo(l10n),
          const SizedBox(height: 24),
          _buildServicesList(l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final status = _appInfo!.status?.toLowerCase() ?? '';
    Color statusColor;
    String statusText;

    if (status == 'running') {
      statusColor = Colors.green;
      statusText = l10n.appStatusRunning;
    } else if (status == 'stopped') {
      statusColor = Colors.orange;
      statusText = l10n.appStatusStopped;
    } else {
      statusColor = Colors.grey;
      statusText = status;
    }

    return Row(
      children: [
        if (_appInfo!.icon != null)
          Image.network(
            _appInfo!.icon!,
            width: 64,
            height: 64,
            errorBuilder: (_, __, ___) => const Icon(Icons.apps, size: 64),
          )
        else
          const Icon(Icons.apps, size: 64),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _appInfo!.appName ?? _appInfo!.name ?? '-',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_appInfo!.name != null && _appInfo!.name != _appInfo!.appName)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _appInfo!.name!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appBaseInfo,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(l10n.appInfoVersion, _appInfo!.version ?? '-'),
                const Divider(),
                _buildInfoRow(l10n.appInfoCreated, _appInfo!.createdAt ?? '-'),
                if (_appInfo!.description != null) ...[
                  const Divider(),
                  _buildInfoRow('Description', _appInfo!.description!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(AppLocalizations l10n) {
    if (_services == null || _services!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appServiceList,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _services!.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final service = _services![index];
              return ListTile(
                title: Text(service.label),
                subtitle: Text(service.value),
                trailing: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: service.status == 'running' ? Colors.green : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    if (_loading || _appInfo == null) return const SizedBox.shrink();

    final status = _appInfo!.status?.toLowerCase();
    final isRunning = status == 'running';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: isRunning
                  ? OutlinedButton.icon(
                      onPressed: () => _handleAction('stop'),
                      icon: const Icon(Icons.stop),
                      label: Text(l10n.appActionStop),
                    )
                  : FilledButton.icon(
                      onPressed: () => _handleAction('start'),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.appActionStart),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleAction('restart'),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.appActionRestart),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              onPressed: () => _handleAction('uninstall'),
              icon: const Icon(Icons.delete),
              tooltip: l10n.appActionUninstall,
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
