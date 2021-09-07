import 'package:flutter/material.dart';
import 'package:flutter_auth_app/providers/auth_provider.dart';
import 'package:flutter_auth_app/utils/style.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String name = '';
  getName() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    name = storage.getString('name') ?? '';
    setState(() {});
  }

  @override
  void initState() {
    getName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(name, style: Styles.h1,),
            SizedBox(height: 50.0,),
            Divider(),
            SizedBox(height: 50.0,),
            ElevatedButton(
              child: Text('Log out'),
              onPressed: () => provider.logOut(),
            ),
          ],
        ),
      ),
    );
  }
}
