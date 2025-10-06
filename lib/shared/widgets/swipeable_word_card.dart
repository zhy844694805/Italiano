import 'package:flutter/material.dart';
import '../models/word.dart';
import 'flip_card.dart';

enum SwipeDirection { left, right, none }

class SwipeableWordCard extends StatefulWidget {
  final Word word;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onAudioTap;
  final bool showAudioButton;

  const SwipeableWordCard({
    super.key,
    required this.word,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onAudioTap,
    this.showAudioButton = true,
  });

  @override
  State<SwipeableWordCard> createState() => _SwipeableWordCardState();
}

class _SwipeableWordCardState extends State<SwipeableWordCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _swipeController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset.dx.abs() > threshold) {
      // 触发滑动
      final direction = _dragOffset.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      _animateSwipe(direction);
    } else {
      // 回弹
      _resetPosition();
    }
  }

  void _animateSwipe(SwipeDirection direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final endOffset = direction == SwipeDirection.right
        ? Offset(screenWidth * 1.5, _dragOffset.dy)
        : Offset(-screenWidth * 1.5, _dragOffset.dy);

    _swipeAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx * 0.0003,
      end: direction == SwipeDirection.right ? 0.3 : -0.3,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));

    _swipeController.forward(from: 0).then((_) {
      if (direction == SwipeDirection.right) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
      _dragOffset = Offset.zero;
      _swipeController.reset();
    });
  }

  void _resetPosition() {
    _swipeAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx * 0.0003,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.elasticOut,
    ));

    _swipeController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
      });
      _swipeController.reset();
    });
  }

  Color _getSwipeIndicatorColor() {
    if (_dragOffset.dx > 50) {
      return Colors.green.withValues(alpha: (_dragOffset.dx / 150).clamp(0.0, 1.0));
    } else if (_dragOffset.dx < -50) {
      return Colors.red.withValues(alpha: (-_dragOffset.dx / 150).clamp(0.0, 1.0));
    }
    return Colors.transparent;
  }

  IconData _getSwipeIcon() {
    if (_dragOffset.dx > 50) return Icons.check_circle;
    if (_dragOffset.dx < -50) return Icons.close;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _swipeController,
        builder: (context, child) {
          final offset = _swipeController.isAnimating
              ? _swipeAnimation.value
              : _dragOffset;
          final rotation = _swipeController.isAnimating
              ? _rotationAnimation.value
              : _dragOffset.dx * 0.0003;
          final scale = _isDragging ? 0.95 : 1.0;

          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Stack(
                  children: [
                    // 主卡片
                    FlipCard(
                      key: _flipCardKey,
                      front: _buildCardFace(
                        child: _buildFrontContent(theme, colorScheme),
                        color: colorScheme.surface,
                      ),
                      back: _buildCardFace(
                        child: _buildBackContent(theme, colorScheme),
                        color: colorScheme.primaryContainer,
                      ),
                    ),

                    // 滑动指示器
                    if (_isDragging)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getSwipeIndicatorColor(),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            _getSwipeIcon(),
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFace({required Widget child, required Color color}) {
    return Container(
      width: double.infinity,
      height: 500,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFrontContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 发音按钮
        if (widget.showAudioButton)
          IconButton(
            icon: Icon(Icons.volume_up, size: 32, color: colorScheme.primary),
            onPressed: widget.onAudioTap,
          ),
        const SizedBox(height: 20),

        // 意大利语单词
        Text(
          widget.word.italian,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // IPA 发音
        if (widget.word.pronunciation != null)
          Text(
            '/${widget.word.pronunciation}/',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),

        const SizedBox(height: 40),

        // 提示文本
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '点击卡片查看释义',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        const Spacer(),

        // 级别标签
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTag(widget.word.level, colorScheme.primary),
              const SizedBox(width: 8),
              _buildTag(widget.word.category, colorScheme.secondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackContent(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 中文释义
          Center(
            child: Text(
              widget.word.chinese,
              style: theme.textTheme.displayMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (widget.word.english != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.word.english!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 40),

          // 例句
          if (widget.word.examples.isNotEmpty) ...[
            Text(
              '例句：',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.word.examples.take(2).map((example) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '• $example',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                )),
          ],

          const Spacer(),

          // 提示
          Center(
            child: Text(
              '左滑不认识 ← | → 右滑认识',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
