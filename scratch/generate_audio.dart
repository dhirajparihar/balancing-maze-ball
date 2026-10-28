// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  // 1. Ratchet click (subtle mechanical tooth click, 25ms)
  _writeWav(File('${outDir.path}/sfx_buttonTap.wav'), _generateClick(duration: 0.025, freq: 1400));
  _writeWav(File('${outDir.path}/sfx_ratchet.wav'), _generateClick(duration: 0.018, freq: 1800));

  // 2. Theme-specific Clanks
  // Steampunk Brass ring clank (metallic sharp resonance, 180ms)
  _writeWav(File('${outDir.path}/sfx_clank_brass.wav'), _generateBrassRing());
  // Jungle Timber thud (hollow warm timber thud, 140ms)
  _writeWav(File('${outDir.path}/sfx_clank_timber.wav'), _generateTimberThud());
  // Classic Cyan ceramic tap (crisp plastic-acrylic click, 60ms)
  _writeWav(File('${outDir.path}/sfx_clank_ceramic.wav'), _generateCeramicTap());
  // General marble collision
  _writeWav(File('${outDir.path}/sfx_marbleCollision.wav'), _generateCeramicTap());

  // 3. Marble Roll rumble (loopable low-frequency mechanical rumble, 400ms)
  _writeWav(File('${outDir.path}/sfx_marbleRoll.wav'), _generateRollingRumble());

  // 4. Chute vacuum & fall out pop
  _writeWav(File('${outDir.path}/sfx_fallOut.wav'), _generateFallVacuum());

  // 5. Checkpoint chime / sequential hit (bright ding)
  _writeWav(File('${outDir.path}/sfx_checkpoint.wav'), _generateChime(freqs: [660, 880, 1320]));

  // 6. Victory fanfare (warm ascending arpeggio)
  _writeWav(File('${outDir.path}/sfx_victory.wav'), _generateFanfare());

  // 7. Failure drop
  _writeWav(File('${outDir.path}/sfx_failure.wav'), _generateFailureSound());

  // 8. Tape crack / tear
  _writeWav(File('${outDir.path}/sfx_tape_crack.wav'), _generateTapeCrack());

  // 9. Coin / star collect
  _writeWav(File('${outDir.path}/sfx_coinCollect.wav'), _generateCoinPing());
  _writeWav(File('${outDir.path}/sfx_starCollect.wav'), _generateCoinPing(baseFreq: 987));

  // 10. Timer warning tick
  _writeWav(File('${outDir.path}/sfx_timerWarning.wav'), _generateClick(duration: 0.03, freq: 880));

  // 11. Revive & powerup & unlock
  _writeWav(File('${outDir.path}/sfx_revive.wav'), _generateChime(freqs: [440, 554, 659, 880]));
  _writeWav(File('${outDir.path}/sfx_powerUpActivate.wav'), _generateChime(freqs: [523, 659, 784, 1046]));
  _writeWav(File('${outDir.path}/sfx_purchase.wav'), _generateCoinPing(baseFreq: 880));
  _writeWav(File('${outDir.path}/sfx_themeUnlock.wav'), _generateFanfare());
  _writeWav(File('${outDir.path}/sfx_achievementUnlock.wav'), _generateFanfare());
  _writeWav(File('${outDir.path}/sfx_countdown.wav'), _generateClick(duration: 0.04, freq: 520));
  _writeWav(File('${outDir.path}/sfx_menuTransition.wav'), _generateClick(duration: 0.03, freq: 600));

  // 12. Ambient mechanical background loops
  _writeWav(File('${outDir.path}/music_gameplay.wav'), _generateAmbientDrone());
  _writeWav(File('${outDir.path}/music_homeMenu.wav'), _generateAmbientDrone(baseFreq: 110));

  print('Generated ${outDir.listSync().length} audio asset files.');
}

