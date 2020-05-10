import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mpoil/widgets/button.dart';
import 'package:mpoil/widgets/toast.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class Checkout extends StatefulWidget {
  final String message;
  final int price;

  const Checkout({Key key, this.message, this.price}) : super(key: key);
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  String cardNumber ='';
  String expiryDate='';
  String cardHolderName='';
  String cvvCode = '';
  bool isCvvFocused = false;

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "pk_test_445cyWSg9mtcupqL7EkCT9wt00bAEcinGT",
        androidPayMode: 'test',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 720, height: 1520,allowFontScaling: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.bold,fontSize: 25),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('images/logback.png'),fit: BoxFit.fill)
        ),

        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: CreditCardForm(
                  textColor: Colors.white,
                  themeColor: Colors.white,
                  cardHolderName: cardHolderName,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
              ),
            ),
//            Expanded(child: Container()),
            Align(
                alignment: Alignment.bottomCenter,
                child: Button(text: 'Pay',onTap: (){
                  ToastBar(text: 'Please wait',color: Colors.orange).show();
                  try{
                    final CreditCard testCard = CreditCard(
                      number: cardNumber,
                      expMonth: int.parse(expiryDate[0]+expiryDate[1]),
                      expYear: int.parse(expiryDate[3]+expiryDate[4]),
                      cvc: cvvCode,
                    );

                    //print(int.parse(expiryDate[3]+expiryDate[4]));
                    StripePayment.createTokenWithCard(
                      testCard,
                    ).then((token) async {
                      try{
                        var response = await http.post('https://api.stripe.com/v1/charges',
                          body: {'amount': '${(widget.price).toString()}','currency': 'usd',"source": token.tokenId},
                          headers: {'Authorization': "Bearer sk_test_jrnjAy3DKPoiu4QNTRyrMFsa007bnR4V2i"},
                        );
                        print('Response status: ${response.statusCode}');
                        print('Response body: ${response.body}');

                        if(response.statusCode == 200){
                          await ToastBar(text: 'Payment Completed!',color: Colors.green).show();
                          sendMail(widget.message);
                          Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context){
                            return Home();}));
                        }
                        else{
                          ToastBar(text: 'Something went Wrong While Processing the Payment',color: Colors.red).show();
                        }
                      }
                      catch(e){
                        ToastBar(text: 'Something went Wrong While Processing the Payment',color: Colors.red).show();
                      }
                    });
                  }
                  catch(e){

                  }
                },)),
          ],
        ),

      ),

    );
  }
}
