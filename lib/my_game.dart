import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:space_war/components/asteroid.dart';
import 'package:space_war/components/player.dart';
import 'package:space_war/components/shoot_button.dart';

class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Player player;
  late JoystickComponent joystick;
  late SpawnComponent _asteroidSpawnner;
  late ShootButton _shootButton;

  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await Flame.device.fullScreen();
    await Flame.device.setPortrait();
    startGame();
    super.onLoad();
  }

  void startGame() async {
    await createJoystick();
    await _createPlayer();
    _createShootButton();
    _createAsteroidSpawnner();

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

  Vector2 _generateSpawnPosition() {
    return Vector2(10 + _random.nextDouble() * (size.x - 10 * 2), -100);
  }
}
