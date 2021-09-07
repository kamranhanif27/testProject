import 'package:flutter/material.dart';
import 'package:flutter_auth_app/providers/auth_provider.dart';
import 'package:flutter_auth_app/screens/login_screen.dart';
import 'package:flutter_auth_app/screens/main_screen.dart';
import 'package:flutter_auth_app/screens/widgets/loading.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Router(),
      ),
    );
  }
}


class Router extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);

    return Consumer<AuthProvider>(
      builder: (context, user, child) {
        print('Status: ${user.status}');
        switch (user.status) {
          case Status.Uninitialized:
            return Loading();
          case Status.Unauthenticated:
            return LogIn();
          case Status.Authenticated:
            return MainScreen();
          default:
            return LogIn();
        }
      },
    );
  }
}

