library ListViewWidget;


import 'package:flutter/material.dart';
import 'dart:isolate';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ListViewWidget extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ListViewState();
  }
}

class ListViewState extends State<ListViewWidget>{

  List widgets = [];

  @override
  void initState()
  {
    super.initState();
    loadData();
  }

  showLoadingDialog()
  {
    if(widgets.length == 0)
    {
      return true;
    }
    return false;
  }

  Widget getProgressDialog()
  {
    return new Center(child: new CircularProgressIndicator(),);
  }

  Widget getBody()
  {
    if(showLoadingDialog()){
      return getProgressDialog();
    }else
    {
      return getListView();
    }
  }

  Widget getRow(int position)
  {
    return new GestureDetector(child:new Padding(padding: new EdgeInsets.all(10.0),
        child: new Text("Row"+
            "id ${widgets[position]['id']}" +"  ${widgets[position]["title"]}")),
        onTap: (){
          print("onClinck");
        });
  }

  Widget getListView()
  {
//    debugPrint("${widgets.length}");

    return ListView.builder(
        itemCount: widgets.length,
        itemBuilder: (BuildContext context,int position){
          return getRow(position);
        });
  }

  loadData() async{
    ReceivePort receivePort = new ReceivePort();
    await Isolate.spawn(dataLoader,receivePort.sendPort);

    SendPort sendPort = await receivePort.first;

    List msg = await sendReceive(sendPort,"https://jsonplaceholder.typicode.com/posts");

    setState(() {
      widgets = msg;
    });
  }

  Future sendReceive(SendPort port,msg){
    ReceivePort response = new ReceivePort();
    port.send([msg,response.sendPort]);
    return response.first;
  }

  static dataLoader(SendPort send) async{

    ReceivePort receivePort = new ReceivePort();
    send.send(receivePort.sendPort);

    await for (var msg in receivePort){
      String data = msg[0];
      SendPort replyTo = msg[1];

      http.Response response = await http.get(data);
      debugPrint("response ...${response.body.toString()}");
      replyTo.send(new JsonCodec().decode(response.body));
    }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("listView"),
      ),
      body: getBody(),
    );
  }

}