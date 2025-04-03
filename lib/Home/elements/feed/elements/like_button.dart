import 'package:flutter/material.dart';
import 'dart:math';

class ExplodingHeartsButton extends StatefulWidget {
  @override
  _ExplodingHeartsButtonState createState() => _ExplodingHeartsButtonState();
}

class _ExplodingHeartsButtonState extends State<ExplodingHeartsButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Widget> _heartWidgets = [];
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateHearts() {
    setState(() {
      _liked = !_liked;
      if (_liked) {
        _generateHearts();
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse(from: 1.0);
      }
    });
  }

  void _generateHearts() {
    final random = Random();
    _heartWidgets.clear();

    for (int i = 0; i < 20; i++) {
      final randomSize = random.nextDouble() * 20 + 10;
      final randomDuration = random.nextDouble() * 0.5 + 0.5;

      final heart = Positioned(
        left: 100,
        top: 200,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value - (i * 0.03);

            return Opacity(
              opacity: 1 - progress,
              child: Transform.translate(
                offset: Offset(
                  cos(i.toDouble()) * progress * 100,
                  sin(i.toDouble()) * progress * 100,
                ),
                child: Transform.scale(
                  scale: 1 - progress,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: randomSize,
                  ),
                ),
              ),
            );
          },
        ),
      );

      _heartWidgets.add(heart);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animateHearts,
      child: Stack(
        children: [
          Container(
            width: 200,
            height: 400,
            alignment: Alignment.center,
            child: Icon(
              _liked ? Icons.favorite : Icons.favorite_border,
              color: _liked ? Colors.red : Colors.grey,
              size: 80,
            ),
          ),
          ..._heartWidgets,
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Exploding Hearts Button')),
      body: Center(
        child: ExplodingHeartsButton(),
      ),
    ),
  ));
}
