import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:space_war/my_game.dart';

void main() {
  final MyGame game = MyGame();
  runApp(GameWidget(game: game));
}
