import 'package:flutter/cupertino.dart';

class AutoScrollRow extends StatefulWidget {
  final List<Widget> children;

  const AutoScrollRow({
    super.key,
    required this.children,
  });

  @override
  State<AutoScrollRow> createState() => _AutoScrollRowState();
}

class _AutoScrollRowState extends State<AutoScrollRow> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() async {
    while (mounted) {

      if (!_controller.hasClients) {
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
        continue;
      }

      final max =
          _controller.position.maxScrollExtent;

      await _controller.animateTo(
        max,
        duration: const Duration(seconds: 10),
        curve: Curves.linear,
      );

      if (!mounted || !_controller.hasClients) {
        return;
      }

      _controller.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        children: widget.children,
      ),
    );
  }
}