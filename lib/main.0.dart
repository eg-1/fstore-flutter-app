import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:core';



var geolocator = Geolocator();
var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

StreamSubscription<Position> positionStream = geolocator.getPositionStream(locationOptions).listen(
    (Position position) {
        print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
        print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
    });