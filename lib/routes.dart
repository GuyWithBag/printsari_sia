import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:printsari_sia/controllers/controllers.dart';
import 'package:printsari_sia/shared/page_transitions/page_transitions.dart';
import 'package:printsari_sia/ui/ui.dart';
import 'pages/pages.dart';

GoRouter routes = GoRouter(
  routes: [
    ShellRoute(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, state) {
            return slideTransition(
              state: state,
              toLeft: false,
              child: Home(key: state.pageKey),
            );
          },
          routes: const [
            // GoRoute(
            //   path: 'room/:roomid',
            //   pageBuilder: (context, state) {
            //     final nav = context.read<NavigationController>();
            //     nav.addOnGoListener(
            //       (toLocation) {
            //         if (!toLocation.contains('room')) {
            //           return;
            //         }
            //         final appBarController = context.read<AppBarController>();
            //         final scrollController = appBarController.controller;
            //         appBarController.setPinned(false);
            //         scrollController?.animateTo(
            //           0,
            //           duration: const Duration(milliseconds: 500),
            //           curve: Curves.decelerate,
            //         );
            //       },
            //     );
            //     return slideTransition(
            //       state: state,
            //       child: Room(
            //         key: state.pageKey,
            //         id: state.pathParameters['roomid'],
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ],
      builder: (context, _, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<NavigationController>(
              create: (_) => NavigationController(),
            ),
          ],
          builder: (context, _) {
            return AppScaffold(child: child);
          },
        );
      },
    ),
  ],
);