List<int> _generateAmbientDrone({double baseFreq = 98.0, int sampleRate = 22050}) {
  const duration = 2.0; // 2-second seamless mechanical ambient loop
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final f1 = sin(2 * pi * baseFreq * t);
    final f2 = sin(2 * pi * (baseFreq * 1.5) * t) * 0.4;
    final f3 = sin(2 * pi * (baseFreq * 2.0) * t) * 0.25;
    // Rhythmic pulse (heartbeat 60 BPM = 1Hz)
    final pulse = 0.85 + 0.15 * sin(2 * pi * 1.0 * t);
    final val = (f1 + f2 + f3) * pulse * 12000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateClick({required double duration, required double freq, int sampleRate = 22050}) {
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);
  final rand = Random();

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-t * 120.0);
    // Combination of tone and white noise transient
    final tone = sin(2 * pi * freq * t);
    final noise = (rand.nextDouble() * 2.0 - 1.0) * 0.4;
    final val = ((tone + noise) * env * 24000).clamp(-32767, 32767).toInt();
    samples[i] = val;
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateBrassRing({int sampleRate = 22050}) {
  const duration = 0.22;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-t * 18.0);
    // Metallic inharmonic spectrum: 850Hz, 1720Hz, 2640Hz
    final val = (
      sin(2 * pi * 850 * t) * 0.5 +
      sin(2 * pi * 1720 * t) * 0.35 +
      sin(2 * pi * 2640 * t) * 0.15
    ) * env * 26000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateTimberThud({int sampleRate = 22050}) {
  const duration = 0.18;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-t * 28.0);
    // Low hollow wood resonance: 180Hz, 360Hz with rapid decay
    final val = (
      sin(2 * pi * 180 * t) * 0.7 +
      sin(2 * pi * 360 * t) * 0.3
    ) * env * 28000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateCeramicTap({int sampleRate = 22050}) {
  const duration = 0.08;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-t * 60.0);
    final val = (
      sin(2 * pi * 1250 * t) * 0.6 +
      sin(2 * pi * 2500 * t) * 0.4
    ) * env * 26000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateRollingRumble({int sampleRate = 22050}) {
  const duration = 0.35;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);
  final rand = Random(42);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = sin(pi * t / duration); // Smooth fade in and out
    final lowTone = sin(2 * pi * 95 * t);
    final rumbleNoise = (rand.nextDouble() * 2.0 - 1.0) * 0.35;
    final val = (lowTone + rumbleNoise) * env * 14000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateFallVacuum({int sampleRate = 22050}) {
  const duration = 0.32;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    // Downward pitch bend from 500Hz to 120Hz
    final freq = 500.0 - (380.0 * (t / duration));
    final env = (1.0 - t / duration) * (t < 0.05 ? (t / 0.05) : 1.0);
    final val = sin(2 * pi * freq * t) * env * 26000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateChime({required List<double> freqs, int sampleRate = 22050}) {
  const duration = 0.35;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-t * 8.0);
    double mixed = 0.0;
    for (int f = 0; f < freqs.length; f++) {
      mixed += sin(2 * pi * freqs[f] * t) / freqs.length;
    }
    final val = mixed * env * 25000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateFanfare({int sampleRate = 22050}) {
  const duration = 0.65;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);
  final notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
  final noteDur = duration / notes.length;

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final noteIdx = min((t / noteDur).toInt(), notes.length - 1);
    final noteT = t - (noteIdx * noteDur);
    final env = exp(-noteT * 6.0);
    final val = sin(2 * pi * notes[noteIdx] * t) * env * 24000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateFailureSound({int sampleRate = 22050}) {
  const duration = 0.40;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final freq = 280.0 - (150.0 * (t / duration));
    final env = exp(-t * 5.0);
    final val = sin(2 * pi * freq * t) * env * 25000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateTapeCrack({int sampleRate = 22050}) {
  const duration = 0.12;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);
  final rand = Random(99);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = exp(-t * 35.0);
    final noise = (rand.nextDouble() * 2.0 - 1.0);
    final val = noise * env * 28000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _generateCoinPing({double baseFreq = 784, int sampleRate = 22050}) {
  const duration = 0.25;
  final numSamples = (duration * sampleRate).toInt();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final freq = t < 0.08 ? baseFreq : baseFreq * 1.33;
    final env = exp(-t * 12.0);
    final val = sin(2 * pi * freq * t) * env * 24000;
    samples[i] = val.clamp(-32767, 32767).toInt();
  }
  return _encodeWav(samples, sampleRate);
}

List<int> _encodeWav(Int16List samples, int sampleRate) {
  final byteData = ByteData(44 + samples.length * 2);

  // "RIFF"
  byteData.setUint8(0, 0x52); byteData.setUint8(1, 0x49);
  byteData.setUint8(2, 0x46); byteData.setUint8(3, 0x46);
  // File size - 8
  byteData.setUint32(4, 36 + samples.length * 2, Endian.little);
  // "WAVE"
  byteData.setUint8(8, 0x57); byteData.setUint8(9, 0x41);
  byteData.setUint8(10, 0x56); byteData.setUint8(11, 0x45);
  // "fmt "
  byteData.setUint8(12, 0x66); byteData.setUint8(13, 0x6D);
  byteData.setUint8(14, 0x74); byteData.setUint8(15, 0x20);
  // Subchunk1Size = 16
  byteData.setUint32(16, 16, Endian.little);
  // AudioFormat = 1 (PCM)
  byteData.setUint16(20, 1, Endian.little);
  // NumChannels = 1
  byteData.setUint16(22, 1, Endian.little);
  // SampleRate
  byteData.setUint32(24, sampleRate, Endian.little);
  // ByteRate = SampleRate * NumChannels * BitsPerSample/8
  byteData.setUint32(28, sampleRate * 2, Endian.little);
  // BlockAlign = NumChannels * BitsPerSample/8
  byteData.setUint16(32, 2, Endian.little);
  // BitsPerSample = 16
  byteData.setUint16(34, 16, Endian.little);
  // "data"
  byteData.setUint8(36, 0x64); byteData.setUint8(37, 0x61);
  byteData.setUint8(38, 0x74); byteData.setUint8(39, 0x61);
  // Subchunk2Size
  byteData.setUint32(40, samples.length * 2, Endian.little);

  for (int i = 0; i < samples.length; i++) {
    byteData.setInt16(44 + i * 2, samples[i], Endian.little);
  }

  return byteData.buffer.asUint8List();
}

void _writeWav(File file, List<int> bytes) {
  file.writeAsBytesSync(bytes);
}
