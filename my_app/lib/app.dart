import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'shell/root_shell.dart';

// importing my feature pages
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/map/presentation/pages/campus_map_page.dart';
import 'features/campus/presentation/pages/campus_info_page.dart';
import 'features/timetable/presentation/pages/timetable_page.dart';
import 'features/auth/presentation/pages/login_page.dart'; //new import for login
import 'features/auth/presentation/controllers/auth_router_notifier.dart'; //import for route guard

class MyApp extends ConsumerWidget { // consumer widget means it can read Riverpod providers.
  const MyApp({super.key}); // passes the key to ConsumerWidget so Flutter can track this widget in the widget tree.

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // build method: Every widget has one. Flutter calls it whenever it needs to draw or redraw the widget on the screen. 
    // context gives info abt the current widget’s place in the widget tree.
    // ref comes from ConsumerWidget (Riverpod). It lets this widget read or watch providers.

    final authNotifier = AuthRouterNotifier(); //listens for login/logout events and triggers router refresh

    final router = GoRouter( // modern navigation system instead of Navigator.push
      initialLocation: '/chat', // where we start
      refreshListenable: authNotifier, //tells GoRouter to rebuild when auth state changes (login/logout)
      
      //redirect: controls access based on whether user is signed in
      redirect: (context, state) {
        final loggedIn = authNotifier.isLoggedIn;
        final goingToLogin = state.matchedLocation == '/login';

        // if NOT logged in and NOT going to login page → redirect to /login
        if (!loggedIn && !goingToLogin) return '/login';

        // if already logged in but trying to access login → redirect to /chat
        if (loggedIn && goingToLogin) return '/chat';

        return null; // otherwise, stay on the current route
      },

      routes: [ 
        //Login route (public)
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginPage(),
        ),

        //Protected routes (inside ShellRoute)
        ShellRoute( // used in the bottom navbar as it will not disappear.
          // inside the ShellRoute (the permanent container), we define GoRoutes,
          // and each one changes the child that appears inside the shell.
          builder: (context, state, child) => RootShell(child: child),  
          // injects the current page here / RootShell is the persistent container (bottom navbar)
          // child is the current page inside RootShell
          routes: [ // I have defined a list of GoRoute objects
            GoRoute(path: '/chat', builder: (_, __) => const ChatPage()),
            GoRoute(path: '/map', builder: (_, __) => const CampusMapPage()),
            GoRoute(path: '/campus', builder: (_, __) => const CampusInfoPage()),
            GoRoute(path: '/timetable', builder: (_, __) => const TimetablePage()),
          ],
        ),
      ],
    );

    return ProviderScope(
      child: MaterialApp.router( 
        // main app container. Gives access to all the Flutter Material features (app bar...).
        // .router is used because we’re using GoRouter for navigation instead of older Navigator.
        // MaterialApp.router(...) = the whole app UI that knows how to navigate between pages.
        debugShowCheckedModeBanner: false,
        title: 'Mobile Induction e-Kit', // name of app
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
        ),
        routerConfig: router, // tell it how to move between pages. (See above, we defined this earlier line 30)
      ),
    );
  }
}
