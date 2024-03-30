import 'dart:ffi';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/constants.dart';



class BalloonMakers{
  static dashboardBalloon({
    CameraPosition  = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 0.0,
    ),
    String cityName = "adf",
    String tabName = "",
    double height = 0.0,
  }) =>
      '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
 <name>About Data</name>
 <Style id="about_style">
   <BalloonStyle>
     <textColor>ffffffff</textColor>
     <text>
        <h1>Saumya</h1> 
        <h1>Kolkata</h1>
        
     </text>
     <bgColor>ff15151a</bgColor>
   </BalloonStyle>
 </Style>
 <Placemark id="ab">
   <description>
   </description>
   <LookAt>
     <longitude>${Const.longitude}</longitude>
     <latitude>${Const.latitude}</latitude>
     <heading>0.0</heading>
     <tilt>0.0</tilt>
     <range>11</range>
   </LookAt>
   <styleUrl>#about_style</styleUrl>
   <gx:balloonVisibility>1</gx:balloonVisibility>
   <Point>
     <coordinates>${Const.longitude},${Const.latitude},0</coordinates>
   </Point>
 </Placemark>
</Document>
</kml>''';

  static blankKml() => ''' 
    <?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
  </Document>
</kml>
  ''';
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

  static showPlaceMark(double latitude, double longitude) => '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Placemark with Fly-To</name>
    <LookAt>
      <longitude>$longitude</longitude>
      <latitude>$latitude</latitude>
      <altitude>0</altitude>
      <heading>0</heading>
      <tilt>0</tilt>
      <range>1000</range> <!-- Distance from the point in meters -->
      <altitudeMode>relativeToGround</altitudeMode>
    </LookAt>
    <Placemark>
      <name>Simple placemark</name>
      <description>Attached to the ground. Intelligently places itself 
         at the height of the underlying terrain.</description>
      <Point>
        <coordinates>$longitude,$latitude,0</coordinates>
      </Point>
    </Placemark>
  </Document>
</kml>
''';




  static showExample() {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
 <kml xmlns="http://www.opengis.net/kml/2.2">
  <Placemark>
    <name>Simple placemark</name>
    <description>Attached to the ground. Intelligently places itself at the height of the underlying terrain.</description>
    <Point>
      <coordinates>88.513688,22.465971,0</coordinates>
    </Point>
  </Placemark>
</kml>''';
  }


  static String showTriangle() {
    // Coordinates of the center point
    double centerLongitude = 88.351346;
    double centerLatitude = 22.547231;

    // Approximate distance in degrees for 10km at this latitude
    double deltaLatitude = 0.090135; // Approximately 1 degree is about 111.32 km
    double deltaLongitude = 0.080841; // Adjusted for the longitude change with latitude

    // Coordinates of the vertices
    double vertex1Longitude = centerLongitude;
    double vertex1Latitude = centerLatitude + deltaLatitude;

    double vertex2Longitude = centerLongitude + deltaLongitude;
    double vertex2Latitude = centerLatitude;

    double vertex3Longitude = centerLongitude - deltaLongitude;
    double vertex3Latitude = centerLatitude;

    return '''
<?xml version="1.0" encoding="UTF-8"?>
    <kml xmlns="http://www.opengis.net/kml/2.2">
      <Document>
        <Placemark>
          <name>Triangle</name>
          <Polygon>
            <outerBoundaryIs>
              <LinearRing>
                <coordinates>
                  $vertex1Longitude,$vertex1Latitude,0
                  $vertex2Longitude,$vertex2Latitude,0
                  $vertex3Longitude,$vertex3Latitude,0
                  $vertex1Longitude,$vertex1Latitude,0
                </coordinates>
              </LinearRing>
            </outerBoundaryIs>
          </Polygon>
        </Placemark>
      </Document>
    </kml>
  ''';
  }




  static String showCircle() {
    double centerLatitude = 25.557054;
    double centerLongitude = 88.353560;
    double radiusInKm = 50.0;
    int numberOfPoints = 360;

    String kml = '''
<?xml version='1.0' encoding='UTF-8'?>
<kml xmlns='http://www.opengis.net/kml/2.2'>
  <Document>
    <Placemark>
      <name>Circular Polygon</name>
      <Polygon>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
''';

    // Calculate circle coordinates
    for (int i = 0; i < numberOfPoints; i++) {
      double angle = (i * 360.0) / numberOfPoints;
      double latitude = centerLatitude + (radiusInKm / 111.32) * cos(angle * pi / 180.0);
      double longitude = centerLongitude + (radiusInKm / (111.32 * cos(centerLatitude * pi / 180.0))) * sin(angle * pi / 180.0);
      kml += '$longitude,$latitude,0\n';
    }

    kml += '''
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
    </Placemark>
  </Document>
</kml>
''';

    return kml;
  }



  static flyTo() => '''
  <?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>FlyTo Example</name>
    <Camera>
      <longitude>88.513688</longitude>
      <latitude>22.465971</latitude>
      <altitude>1000</altitude>
      <heading>0</heading>
      <tilt>0</tilt>
      <roll>0</roll>
      <altitudeMode>absolute</altitudeMode>
    </Camera>
    <LookAt>
      <longitude>88.513688</longitude>
      <latitude>22.465971</latitude>
      <altitude>0</altitude>
      <heading>0</heading>
      <tilt>0</tilt>
      <range>1000</range>
      <altitudeMode>absolute</altitudeMode>
    </LookAt>
  </Document>
</kml>''';
  static blankBalloon() => '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
 <name>None</name>
 <Style id="blank">
   <BalloonStyle>
     <textColor>ffffffff</textColor>
     <text></text>
     <bgColor>ff15151a</bgColor>
   </BalloonStyle>
 </Style>
 <Placemark id="bb">
   <description></description>
   <styleUrl>#blank</styleUrl>
   <gx:balloonVisibility>0</gx:balloonVisibility>
   <Point>
     <coordinates>0,0,0</coordinates>
   </Point>
 </Placemark>
</Document>
</kml>''';
}


