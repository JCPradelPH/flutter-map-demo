
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceMarkerBody extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<PlaceMarkerBody> {
    static final LatLng makati = const LatLng(14.569120, 121.026154);
    static const double ZOOM_LEVEL = 12;
    final BitmapDescriptor markerImage = BitmapDescriptor.fromAsset("assets/loc.bmp");
    final BitmapDescriptor markerImageTap = BitmapDescriptor.fromAsset("assets/markerinfo.png");
    GoogleMapController controller;
    Marker _selectedMarker;
    bool _updatingLoc = false;
    GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            key: globalKey,
            body: Container(
                child: Stack(
                    children: <Widget>[
                        _mainMap(),
                        _navigateButton(),
                        _updatingLoc ? _pageLoader() : Container()
                    ],
                ),
            ),
        );
    }

    @override
    void dispose() {
        controller.removeListener(_listener);
        super.dispose();
    }

    Widget _pageLoader() => Container(
        color: Color.fromRGBO(255, 255, 255, 0.3),
        child: Center(
            child: Image(image: AssetImage("assets/loading.gif"))
        )
    ) ;

    GoogleMap _mainMap() => GoogleMap(
        onMapCreated: _onMapCreated,
        options: GoogleMapOptions(
            trackCameraPosition: true,
            cameraPosition: CameraPosition(
                target: makati,
                zoom: ZOOM_LEVEL
            )
        ),
    );

    Widget _navigateButton() => Positioned(
        bottom: 10,
        right: 10,
        child: RaisedButton(
            color: Color.fromRGBO(0, 91, 171, 1.0),
            child: Row(
                children: <Widget>[
                    Icon(Icons.gps_fixed, color: Colors.white),
                    Text("Navigate To Origin", style: TextStyle(color: Colors.white),)
                ],
            ),
            onPressed: (){
                controller.animateCamera(
                    CameraUpdate.newCameraPosition( CameraPosition(target: makati, zoom: ZOOM_LEVEL) )
                );
            }
        )
    );

    SnackBar _successSnackbar(double height) => SnackBar(content: Container(
        height: height,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                Text("Location Saved!"),
                Text("Latitude: ${
                    controller.cameraPosition.target.latitude.toString()
                } - Longitude: ${controller.cameraPosition.target.latitude.toString()}")
            ],
        )
    ));


    Future<Marker> _addInitialMarker() async {
        return await controller.addMarker(MarkerOptions(
            position: LatLng(
                makati.latitude,
                makati.longitude,
            ),
            icon: markerImageTap,
        ));
    }

    void _onMapCreated(GoogleMapController controller) async {
        this.controller = controller;
        controller.addListener(_listener);
        controller.onMarkerTapped.add(_markerTapped);
        _selectedMarker = await _addInitialMarker();
    }

    void _markerTapped(Marker marker){
        setState(() { _updatingLoc = true; });
        globalKey.currentState.showSnackBar(SnackBar(content: Text("Saving location...")));
        _changePosition(markerImage);
        Future.delayed(Duration(seconds: 3), (){ // delay to mock firestore request when saving location
            AppBar appBar = AppBar();
            globalKey.currentState.hideCurrentSnackBar();
            globalKey.currentState.showSnackBar(_successSnackbar(appBar.preferredSize.height));
            setState(() { _updatingLoc = false; });
            _changePosition(markerImageTap);
        });
    }

    void _listener(){
        if(!controller.isCameraMoving && _selectedMarker != null && !_updatingLoc){
            _changePosition(markerImageTap);
        }
    }

    void _updateSelectedMarker(MarkerOptions changes) {
        controller.updateMarker(_selectedMarker, changes);
    }

    void _changePosition(BitmapDescriptor icon, {InfoWindowText infoWindowText}) {
        _updateSelectedMarker(
            MarkerOptions(
                position: LatLng(
                    controller.cameraPosition.target.latitude ,
                    controller.cameraPosition.target.longitude ,
                ),
                icon: icon,
                infoWindowText: infoWindowText
            ),
        );
    }
}