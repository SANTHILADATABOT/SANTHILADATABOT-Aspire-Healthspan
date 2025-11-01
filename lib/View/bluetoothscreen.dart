import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/View/login_Screen.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BluetoothPair extends StatefulWidget {

  @override
  _BluetoothPairState createState() => _BluetoothPairState();
}

class _BluetoothPairState extends State<BluetoothPair> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  List<String> _devices = [];
  String? _registeredDevice;
  String? _pairingDevice;
  Map<String, String> _pairingStatus = {}; // Map to store pairing status

  @override
  void initState() {
    super.initState();
  }


  void _navigateToSyncScreen() {
    if (_registeredDevice != null) {
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SyncDataScreen(deviceID: _registeredDevice!)));
    }
  }

  void _navigateToSkip() {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(deviceID: '')));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppText.SDK_headings,
            style:Apptextstyle.s18wbap,),
          backgroundColor:Colors.white,
          leading: IconButton(
            onPressed: () {
              //Get.to(() => LoginScreen());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.others, // Button background color
                foregroundColor: Colors.white, // Text (and icon) color
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Text(AppText.scandevice),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: _navigateToSkip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.others, // Button background color
                foregroundColor: Colors.white, // Text (and icon) color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Text(AppText.skip),
            ),//
            SizedBox(height: 20),
            Expanded(
              child: _devices.isEmpty
                  ? Center(child: Text(AppText.nodevices))
                  : ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  String deviceID = _devices[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(deviceID),
                        subtitle: Text(
                          _pairingStatus[deviceID] ?? AppText.notpaired,
                          style: _pairingStatus[deviceID] == AppText.paired
                        ? Apptextstyle.s16wncGreen
                            : _pairingStatus[deviceID] == AppText.failed
                          ? Apptextstyle.s16wncR
                          : Apptextstyle.s16wncB,
                        ),
                        onTap: () {},
                        trailing: _pairingDevice == deviceID
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Icon(
                          Icons.bluetooth,
                          color: _pairingStatus[deviceID] == AppText.paired
                              ? AppColors.others
                              : _pairingStatus[deviceID] == AppText.failed
                              ? AppColors.Red
                              : AppColors.Grey,
                        ),
                      ),
                      const Divider(height: 0.5, thickness: 0.5),
                    ],
                  );
                },
              ),
            ),
            if (_registeredDevice != null) ...[
              Divider(),
              Text(
                "Registered Device: $_registeredDevice",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _navigateToSyncScreen,
                child: Text(AppText.syncdata),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
