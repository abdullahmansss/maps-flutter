import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  late GoogleMapController _controller;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget adWidget = AdWidget(ad: myBanner);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AdWidget(ad: myBanner),
            Expanded(
              child: GoogleMap(
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                compassEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                mapType: MapType.hybrid,
                markers: markers.values.toSet(),
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) async {
                  _controller = controller;


                  const LocationSettings locationSettings = LocationSettings(
                    accuracy: LocationAccuracy.best,
                    distanceFilter: 100,
                  );

                  // Geolocator.getPositionStream(
                  //     locationSettings: locationSettings,
                  // ).listen(
                  //         (Position value) {
                  //
                  //           final marker = Marker(
                  //             markerId: const MarkerId('place_name'),
                  //             position: LatLng(
                  //               value.latitude,
                  //               value.longitude,
                  //             ),
                  //             infoWindow: const InfoWindow(
                  //               title: 'title',
                  //               snippet: 'address',
                  //             ),
                  //           );
                  //
                  //           setState(() {
                  //             markers[const MarkerId('place_name')] = marker;
                  //           });
                  //
                  //           _controller.animateCamera(
                  //             CameraUpdate.newCameraPosition(
                  //               CameraPosition(
                  //                 target: LatLng(
                  //                   value.latitude,
                  //                   value.longitude,
                  //                 ),
                  //                 zoom: 17.0,
                  //               ),
                  //             ),
                  //           );
                  //     });

                  determinePosition().then((value) {
                    _controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            value.latitude,
                            value.longitude,
                          ),
                          zoom: 16.0,
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: adWidget,
              width: myBanner.size.width.toDouble(),
              height: myBanner.size.height.toDouble(),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  void _goToTheLake() async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}

// AIzaSyACbkNR08VnxiIfnekxOfMV6TLuCcNoox8

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
