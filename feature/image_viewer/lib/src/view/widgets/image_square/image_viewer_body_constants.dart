/// When content overflows viewport, each block reveals based on scroll position.
/// Fraction of viewport scrolled per block to trigger reveal (5–10%).
const scrollRevealFraction = 0.05;

/// Delay (ms) before first body block animates in when content fits viewport.
const bodyDelayStartMs = 1000;

/// Step (ms) between each body block reveal when content fits viewport.
const bodyDelayStepMs = 200;
