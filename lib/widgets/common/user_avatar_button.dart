import 'package:ciaraos/providers/profile_providers.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAvatarButton extends ConsumerWidget {
  const UserAvatarButton({
    super.key,
    this.size = 40,
    this.onTap,
    this.tooltip = 'Open navigation menu',
  });

  final double size;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = ref.watch(profileProvider);
    final initials = profile.initials;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundColor: colorScheme.primary,
        child: Text(
          initials,
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.3,
          ),
        ),
      ),
    );

    if (onTap == null) {
      return avatar;
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: avatar,
        ),
      ),
    );
  }
}
