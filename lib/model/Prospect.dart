class Prospect{
  final String id;
  final String nama;
  final String status_prospek;
  final String tipe_kendaraan;
  final String nohp;
  final String rencana;
  final String alamat;
  final String keterangan;
  final String created_at;
  final int prospek_count;
  final String ntb;
  final String ttb;
  final String atb;
  final String mtb;
  final String prospek;

  Prospect({this.ttb,this.atb,this.mtb,this.ntb,this.id, this.nama, this.status_prospek, this.tipe_kendaraan, this.nohp, this.rencana, this.alamat, this.keterangan, this.created_at, this.prospek_count, this.prospek});

  Prospect.fromJson(Map<String,dynamic> data)
      : id =data['id'],
        nama = data['nama'],
        status_prospek = data['status_prospek'],
        tipe_kendaraan = data['tipe_kendaraan'],
        nohp =data['nohp'],
        rencana = data['rencana'],
        alamat = data['alamat'],
        keterangan = data['keterangan'],
        created_at = data['created_at'],
        prospek_count = data['prospek_count'],
        prospek = data['prospek'],
        ntb = data['ntb'],
        atb = data['atb'],
        ttb = data['ttb'],
        mtb = data['mtb'];

}