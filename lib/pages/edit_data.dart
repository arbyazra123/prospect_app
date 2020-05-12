import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:prospek/pages/detail_data.dart';
import 'package:prospek/db/DatabaseHelper.dart';
import 'package:prospek/model/Prospect.dart';
import 'package:prospek/model/ResponseResult.dart';
import 'package:prospek/utils/Constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'Detail.dart';
import '../main.dart';

import '../model/Notif.dart';

class EditData extends StatefulWidget {
  final String id;
  EditData({this.id});

  @override
  _EditDataState createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();
  final flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  TextEditingController namacontroller = new TextEditingController();
  TextEditingController tanggalcontroller = new TextEditingController();
  TextEditingController nohpcontroller = new TextEditingController();
  TextEditingController rencanacontroller = new TextEditingController();
  TextEditingController tipecontroller = new TextEditingController();
  TextEditingController alamatcontroller = new TextEditingController();
  TextEditingController keterangancontroller = new TextEditingController();
  TextEditingController statuscontroller = new TextEditingController();

  ProgressDialog pr;



  bool loading = false;
  bool isNotifFound = false;
  Prospect prospect ;
  ResponseResult res;
  ResponseResult deleteRes;
  Notif notif;



  void getData()async{
    setState(() {
      loading=true;
    });
    var r = await http.post(Constants.GET_PROSPECT_BY_ID,body: {
      "id":widget.id
    });
    var data = jsonDecode(r.body);
    if(r.statusCode==200){
      setState(() {
        prospect = Prospect.fromJson(data);

      });

    }
    setState(() {
      namacontroller =
      new TextEditingController(text: prospect.nama);
      tanggalcontroller =
      new TextEditingController(text: prospect.created_at);
      nohpcontroller =
      new TextEditingController(text: prospect.nohp);
      rencanacontroller =
      new TextEditingController(text: prospect.rencana);
      tipecontroller =
      new TextEditingController(text: prospect.tipe_kendaraan);
      alamatcontroller =
      new TextEditingController(text: prospect.alamat);
      keterangancontroller =
      new TextEditingController(text: prospect.keterangan);
      statuscontroller =
      new TextEditingController(text: prospect.prospek);
      loading=false;

      if(prospect.ntb=="1"){
        forChecked.add("Need to buy");
        ntb = int.parse(prospect.ntb);
      }
      if(prospect.ttb=="1"){
        forChecked.add("Time to buy");
        ttb = int.parse(prospect.ttb);

      }
      if(prospect.atb=="1"){
        forChecked.add("Authority to buy");
        atb = int.parse(prospect.atb);

      }
      if(prospect.mtb=="1"){
        forChecked.add("Money to buy");
        mtb = int.parse(prospect.mtb);

      }

    });
  }

  //GlobalDateTimeUtility
  var datetimeForNow = DateTime.now();
  var dateForNotif;
  var completeTimetoDB = "";

  //checkbox utils
  List<String> forChecked=[];
  int ntb=0;
  int ttb=0;
  int atb=0;
  int mtb=0;

  void editData(BuildContext context) async{
    Map result;
    setState(() {
      loading=true;
    });
    var r = await http.post(Constants.UPDATE_PROSPECT, body: {
      "id":widget.id,
      "namaPegawai": namacontroller.text,
      "tglPegawai": tanggalcontroller.text,
      "nohpPegawai": nohpcontroller.text,
      "rencanaPegawai": rencanacontroller.text,
      "kendaraanPegawai": tipecontroller.text,
      "alamatPegawai": alamatcontroller.text,
      "ketPegawai": keterangancontroller.text,
      "ntbPegawai": ntb.toString(),
      'ttbPegawai':ttb.toString(),
      'atbPegawai':atb.toString(),
      'mtbPegawai':mtb.toString(),
    });
    print(tanggalcontroller.text);
    var data = jsonDecode(r.body);
    if(r.statusCode==200){
      setState(() {
        res = ResponseResult.fromJson(data);
      });
    }

      if(res.error=="false"){
        _scaffoldState.currentState.showSnackBar(new SnackBar(content: Text("Berhasil Diubah"),duration: Duration(seconds: 2),));
        Future.delayed(Duration(seconds: 2),(){
          Navigator.pushReplacement(context,MaterialPageRoute(
              builder: (context)=>Detail(id:widget.id)
          ));
        });

      } else {
        setState(() {
          loading=false;
        });
        _scaffoldState.currentState.showSnackBar(new SnackBar(content: Text("Gagal Diubah")));
      }
  }

