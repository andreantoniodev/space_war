import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:space_war/my_game.dart';

class ShootButton extends SpriteComponent with HasGameReference<MyGame>, TapCallbacks, HoverCallbacks {
  ShootButton() : super(size: Vector2.all(80));

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('shoot_button.png');
    super.onLoad();
  }

  @override
  bool onTapDown(TapDownEvent event) {
    game.player.strarShooting();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    game.player.stopShooting();
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    game.player.stopShooting();
    return true;
  }

  @override
  void onHoverEnter() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
