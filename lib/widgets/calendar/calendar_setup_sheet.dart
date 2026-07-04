import 'package:ciaraos/providers/calendar_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showCalendarSetupSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => CalendarSetupSheet(parentRef: ref),
  );
}

class CalendarSetupSheet extends ConsumerStatefulWidget {
  const CalendarSetupSheet({super.key, required this.parentRef});

  final WidgetRef parentRef;

  @override
  ConsumerState<CalendarSetupSheet> createState() =>
      _CalendarSetupSheetState();
}

class _CalendarSetupSheetState extends ConsumerState<CalendarSetupSheet> {
  bool _connecting = false;
  bool _awaitingBrowser = false;
  bool _disconnecting = false;
  bool _showSetup = false;

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _awaitingBrowser = false;
      _showSetup = false;
    });

    final authUrl = await ref.read(calendarServiceProvider).getAuthUrl();
    if (!mounted) {
      return;
    }

    if (authUrl == null) {
      setState(() {
        _connecting = false;
        _showSetup = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google OAuth is not configured on the backend. '
            'Add credentials to .env first (see setup steps).',
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(authUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    setState(() {
      _connecting = false;
      _awaitingBrowser = true;
    });
  }

  Future<void> _confirmConnected() async {
    widget.parentRef.invalidate(calendarAuthProvider);
    final status = await widget.parentRef.read(calendarAuthProvider.future);
    if (!mounted) {
      return;
    }

    if (status.authorized) {
      widget.parentRef.read(calendarEventsProvider.notifier).refresh();
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Not connected yet. Complete authorization in browser.'),
      ),
    );
  }

  Future<void> _disconnect() async {
    setState(() => _disconnecting = true);
    final ok = await ref.read(calendarServiceProvider).disconnect();
    widget.parentRef.invalidate(calendarAuthProvider);
    widget.parentRef.read(calendarEventsProvider.notifier).loadDays(1);
    if (!mounted) {
      return;
    }
    setState(() => _disconnecting = false);
    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authAsync = ref.watch(calendarAuthProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: authAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _buildConnectFlow(colorScheme),
          data: (status) {
            if (status.authorized) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Google Calendar',
                    style: AppTypography.headingLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    status.email ?? 'Connected',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Connected',
                        style: AppTypography.labelSmall.copyWith(
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: _disconnecting ? null : _disconnect,
                    child: Text(
                      'Disconnect',
                      style: AppTypography.labelLarge.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              );
            }

            return _buildConnectFlow(colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildConnectFlow(ColorScheme colorScheme) {
    if (_showSetup) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backend setup required',
            style: AppTypography.headingLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SetupStep(
            number: '1',
            text: 'Go to console.cloud.google.com → APIs & Services → Credentials',
          ),
          const _SetupStep(
            number: '2',
            text:
                'Create OAuth client ID → Web application. '
                'Add redirect URI: http://localhost:8001/auth/google/callback',
          ),
          const _SetupStep(
            number: '3',
            text:
                'Enable Google Calendar API for the project '
                '(APIs & Services → Library)',
          ),
          const _SetupStep(
            number: '4',
            text:
                'Copy Client ID and Client Secret into ciara_os_backend/.env',
          ),
          const _SetupStep(
            number: '5',
            text: 'Restart the backend, then tap Connect again',
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              'GOOGLE_CLIENT_ID=....apps.googleusercontent.com\n'
              'GOOGLE_CLIENT_SECRET=GOCSPX-...\n'
              'GOOGLE_REDIRECT_URI=http://localhost:8001/auth/google/callback',
              style: AppTypography.labelSmall.copyWith(
                fontFamily: 'monospace',
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _connecting ? null : _connect,
            child: const Text('Try Connect again'),
          ),
        ],
      );
    }

    return _ConnectBody(
      connecting: _connecting,
      awaitingBrowser: _awaitingBrowser,
      onConnect: _connect,
      onDone: _confirmConnected,
      onShowSetup: () => setState(() => _showSetup = true),
    );
  }
}

class _ConnectBody extends StatelessWidget {
  const _ConnectBody({
    required this.connecting,
    required this.awaitingBrowser,
    required this.onConnect,
    required this.onDone,
    required this.onShowSetup,
  });

  final bool connecting;
  final bool awaitingBrowser;
  final VoidCallback onConnect;
  final VoidCallback onDone;
  final VoidCallback onShowSetup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connect Google Calendar',
          style: AppTypography.headingLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ciara OS reads your calendar and creates focus blocks tagged '
          '[FOCUS] — it never modifies your other events.',
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (awaitingBrowser) ...[
          Text(
            'Complete authorization in your browser, then tap Done.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onDone,
            child: const Text('Done'),
          ),
        ] else ...[
          FilledButton(
            onPressed: connecting ? null : onConnect,
            child: connecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Connect →'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onShowSetup,
            child: const Text('Setup instructions'),
          ),
        ],
      ],
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
