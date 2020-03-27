import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

void main() {
  runApp(const NavigationApp());
}

class NavigationApp extends StatefulWidget {
  const NavigationApp({Key key}) : super(key: key);

  @override
  _NavigationAppState createState() => _NavigationAppState();
}

class _NavigationAppState extends State<NavigationApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageA(),
      routes: <String, WidgetBuilder>{
        'pageB': (BuildContext context) => PageB(),
      },
    );
  }
}

class PageA extends StatefulWidget {
  @override
  _PageAState createState() => _PageAState();
}

class _PageAState extends State<PageA> {
  List<LatLng> data = <LatLng>[];
  List<String> places = <String>[];
  final List<String> formattedAdresses = <String>[];

  Future<void> getPlaces(LatLng position) async {
    final Client client = Client();
    final Response result = await client.get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyDCd7nDl8dQExpPi120tQTBPNeJf1XyvAg');
    final String body = result.body;
    print(body);

    final Map<String, dynamic> placesData = jsonDecode(body);
    final String places = placesData['results'][0]['formatted_address'];
    setState(() {
      formattedAdresses.add(places);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page A'),
      ),
      body: ListView.builder(
        itemCount: formattedAdresses.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('${formattedAdresses[index]}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return PageB(
                      location: data[index],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final dynamic pos = await Navigator.pushNamed(context, 'pageB');
          if (pos != null) {
            setState(() {
              data.add(pos);
            });
            await getPlaces(pos);
          }
        },
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({Key key, this.location}) : super(key: key);
  final LatLng location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page B'),
      ),
      body: GoogleMap(
        markers: <Marker>{
          if (location != null)
            Marker(
              markerId: MarkerId('nu am habar de nimic'),
              position: location,
            )
        },
        onTap: (LatLng position) {
          Navigator.pop(context, position);
        },
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(47.0, 24.0),
          zoom: 11.0,
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {}
}
