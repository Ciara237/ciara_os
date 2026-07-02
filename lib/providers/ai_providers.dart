import 'package:ciaraos/models/executive_brief.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final executiveBriefProvider =
    StateNotifierProvider<ExecutiveBriefNotifier, AsyncValue<ExecutiveBrief?>>(
  (ref) {
    return ExecutiveBriefNotifier(ref.read(aiServiceProvider));
  },
);

class ExecutiveBriefNotifier
    extends StateNotifier<AsyncValue<ExecutiveBrief?>> {
  ExecutiveBriefNotifier(this._aiService)
      : super(const AsyncValue.data(null));

  final AiService _aiService;
  String? lastError;

  Future<void> fetchBrief(Map<String, dynamic> payload) async {
    state = const AsyncValue.loading();
    lastError = null;

    final result = await _aiService.fetchBrief(payload);
    if (result.isSuccess) {
      state = AsyncValue.data(result.brief);
      return;
    }

    lastError = result.errorMessage;
    state = const AsyncValue.data(null);
  }

  void clear() {
    lastError = null;
    state = const AsyncValue.data(null);
  }
}
