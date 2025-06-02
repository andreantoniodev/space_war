import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:space_war/components/laser.dart';
import 'package:space_war/my_game.dart';

class Player extends SpriteComponent with HasGameReference<MyGame>, KeyboardHandler {
  bool _isShooting = false;
  final double _fireCooldown = 0.2;
  double _elapsedFireTimer = 0;
  final Vector2 _keyboarMovement = Vector2.zero();

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('player_blue_on0.png');

    size *= 0.3;
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final Vector2 movement = game.joystick.relativeDelta + _keyboarMovement;
    position += movement.normalized() * 200 * dt;

    _handleScreenBounds();

    _elapsedFireTimer += dt;
    if (_isShooting && _elapsedFireTimer >= _fireCooldown) {
      _fireLaser();
      _elapsedFireTimer = 0;
    }
  }

  void _handleScreenBounds() {
    final double screenWidth = game.size.x;
    final double screenHeight = game.size.y;

    position.y = clampDouble(position.y, size.y / 2, screenHeight - size.y / 2);

    if (position.x < 0) {
      position.x = screenWidth;
    } else if (position.x > screenWidth) {
      position.x = 0;
    }
  }

  void strarShooting() {
    _isShooting = true;
  }

  void stopShooting() {
    _isShooting = false;
  }

  void _fireLaser() {
    game.add(Laser(position: position.clone() + Vector2(0, -size.y / 2)));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboarMovement.x = 0;
    _keyboarMovement.x += keysPressed.contains(LogicalKeyboardKey.altLeft) ? -1 : 0;
    _keyboarMovement.x += keysPressed.contains(LogicalKeyboardKey.altRight) ? 1 : 0;

    _keyboarMovement.y = 0;
    _keyboarMovement.y += keysPressed.contains(LogicalKeyboardKey.arrowUp) ? -1 : 0;
    _keyboarMovement.y += keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 1 : 0;
    return true;
  }
}
