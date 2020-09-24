import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widget/permission_widget.dart';

class BleStatusScreen extends StatelessWidget {
  const BleStatusScreen({@required this.status, Key key})
      : assert(status != null),
        super(key: key);

  final BleStatus status;

  // String determineText(BleStatus status) {
  //   switch (status) {
  //     case BleStatus.unsupported:
  //       return "This device does not support Bluetooth";
  //     case BleStatus.unauthorized:
  //       return "Authorize the FlutterReactiveBle example app to use Bluetooth and location";
  //     case BleStatus.poweredOff:
  //       return "Bluetooth is powered off on your device turn it on";
  //     case BleStatus.locationServicesDisabled:
  //       return "Enable location services";
  //     case BleStatus.ready:
  //       return "Bluetooth is up and running";
  //     default:
  //       return "Waiting to fetch Bluetooth status $status";
  //   }
  // }

  Widget determineWidget(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return Text("This device does not support Bluetooth");
      case BleStatus.poweredOff:
        return Text("Bluetooth is powered off on your device turn it on");
      case BleStatus.locationServicesDisabled:
        return Text("Enable location services");
      case BleStatus.ready:
        return Text("Bluetooth is up and running");
      case BleStatus.unauthorized:
        return Center(
          child: ListView(
            children: Permission.values
                .where((Permission permission) {
                  if (Platform.isIOS) {
                    return permission != Permission.unknown &&
                        permission != Permission.sms &&
                        permission != Permission.ignoreBatteryOptimizations &&
                        permission != Permission.accessMediaLocation;
                  } else {
                    return permission != Permission.unknown &&
                        permission != Permission.mediaLibrary &&
                        permission != Permission.photos &&
                        permission != Permission.reminders;
                  }
                })
                .map((permission) => PermissionWidget(permission))
                .toList(),
          ),
        );
      default:
        return Text("Waiting to fetch Bluetooth status $status");
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: determineWidget(status),
        ),
      );
}
