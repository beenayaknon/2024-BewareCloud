import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  Location location = Location();

  Future<bool> requestPermission() async {
    final permission = await location.requestPermission();
    return permission == PermissionStatus.granted;
  }

  Future<LocationData> getCurrentLocation() async {
    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      final result = await location.requestService();
      if (!result) {
        throw Exception('GPS service not enabled');
      }
    }

    final locationData = await location.getLocation();
    return locationData;
  }

  // Use this method to get the city name from location data
  Future<String> getCityNameFromLocation(LocationData locationData) async {
    try {
      // Check if latitude and longitude are not null
      if (locationData.latitude == null || locationData.longitude == null) {
        return "Location data is incomplete";
      }

      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks.first;
        return "${place.locality}, ${place.country}";
      } else {
        return "Unknown location";
      }
    } catch (e) {
      // Return or log the error message
      return "Failed to get city name: $e";
    }
  }
}

class WeatherForecast extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherForecast> {
  final String apiKey = 'dbc6ddcf06754a25bd1134032242002';
  final LocationService _locationService = LocationService();
  LocationData? _currentLocation;
  String _locationInfo = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchLocationAndCity();
  }

  Future<void> _fetchLocationAndCity() async {
    bool permissionGranted = await _locationService.requestPermission();
    if (permissionGranted) {
      try {
        LocationData locationData = await _locationService.getCurrentLocation();
        // Check if latitude and longitude are not null
        if (locationData.latitude != null && locationData.longitude != null) {
          String cityName =
              await _locationService.getCityNameFromLocation(locationData);
          setState(() {
            _currentLocation = locationData;
            _locationInfo = cityName; // Now storing the city name
          });
        } else {
          setState(() {
            _locationInfo = "Location data incomplete";
          });
        }
      } catch (e) {
        setState(() {
          _locationInfo = "Failed to get location: $e";
        });
      }
    } else {
      setState(() {
        _locationInfo = "Location permission not granted";
      });
    }
  }

  // Fetch weather forecast data
  Future<Map<String, dynamic>> fetchWeatherForecast() async {
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$_locationInfo&days=10&aqi=no');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather forecast data');
    }
  }
  @override
  Widget build(BuildContext context) {
    const double fem = 1.0;
    const double ffem = 1.0;
    return Scaffold(
        backgroundColor: Color(0xFFF8FAFB),
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset(
                'assets/icon/back.png',
                width:25 * fem,
                height: 25 * fem,
                fit: BoxFit.cover
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Weather');
            },
          ),
          title: Text('Weather Forecast'),
          titleTextStyle: TextStyle(
            fontFamily: 'Heebo',
            fontSize: 32 * ffem,
            fontWeight: FontWeight.w700,
            color: Color(0xff000000),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(40 * fem, 40 * fem, 40 * fem, 0 * fem),
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(_locationInfo,
                  style: TextStyle(
                    fontFamily: 'Heebo',
                    fontSize: 20 * ffem,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff000000),
                  )
              ),
              SizedBox(height: 10),
              FutureBuilder<Map<String, dynamic>>(
                future: fetchWeatherForecast(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text(
                        'Error fetching weather forecast: ${snapshot.error}');
                  } else {
                    // Assuming data is returned in the desired format
                    var forecastData = snapshot.data!;
                    List<Widget> forecastWidgets = [];
                    var forecastDays = forecastData['forecast']['forecastday'];

                    for (var day in forecastDays) {
                      var date = day['date'];
                      var temp = day['day']['avgtemp_c'];
                      var maxTemp = day['day']['maxtemp_c'];
                      var minTemp = day['day']['mintemp_c'];
                      var condition = day['day']['condition']['text'];
                      String iconUrl = day['day']['condition']['icon'];

                      if (!iconUrl.startsWith('http')) {
                        iconUrl = 'http:$iconUrl';
                      }

                      forecastWidgets.add(
                        Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          padding: EdgeInsets.all(10.0),
                          constraints: BoxConstraints(
                            minHeight:
                                120.0, // Minimum height: adjust accordingly
                            maxWidth: double
                                .infinity, // Assuming you want to stretch across the width
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xffE7F5FF),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [ // Add shadow behind each card
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Text('$date',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(height: 30),
                                    Row(
                                      children: [
                                        Image.network(iconUrl, width: 30, // Set the size as needed
                                            height: 30,
                                            fit: BoxFit.cover), // Display weather icon
                                        SizedBox(width: 5),
                                        Text('$condition',
                                            style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 25),
                                    Text('$temp°',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 30 * ffem,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff000000),)
                                    ),
                                    Text('${maxTemp}° / ${minTemp}°',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 16 * ffem,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff000000),)
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: forecastWidgets,
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
        /*
        bottomNavigationBar: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: Color(0xFFffffff),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            type: BottomNavigationBarType
                .fixed, // Ensure all text labels are visible
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'Weather',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/Home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/Activity');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/Weather');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/UserSetting');
                  break;
              }
            },
          ),
        )*/
    );

  }
}
