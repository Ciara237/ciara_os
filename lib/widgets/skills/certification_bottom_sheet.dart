import 'package:ciaraos/models/certification.dart';
import 'package:ciaraos/models/enums/domain.dart';
import 'package:ciaraos/providers/certification_providers.dart';
import 'package:ciaraos/theme/app_colors.dart';
import 'package:ciaraos/theme/app_spacing.dart';
import 'package:ciaraos/theme/app_typography.dart';
import 'package:ciaraos/utils/domain_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showCertificationBottomSheet(
  BuildContext context, {
  Certification? certification,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
    builder: (context) => CertificationBottomSheet(certification: certification),
  );
}

class CertificationBottomSheet extends ConsumerStatefulWidget {
  const CertificationBottomSheet({super.key, this.certification});

  final Certification? certification;

  @override
  ConsumerState<CertificationBottomSheet> createState() =>
      _CertificationBottomSheetState();
}

class _CertificationBottomSheetState
    extends ConsumerState<CertificationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _issuerController;
  late final TextEditingController _linkController;
  late final TextEditingController _progressCurrentController;
  late final TextEditingController _progressTotalController;

  late Domain _domain;
  late CertificationStatus _status;
  DateTime? _dateEarned;
  DateTime? _targetDate;
  CertificationPriority? _priority;
  bool _saving = false;

  bool get _isEditing => widget.certification != null;

  @override
  void initState() {
    super.initState();
    final cert = widget.certification;
    _nameController = TextEditingController(text: cert?.name ?? '');
    _issuerController = TextEditingController(text: cert?.issuer ?? '');
    _linkController = TextEditingController(text: cert?.externalLink ?? '');
    _progressCurrentController = TextEditingController(
      text: '${cert?.progressCurrent ?? 0}',
    );
    _progressTotalController = TextEditingController(
      text: '${cert?.progressTotal ?? 0}',
    );
    _domain = cert?.domain ?? Domain.engineering;
    _status = cert?.status ?? CertificationStatus.inProgress;
    _dateEarned = cert?.dateEarned;
    _targetDate = cert?.targetDate;
    _priority = cert?.priority;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _linkController.dispose();
    _progressCurrentController.dispose();
    _progressTotalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required bool earned,
  }) async {
    final now = DateTime.now();
    final initial = earned
        ? (_dateEarned ?? now)
        : (_targetDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (earned) {
        _dateEarned = picked;
      } else {
        _targetDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(certificationRepositoryProvider);
    final now = DateTime.now();
    final progressCurrent = int.tryParse(_progressCurrentController.text) ?? 0;
    final progressTotal = int.tryParse(_progressTotalController.text) ?? 0;

    try {
      if (_isEditing) {
        final updated = widget.certification!.copyWith(
          name: _nameController.text.trim(),
          issuer: _issuerController.text.trim(),
          domain: _domain,
          status: _status,
          dateEarned: _status == CertificationStatus.earned ? _dateEarned : null,
          targetDate: _status == CertificationStatus.earned
              ? null
              : _targetDate,
          progressCurrent:
              _status == CertificationStatus.inProgress ? progressCurrent : 0,
          progressTotal:
              _status == CertificationStatus.inProgress ? progressTotal : 0,
          priority: _status == CertificationStatus.planned ? _priority : null,
          externalLink: _linkController.text.trim().isEmpty
              ? null
              : _linkController.text.trim(),
          updatedAt: now,
          clearDateEarned: _status != CertificationStatus.earned,
          clearTargetDate: _status == CertificationStatus.earned,
          clearPriority: _status != CertificationStatus.planned,
          clearExternalLink: _linkController.text.trim().isEmpty,
        );
        await repo.update(updated.toCompanion());
      } else {
        final cert = Certification(
          id: 0,
          name: _nameController.text.trim(),
          issuer: _issuerController.text.trim(),
          domain: _domain,
          status: _status,
          dateEarned:
              _status == CertificationStatus.earned ? _dateEarned : null,
          targetDate:
              _status == CertificationStatus.earned ? null : _targetDate,
          progressCurrent:
              _status == CertificationStatus.inProgress ? progressCurrent : 0,
          progressTotal:
              _status == CertificationStatus.inProgress ? progressTotal : 0,
          priority: _status == CertificationStatus.planned ? _priority : null,
          externalLink: _linkController.text.trim().isEmpty
              ? null
              : _linkController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.insert(cert.toCompanion(forInsert: true));
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'EDIT CERTIFICATION' : 'NEW CERTIFICATION',
                        style: AppTypography.labelLarge.copyWith(
                          color: colorScheme.onSurface,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'CERTIFICATION NAME',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _issuerController,
                        decoration: const InputDecoration(labelText: 'ISSUER'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Issuer is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'DOMAIN',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: Domain.values.map((domain) {
                          final selected = _domain == domain;
                          final domainColor = AppColors.domainColors[domain]!;
                          return FilterChip(
                            label: Text(domainShortLabel(domain)),
                            selected: selected,
                            onSelected: (_) => setState(() => _domain = domain),
                            selectedColor: domainColor.withValues(alpha: 0.15),
                            checkmarkColor: domainColor,
                            labelStyle: AppTypography.labelSmall.copyWith(
                              color: selected
                                  ? domainColor
                                  : colorScheme.onSurfaceVariant,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? domainColor
                                  : colorScheme.outlineVariant,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'STATUS',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: CertificationStatus.values.map((status) {
                          final selected = _status == status;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: status != CertificationStatus.planned
                                    ? AppSpacing.sm
                                    : 0,
                              ),
                              child: OutlinedButton(
                                onPressed: () => setState(() => _status = status),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: selected
                                      ? colorScheme.primary
                                          .withValues(alpha: 0.1)
                                      : null,
                                  foregroundColor: selected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  side: BorderSide(
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: AppTypography.labelSmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (_status == CertificationStatus.earned) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'DATE EARNED',
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          subtitle: Text(
                            _dateEarned == null
                                ? 'Not set'
                                : DateFormat.yMMMd().format(_dateEarned!),
                          ),
                          trailing: const Icon(Icons.calendar_today_outlined),
                          onTap: () => _pickDate(earned: true),
                        ),
                      ] else ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'TARGET DATE',
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          subtitle: Text(
                            _targetDate == null
                                ? 'Not set'
                                : DateFormat.yMMMd().format(_targetDate!),
                          ),
                          trailing: const Icon(Icons.calendar_today_outlined),
                          onTap: () => _pickDate(earned: false),
                        ),
                      ],
                      if (_status == CertificationStatus.inProgress) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'MODULES COMPLETE',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _progressCurrentController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Current',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Text(
                                '/',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _progressTotalController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Total',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_status == CertificationStatus.planned) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'PLANNING PRIORITY',
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: CertificationPriority.values.map((priority) {
                            final selected = _priority == priority;
                            final color = _priorityColor(priority);
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: priority != CertificationPriority.high
                                      ? AppSpacing.sm
                                      : 0,
                                ),
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _priority = priority),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: selected
                                        ? color.withValues(alpha: 0.1)
                                        : null,
                                    foregroundColor: selected
                                        ? color
                                        : colorScheme.onSurfaceVariant,
                                    side: BorderSide(
                                      color: selected
                                          ? color
                                          : colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: Text(
                                    priority.name.toUpperCase(),
                                    style: AppTypography.labelSmall,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      TextFormField(
                        controller: _linkController,
                        decoration: const InputDecoration(
                          labelText: 'EXTERNAL LINK / SYLLABUS URL',
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_outlined, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'SAVE CERTIFICATION',
                              style: AppTypography.labelLarge.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(CertificationStatus status) {
    return switch (status) {
      CertificationStatus.earned => 'EARNED',
      CertificationStatus.inProgress => 'IN PROGRESS',
      CertificationStatus.planned => 'PLANNED',
    };
  }

  static Color _priorityColor(CertificationPriority priority) {
    return switch (priority) {
      CertificationPriority.low => AppColors.priorityLow,
      CertificationPriority.medium => AppColors.priorityMedium,
      CertificationPriority.high => AppColors.priorityHigh,
    };
  }
}

Color certificationStatusColor(CertificationStatus status) {
  return switch (status) {
    CertificationStatus.earned => const Color(0xFF34D399),
    CertificationStatus.inProgress => const Color(0xFFFBBF24),
    CertificationStatus.planned => const Color(0xFF8E9197),
  };
}

String certificationStatusLabel(CertificationStatus status) {
  return switch (status) {
    CertificationStatus.earned => 'EARNED',
    CertificationStatus.inProgress => 'IN PROGRESS',
    CertificationStatus.planned => 'PLANNED',
  };
}

Future<void> openCertificationLink(BuildContext context, String? url) async {
  if (url == null || url.isEmpty) {
    return;
  }
  final uri = Uri.tryParse(url);
  if (uri == null || !await canLaunchUrl(uri)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link.')),
      );
    }
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
