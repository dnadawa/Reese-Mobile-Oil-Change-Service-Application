import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:mpoil/screens/sign-up.dart';
import 'package:mpoil/widgets/button.dart';
import 'package:mpoil/widgets/custom-text.dart';
import 'package:mpoil/widgets/input-field.dart';
import 'package:mpoil/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class LogIn extends StatelessWidget {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReference = Firestore.instance.collection('users');

  signInWithEmail(BuildContext context) async {
    try{
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email.text, password: password.text);
      FirebaseUser user = result.user;
      print(user.uid);
      var sub = await Firestore.instance.collection('users').where('email',isEqualTo: email.text).getDocuments();
      var logged = sub.documents;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', user.email);
      prefs.setString('name', logged[0]['name']);
      prefs.setString('location', logged[0]['location']);
      Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context){
        return Home();}));
    }
    catch(E){
      print(E);
      ToastBar(color: Colors.red,text: 'Something went Wrong').show();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 720, height: 1520,allowFontScaling: false);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/logback.png'),fit: BoxFit.fill)
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: ScreenUtil.statusBarHeight,),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: ScreenUtil().setWidth(275),
                height: ScreenUtil().setHeight(225),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40))
                ),
                child: Center(child: Image.asset('images/logo.png')),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(60)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: ScreenUtil().setHeight(100),),
                      CustomText(text: 'Log into\nyour account',size: ScreenUtil().setSp(70)),
                      SizedBox(height: ScreenUtil().setHeight(100),),
                      InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                      SizedBox(height: ScreenUtil().setHeight(30),),
                      InputField(hint: 'Password',isPassword: true,controller: password,),
                      SizedBox(height: ScreenUtil().setHeight(70),),
                      GestureDetector(
                          onTap: (){
                            Navigator.push(context, CupertinoPageRoute(builder: (context){
                              return SignUp();}));
                          },
                          child: CustomText(text: 'Create an account',size: ScreenUtil().setSp(35),)),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Button(text: 'Login',onTap: ()=>signInWithEmail(context),),
            ),
          ],
        ),
      ),
    );
  }
}
