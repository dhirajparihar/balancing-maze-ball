# Balancing Maze (Climbing Ball Maze)

A precision 2.5D marble balancing arcade puzzle game built with **Flutter**, **Flame**, and **Forge2D**. Guide a heavy marble up a perilous vertical board by independently lifting the left and right carriages of a mechanical bar, negotiating organic beveled cutouts, hazard suction rims, tape shields, and sequential goal cups.

Inspired by mechanical arcade classics like *Ice Cold Beer* and wooden labyrinth balance boards.

---

## Architecture & Systems

### 1. Physics Engine (Forge2D)
- **Kinematic Lifting Bar**: Spans horizontally between the left guide rail ($x = 6.0$) and right guide rail ($x = 34.0$). Driven purely by spring-damped vertical velocities (no discontinuous teleportation) to prevent catapulting the marble.
- **Dynamic Marble**: Continuous collision detection (`bullet: true`) with heavy density ($5.5$) and surface friction damping to simulate realistic inertia and roll.
- **Three-Zone Hole Interaction**:
  1. *Safe Bridge Zone*: Solid board sections where the marble rolls smoothly along the bar.
  2. *Beveled Rim Suction Lip*: Radial tipping force ($16.0$ N suction tension) with warning haptic vibration heartbeat.
  3. *Inner Drop-in Sensor*: Scaled to $80\%$ radius on hazard holes for forgiving near-miss clearance.
- **Zero-Load Chute Respawn**: Falls into hazard holes trigger a smooth $0.6$-second chute reset, recording a faint ghost trail of the failed attempt without intrusive modal interruptions.

### 2. Dual-Lift Control Scheme
- **Independent Sliders**: Left and Right vertical thumb sliders control the carriage heights on each rail.
- **Interactive First-Session Tutorial**: Teaches single-side lifting, slope generation, counter-tilting to brake, and hazard avoidance before timer pressure kicks in.
- **Accessibility & Customization**:
  - *Left-Handed Layout*: Mirrors slider positions for left-dominant players.
  - *Control Sensitivity*: Configurable from $0.3\times$ to $2.0\times$.
  - *Reduced Motion*: Tones down high-frequency pulses and decorative glow effects.
  - *Haptics Toggle*: Respects system and in-game vibration preferences.

### 3. Playable Content & Level Progression
The launch campaign features **6 handcrafted master levels** across distinct themes and mechanics:

| Level | Title | Theme | Mechanics & Goals | Par Time |
| :---: | :--- | :--- | :--- | :---: |
| **01** | Taped Training | Neon Aqua | Wide forgiving bridges, 3 taped hole shields | 82s |
| **02** | Arcade Sequential | Neon Aqua | Sequential target progression ($1 \rightarrow 2 \rightarrow \text{Top Goal}$) | 66s |
| **03** | Clockwork Run | Steampunk Brass | 4 sequential illuminated pockets through brass machinery | 60s |
| **04** | Master Organic | Classic Cyan | Full iconic 9-cutout organic labyrinth | 55s |
| **05** | Cyberpunk Grid | Cyberpunk Neon | Neon grid with magnetic rim suction pulses | 49s |
| **06** | Jungle Ruins | Jungle Bamboo | Bamboo rails and high-incline bridge vine gaps | 46s |

- **Daily Challenge Mode**: Deterministic daily challenge generator rotating 3 unique physics modifiers every 24 hours:
  - *Low Gravity Day* (Floaty $18.0$ downward gravity)
  - *Slippery Ice Mode* (Halved surface friction $0.20$)
  - *Speed Run Attack* ($30$s par time with $2\times$ coin bonus)

### 4. 3-Star Mastery Rules
- **★ 1 Star (Completion)**: Reach the final goal cup before the timer countdown expires.
- **★★ 2 Stars (Par Time)**: Complete the level with cumulative run time $\le$ par time.
- **★★★ 3 Stars (Flawless)**: Flawless run ($0$ falls, $1$ attempt) under par time.
- **Clean Instrument Mastery**: Awarded for completing a level with $0$ wall rail bounces.

### 5. Economy & Customization
- **Marble Skins**: Equip procedural gradient finishes (Ruby, Sapphire, Emerald, Gold, Neon, Galaxy, Crystal).
- **Themes**: Switch board aesthetics between Classic Cyan, Steampunk Brass, Cyberpunk Neon, Jungle Bamboo, Candy Frosting, and Deep Space.
- **Fair Economy**: First-clear bonuses are awarded only once per level; replays award performance coins to prevent farming exploits.

---

## Asset Architecture

The visual rendering is **$100\%$ procedural**:
- Organic cutouts are drawn using mathematical cubic Bézier paths.
- Marbles and rails use radial gradient shaders and dynamic shadows.
- No heavy raster textures or sprite sheets are required.
- Audio consists of embedded procedural WAV sound effects and chiptune/synth audio loops.

---

## Setup & Running

### Prerequisites
- Flutter SDK (3.x or later)
- Dart SDK (3.x or later)

### Run the App
```bash
# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Run Automated Tests
```bash
# Run the complete test suite
flutter test
```

---

## Known Limitations & Roadmap
- Expansions (Chapter 2: Deep Cosmos, Chapter 3: Foundry Pro) are previewed in the Level Select screen and will be released in future updates.
- Power-ups tab in the shop is currently disabled until active consumable items (Safety Shields, Slow-Mo) are integrated into the core physics loop.
