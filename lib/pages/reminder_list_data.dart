
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prospek/db/DatabaseHelper.dart';
import 'package:prospek/main.dart';
import 'package:prospek/model/Notif.dart';
import 'package:prospek/model/Prospect.dart';

import 'detail_data.dart';

class ReminderListData extends StatefulWidget {
  final MyAppState parent;

  const ReminderListData({Key key,@required this.parent}) : super(key: key);
  @override
  _ReminderListDataState createState() => _ReminderListDataState();
}

class _ReminderListDataState extends State<ReminderListData> {
  static final flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool loading = false;

  ScrollController scrollController;
  Prospect current;
  @override
  void initState() {
    scrollController= new ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 15),
          child: TextFormField(
            controller: widget.parent.searchNotifications,
            decoration: InputDecoration(
                suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: (){}
                ),
                hintText: "Search..."),
          ),
        ),
        Expanded(
          child: loading?Center(child: CircularProgressIndicator(),): widget.parent.dataNotificationJson.length!=0?  ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              itemCount: widget.parent.dataNotificationJson.length,
              itemBuilder: (context, i) {
                var data = widget.parent.dataNotificationJson[i];
                return widget.parent.filterNotif ==null||widget.parent.filterNotif==""?
                _buildItemList(data)
                    :data.title.toLowerCase().contains(widget.parent.filterNotif.toLowerCase())? _buildItemList(data):new Container();
              }
          ): Center(child: Text("Data Kosong"),),
        )
      ],
    );
  }

  Widget _buildItemList(Notif data){
    return new Container(
      child: new GestureDetector(
        onTap: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => new Detail(
              id: data.id.toString(),
            ))),
        child: new Card(
          color: Colors.white,
          child: new ListTile(
            title: new Text(data.title),
            leading: new Icon(Icons.alarm),
            subtitle: new Text("Hari : ${getDay(int.parse(data.day))} \nWaktu: ${data.time} \n " ),
            trailing: InkWell(
                onTap: (){

                  _showDeleteDialog(data);
                },
                child: new Icon(Icons.delete)),
            isThreeLine: true,

          ),
        ),
      ),
    );
  }

  String getDay(int day){
    List days = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    return days[day-1];
  }

  void _showDeleteDialog(Notif data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Apakah yakin ingin menghapus?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
                onPressed: () async{


                  Future.wait(List.generate(1, (index) async{
                    await DatabaseHelper.instance.delete(data.notifId.toString());
                    await flutterLocalNotificationsPlugin.cancel(int.parse(data.notifId));
                  })).then((value){
                    setState(() {
                    widget.parent.dataNotificationJson.remove(data);
                    Navigator.of(context).pop();
                    });
                    widget.parent.setState(() { });

                  });


                },
                child: Text("Yes"))
          ],
        );
      },
    );
  }
}
