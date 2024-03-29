import 'package:flutter/material.dart';

class UserSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Setting'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Text("Tutorial"),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/Tutorial1');
                },
              ),
              ElevatedButton(
                child: Text("About us"),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/Aboutus');
                },
              ),
              ElevatedButton(
                child: Text("Logout"),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomNavigationBar(
            selectedItemColor: Colors.grey,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
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
        ));
  }
}
