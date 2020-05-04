import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:mpoil/widgets/button.dart';
import 'package:mpoil/widgets/custom-text.dart';
import 'package:mpoil/widgets/input-field.dart';
import 'package:mpoil/widgets/toast.dart';

class SignUp extends StatelessWidget {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController name = TextEditingController();

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReference = Firestore.instance.collection('users');

  signUp() async {
    if(email.text!='' && password.text!='' && location.text!=''){
      try{
        AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email.text, password: password.text);
        FirebaseUser user = result.user;
        print(user.uid);

        await collectionReference.document(email.text).setData({
          'name': name.text,
          'email': email.text,
          'location': location.text
        });

        email.clear();
        password.clear();
        ToastBar(color: Colors.green,text: 'Signed Up Successfully!').show();
      }
      catch(E){
        ToastBar(color: Colors.red,text: 'Something Went Wrong!').show();
        print(E);
      }
    }else{
      ToastBar(color: Colors.red,text: 'Please Fill all the Fields!').show();
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 720, height: 1520,allowFontScaling: false);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: ScreenUtil.screenHeight,
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
                      CustomText(text: 'Create your\naccount',size: ScreenUtil().setSp(70)),
                      SizedBox(height: ScreenUtil().setHeight(100),),
                      InputField(hint: 'Name',controller: name,),
                      SizedBox(height: ScreenUtil().setHeight(30),),
                      InputField(hint: 'Email',type: TextInputType.emailAddress,controller: email,),
                      SizedBox(height: ScreenUtil().setHeight(30),),
                      InputField(hint: 'Password',isPassword: true,controller: password,),
                      SizedBox(height: ScreenUtil().setHeight(30),),
                      InputField(hint: 'Location',controller: location,),
                      SizedBox(height: ScreenUtil().setHeight(70),),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Button(text: 'Signup',onTap: ()=>signUp(),),
            ),
          ],
        ),
      ),
    );
  }
}
