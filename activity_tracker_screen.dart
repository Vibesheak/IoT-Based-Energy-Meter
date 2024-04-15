import 'package:flutter/material.dart';
import 'package:vibesheak_s_application11/core/app_export.dart';
import 'package:vibesheak_s_application11/widgets/custom_elevated_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../profile_screen/profile_screen.dart';

class MyHomePage extends StatefulWidget {
  @override
  ActivityTrackerScreen createState() => ActivityTrackerScreen();
}

class ActivityTrackerScreen extends State<MyHomePage> {
  // const ActivityTrackerScreen({Key? key})
  //     : super(
  //         key: key,
  //       );
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  String valueFromFirebaseVoltage = "";
  String valueFromFirebaseCurrent = "";
  String valueFromFirebasePower = "";
  String valueFromFirebaseKwh = "";
  String valueFromFirebaseBill = "";

  @override
  void initState() {
    super.initState();
    // Start listening to the stream when the widget is created
    _listenToFirebaseStreamVoltage();
    _listenToFirebaseStreamCurrent();
    _listenToFirebaseStreamPower();
    _listenToFirebaseStreamKwh();
    _listenToFirebaseStreamBill();
  }

  void _listenToFirebaseStreamVoltage() {
    // Replace "your_path" with the actual path to your data in the Realtime Database
    _database.child('EnergyData/Voltage').onValue.listen((event) {
      // Handle the event when the data at the specified path changes
      if (event.snapshot.value != null) {
        setState(() {
          // Assuming the data is of type int, adjust to the correct type
          valueFromFirebaseVoltage = event.snapshot.value.toString();
        });
      } else {
        print("Data from Firebase is null");
      }
    },onError: (error) {
      print("Error listening to Firebase stream: $error");
    });
  }
  void _listenToFirebaseStreamCurrent() {
    // Replace "your_path" with the actual path to your data in the Realtime Database
    _database.child('EnergyData/Current').onValue.listen((event) {
      // Handle the event when the data at the specified path changes
      if (event.snapshot.value != null) {
        setState(() {
          // Assuming the data is of type int, adjust to the correct type
          valueFromFirebaseCurrent = event.snapshot.value.toString();
        });
      } else {
        print("Data from Firebase is null");
      }
    },onError: (error) {
      print("Error listening to Firebase stream: $error");
    });
  }

  void _listenToFirebaseStreamPower() {
    // Replace "your_path" with the actual path to your data in the Realtime Database
    _database.child('EnergyData/Power').onValue.listen((event) {
      // Handle the event when the data at the specified path changes
      if (event.snapshot.value != null) {
        setState(() {
          // Assuming the data is of type int, adjust to the correct type
          valueFromFirebasePower = event.snapshot.value.toString();
        });
      } else {
        print("Data from Firebase is null");
      }
    },onError: (error) {
      print("Error listening to Firebase stream: $error");
    });
  }

  void _listenToFirebaseStreamKwh() {
    // Replace "your_path" with the actual path to your data in the Realtime Database
    _database.child('EnergyData/KWh').onValue.listen((event) {
      // Handle the event when the data at the specified path changes
      if (event.snapshot.value != null) {
        setState(() {
          // Assuming the data is of type int, adjust to the correct type
          valueFromFirebaseKwh = event.snapshot.value.toString();
        });
      } else {
        print("Data from Firebase is null");
      }
    },onError: (error) {
      print("Error listening to Firebase stream: $error");
    });
  }

