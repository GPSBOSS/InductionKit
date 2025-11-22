import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootShell extends StatelessWidget {
  final Widget child;
  const RootShell({super.key, required this.child});

  static const _paths = ['/chat', '/map', '/campus', '/timetable']; //this is a list

  int _indexFromLocation(String location) {
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/campus')) return 2;
    if (location.startsWith('/timetable')) return 3;
    return 0; // else default to /chat
  }

  @override
  Widget build(BuildContext context) { 
    final location = GoRouterState.of(context).uri.toString(); //GoRouterState.of(context).uri.toString() → gets the current page route (/chat, /map, etc.). toString ensures it goes from /chat to "/chat"
    final currentIndex = _indexFromLocation(location);  //Then _indexFromLocation(location) → determines which nav icon should be selected.

    return Scaffold(
      body: child, //current page that appears above nav bar. If user is on /chat, child = ChatPage()
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex, //it makes the icon ACTIVE
        onDestinationSelected: (i) {
          final target = _paths[i];
          if (target != location) context.go(target);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'Campus'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), label: 'Timetable'),
        ],
      ),
    );
  }
}
