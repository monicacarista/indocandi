import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tes/detailPage.dart';
import 'package:flutter_tes/model.dart';
import 'package:flutter_tes/Tab/SideBar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'list_item.dart';


class CandiPribadi extends StatefulWidget{

  @override
  _CandiPribadi createState() => _CandiPribadi();
}

class _CandiPribadi extends State {

  List<Tripleset> jokes = [];
  Future<List<Tripleset>> mainPri() async {
    var payload = Uri.encodeComponent("prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"+
        "  prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>"+
        "prefix : <http://alunalun.info/ontology/candi#>"+
        "prefix schema: <http://schema.org/>"+
        "PREFIX dbo: <http://dbpedia.org/ontology/>"+
        "SELECT  ?id ?candi  ?jenis  ?gambar ?lokasi "+
        "(GROUP_CONCAT(COALESCE(?arcas,''); separator = ',' )as ?arca)"+
        "  (GROUP_CONCAT(COALESCE(?acara,''); separator = ',' )as ?upacara)"+
        "(GROUP_CONCAT(COALESCE(?relieff,''); separator = ',' )as ?relief)"+
        "(GROUP_CONCAT(COALESCE(?sb,''); separator = ',' )as ?struktur_bangunan)"+
        "(GROUP_CONCAT(COALESCE(?desc,''); separator = ',' )as ?deskripsi)"+
        "  WHERE {"+
        " ?id rdf:type :CandiPribadi ."+
        "   :CandiPribadi rdfs:label ?jenis."+
        "   ?id rdfs:label ?candi."+
        " ?id :profil ?gambar."+
        "  OPTIONAL{?id :berasalDari ?idasal."+
        "  ?idasal dbo:location ?asall. }"+
        "OPTIONAL{?id :Deskripsi ?desc.}"+
        "?id :berasalDari ?idasal."+
        "?idasal dbo:location ?lokasi. "+
        " OPTIONAL{?id :untukUpacara ?idu."+
        "  ?idu rdfs:label ?acara}"+
        "OPTIONAL {?id :terdapatRelief ?idrelief."+
        "?idrelief rdfs:label ?relieff}"+
        "OPTIONAL {?id :terdiriDari ?idsb."+
        "?idsb rdfs:label ?sb}"+
        "  OPTIONAL{?id :terdapatArca ?idarca. ?idarca rdfs:label ?arcas}}"+
        "GROUP BY  ?id ?candi  ?jenis  ?gambar ?lokasi ");

    var headers = new Map<String, String>();
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    headers['Accept'] = 'application/json';

    var response = await http.post(
        'https://app.alunalun.info/fuseki/candi/query',
        headers: headers,
        body: "query=${payload}");
    print(response.body);


    if (response.statusCode == 200) {
      Map value = json.decode(response.body);
      print(value);
      var head = SparqlResult.fromJson(value);
      for (var data in head.results.listTriples) {
        print(data);
        Tripleset tp = Tripleset(data.id,data.candi,data.lokasi,data.gambar,data.jenis,data.deskripsi,data.arca,data.upacara,data.relief,data.struktur_bangunan,data.bahan,data.namaLain);
        //print(data);
        jokes.add(tp);
      }
      print(jokes);
      return jokes;
    }else{

    }

  }

  @override
  void initState() {
    super.initState();
    mainPri();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Candi Pribadi'),
        backgroundColor: Colors.blueGrey.shade700,

      ),
      body: Center(
        child: FutureBuilder <List<Tripleset>>(
          future: mainPri(),
          builder: (context, AsyncSnapshot snapshot){

            if (snapshot.data == null) {
              print("DAta null");
              return CircularProgressIndicator();

            } else{
              return
                ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new Card(
                        elevation: 2.0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(16.0),
                        ),
                        child: new InkWell(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new ClipRRect(
                                child: new Image.network(
                                  // "assets/images/borobudur.jpg",
                                    "snapshot.data[index].gambar.value"
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: new Radius.circular(16.0),
                                  topRight: new Radius.circular(16.0),
                                ),
                              ),
                              new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  new IconButton(
                                    icon: new Icon(FontAwesomeIcons.angleRight),
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => new DetailPage(candi: snapshot.data[index].candi.value,
                                        jenis: snapshot.data[index].jenis.value,
                                        lokasi : snapshot.data[index].lokasi.value,
                                        deskripsi: snapshot.data[index].deskripsi.value,
                                        arca: snapshot.data[index].arca.value,
                                        upacara: snapshot.data[index].upacara.value,
                                        //  relief: snapshot.data[index].relief.value,
                                        //    type:snapshot.data[index].candi.type
                                      )));
                                    },
                                  )
                                ],
                              ),
                              new Padding(
                                padding: new EdgeInsets.all(16.0),
                                child: new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text(snapshot.data[index].candi.value,
                                      style: new TextStyle(fontWeight: FontWeight.bold),),
                                    new SizedBox(height: 16.0),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        new Text(snapshot.data[index].jenis.value),
                                        new Text(snapshot.data[index].lokasi.value),

                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => new DetailPage(data: this.data)));
                          // },
                        ),
                      );
                    }
                );





            }

          },
        ),
      ),
    );
  }

}