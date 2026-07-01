enum FocusQuality {
  deepFocus,
  good,
  okay,
  distracted,
}

String focusQualityLabel(FocusQuality quality) {
  return switch (quality) {
    FocusQuality.deepFocus => 'Deep Focus',
    FocusQuality.good => 'Good',
    FocusQuality.okay => 'Okay',
    FocusQuality.distracted => 'Distracted',
  };
}

/// Numeric score for averaging (AI/analytics layer).
int focusQualityScore(FocusQuality quality) {
  return switch (quality) {
    FocusQuality.deepFocus => 4,
    FocusQuality.good => 3,
    FocusQuality.okay => 2,
    FocusQuality.distracted => 1,
  };
}
