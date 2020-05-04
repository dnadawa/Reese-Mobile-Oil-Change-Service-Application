import 'package:flutter/material.dart';
import 'package:mpoil/screens/home.dart';
import 'package:mpoil/screens/login.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffFFEB3B)
      ),
      home: LogIn(),
    );
  }
}
