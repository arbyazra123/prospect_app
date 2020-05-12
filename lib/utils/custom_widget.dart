

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class CustomWidget{
  static showLoadingDialog(BuildContext context){
    return showDialog(
        context: context,
        barrierDismissible:false ,
        child: Center(
          child: CircularProgressIndicator(),));
  }

  static showFlushBar(BuildContext context,String message,{ int duration=2,Color color = Colors.white}){
    return Flushbar(

      message: message,
      routeColor: color,
      duration: Duration(seconds: duration),
    )..show(context);
  }

}