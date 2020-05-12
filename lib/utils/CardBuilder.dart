import 'package:flutter/material.dart';

class CardBuilder extends StatefulWidget {
  final String title;
  final String value;

  const CardBuilder({Key key, this.title, this.value}) : super(key: key);

  @override
  _CardBuilderState createState() => _CardBuilderState();
}

class _CardBuilderState extends State<CardBuilder> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 150,
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
      child: Row(

        mainAxisAlignment:MainAxisAlignment.spaceBetween ,
        children: <Widget>[
          Text(widget.title),
          SizedBox(
            height: 30,
            width: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(
                    width:140,
                    child: Text(widget.value))

              ],
            ),
          )
        ],
      ),
    );
  }
}
