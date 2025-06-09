import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:space_war/components/asteroid.dart';
import 'package:space_war/components/bomb.dart';
import 'package:space_war/components/explosion.dart';
import 'package:space_war/components/laser.dart';
import 'package:space_war/components/pickup.dart';
import 'package:space_war/components/shield.dart';
import 'package:space_war/my_game.dart';

class Player extends SpriteAnimationComponent with HasGameReference<MyGame>, KeyboardHandler, CollisionCallbacks {
  Player() {
    _explosionTimer = Timer(0.1, onTick: _createRandomExplosion, repeat: true, autoStart: false);
    _laserPowerupTimer = Timer(10, autoStart: false);
  }

  bool _isShooting = false;
  final double _fireCooldown = 0.2;
  double _elapsedFireTimer = 0;
  final Vector2 _keyboarMovement = Vector2.zero();
  bool _isDestroyed = false;
  final Random _random = Random();
  late Timer _explosionTimer;
  late Timer _laserPowerupTimer;
  Shield? activeShield;
  late String _color;

  @override
  Future<void> onLoad() async {
    _color = game.playerColors[game.playerColorIndex];

    animation = await _loadAnimation();

    size *= 0.3;

    add(RectangleHitbox.relative(Vector2(0.6, 0.9), parentSize: size, anchor: Anchor.center));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isDestroyed) {
      _explosionTimer.update(dt);
      return;
    }

    if (_laserPowerupTimer.isRunning()) {
      _laserPowerupTimer.update(dt);
    }

    final Vector2 movement = game.joystick.relativeDelta + _keyboarMovement;
    position += movement.normalized() * 250 * dt;

    _handleScreenBounds();

    _elapsedFireTimer += dt;
    if (_isShooting && _elapsedFireTimer >= _fireCooldown) {
      _fireLaser();
      _elapsedFireTimer = 0;
    }
  }

  Future<SpriteAnimation> _loadAnimation() async {
    return SpriteAnimation.spriteList(
      [await game.loadSprite('player_${_color}_on0.png'), await game.loadSprite('player_${_color}_on1.png')],
      stepTime: 0.1,
      loop: true,
    );
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

    if (_laserPowerupTimer.isRunning()) {
      game.add(Laser(position: position.clone() + Vector2(0, -size.y / 2), angle: 15 * degrees2Radians));
      game.add(Laser(position: position.clone() + Vector2(0, -size.y / 2), angle: -15 * degrees2Radians));
    }
  }

  void _handleDestruction() async {
    animation = SpriteAnimation.spriteList([await game.loadSprite('player_${_color}_off.png')], stepTime: double.infinity);
    add(ColorEffect(const Color.fromRGBO(255, 255, 255, 1), EffectController(duration: 0)));
    add(OpacityEffect.fadeOut(EffectController(duration: 0.5), onComplete: () => _explosionTimer.stop()));
    add(MoveEffect.by(Vector2(0, 200), EffectController(duration: 3)));
    add(RemoveEffect(delay: 1, onComplete: () => game.playerDied()));

    _isDestroyed = true;

    _explosionTimer.start();
  }

  void _createRandomExplosion() {
    final Vector2 explosionPosition = Vector2(
      position.x - size.y / 2 + _random.nextDouble() * size.x,
      position.y - size.y / 2 + _random.nextDouble() * size.y,
    );

    final ExplosionType explosionType = _random.nextBool() ? ExplosionType.smoke : ExplosionType.fire;
    final Explosion explosion = Explosion(position: explosionPosition, explosionType: explosionType, explosionSize: size.x * 0.7);
    game.add(explosion);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_isDestroyed) return;
    if (other is Asteroid) {
      if (activeShield == null) _handleDestruction();
    } else if (other is Pickup) {
      other.removeFromParent();
      game.incrementScore(1);

      switch (other.pickupType) {
        case PickupType.laser:
          _laserPowerupTimer.start();
          break;
        case PickupType.bomb:
          game.add(Bomb(position: position.clone()));
          break;
        case PickupType.shield:
          if (activeShield != null) {
            activeShield!.removeFromParent();
          }
          activeShield = Shield();
          add(activeShield!);
          break;
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboarMovement.x = 0;
    _keyboarMovement.x += keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    _keyboarMovement.x += keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;

    _keyboarMovement.y = 0;
    _keyboarMovement.y += keysPressed.contains(LogicalKeyboardKey.arrowUp) ? -1 : 0;
    _keyboarMovement.y += keysPressed.contains(LogicalKeyboardKey.arrowDown) ? 1 : 0;

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      strarShooting();
    } else if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.space) {
      stopShooting();
    }

    return true;
  }
}
