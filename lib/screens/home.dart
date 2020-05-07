import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mpoil/screens/checkout.dart';
import 'package:mpoil/widgets/button.dart';
import 'package:mpoil/widgets/custom-text.dart';
import 'package:mpoil/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  DateTime picked;
  String make;
  String model;
  String engine;
  String price = 'Platinum service- basic oil change most cars \$65';
  List<DropdownMenuItem<String>> makes = [];
  List<DropdownMenuItem<String>> models = [];
  List<DropdownMenuItem<String>> engines = [];

  sendMail(String messageToSend) async {
    String username = 'mpoilservice14@gmail.com';
    String password = 'admin@MPoil123';
    final smtpServer = gmail(username, password);
    final message = Message()
        ..from = Address(username, 'Reese Mobile Oil Change Service')
        ..recipients.add('damienkenway61@gmail.com')
        ..subject = 'New Order'
        ..text = messageToSend;
    try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
        ToastBar(text: 'Schedule Successful!',color: Colors.blue.shade900).show();
      } on MailerException catch (e) {
      ToastBar(text: 'Email not sent!',color: Colors.red).show();
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
  }

  getMake() async {
    var makeSub = await Firestore.instance.collection('make').getDocuments();
    var makeList = makeSub.documents;
    make = makeList[0]['make'];
    model = makeList[0]['models'][0];
    for(int i=0;i<makeList.length;i++){
      setState(() {
        makes.add(
            DropdownMenuItem(child: CustomText(text: makeList[i]['make'],color: Colors.black,),value: makeList[i]['make'],)
        );
      });
    }
    getModel(make);
  }

  getModel(String makeName) async {
    models.clear();
    var makeSub = await Firestore.instance.collection('make').where('make',isEqualTo: makeName).getDocuments();
    var makeList = makeSub.documents;
    model = makeList[0]['models'][0];
    for(int i=0;i<makeList.length;i++){
      List modelList = makeList[i]['models'];
      for(int y=0;y<modelList.length;y++){
        setState(() {
          models.add(
              DropdownMenuItem(child: CustomText(text: modelList[y],color: Colors.black,),value: modelList[y],)
          );
        });
      }
    }
    getEngine(model);
  }

  getEngine(String modelName) async {
    engines.clear();
    var makeSub = await Firestore.instance.collection('engine').where('model',isEqualTo: modelName).getDocuments();
    var makeList = makeSub.documents;
    engine = makeList[0]['engine'][0];
    for(int i=0;i<makeList.length;i++){
      List engineList = makeList[i]['engine'];
      for(int y=0;y<engineList.length;y++){
        setState(() {
          engines.add(
              DropdownMenuItem(child: CustomText(text: engineList[y],color: Colors.black,),value: engineList[y],)
          );
        });
      }
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMake();
  }
  
  
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 720, height: 1520,allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold,fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/homeback.png'),fit: BoxFit.fitHeight)
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(50),ScreenUtil().setWidth(20),ScreenUtil().setWidth(50),0),
          child: Column(
            children: <Widget>[
              CustomText(
                text: 'Schedule your oil change from the convenience of your home and we will come to you',
                size: ScreenUtil().setSp(40),
              ),
              SizedBox(height: ScreenUtil().setHeight(65),),
              GestureDetector(
                onTap: () async {
                  picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020, 1),
                      lastDate: DateTime(2101));
                  print(picked);
                },
                child: Container(
                  width: ScreenUtil().setWidth(400),
                  height: ScreenUtil().setHeight(120),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).primaryColor
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomText(text: 'Select a date',color: Colors.black,size: ScreenUtil().setSp(40),),
                      SizedBox(width: ScreenUtil().setWidth(20),),
                      SizedBox(
                        width: ScreenUtil().setWidth(50),
                        height: ScreenUtil().setHeight(50),
                        child: Image.asset('images/calender.png'),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(35), ScreenUtil().setWidth(65), ScreenUtil().setWidth(35), 0),
                child: Container(
                  height: ScreenUtil().setHeight(120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xffE5E5E5)
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                      child: DropdownButton(
                        isExpanded: true,
                        underline: Divider(color: Color(0xffE5E5E5),height: 0,thickness: 0,),
                        items: makes,
                        onChanged:(newValue){
                          setState(() {
                            make = newValue;
                            getModel(make);
                          });
                        },
                        value: make,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(35), ScreenUtil().setWidth(35), ScreenUtil().setWidth(35), 0),
                child: Container(
                  height: ScreenUtil().setHeight(120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xffE5E5E5)
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                      child: DropdownButton(
                        isExpanded: true,
                        underline: Divider(color: Color(0xffE5E5E5),height: 0,thickness: 0,),
                        items: models,
                        onChanged:(newValue){
                          setState(() {
                            model = newValue;
                            getEngine(model);
                          });
                        },
                        value: model,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(35), ScreenUtil().setWidth(35), ScreenUtil().setWidth(35), 0),
                child: Container(
                  height: ScreenUtil().setHeight(120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xffE5E5E5)
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                      child: DropdownButton(
                        isExpanded: true,
                        underline: Divider(color: Color(0xffE5E5E5),height: 0,thickness: 0,),
                        items: engines,
                        onChanged:(newValue){
                          setState(() {
                            engine = newValue;
                          });
                        },
                        value: engine,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.fromLTRB(ScreenUtil().setWidth(35), ScreenUtil().setWidth(35), ScreenUtil().setWidth(35), 0),
                child: Container(
                  height: ScreenUtil().setHeight(120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xffE5E5E5)
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16)),
                      child: DropdownButton(
                        isExpanded: true,
                        underline: Divider(color: Color(0xffE5E5E5),height: 0,thickness: 0,),
                        items: [
                          DropdownMenuItem(child: CustomText(text: 'Platinum service- basic oil change most cars \$65',color: Colors.black,),value: 'Platinum service- basic oil change most cars \$65',),
                          DropdownMenuItem(child: CustomText(text: 'Silver service- over 75k miles- \$110',color: Colors.black,),value: 'Silver service- over 75k miles- \$110',),
                          DropdownMenuItem(child: CustomText(text: 'Gold service- full synthetic- \$155',color: Colors.black,),value: 'Gold service- full synthetic- \$155',)
                        ],
                        onChanged:(newValue){
                          setState(() {
                            price = newValue;
                          });
                        },
                        value: price,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Button(text: 'Schedule',onTap: () async {
                  ToastBar(text: 'Please wait...',color: Colors.orange).show();
                  if(picked!=null){
                    try{
                      var sub = await Firestore.instance.collection('oil').where('engine',isEqualTo: engine).getDocuments();
                      var list = sub.documents;
                      if(list.isNotEmpty){
                        List oilList = list[0]['oil'];
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String email = prefs.getString('email');
                        String location = prefs.getString('location');
                        String name = prefs.getString('name');
                        String message = "Hey, you have a new order from $name. "
                            "The $name wants to change the oil in ${DateFormat('yyyy-MM-dd').format(picked)}, and his location is $location. "
                            "You can see the detailed information about his order below.\n\n"
                            "Email:-$email\n"
                            "Make:- $make\n"
                            "Model:- $model\n"
                            "Engine:- $engine\n"
                            "Price:- $price\n\n"
                            "Here are the recommended list of oil for this:\n\n";
                            //"$oilList";

                        for(int i=0;i<oilList.length;i++){
                          message += '\t• ${oilList[i]}\n';
                        }
                        var finalPrice;
                        if(price=="Platinum service- basic oil change most cars \$65"){
                          finalPrice = 6500;
                        }
                        else if(price=="Silver service- over 75k miles- \$110"){
                          finalPrice = 11000;
                        }
                        else{
                          finalPrice = 15500;
                        }


                        print(message);
                        //sendMail(message);
                        Navigator.push(context, CupertinoPageRoute(builder: (context){
                          return Checkout(message: message,price: finalPrice,);}));
                      }
                      else{
                        ToastBar(text: 'We are sorry! We haven\'t any oil for this category!',color: Colors.red).show();
                      }

                    }
                    catch(e){
                      ToastBar(text: e.toString(),color: Colors.red).show();
                    }
                  }
                  else{
                    ToastBar(text: 'Please Select a date',color: Colors.red).show();
                  }
                },),
              )
            ],
          ),
        ),
      ),
    );
  }
}
