import 'package:flutter/material.dart';

class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final Function()? onTap;
  final bool enableHoverEffect;
  final Duration hoverDuration;
  
  const HoverBuilder({
    Key? key,
    required this.builder,
    this.onTap,
    this.enableHoverEffect = true,
    this.hoverDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  _HoverBuilderState createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _updateHoverState(true),
      onExit: (_) => _updateHoverState(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.hoverDuration,
          curve: Curves.easeInOut,
          transform: _isHovered && widget.enableHoverEffect 
              ? (Matrix4.identity()..translate(0, -2)) 
              : Matrix4.identity(),
          child: Material(
            color: Colors.transparent,
            child: widget.builder(context, _isHovered),
          ),
        ),
      ),
    );
  }

  void _updateHoverState(bool isHovered) {
    if (widget.enableHoverEffect) {
      setState(() {
        _isHovered = isHovered;
      });
    }
  }
}
