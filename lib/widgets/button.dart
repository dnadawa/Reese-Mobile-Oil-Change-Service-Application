import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'custom-text.dart';

class Button extends StatelessWidget {
  final Function onTap;
  final String text;

  const Button({Key key, this.onTap, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ScreenUtil().setWidth(420),
        height: ScreenUtil().setHeight(120),
        decoration: BoxDecoration(
            color: Color(0xffFF8A65),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white,width: 3)
        ),
        child: Center(child: CustomText(text: text,color: Colors.black,size: ScreenUtil().setSp(50),)),
      ),
    );
  }
}

