import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:space_war/my_game.dart';

enum ExplosionType { dust, smoke, fire }

class Explosion extends PositionComponent with HasGameReference<MyGame> {
  Explosion({required super.position, required this.explosionType, required this.explosionSize}) : super(size: Vector2.all(100));

  final ExplosionType explosionType;
  final double explosionSize;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    _createFlash();
    _createParticles();
    add(RemoveEffect(delay: 1));
    super.onLoad();
  }

  void _createFlash() {
    final CircleComponent flash = CircleComponent(
      radius: explosionSize * 0.6,
      paint: Paint()..color = const Color.fromRGBO(255, 255, 255, 1),
      anchor: Anchor.center,
    );
    final OpacityEffect fadeOutEffect = OpacityEffect.fadeOut(EffectController(duration: 0.3));
    flash.add(fadeOutEffect);
    add(flash);
  }

  List<Color> _generateColors() {
    switch (explosionType) {
      case ExplosionType.dust:
        return [const Color(0xFF5A4632), const Color(0xFF6b543d), const Color(0xFF8A6E50)];
      case ExplosionType.smoke:
        return [const Color(0xFF404040), const Color(0xFF606060), const Color(0xFF808080)];
      case ExplosionType.fire:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500), const Color(0xFFFFC107)];
    }
  }

  void _createParticles() {
    final List<Color> colors = _generateColors();
    final ParticleSystemComponent particles = ParticleSystemComponent(
      particle: Particle.generate(
        count: 8 + _random.nextInt(5),
        generator: (index) {
          return MovingParticle(
            child: CircleParticle(
              paint: Paint()..color = colors[_random.nextInt(colors.length)].withValues(alpha: 0.4 + _random.nextDouble() * 0.4),
              radius: explosionSize * (0.1 + _random.nextDouble() * 0.05),
            ),
            to: Vector2((_random.nextDouble() - 0.05) * explosionSize * 2, (_random.nextDouble() - 0.05) * explosionSize * 2),
            lifespan: 0.5 + _random.nextDouble() * 0.5,
          );
        },
      ),
    );
    add(particles);
  }
}
