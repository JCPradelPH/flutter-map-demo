import 'package:flutter/material.dart';
import 'package:google_map_demo/place_marker_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
			title: 'Flutter Maps Demo',
			theme: new ThemeData(
				primarySwatch: Colors.blue,
			),
			home: PlaceMarkerBody(),
		);
    }
}