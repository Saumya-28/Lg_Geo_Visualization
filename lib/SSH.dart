import 'dart:math';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_poly_glide/providers.dart';
import 'package:geo_poly_glide/utils/constants.dart';
import 'package:geo_poly_glide/utils/images.dart';

import 'kml/LookAt.dart';
import 'kml/NamePlaceBallon.dart';
import 'kml/kml_makers.dart';
class SSH{
  final WidgetRef ref;

  SSH({required this.ref});

  SSHClient? _client;
  // final CustomWidgets customWidgets = CustomWidgets();
  Future<bool?> connectToLG(BuildContext context) async {
    try {
      final socket = await SSHSocket.connect(
          ref.read(ipProvider), ref.read(portProvider),
          timeout: const Duration(seconds: 5));
      ref
          .read(sshClientProvider.notifier)
          .state = SSHClient(
        socket,
        username: ref.read(usernameProvider),
        onPasswordRequest: () => ref.read(passwordProvider),
      );
      ref
          .read(connectedProvider.notifier)
          .state = true;
      return true;
    } catch (e) {
      ref
          .read(connectedProvider.notifier)
          .state = false;
      print('Failed to connect: $e');
      // customWidgets.showSnackBar(context: context, message: e.toString(), color: Colors.red);
      return false;
    }
  }

  Future<SSHSession?> motionControls (double updownflag, double rightleftflag, double zoomflag, double tiltflag, double bearingflag) async {
    _client = ref.read(sshClientProvider);
    LookAt flyto = LookAt(rightleftflag, updownflag, zoomflag.toString(),
        tiltflag.toString(), bearingflag.toString());
    try {
      final session = await _client?.execute(
          'echo "flytoview=${flyto.generateLinearString()}" > /tmp/query.txt');
      return session;
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  Future<SSHSession?> cleanLogos() async{
    try {
      _client = ref.read(sshClientProvider);
      return await _client?.execute("echo '${BalloonMakers.blankKml()}' > /var/www/html/kml/slave_${ref.read(rigsProvider)}.kml");
    } catch (e) {
      print('Could not connect to host LG');
      return Future.error(e);
    }
  }

  Future<SSHSession?> showCircle(double latitude, double longitude, double radius) async{
    final double earthRadius = 6371.0;
    final int segments = 36; // Number of segments to approximate the circle

    // Convert latitude and longitude from degrees to radians
    final double latRadians = latitude * (3.1415926535897932 / 180.0);
    final double lonRadians = longitude * (3.1415926535897932 / 180.0);

    // Calculate the angular radius
    final double angularRadius = radius / earthRadius;

    // List to hold the circle coordinates
    List<String> coordinates = [];

    // Generate points along the circle
    for (int i = 0; i <= segments; i++) {
      double theta = (3.1415926535897932 * 2.0) * (i.toDouble() / segments.toDouble());
      double thetaRad = theta;
      double lat = asin(sin(latRadians) * cos(angularRadius) +
          cos(latRadians) * sin(angularRadius) * cos(thetaRad));
      double lon = lonRadians +
          atan2(sin(thetaRad) * sin(angularRadius) * cos(latRadians),
              cos(angularRadius) - sin(latRadians) * sin(lat));
      coordinates.add('${lon * (180.0 / 3.1415926535897932)},${lat * (180.0 / 3.1415926535897932)},0');
    }
    try {
      _client = ref.read(sshClientProvider);
      if (_client != null) {
        String kmlContent = BalloonMakers.showPlaceMark(latitude, longitude);
        String command = "echo '$kmlContent' > /var/www/html/kml/slave_${ref.read(rigsProvider)}.kml";
        return await _client!.execute(command);
      } else {
        print('SSH client is null. Unable to execute command.');
        return null; // Or handle the error appropriately
      }
    } catch (e) {
      print('Error occurred while executing SSH command: $e');
      return Future.error(e);
    }
  }

  Future<SSHSession?> displayPlaceMark() async{
    try {
      _client = ref.read(sshClientProvider);
      if (_client != null) {
        String kmlContent = BalloonMakers.showExample();
        String command = "echo '$kmlContent' > /var/www/html/kml/slave_${ref.read(rightmostRigProvider)}.kml";
        return await _client!.execute(command);
      } else {
        print('SSH client is null. Unable to execute command.');
        return null; // Or handle the error appropriately
      }
    } catch (e) {
      print('Error occurred while executing SSH command: $e');
      return Future.error(e);
    }
  }


  displayTriangle() async{
    try {
      _client = ref.read(sshClientProvider);
      if (_client != null) {
        String kmlContent = BalloonMakers.showTriangle();
        String command = 'echo "$kmlContent" > /tmp/query.txt';
        return await _client!.run(command);
      } else {
        print('SSH client is null. Unable to execute command.');
        return null; // Or handle the error appropriately
      }
    } catch (e) {
      print('Error occurred while executing SSH command: $e');
      return Future.error(e);
    }
  }

  flyTo(double latitude, double longitude, double zoom, double tilt,
      double bearing) async{
    try{
      _client = ref.read(sshClientProvider);
      if (_client != null) {
        String kmlContent = BalloonMakers.flyTo();
        await _client!.run('echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
      } else {
        print('SSH client is null. Unable to execute command.');
        return null; // Or handle the error appropriately
      }
    } catch (e) {
      print('Error occurred while executing SSH command: $e');
    }
  }

  showPolygon() async{
    try {
      _client = ref.read(sshClientProvider);
      if (_client != null) {
        print('Showing Circle');
        String kmlContent = BalloonMakers.showCircle();
        await _client!.execute('echo "$kmlContent" > /var/www/html/kml/slave_2.kml');
      } else {
        print('SSH client is null. Unable to execute command.');
      }
    } catch (e) {
      print('Error occurred while executing SSH command: $e');
      return Future.error(e);
    }
  }
  Future<SSHSession?> locatePlace(String place) async {
    try {
      _client = ref.read(sshClientProvider);
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      final session =
      await _client!.execute('echo "search=$place" >/tmp/query.txt');
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }
  cleanKML(context) async {
    try {
      _client = ref.read(sshClientProvider);
      await stopOrbit(context);
      await ref.read(sshClientProvider)?.execute('echo "" > /tmp/query.txt');
      await ref.read(sshClientProvider)?.execute("echo '' > /var/www/html/kmls.txt");
    } catch (error) {
      await cleanKML(context);
      // showSnackBar(
      //     context: context, message: error.toString(), color: Colors.red);
    }
  }
  cleanSlaves(context) async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        await ref
            .read(sshClientProvider)
            ?.run("echo '' > /var/www/html/kml/slave_$i.kml");
      }
    } catch (error) {
      await cleanSlaves(context);
    }
  }

  setRefresh(context) async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await ref.read(sshClientProvider)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (error) {
    }
  }
  stopOrbit(context) async {
    try {
      await ref.read(sshClientProvider)?.execute('echo "exittour=true" > /tmp/query.txt');
    } catch (error) {
      stopOrbit(context);
    }
  }

  cleanBalloon(context) async {
    try {
      _client = ref.read(sshClientProvider);
      if(_client == null){
        await ref.read(sshClientProvider)?.execute(
            "echo '${BalloonMakers.blankBalloon()}' > /var/www/html/kml/slave_${ref.read(rightmostRigProvider)}.kml");
        return;
      }

    } catch (error) {
      await cleanBalloon(context);
    }
  }

}