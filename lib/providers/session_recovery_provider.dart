import 'package:flutter_riverpod/legacy.dart';

/// Set when daily brief already handled an interrupted focus session.
final sessionRecoveryHandledProvider = StateProvider<bool>((ref) => false);
