import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:space_war/components/explosion.dart';
import 'package:space_war/my_game.dart';

class Asteroid extends SpriteComponent with HasGameReference<MyGame> {
  Asteroid({required super.position, double size = _maxSize}) : super(size: Vector2.all(120), anchor: Anchor.center, priority: -1) {
    _velocity = _generateVelocity();
    _originalVelocity.setFrom(_velocity);
    _spinSpeed = _random.nextDouble() * 1.5 - 0.75;
    _health = size / _maxSize * _maxHealth;

    add(CircleHitbox());
  }

  final Random _random = Random();
  static const double _maxSize = 120;
  late Vector2 _velocity;
  final Vector2 _originalVelocity = Vector2.zero();
  late double _spinSpeed;
  final double _maxHealth = 3;
  late double _health;
  bool _isKnockBack = false;

  @override
  Future<void> onLoad() async {
    final int imageNum = _random.nextInt(3) + 1;
    sprite = await game.loadSprite('asteroid$imageNum.png');
    super.onLoad();
  }

  @override
  void update(double dt) {
    position += _velocity * dt;
    _handleScreenBounds();

    angle += _spinSpeed * dt;

    super.update(dt);
  }

  Vector2 _generateVelocity() {
    final double forceFactor = _maxSize / size.x;
    return Vector2(_random.nextDouble() * 120 - 60, 100 + _random.nextDouble() * 50) * forceFactor;
  }

  void _handleScreenBounds() {
    if (position.y > game.size.y + size.y / 2) {
      removeFromParent();
    }
    final double screenWidth = game.size.x;

    if (position.x < -size.x / 2) {
      position.x = screenWidth + size.x / 2;
    } else if (position.x > screenWidth + size.x / 2) {
      position.x = -size.x / 2;
    }
  }

  void takeDamage() {
    _health--;

    if (_health <= 0) {
      removeFromParent();
      _createExplosion();
    } else {
      _flashWhite();
      _applyKnockBack();
    }
  }

  void _flashWhite() {
    final ColorEffect flashEffect = ColorEffect(
      const Color.fromRGBO(255, 255, 255, 1),
      EffectController(duration: 0.1, alternate: true, curve: Curves.easeInOut),
    );
    add(flashEffect);
  }

  void _applyKnockBack() {
    if (_isKnockBack) return;

    _velocity.setZero();
    final MoveByEffect knockBackEffect = MoveByEffect(Vector2(0, -20), EffectController(duration: 0.1), onComplete: _restoreVelocity);
    add(knockBackEffect);
  }

  void _restoreVelocity() {
    _velocity.setFrom(_originalVelocity);

    _isKnockBack = false;
  }

  void _createExplosion() {
    final Explosion explosion = Explosion(position: position.clone(), explosionType: ExplosionType.dust, explosionSize: size.x);
    game.add(explosion);
  }
}
