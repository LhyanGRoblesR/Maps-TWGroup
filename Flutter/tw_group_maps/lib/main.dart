import 'package:flutter/material.dart';
import 'package:tw_group_maps/Auth/login.dart';
import 'package:tw_group_maps/Maps/maps.dart';
import 'package:tw_group_maps/Utils/validate_token.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/tokenValidate',
      routes: {
        '/tokenValidate': (context) => const TokenValidate(),
        '/login': (context) => Login(),
        '/maps': (context) => const Maps(),
      },
    );
  }
}


class TokenValidate extends StatelessWidget {
  const TokenValidate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ValidateToken.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data == true) {
            return const Maps();
          } else {
            return Login();
          }
        }
      },
    );
  }
}