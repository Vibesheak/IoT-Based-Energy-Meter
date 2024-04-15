import 'package:flutter/material.dart';
import 'package:vibesheak_s_application11/core/app_export.dart';
import 'package:vibesheak_s_application11/widgets/app_bar/appbar_leading_iconbutton.dart';
import 'package:vibesheak_s_application11/widgets/app_bar/appbar_title.dart';
import 'package:vibesheak_s_application11/widgets/app_bar/custom_app_bar.dart';
import 'package:vibesheak_s_application11/widgets/custom_text_form_field.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key})
      : super(
          key: key,
        );

  //TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(context),
        body: Container(
          width: SizeUtils.width,
          height: SizeUtils.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.5, 1.01),
              end: Alignment(0.5, 0),
              colors: [
                appTheme.whiteA700,
                appTheme.blue5002,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 80.v),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.h),
                  child: Text(
                    //controller: amountController,
                        "Month     |     Kwh     |     Bill Amount",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0, // Adjust the font size as needed
                    ),
                  ),
                ),
                SizedBox(height: 26.v),
                Container(
                  height: 678.v,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.h),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment(0.5, 0.98),
                      end: Alignment(0.5, 0),
                      colors: [
                        appTheme.whiteA700,
                        appTheme.blue5001,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 70.h,
      leading: AppbarLeadingIconbutton(
        imagePath: ImageConstant.imgBack,
        margin: EdgeInsets.only(
          left: 38.h,
          top: 9.v,
          bottom: 14.v,
        ),
      ),
      centerTitle: true,
      title: AppbarTitle(
        text: "Usage History"
      ),
    );
  }
}
