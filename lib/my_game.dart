import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:space_war/components/asteroid.dart';
import 'package:space_war/components/pickup.dart';
import 'package:space_war/components/player.dart';
import 'package:space_war/components/shoot_button.dart';
import 'package:flutter/material.dart';
import 'package:space_war/components/star.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _asteroidSpawnner;
  late ShootButton _shootButton;
  int _score = 0;
  late TextComponent _scoreDisplay;
  late SpawnComponent _pickupSpawnner;

  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();
    startGame();
    _createStars();
    super.onLoad();
  }

  void startGame() async {
    await createJoystick();
    await _createPlayer();
    _createShootButton();
    _createAsteroidSpawnner();
    _createScoreDisplay();
    _createPickupSpawnner();

    add(Asteroid(position: Vector2(200, 0)));
  }

  Future<void> _createPlayer() async {
    player = Player()
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y * 0.8);
    add(player);
  }

  Future<void> createJoystick() async {
    joystick = JoystickComponent(
      knob: SpriteComponent(sprite: await loadSprite('joystick_knob.png'), size: Vector2.all(50)),
      background: SpriteComponent(sprite: await loadSprite('joystick_background.png'), size: Vector2.all(100)),
      anchor: Anchor.bottomLeft,
      position: Vector2(20, size.y - 20),
      priority: 10,
    );
    add(joystick);
  }

  void _createShootButton() {
    _shootButton = ShootButton()
      ..anchor = Anchor.bottomRight
      ..position = Vector2(size.x - 20, size.y - 20)
      ..priority = 10;
    add(_shootButton);
  }

  void _createAsteroidSpawnner() {
    _asteroidSpawnner = SpawnComponent.periodRange(
      factory: (amount) => Asteroid(position: _generateSpawnPosition()),
      minPeriod: 0.7,
      maxPeriod: 1.2,
      selfPositioning: true,
    );
    add(_asteroidSpawnner);
  }

  void _createPickupSpawnner() {
    _pickupSpawnner = SpawnComponent.periodRange(
      factory: (amount) => Pickup(position: _generateSpawnPosition(), pickupType: PickupType.values[_random.nextInt(PickupType.values.length)]),
      minPeriod: 5,
      maxPeriod: 10,
      selfPositioning: true,
    );
    add(_pickupSpawnner);
  }

  Vector2 _generateSpawnPosition() {
    return Vector2(10 + _random.nextDouble() * (size.x - 10 * 2), -100);
  }

  void _createScoreDisplay() {
    _score = 0;
    _scoreDisplay = TextComponent(
      text: _score.toString(),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 20),
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 2, color: Colors.black, offset: Offset(2, 2))],
        ),
      ),
    );
    add(_scoreDisplay);
  }

  void incrementScore(int amount) {
    _score += amount;
    _scoreDisplay.text = _score.toString();

    final ScaleEffect popEffect = ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.05, alternate: true, curve: Curves.easeInOut));

    _scoreDisplay.add(popEffect);
  }

  void _createStars() {
    for (int i = 0; i < 50; i++) {
      add(Star()..priority = -10);
    }
  }
}
