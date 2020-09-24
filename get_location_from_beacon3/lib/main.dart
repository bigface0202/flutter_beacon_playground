import 'package:flutter/material.dart';
import 'package:flutter_ble/flutter_ble.dart';

import './beacon.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool isScanning = false;

  FlutterBle flutterBlue = FlutterBle.instance;

  Map<String, Beacon> scanMap = Map();
  List<Beacon> scanList = List();

  var scanSubscription;

  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animateColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));

    scanBLE();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    stopBLE();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemBuilder: (context, length) {
            return ListTile(
              title: Text(scanList[length].name),
              subtitle: Text(scanList[length].timestamp.toString()),
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                radius: 20,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FittedBox(
                    child: Text(
                      scanList[length].rssi.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          },
          itemCount: scanList.length,
        ).build(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _animateColor.value,
        label: Text(isScanning ? 'Stop' : 'Scan'),
        elevation: 10.0,
        icon: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _animateIcon,
        ),
        onPressed: () {
          isScanning ? stopBLE() : scanBLE();
        },
        tooltip: 'Toggle',
      ),
    );
  }

  /// Stop scanning
  void stopBLE() {
    _animationController.reverse();

    setState(() {
      isScanning = false;
    });
    scanSubscription.cancel();
  }

  void scanBLE() {
    _animationController.forward();

    setState(() {
      isScanning = true;
    });

    scanSubscription = flutterBlue.scan().listen((scanResult) {
      Beacon beacon = Beacon(
          scanResult.device.id.id,
          scanResult.device.name.toString(),
          scanResult.rssi,
          scanResult.device,
          scanResult.advertisementData,
          new DateTime.now().millisecondsSinceEpoch);
      if (beacon.name.startsWith('LINE BEACON')) {
        scanMap[scanResult.device.id.id] = beacon;
      }
      updateScanList();
    });
  }

  void updateScanList() {
    scanMap.forEach((String key, Beacon value) => {
          if (scanList.contains(value))
            {
              if ((new DateTime.now().millisecondsSinceEpoch -
                      value.timestamp) >
                  5000)
                {
                  setState(() {
                    print(key);
                    print(value);
                    scanMap.remove(key);
                    scanList.remove(value);
                  })
                }
              else
                {
                  setState(() {
                    scanMap[key] = value;
                    Beacon beacon = value;
                    beacon.timestamp =
                        new DateTime.now().millisecondsSinceEpoch;
                    scanList.remove(value);
                    scanList.add(beacon);
                  })
                }
            }
          else
            {
              setState(() {
                scanList.add(value);
              })
            }
        });
  }
}
