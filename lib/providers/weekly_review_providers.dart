import 'package:ciaraos/models/weekly_review.dart';
import 'package:ciaraos/providers/database_provider.dart';
import 'package:ciaraos/repositories/weekly_review_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyReviewRepositoryProvider = Provider<WeeklyReviewRepository>((ref) {
  return WeeklyReviewRepository(ref.watch(databaseProvider));
});

final allWeeklyReviewsProvider = StreamProvider<List<WeeklyReview>>((ref) {
  return ref.watch(weeklyReviewRepositoryProvider).watchAll();
});