  bool readyToMove = false;
  @override



  void _showDeleteDialog(BuildContext ctx) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: loading?Center(child: CircularProgressIndicator(),):Text("Apakah yakin ingin menghapus?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
                onPressed: () async{
                  Navigator.of(context).pop();

                  setState(() {
                    loading=true;
                  });
                  if(isNotifFound){
                    await flutterLocalNotificationsPlugin.cancel(
                        int.parse(widget.id));
                    await DatabaseHelper.instance.delete(widget.id);
                  }
                  var r = await http.post(Constants.DELETE_PROSPECT,body: {
                    "id":widget.id
                  });
                  var data = jsonDecode(r.body);
                  if(r.statusCode==200){
                    setState(() {
                        deleteRes = ResponseResult.fromJson(data);
                    });
                  }
                  if(deleteRes.error=="false"){
                    _scaffoldState.currentState.showSnackBar(new SnackBar(content: Text("Berhasil Menghapus!"),duration: Duration(seconds: 2),));

                    Future.delayed(Duration(seconds: 2),(){
                      Navigator.pushReplacement(ctx, MaterialPageRoute(
                        builder: (ctx)=>new MyApp(isRefresh: false,)
                      ));
                    });
                  } else {
                    setState(() {
                      loading=false;
                    });
                    _scaffoldState.currentState.showSnackBar(new SnackBar(content: Text("Gagal Menghapus")));
                  }

                },
                child: Text("Yes"))
          ],
        );
      },
    );
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void findNotifToDelete() async {
    var r = await DatabaseHelper.instance.getData(widget.id);
    if(r.length>0){
      setState(() {
        isNotifFound = true;
        for(var i=0;i<r.length;i++) {
          notif = Notif.fromjson(r[i]);
        }
      });
    } else {
      setState(() {
        isNotifFound = false;
      });
    }
    print(isNotifFound);

  }
  void _onRefresh() async{
    // monitor network fetch;

    await Future.delayed(Duration(milliseconds: 1000));
    prospect==null;
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
    prospect==null;
    getData();
    if(mounted)
      setState(() {
      });

    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getData();
    findNotifToDelete();

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()=> Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context)=>Detail(id: widget.id,)
      )),
      child: new Scaffold(
        key: _scaffoldState,
        appBar: new AppBar(
          automaticallyImplyLeading: true,
          title: Text(loading?"":prospect.nama),
          backgroundColor: Colors.green,
        ),
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropMaterialHeader(),
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          controller: _refreshController,
          child: loading?Center(child: CircularProgressIndicator(),): Padding(
            padding: const EdgeInsets.symmetric(horizontal:10.0,vertical: 20),
            child: ListView(
                children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new Padding(padding: new EdgeInsets.only(top: 15.0)),
                    new TextField(
                        controller: namacontroller,
                        decoration: new InputDecoration(
                          hintText: "John Doe",
                          labelText: "Nama Prospek",
                        )),
                    new Padding(padding: new EdgeInsets.all(5.0)),
                    TextFormField(
                      maxLength: 23,
                      readOnly: true,
                      controller: tanggalcontroller,
                      decoration: InputDecoration(
                          labelText: "Time",
                          suffixIcon: InkWell(
                            onTap: () {
                              DatePicker.showDateTimePicker(
                                  context,
                                  currentTime:
                                  datetimeForNow,
                                  onConfirm: (date) {
                                    setState(() {
                                      tanggalcontroller.text = DateFormat(
                                          'yyyy-MM-dd HH:mm').format(date);

                                      completeTimetoDB = DateFormat(
                                          'yyyy-MM-dd HH:mm')
                                          .format(date);

                                      dateForNotif =
                                          date.toUtc();
//
                                    });
                                  });
                            },
                            child: Icon(Icons.date_range),
                          )),
                    ),
                    new Padding(padding: new EdgeInsets.all(5.0)),
                    new TextField(
                        controller: nohpcontroller,
                        decoration: new InputDecoration(
                          hintText: "081234567890",
                          labelText: "Nomor Hp",
                        )),
                    new Padding(padding: new EdgeInsets.all(5.0)),
                    new TextField(
                        controller: rencanacontroller,
                        decoration: new InputDecoration(
                          hintText: "Bulan ini",
                          labelText: "Rencana Pembelian",
                        )),
                    new Padding(padding: new EdgeInsets.all(5.0)),
                    new TextField(
                        controller: tipecontroller,
                        decoration: new InputDecoration(
                          hintText: "Fortuner",
                          labelText: "Type Kendaraan",
                        )),
                    new Padding(padding: new EdgeInsets.all(5.0)),
                    new TextField(
                        maxLines: 3,
                        minLines: 2,
                        controller: alamatcontroller,
                        decoration: new InputDecoration(
                          hintText: "Jl. Raya Blok i1 Tangerang",
                          labelText: "Alamat Prospek",
                        )),
                    new Padding(padding: new EdgeInsets.all(5.0)),
                    new TextField(
                        maxLines: 3,
                        minLines: 2,
                        controller: keterangancontroller,
                        decoration: new InputDecoration(
                          hintText: "Keterangan",
                          labelText: "Keterangan Prospek",
                        )),

                    new Padding(padding: new EdgeInsets.all(5.0)),
                    Text("Status Proyek",style: TextStyle(fontSize: 16,color: Colors.grey[600]),),
                    CheckboxGroup(
                      checked: forChecked,
                      labels: <String>[
                        "Need to buy",
                        "Time to buy",
                        "Authority to buy",
                        "Money to buy",

                      ],
                      onChange: (bool isChecked, String label, int index){
                        switch(index){
                          case 0 :
                            setState(() {
                              if(!isChecked){
                                setState(() {
                                  forChecked.removeWhere((item) => item == 'Need to buy');
                                });
                              } else {
                                  forChecked.add("Need to buy");
                              }
                              setState(() {
                                isChecked?ntb=1:ntb=0;

                              });
                            });
                            break;
                          case 1 :
                            setState(() {
                              if(!isChecked){
                                setState(() {
                                  forChecked.removeWhere((item) => item == 'Time to buy');
                                });
                              } else {
                                forChecked.add("Time to buy");
                              }
                              setState(() {
                                isChecked?ttb=1:ttb=0;

                              });
                            });
                            break;
                          case 2 :
                            setState(() {
                              if(!isChecked){
                                setState(() {
                                  forChecked.removeWhere((item) => item == 'Authority to buy');
                                });
                              } else {
                                forChecked.add("Authority to buy");
                              }
                              setState(() {
                                isChecked?atb=1:atb=0;

                              });
                            });
                            break;
                          case 3 :
                            setState(() {
                              if(!isChecked){
                                setState(() {
                                  forChecked.removeWhere((item) => item == 'Money to buy');
                                });
                              } else {
                                forChecked.add("Money to buy");
                              }
                              setState(() {
                                isChecked?mtb=1:mtb=0;

                              });
                            });
                            break;
                          default:

                        }
                        print(isChecked);

                        print(ntb);
                      },
                      onSelected: (List<String> checked) {
                        switch(checked.length){
                          case 1:
                            statuscontroller.text = "Low Prospect";
                            break;
                          case 2:
                            statuscontroller.text = "Medium Prospect";
                            break;
                          case 3 :
                            statuscontroller.text = "Medium Prospect";
                            break;
                          case 4 :
                            statuscontroller.text = "Hot Prospect";
                            break;
                          default:
                            statuscontroller.text = "";
                            break;
                        }
                      },
                    ),
                    new TextField(
                        readOnly: true,
                        enabled: false,
                        controller: statuscontroller,

                        decoration: new InputDecoration(
                            hintText: "Pilih salah satu dari diatas"
                        )),
                    new Padding(padding: const EdgeInsets.all(5.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                            new RaisedButton(
                            child: new Text("EDIT DATA",style: TextStyle(color: Colors.white),),
                            color: Colors.green,
                            onPressed: () {
                              editData(context);

                            }),
                            new RaisedButton(
                            child: new Text("DELETE DATA",style: TextStyle(color: Colors.white),),
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteDialog(context);

                            }),
                          ],
                    )
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
