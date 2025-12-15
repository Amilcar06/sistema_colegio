import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'menu/menu_items.dart';

class BottomNav extends StatefulWidget {
  final List<MenuItem> menu;

  const BottomNav({super.key, required this.menu});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocation = GoRouterState.of(context).uri.path;
    final index = widget.menu.indexWhere((item) => currentLocation.startsWith(item.route));
    if (index != -1 && index != _selectedIndex) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        context.go(widget.menu[index].route);
      },
      items: widget.menu.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
