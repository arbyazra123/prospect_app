import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:prospek/db/DatabaseHelper.dart';
import 'package:prospek/pages/edit_data.dart';
import 'package:prospek/main.dart';
import 'package:prospek/model/Notif.dart';
import 'package:prospek/model/Prospect.dart';
import 'package:prospek/utils/CardBuilder.dart';
import 'package:prospek/utils/Constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class Detail extends StatefulWidget {
  final String id;

  const Detail({Key key, this.id}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  //GlobalVariable
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Prospect dataJson;
  bool loading = false;
  int selectedDay = 2;
  bool isReminderOn = false;
  bool _validate =false;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void getData() async {
    setState(() {
      loading = true;
    });
    var r = await http
        .post(Constants.GET_PROSPECT_BY_ID, body: {"id": widget.id.toString()});
    var data = jsonDecode(r.body);
    print(widget.id);
    if (r.statusCode == 200) {
      dataJson = Prospect.fromJson(data);
      selectedDay = new DateTime.now().weekday+1;


    }
    setState(() {
//      var hari_bagi = dataJson.created_at.split(" ");
//      var hari_final = DateTime.parse(hari_bagi[0]).weekday;
//
//      if(hari_final+1>7){
//        selectedDay=1;
//      } else {
//        selectedDay=hari_final;
//      }
      checkNotif();
      loading = false;
    });
  }

  void checkNotif() async{
    var r = await DatabaseHelper.instance.getData(widget.id);
    List<Notif> a=[];
    setState(() {
      if(r.length==0){
        isReminderOn=false;
      } else {
        for(var i=0;i<r.length;i++){
          a.add(Notif.fromjson(r[i]));
        }

        selectedDay = int.parse(a[0].day);
        notifdate.text = a[0].time;
        dateForNotif = DateFormat("HH:mm").parse(a[0].time);
        isReminderOn=true;
      }
    });
    print(r);
  }

  //Show Delete Dialog
  void _showDeleteDialog() {
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
                  setState(() {
                    loading=true;
                  });
                  await DatabaseHelper.instance.delete(dataJson.id
                      .toString());
                  checkNotif();
                  await flutterLocalNotificationsPlugin.cancel(
                      int.parse(dataJson.id));
                  setState(() {
                    loading=false;
                    notifdate.text = "";
                    checkNotif();
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Yes"))
          ],
        );
      },
    );
  }
  //Show Update Dialog
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Text("Apakah yakin ingin mengubah?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
                onPressed: () async{
                  setState(() {
                    loading=true;
                  });
                  await flutterLocalNotificationsPlugin.cancel(
                      int.parse(dataJson.id.toString()));
                  var row = {
                    DatabaseHelper.columnIdNotif:dataJson.id.toString(),
                    DatabaseHelper.columnTitle:dataJson.nama,
                    DatabaseHelper.columnData:dataJson.prospek,
                    DatabaseHelper.columnDay:selectedDay,
                    DatabaseHelper.columnTime:notifdate.text
                  };
                  await weeklyNotification(
                      int.parse(dataJson.id),
                      notifdate.text,
                      dataJson.nama,
                      dataJson.prospek,
                      dataJson.id);
                  await DatabaseHelper.instance.update(row);
                  checkNotif();

                  setState(() {
                    loading=false;
                    checkNotif();
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Yes"))
          ],
        );
      },
    );
  }

  Future weeklyNotification(int id, String s, String namaProspect,
      String statusProspek, String payload) async {
    var datetime = DateFormat("HH:mm").parse(s);
    print("DATETIME"+datetime.toString());
    Time t = new Time(datetime.hour, datetime.minute, datetime.second);
    print("DATETIME"+t.toString());

    print(t);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel-id',
      'channel-name',
      'channel-description',
        importance: Importance.Max,
        priority: Priority.High,
        autoCancel: false,
        playSound: true
        );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
     await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id,
      'Follow Up',
      'Nama Prospect : $namaProspect | Status : $statusProspek ',
      Day(selectedDay),
      t,
      platformChannelSpecifics,payload: id.toString()

    );
  }

  //AlarmUtilsHandler
  TextEditingController notifdate = new TextEditingController();

  //GlobalDateTimeUtility
  var datetimeForNow = DateTime.now();
  DateTime dateForNotif;
  var completeTimetoDB = "";


  void changedDropDownItem(int selectedDay) {
    setState(() {
      this.selectedDay = selectedDay;
    });
  }
  void _onRefresh() async{
    // monitor network fetch;

    await Future.delayed(Duration(milliseconds: 1000));
    dataJson==null;
    getData();
    // if failed,use refreshFailed()
    if(mounted)
      setState(() {
      });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch

    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    dataJson==null;
    getData();
    if(mounted)
      setState(() {
      });

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    setState(() {
      selectedDay = DateTime.now().weekday+1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=>Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context)=>new MyApp(isRefresh: false,)
      )),
      child: new Scaffold(
        floatingActionButton: new FloatingActionButton(
          child: new Icon(
            Icons.edit,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (context) => EditData(id: widget.id,),
          )),
        ),
        appBar: AppBar(
          title: Text(loading?"":dataJson.nama),
          leading: Icon(Icons.person),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropMaterialHeader(),
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          controller: _refreshController,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: <Widget>[
                          CardBuilder(
                            title: "Nama Prospect",
                            value: dataJson.nama,
                          ),
                          CardBuilder(
                            title: "Tanggal Prospect",
                            value: dataJson.created_at,
                          ),
                          CardBuilder(
                            title: "Nomor Handphone",
                            value: dataJson.nohp,
                          ),
                          CardBuilder(
                            title: "Rencana Pembelian",
                            value: dataJson.rencana,
                          ),
                          CardBuilder(
                            title: "Type kendaraan",
                            value: dataJson.tipe_kendaraan,
                          ),
                          CardBuilder(
                            title: "Alamat",
                            value: dataJson.alamat,
                          ),
                          CardBuilder(
                            title: "Keterangan",
                            value: dataJson.keterangan,
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Status Project : "),
                              Text(
                                dataJson.prospek,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text("Reminder",style: TextStyle(color: Colors.grey[600]),),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SizedBox(
                                width:120,
                                child: new DropdownButton(
                                    value: selectedDay,
                                    items: [
                                      DropdownMenuItem(child: Text("Minggu"), value: 1),

                                      DropdownMenuItem(
                                        child: Text("Senin"),
                                        value: 2,
                                      ),
                                      DropdownMenuItem(child: Text("Selasa"), value: 3),
                                      DropdownMenuItem(child: Text("Rabu"), value: 4),
                                      DropdownMenuItem(child: Text("Kamis"), value: 5),
                                      DropdownMenuItem(child: Text("Jumat"), value: 6),
                                      DropdownMenuItem(child: Text("Sabtu"), value: 7)
                                    ],
                                    onChanged: changedDropDownItem),
                              ),
                              SizedBox(
                                width: 150,
                                child: TextFormField(
                                  readOnly: true,
                                  controller: notifdate,
                                  decoration: InputDecoration(
                                      errorText: _validate ? 'Harus diisi!' : null,
                                      hintText: "Waktu",
                                      hintMaxLines: 1,
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          DatePicker.showTimePicker(
                                              context,
                                              currentTime: datetimeForNow,
                                              onConfirm: (date) {
                                                setState(() {
                                                  notifdate.text =
                                                      DateFormat('HH:mm')
                                                          .format(date);

                                                  completeTimetoDB =
                                                      DateFormat('yyyy-MM-dd kk:mm:ss.SS')
                                                          .format(date);
                                                  setState(() {
                                                    dateForNotif = date;
                                                  });
                                                });
                                              });
                                        },
                                        child: Icon(Icons.date_range),
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                RaisedButton(
                                  color:  Colors.blue,
                                  onPressed: () async {
                                    if(!isReminderOn) {
                                      if(notifdate.text.isEmpty){
                                        setState(() {
                                          _validate=true;

                                        });
                                      } else {
                                        setState(() {
                                          _validate=false;
                                        });

                                          var row = {
                                            DatabaseHelper.columnIdNotif:dataJson.id.toString(),
                                            DatabaseHelper.columnTitle:dataJson.nama,
                                            DatabaseHelper.columnData:dataJson.prospek,
                                            DatabaseHelper.columnDay:selectedDay,
                                            DatabaseHelper.columnTime:notifdate.text
                                          };
                                          await DatabaseHelper.instance.insert(row);
                                          checkNotif();
                                          await weeklyNotification(
                                              int.parse(dataJson.id),
                                              notifdate.text,
                                              dataJson.nama,
                                              dataJson.prospek,
                                              dataJson.id.toString());

                                        }
                                      } else {
                                      _showUpdateDialog();
                                    }
                                  },
                                  child: Text(
                                    isReminderOn? "Update Reminder":"Add Reminder",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                RaisedButton(

                                  color: isReminderOn? Colors.red:Colors.red[200],
                                  onPressed: () async {

                                    if(isReminderOn) {
                                      _showDeleteDialog();

//                          await showNotification();
                                    }
                                  },
                                  child: Text(
                                    "Delete Reminder",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: RaisedButton(
                              color:Colors.green,
                              onPressed: ()=>launch("tel://"+dataJson.nohp),
                              child: Icon(Icons.call,color: Colors.white,),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
