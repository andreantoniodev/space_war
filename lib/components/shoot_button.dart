import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:space_war/my_game.dart';

class ShootButton extends SpriteComponent with HasGameReference<MyGame>, TapCallbacks {
  ShootButton() : super(size: Vector2.all(80));

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('shoot_button.png');
    super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.strarShooting();
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.stopShooting();
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    game.player.stopShooting();
    super.onTapCancel(event);
  }
}
