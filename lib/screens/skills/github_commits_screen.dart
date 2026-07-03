import 'package:ciaraos/providers/github_providers.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/widgets/navigation/minimal_back_header.dart';
import 'package:ciaraos/widgets/skills/github_commit_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class GitHubCommitsScreen extends ConsumerWidget {
  const GitHubCommitsScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await canLaunchUrl(uri)) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final commits = ref.watch(githubActivityProvider).value?.recentCommits ?? [];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const MinimalBackHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Text(
                  'RECENT COMMITS',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (commits.isEmpty)
                  Text(
                    'No commits to show.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...commits.map(
                    (commit) => GitHubCommitTile(
                      commit: commit,
                      onTap: () => _openUrl(commit.url),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
