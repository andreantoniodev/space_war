import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_war/components/asteroid.dart';
import 'package:space_war/my_game.dart';

class Laser extends SpriteComponent with HasGameReference<MyGame>, CollisionCallbacks {
  Laser({required super.position, super.angle = 0}) : super(anchor: Anchor.center, priority: -1);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('laser.png');
    size *= 0.25;
    add(RectangleHitbox());
    super.onLoad();
  }

  @override
  void update(double dt) {
    position += Vector2(sin(angle), -cos(angle)) * 500 * dt;

    if (position.y < -size.y / 2) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Asteroid) {
      removeFromParent();
      other.takeDamage();
    }
    super.onCollision(intersectionPoints, other);
  }
}
