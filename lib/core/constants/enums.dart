/// Game state machine — every distinct state the game can be in.
library;

enum GameState {
  initializing,
  home,
  levelMap,
  briefing,
  countdown,
  playing,
  paused,
  checkpoint,
  completed,
  transitioning,
  failed,
  reviving,
  gameOver,
}

/// Quality preset for rendering effects.
enum GraphicsQuality { low, medium, high }
