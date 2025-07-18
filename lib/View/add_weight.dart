
import 'package:azpire_new/Controller/addweight_controller.dart';
import 'package:azpire_new/Model/addweight_model.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../utils/app_color.dart';
import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';
import 'package:cupertino_height_picker/cupertino_height_picker.dart';



class AddWeight extends StatefulWidget {
  @override
  State<AddWeight> createState() => _AddWeightState();
}

class _AddWeightState extends State<AddWeight> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController height = TextEditingController();
  final DateFormat _dateFormat = DateFormat('MM-dd-yyyy');
  bool isLoading = false;
  String? mainDate; // Variable to store the fetched date
  int? weekhearrtrate; // Variable to store the systolic value
  var bmi1;
  List<WeightChart> chartData = [];
  final AddWeightController addweightcontroller = Get.put(AddWeightController());
  int? heightFeet;
  int? heightInches;

  @override
  void initState() {
    Weight_Chart();
    // TODO: implement initState
    super.initState();
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> showHeightPicker(BuildContext context) async {
    int initFeet = heightFeet ?? 5;
    int initInches = heightInches ?? 6;

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Feet Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: initFeet),
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        heightFeet = index;
                      },
                      children: List.generate(8, (i) => Text("$i ft")),
                    ),
                  ),
                  // Inches Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: initInches),
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        heightInches = index;
                      },
                      children: List.generate(12, (i) => Text("$i in")),
                    ),
                  ),
                ],
              ),
            ),
            // CupertinoButton.filled(
            //   child: Text("Done"),
            //   onPressed: () {
            //     setState(() {
            //       heightFeet ??= initFeet;
            //       heightInches ??= initInches;
            //       height.text = "${heightFeet!} ft ${heightInches!} in";
            //     });
            //     Navigator.of(context).pop();
            //   },
            // )
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: AppColors.button
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  borderRadius: BorderRadius.circular(8),
                  child: Text(
                    "Done",
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                  onPressed: () {
                    setState(() {
                      heightFeet ??= initFeet;
                      heightInches ??= initInches;
                      height.text = "${heightFeet!} ft ${heightInches!} in";
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            )

          ],
        ),
      ),
    );
  }





  Future<void> Weight_Chart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await addweightcontroller.Weight_Chart(userId: '102');
      setState(() {
        chartData = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading daily average weight chart: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  void check() {
    if (_dateController.text.isEmpty || _dateController.text == "Select Date") {
      showToast("Kindly Select a Valid Date");
    } else if (weight.text.isEmpty) {
      showToast("Kindly Enter Your Weight");
    } else {
      add_data();
    }
  }

  Future<void> add_data() async {
    // if (heightFeet == null || heightInches == null) {
    //   showToast("Please select a valid height.");
    //   return;
    // }

    addweightcontroller.addData(
      dateController: _dateController,
      weightController: weight,
      dateFormat: _dateFormat,
      context: context,
      showToast: showToast,
      weightChartCallback: Weight_Chart,
      heightFeet: heightFeet!,        // ✅ now safe to use !
      heightInches: heightInches!,    // ✅ now safe to use !
    );
  }


  @override
  void dispose() {
    _dateController.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFffffff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(AppText.add_weight_headings,style: Apptextstyle.s18wbap),
      ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 40,),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(left: 20),
          //       child: Container(
          //         constraints: BoxConstraints(maxWidth: size.width * 0.6),
          //         decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.transparent)),
          //         width: size.width * 0.4,
          //         child: TextFormField(
          //           controller: _dateController,
          //           style: TextStyle(fontSize: 14),
          //           readOnly: true,
          //           onTap: () {
          //             _selectDate(context);
          //           },
          //           decoration: InputDecoration(
          //
          //             border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.all(Radius.circular(10))
          //             ),
          //             hintText: "Select Date",
          //             suffixIcon: Icon(Icons.calendar_month,color: Color(0xFF365c7f),),
          //           ),
          //         ),
          //       ),
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(right: 10),
          //       child: Container(
          //         constraints: BoxConstraints(maxWidth: size.width * 0.6),
          //         decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.transparent)),
          //         width: size.width * 0.5,
          //         child: TextFormField(
          //           controller: weight,
          //           readOnly: false,
          //           style: TextStyle(fontSize: 14),
          //           keyboardType: TextInputType.number,
          //           decoration: InputDecoration(
          //             border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.all(Radius.circular(10))
          //             ),
          //
          //             hintText: "Enter Weight(lbs)",
          //             hintStyle: TextStyle(fontSize: 13),
          //             suffixIcon: Icon(Icons.content_paste_rounded,color: Color(0xFF365c7f),),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       Container(
          //         constraints: BoxConstraints(maxWidth: size.width * 0.6),
          //         decoration: BoxDecoration(color: Colors.white,border: Border.all(color: Colors.transparent)),
          //         width: size.width * 0.5,
          //         child: TextFormField(
          //           controller: weight,
          //           readOnly: false,
          //           style: TextStyle(fontSize: 14),
          //           keyboardType: TextInputType.number,
          //           decoration: InputDecoration(
          //             border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.all(Radius.circular(10))
          //             ),
          //
          //             hintText: "Enter Height (In Inches)",
          //             hintStyle: TextStyle(fontSize: 13),
          //             suffixIcon: Icon(Icons.content_paste_rounded,color: Color(0xFF365c7f),),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: size.width * 0.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.transparent),
                    ),
                    width: size.width * 0.48,
                    child: GestureDetector(
                      onTap: () => showHeightPicker(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: height,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Select Height",
                            hintStyle: TextStyle(fontSize: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: Icon(Icons.height, color: Color(0xFF365c7f)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: size.width * 0.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.transparent),
                    ),
                    width: size.width * 0.48,
                    child: TextFormField(
                      controller: weight,
                      style: TextStyle(fontSize: 14),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintText: "Enter Weight (lbs)",
                        hintStyle: TextStyle(fontSize: 13),
                        suffixIcon: Icon(
                          Icons.content_paste_rounded,
                          color: Color(0xFF365c7f),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(
                  constraints: BoxConstraints(maxWidth: size.width * 0.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.transparent),
                  ),
                  width: size.width * 0.48,
                  child: TextFormField(
                    controller: _dateController,
                    style: TextStyle(fontSize: 14),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      hintText: "Select Date",
                      suffixIcon: Icon(
                        Icons.calendar_month,
                        color: Color(0xFF365c7f),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // isLoading == false
          //     ?
          SizedBox(height: 15,),
          InkWell(
            onTap: (){
              check();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Color(0xFF35B8EF), Color(0xFF29E7CD)], // Match the button gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  AppText.add,
                  style: Apptextstyle.s20wbcW
                ),
              ),
            ),
          ),
          SizedBox(height: 40,),
          isLoading ?
          Center(child: Image.asset(
            Appimages.applogo,
            height: 50,
            fit: BoxFit.contain,
          ),) :
          Padding(
            padding:  EdgeInsets.only(left: 20,right: 10, bottom: 10),
            child: Container(
              //height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white, // Card background color
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey.shade500, // Border color
                  width: 1.0, // Border width
                ),
              ),
              child: Card(
                color: Colors.white,
                elevation: 0, // Remove default elevation
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                         AppText.dailyweightavg,
                          style:Apptextstyle.s14wbcR,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              AppText.W_date,
                              style: Apptextstyle.s14wbcothers,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppText.bmi_add,
                              style: Apptextstyle.s14wbcothers,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppText.add_weight,
                              style: Apptextstyle.s14wbcothers,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppText.add_height,
                              style: Apptextstyle.s14wbcothers,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(height: 10),
                    SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chartData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0,8,0,0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('MMM dd, yyyy').format(chartData[index].date),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '${chartData[index].bmidata}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '${chartData[index].weightrate}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '${chartData[index].heightrate}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider()
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      
                  ],
                ),
              ),
            ),
          )
          //     : Center(child: Image.asset(
          //   "assets/gif/logo.gif",
          //   height: 50,
          //   fit: BoxFit.contain,
          // ),),
        ],
      ),
    ),
    );
  }
}


