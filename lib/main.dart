import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prospek/db/DatabaseHelper.dart';
import 'package:prospek/model/Notif.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:prospek/model/Prospect.dart';
import 'package:prospek/pages/page_viewer.dart';
import 'package:prospek/pages/reminder_list_data.dart';
import 'package:prospek/utils/Constants.dart';
import 'package:prospek/utils/custom_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';
import 'pages/detail_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pages/add_data.dart';

void main() {
  runApp(new MaterialApp(
    home: MyApp(
      isRefresh: false,
    ),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  final bool isRefresh;

  const MyApp({Key key, this.isRefresh}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  TextEditingController searchTec;
  TextEditingController searchNotifications;
  TabController tabController;
  //InitializationAlarm
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  initializeNotifications() async {
    var initializeAndroid = AndroidInitializationSettings('ic_launcher');
    var initializeIOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
    await localNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotifications);
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Future onSelectNotifications(String payload) {
    if (payload != null) {
      print("Notification payload " + payload);
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Detail(id: payload)));
  }

  bool loading = false;
  List dataJson = [];
  List<Map<String, dynamic>> weekdayDataList = [];
  List<Notif> dataNotificationJson = [];
  List menu = ["Home", "Reminder List"];
  List days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday,",
    "Saturday"
  ];

  void getData() async {
    setState(() {
      loading = true;
    });
    final response = await http.get(Uri.parse(Constants.GET_PROSPECT));
    final notifications = await DatabaseHelper.instance.queryAllRows();
    if (notifications != null) {
      print(notifications.length);
      if (notifications.isNotEmpty) {
        setState(() {
          notifications.forEach((element) {
            dataNotificationJson.add(Notif.fromjson(element));
          });
        });
//        print("Data" +dataNotificationJson[0].id);
      } else {
        print("KOSONG GAN 2");
      }
    } else {
      print("KOSONG GAN");
    }

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        for (var i = 0; i < data.length; i++) {
          dataJson.add(data[i]);
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: "Swipe down to refresh",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    setState(() {
      loading = false;
    });
  }

  void _onRefresh() async {
    // monitor network fetch;

    await Future.delayed(Duration(milliseconds: 1000));
    dataJson.clear();
    dataNotificationJson.clear();
    getData();
    // if failed,use refreshFailed()
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch

    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    dataJson.clear();
    dataNotificationJson.clear();
    getData();
    if (mounted) setState(() {});

    _refreshController.loadComplete();
  }

  String filter;
  String filterNotif;

  @override
  void initState() {
    searchTec = new TextEditingController();
    searchNotifications = new TextEditingController();
    tabController = new TabController(length: 2, vsync: this);

    if (widget.isRefresh) {
      _onRefresh();
    } else {
      getData();
    }
    searchNotifications.addListener(() {
      setState(() {
        filterNotif = searchNotifications.text;
      });
    });

    searchTec.addListener(() {
      setState(() {
        filter = searchTec.text;
      });
    });

    tabController.addListener(() {
      setState(() {});
    });

    initializeNotifications();
    super.initState();
  }

  @override
  void dispose() {
    searchTec.dispose();
    super.dispose();
  }

  Future<void> getWeekdayList() async {
    weekdayDataList.clear();
    return await Future.wait(dataNotificationJson.map((element) async {
      var r = await http.post(Constants.GET_PROSPECT_BY_ID,
          body: {"id": element.notifId.toString()});
      var fetch = jsonDecode(r.body);
      if (r.statusCode == 200) {
        setState(() {
          if(int.parse(element.day)-1==DateTime.now().weekday) {
          weekdayDataList
              .add({"prospect": Prospect.fromJson(fetch), "notif": element});
          }
        });
      }
    }));
  }

  Future<void> checkPermissionAndGeneratePDF() async {
    await new Future.delayed(new Duration(seconds: 1));
    if (await Permission.storage.request().isGranted) {
      Navigator.pop(context);
      await generatePDF();
    } else {
      CustomWidget.showFlushBar(context, "You should accept the permission");
    }
  }

  generatePDF() async {
    final pdfLib.Document pdf = pdfLib.Document(deflate: zlib.encode);
    pdf.addPage(pdfLib.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pdfLib.EdgeInsets.all(10),
      build: (context) => [
        pdfLib.Header(text: "Today is ${days[DateTime.now().weekday]}"),
        pdfLib.Table.fromTextArray(

            context: context,
            margin: pdfLib.EdgeInsets.all(3),
            data: <List<String>>[
          <String>[
            "No",
            'Nama',
            "No Telp",
            "Tipe Mobil",
            "Keterangan",
            "Status Prospek",
            "Tanggal Reminder"
          ],
          ...weekdayDataList.map((e) => [
                (weekdayDataList.indexOf(e) + 1).toString(),
                e["prospect"].nama,
                e['prospect'].nohp,
                e['prospect'].tipe_kendaraan,
                e['prospect'].keterangan,
                e['prospect'].prospek,
                "${days[int.parse(e['notif'].day)-1]}, ${e['notif'].time}"
              ])
        ])
      ],
    ));

    var dir;
    var fileName = "Prospek_${days[DateTime.now().weekday]}_"
    "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_"
        "${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}.pdf";
    if(Platform.isAndroid){
      final folderName="Prospek";
      final path= Directory("storage/emulated/0/$folderName");
      if ((await path.exists())){
        print("exist");
      }else{
        print("not exist");
        path.create();
      }
      dir =path.path+"/$fileName";

    } else {
     dir = (await getApplicationDocumentsDirectory()).path;

    }
    final File file = File(dir);
    await file.writeAsBytes(pdf.save());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(path: dir,title: fileName,),
      ),
    );
    CustomWidget.showFlushBar(context, "File saved...");

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: new AppBar(
            title: new Center(
              child: new Text("Funnel Prospect Controling"),
            ),
            backgroundColor: Colors.blue,
          ),
          floatingActionButton: new FloatingActionButton(
            child: new Icon(
              tabController.index == 0 ? Icons.add : Icons.print,
              color: Colors.white,
            ),
            onPressed: () async {
              if (tabController.index == 0) {
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    builder: (BuildContext context) => new AddData()));
              } else {
                CustomWidget.showLoadingDialog(context);
                await getWeekdayList();
                if (weekdayDataList.isNotEmpty) {
                  await checkPermissionAndGeneratePDF();
                } else {
                  Navigator.pop(context);
                  CustomWidget.showFlushBar(context, "Data tidak ada...");
                }
              }
//              print(days[DateTime.now().weekday]);
            },
          ),
          body: _buildTabBarView(),
          bottomNavigationBar: _buildTabBar(),
        ));
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      child: TabBar(controller: tabController, tabs: _buildItemTabs()),
    );
  }

  List<Widget> _buildItemTabs() {
    return List.generate(
        menu.length,
        (index) => Container(
              alignment: Alignment.center,
              height: 50,
              child: Text(
                menu[index],
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ));
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        SmartRefresher(
          enablePullDown: true,
          header: WaterDropMaterialHeader(),
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          controller: _refreshController,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: TextFormField(
                  controller: searchTec,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          icon: Icon(Icons.search), onPressed: () {}),
                      hintText: "Search..."),
                ),
              ),
              Expanded(
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : dataJson.length != 0
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: dataJson.length,
                            itemBuilder: (context, i) {
                              return filter == null || filter == ""
                                  ? new Container(
                                      child: new GestureDetector(
                                        onTap: () => Navigator.of(context)
                                            .pushReplacement(
                                                new MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        new Detail(
                                                          id: dataJson[i]['id'],
                                                        ))),
                                        child: new Card(
                                          color: Colors.white,
                                          child: new ListTile(
                                            title:
                                                new Text(dataJson[i]['nama']),
                                            leading: new Icon(Icons.people),
                                            subtitle: new Text(
                                                "Tanggal : ${dataJson[i]['created_at']} \nStatus: ${dataJson[i]['prospek']} \n "),
                                            trailing: InkWell(
                                                onTap: () => launch("tel://" +
                                                    dataJson[i]['nohp']),
                                                child: new Icon(Icons.call)),
                                            isThreeLine: true,
                                          ),
                                        ),
                                      ),
                                    )
                                  : dataJson[i]['nama']
                                          .toLowerCase()
                                          .contains(filter.toLowerCase())
                                      ? new Container(
                                          child: new GestureDetector(
                                            onTap: () => Navigator.of(context)
                                                .pushReplacement(
                                                    new MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            new Detail(
                                                              id: dataJson[i]
                                                                  ['id'],
                                                            ))),
                                            child: new Card(
                                              color: Colors.white,
                                              child: new ListTile(
                                                title: new Text(
                                                    dataJson[i]['nama']),
                                                leading: new Icon(Icons.people),
                                                subtitle: new Text(
                                                    "Tanggal : ${dataJson[i]['created_at']} \nStatus: ${dataJson[i]['prospek']} \n "),
                                                trailing: InkWell(
                                                    onTap: () => launch(
                                                        "tel://" +
                                                            dataJson[i]
                                                                ['nohp']),
                                                    child:
                                                        new Icon(Icons.call)),
                                                isThreeLine: true,
                                              ),
                                            ),
                                          ),
                                        )
                                      : new Container();
                            })
                        : Center(
                            child: Text("Data Kosong"),
                          ),
              ),
            ],
          ),
        ),
        ReminderListData(parent: this),
      ],
    );
  }
}
