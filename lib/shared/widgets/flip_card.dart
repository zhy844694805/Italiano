import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final bool flipOnTap;
  final ValueChanged<bool>? onFlip;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 600),
    this.flipOnTap = true,
    this.onFlip,
  });

  @override
  State<FlipCard> createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleCard() {
    if (_controller.isAnimating) return;

    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    setState(() {
      _isFront = !_isFront;
    });

    widget.onFlip?.call(_isFront);
  }

  void flip() {
    toggleCard();
  }

  void reset() {
    if (!_isFront) {
      _controller.reverse();
      setState(() {
        _isFront = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.flipOnTap ? toggleCard : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(angle);

          // 判断显示正面还是背面
          final showFront = angle < math.pi / 2;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: showFront
                ? widget.front
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}
