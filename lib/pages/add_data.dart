import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:prospek/model/ResponseResult.dart';
import 'package:prospek/utils/Constants.dart';
import '../main.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AddData extends StatefulWidget {
  @override
  _AddDataState createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey<ScaffoldState>();
  ProgressDialog pr;
  TextEditingController namacontroller = new TextEditingController();
  TextEditingController tanggalcontroller = new TextEditingController();
  TextEditingController nohpcontroller = new TextEditingController();
  TextEditingController rencanacontroller = new TextEditingController();
  TextEditingController tipecontroller = new TextEditingController();
  TextEditingController alamatcontroller = new TextEditingController();
  TextEditingController keterangancontroller = new TextEditingController();
  TextEditingController statuscontroller = new TextEditingController();

  bool loading =false;
  ResponseResult res;

  void addData(BuildContext context) async{
    setState(() {
      loading=true;
    });
    var r = await http.post(Constants.ADD_PROSPECT, body: {
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
    var data = jsonDecode(r.body);
    if(r.statusCode==200){
      setState(() {
        res = ResponseResult.fromJson(data);
      });
    }
    print("PRINTING DATA");
    if(res.error=="false"){
      _scaffoldState.currentState.showSnackBar(new SnackBar(content: Text("Berhasil Ditambah"),duration: Duration(seconds: 2),));
      Future.delayed(Duration(seconds: 2),(){
        Navigator.pushReplacement(context,MaterialPageRoute(
          builder: (c)=>MyApp(isRefresh: true,)
        ));

      });

    } else {
      setState(() {
        loading=false;
      });
      _scaffoldState.currentState.showSnackBar(new SnackBar(content: Text("Gagal Menambah")));
    }
  }

  //GlobalDateTimeUtility
  var datetimeForNow = DateTime.now();
  var dateForNotif;
  var completeTimetoDB = "";

  //checkbox utils
  int ntb=0;
  int ttb=0;
  int atb=0;
  int mtb=0;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=>Navigator.pushReplacement(context,MaterialPageRoute(
        builder: (context)=>new MyApp(isRefresh: false,)
      )),
      child: new Scaffold(
        key: _scaffoldState,
        appBar: new AppBar(
          title: Text('Tambah Prospek Baru'),
          backgroundColor: Colors.green,
        ),
        body: loading?Center(child: CircularProgressIndicator(),): ListView(children: <Widget>[
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
                    keyboardType: TextInputType.phone,
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
                        isChecked?ntb=1:ntb=0;
                      });
                      break;
                    case 1 :
                      setState(() {
                        isChecked?ttb=1:ttb=0;
                      });
                      break;
                    case 2 :
                      setState(() {
                        isChecked?atb=1:atb=0;
                      });
                      break;
                    case 3 :
                      setState(() {
                        isChecked?mtb=1:mtb=0;
                      });
                      break;
                    default:

                  }
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
                new RaisedButton(
                    child: new Text("BUAT PROSPEK BARU",style: TextStyle(color: Colors.white),),
                    color: Colors.green,
                    onPressed: () {
                      addData(context);



                    })
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
