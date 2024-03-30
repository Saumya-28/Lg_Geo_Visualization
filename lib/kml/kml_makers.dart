import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers.dart';
import '../utils/constants.dart';



class KMLMakers {
  static screenOverlayImage(String imageUrl, double factor) =>
      '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document id ="logo">
         <name>Smart City Dashboard</name>
             <Folder>
                  <name>Splash Screen</name>
                  <ScreenOverlay>
                      <name>Logo</name>
                      <Icon><href>$imageUrl</href> </Icon>
                      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                      <screenXY x="0.025" y="0.95" xunits="fraction" yunits="fraction"/>
                      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                      <size x="300" y="${300 * factor}" xunits="pixels" yunits="pixels"/>
                  </ScreenOverlay>
             </Folder>
    </Document>
</kml>''';

  static String screenOverlayText(String text1, String text2, double factor) => '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="logo">
    <name>Smart City Dashboard</name>
    <Folder>
      <name>Splash Screen</name>
      <ScreenOverlay>
        <name>Text Overlay</name>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.025" y="0.95" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="300" y="${300 * factor}" xunits="pixels" yunits="pixels"/>
        <description><![CDATA[
          <div style="text-align: center;">
            <p style="font-size: 20px; font-weight: bold; color: black;">$text1</p>
            <p style="font-size: 20px; font-weight: bold; color: black;">$text2</p>
          </div>
        ]]></description>
      </ScreenOverlay>
    </Folder>
  </Document>
</kml>''';



  static String lookAtLinear(double latitude, double longitude, double zoom,
          double tilt, double bearing) =>
      '<LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

  static String lookAt(CameraPosition camera, bool scaleZoom) => '''<LookAt>
  <longitude>${camera.target.longitude}</longitude>
  <latitude>${camera.target.latitude}</latitude>
  <range>${scaleZoom ? camera.zoom.zoomLG : camera.zoom}</range>
  <tilt>${camera.tilt}</tilt>
  <heading>${camera.bearing}</heading>
  <gx:altitudeMode>relativeToGround</gx:altitudeMode>
</LookAt>''';

  static String orbitLookAtLinear(double latitude, double longitude,
          double zoom, double tilt, double bearing) =>
      '<gx:duration>2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

  static String lookAtLinearInstant(double latitude, double longitude,
          double zoom, double tilt, double bearing) =>
      '<gx:duration>0.5</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

/*  static String buildTourOfCityAbout(WidgetRef ref) {
    String lookAts = '';

    for (var location in ref.read(cityDataProvider)!.availableTours) {
      lookAts += '''<gx:FlyTo>
  <gx:duration>5.0</gx:duration>
  <gx:flyToMode>bounce</gx:flyToMode>
  ${lookAt(CameraPosition(target: location, zoom: Const.tourZoomScale, tilt: 30), true)}
</gx:FlyTo>
''';
    }

    lookAts += '''<gx:FlyTo>
  <gx:duration>5.0</gx:duration>
  <gx:flyToMode>bounce</gx:flyToMode>
  ${lookAt(ref.read(lastGMapPositionProvider)!, false)}
</gx:FlyTo>
''';

    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
   <gx:Tour>
   <name>Orbit</name>
      <gx:Playlist>
         $lookAts
      </gx:Playlist>
   </gx:Tour>
</kml>''';
  }*/
}
extension ZoomLG on num {
  double get zoomLG =>
      Const.lgZoomScale / pow(2, this); // Formula to match zoom of GMap with LG
}