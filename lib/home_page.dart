import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _url = "https://jsonplaceholder.typicode.com/users";
  StreamSubscription<ConnectivityResult> _stream;
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  // inicializar un stream y suscribirnos para observarlo
  @override
  void initState() {
    _initConnectivity();
    _stream =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  // actualizar el estado de conexion y mostrar snackbar
  void _updateConnectionStatus(ConnectivityResult connStatus) {
    if (connStatus == ConnectivityResult.mobile) {
      print("Conectado a datos mobiles");

      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Con red Datos mobiles.."),
          ),
        );
    } else if (connStatus == ConnectivityResult.wifi) {
      print("Conectado a wifi");

      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Con red por WIFI.."),
          ),
        );
    } else if (connStatus == ConnectivityResult.none) {
      print("Son conectividad a la red");

      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text("Sin acceso a la red.."),
          ),
        );
    }
    setState(() {});
  }

  // revisar si se puede revisar conexion
  Future _initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await Connectivity().checkConnectivity();
      print(result);
    } catch (e) {
      print(e);
    }
  }

  // GET request
  Future _getData() async {
    try {
      Response response = await get(_url);
      if (response.statusCode == HttpStatus.ok) {
        var result = jsonDecode(response.body);
        return result;
      }
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Material App Bar'),
      ),
      body: FutureBuilder(
        future: _getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          if (snapshot.hasData) {
            var dataList = snapshot.data;
            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text("${dataList[index]["name"]}"),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