  void _listenToFirebaseStreamBill() {
    // Replace "your_path" with the actual path to your data in the Realtime Database
    _database.child('EnergyData/Bill').onValue.listen((event) {
      // Handle the event when the data at the specified path changes
      if (event.snapshot.value != null) {
        setState(() {
          // Assuming the data is of type int, adjust to the correct type
          valueFromFirebaseBill = event.snapshot.value.toString();
        });
      } else {
        print("Data from Firebase is null");
      }
    },onError: (error) {
      print("Error listening to Firebase stream: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          width: SizeUtils.width,
          height: SizeUtils.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.5, 1.17),
              end: Alignment(0.5, 0.01),
              colors: [
                appTheme.whiteA700,
                appTheme.blue50,
              ],
            ),
          ),
          child: Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 3.h),
                  child: Text(
                    "Electricity Usage",
                    style: CustomTextStyles.headlineSmallBold,
                  ),
                ),
                SizedBox(height: 19.v),
                _buildElectricityUsageButton(context),
                SizedBox(height: 21.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 6.h,
                    right: 2.h,
                  ),
                  child: _buildElectricityUsageThree(
                    context,
                    currentText: "Voltage (V)",
                    zeroText: "$valueFromFirebaseVoltage",
                  ),
                ),
                SizedBox(height: 14.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 6.h,
                    right: 2.h,
                  ),
                  child: _buildElectricityUsageThree(
                    context,
                    currentText: "Current (A)",
                    zeroText: "$valueFromFirebaseCurrent",
                  ),
                ),
                SizedBox(height: 13.v),
                Padding(
                  padding: EdgeInsets.only(
                    left: 6.h,
                    right: 2.h,
                  ),
                  child: _buildElectricityUsageThree(
                    context,
                    currentText: " Power (W)",
                    zeroText: "$valueFromFirebasePower",
                  ),
                ),
                SizedBox(height: 25.v),
                _buildElectricityUsageAction(context),
                SizedBox(height: 26.v),
                _buildElectricityUsageSeven(context),
                SizedBox(height: 5.v),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildElectricityUsageButton(BuildContext context) {
    return Container(
      width: 307.h,
      margin: EdgeInsets.only(
        left: 6.h,
        right: 2.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 25.h,
        vertical: 21.v,
      ),
      decoration: AppDecoration.outlineBlack.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 30.v,
            width: 112.h,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 30.v,
                    width: 112.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        15.h,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment(1, 1),
                        end: Alignment(-0.24, -0.31),
                        colors: [
                          appTheme.indigoA100,
                          appTheme.blue200,
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 31.h),
                    child: Text(
                      "Kwh",
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 7.v),
          Padding(
            padding: EdgeInsets.only(left: 86.h),
            child: Text(
              "$valueFromFirebaseKwh",
              style: theme.textTheme.headlineSmall,
            ),
          ),
          SizedBox(height: 16.v),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildElectricityUsageAction(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 2.h),
      padding: EdgeInsets.symmetric(
        horizontal: 20.h,
        vertical: 14.v,
      ),
      decoration: AppDecoration.gradientIndigoAToBlue.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 32.h,
              top: 5.v,
              bottom: 2.v,
            ),
            child: Text(
              "Usage History",
              style: CustomTextStyles.titleSmallGray900,
            ),
          ),
          CustomElevatedButton(
            width: 68.h,
            text: "Check",
            margin: EdgeInsets.only(top: 1.v),
            buttonStyle: CustomButtonStyles.none,
            decoration: CustomButtonStyles.gradientIndigoAToBlueDecoration,
            onPressed: () {
              // Navigate to the second page when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildElectricityUsageSeven(BuildContext context) {
    return Container(
      height: 167.v,
      width: 315.h,
      margin: EdgeInsets.only(left: 2.h),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: AppDecoration.gradientIndigoAToBlue200.copyWith(
                borderRadius: BorderRadiusStyle.roundedBorder22,
              ),
              child: CustomImageView(
                imagePath: ImageConstant.imgBannerDots,
                height: 167.v,
                width: 315.h,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: 18.h,
                top: 25.v,
                right: 23.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 136.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 19.h,
                          vertical: 2.v,
                        ),
                        decoration:
                            AppDecoration.gradientDeepPurpleAToPink.copyWith(
                          borderRadius: BorderRadiusStyle.roundedBorder15,
                        ),
                        child: Text(
                          "Bill Amount",
                          style: CustomTextStyles.titleMediumWhiteA700,
                        ),
                      ),
                      CustomElevatedButton(
                        height: 31.v,
                        width: 83.h,
                        text: "January",
                        buttonStyle: CustomButtonStyles.none,
                        decoration:
                            CustomButtonStyles.gradientIndigoAToBlueDecoration,
                        buttonTextStyle: theme.textTheme.bodyMedium!,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.v),
                  SizedBox(
                    width: 101.h,
                    child: Text(
                      "RS . \n      $valueFromFirebaseBill",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.titleMediumGray900Medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Common widget
  Widget _buildElectricityUsageThree(
    BuildContext context, {
    required String currentText,
    required String zeroText,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 38.h,
        vertical: 9.v,
      ),
      decoration: AppDecoration.outlineBlack.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 3.v),
            child: Text(
              currentText,
              style: theme.textTheme.titleSmall!.copyWith(
                color: appTheme.black900,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 24.h),
            child: Text(
              zeroText,
              style: theme.textTheme.titleMedium!.copyWith(
                color: appTheme.black900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
