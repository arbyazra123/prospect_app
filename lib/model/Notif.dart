class Notif {
  final int id;
  final String notifId;
  final String title;
  final String data;
  final String day;
  final String time;

  Notif(this.id, this.notifId, this.title, this.data, this.day, this.time);

  Notif.fromjson(Map<String,dynamic> data):
        id = data['_id'],
        notifId = data['idNotif'],
        title=data['title'],
        data = data['data'],
        day = data['day'],
        time=data['time'];

}