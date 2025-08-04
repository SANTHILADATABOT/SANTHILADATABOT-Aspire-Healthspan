
// custom_card.dart
import 'package:flutter/material.dart';

import '../utils/apptext.dart';
import '../utils/apptextstyle.dart';

class CustomCard1 extends StatelessWidget {
  final String title;
  final String t1,t2,Bps,Bpd,bpunit;
  final String datetime;
  final double t2fontsize;
  final Widget chart;
  final VoidCallback press;
  final Color color1;
  final Color color2;


  CustomCard1({
    required this.title,
    required this.datetime,
    required this.color1,
    required this.color2,
    required this.t1,
    required this.t2,
    required this.Bps,
    required this.Bpd,
    required this.bpunit,
    required this.t2fontsize,
    required this.chart, required this.press,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    // final height = isLandscape ? size.height * 0.85 : size.height * 0.55;
    final screenSize = MediaQuery.of(context).size;
    final double portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;
    return InkWell(
      onTap: press,
      child: Container(
        height: portraitHeight *0.55,
        width: double.infinity,
        child: Card(
          color: Color(0xFFffffff),
          // elevation: 5, // Shadow effect for the card
          margin: EdgeInsets.only(bottom: 24), // Space between cards
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 16, // Font size for the text
                        // fontWeight: FontWeight.bold, // Bold text
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    InkWell(
                      onTap: press,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black,
                      ),
                    )

                  ],
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: size.width * 0.80,
                      height:portraitHeight *0.30,
                      child: chart,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "$t1",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: color1
                            ),
                          ),
                          Text(
                            "/$t2",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: t2fontsize,
                                fontWeight: FontWeight.bold,
                                color: color2
                            ),
                          ),
                          Text(
                            "$bpunit",
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 12,
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          children: [
                            TextSpan(
                              text: "Avg ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: "Sys",
                              style: TextStyle(color: color1),
                            ),
                            TextSpan(
                              text: "/Dia ",
                              style: TextStyle(color: color2),
                            ),
                            TextSpan(
                              text: "Blood Pressure",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final String t1;
  final String t2;
  final String datetime;
  final double t2fontsize;
  final Widget chart;
  final VoidCallback press;
  final Color color;

  CustomCard({
    required this.title,
    required this.datetime,
    required this.color,
    required this.t1,
    required this.t2,
    required this.t2fontsize,
    required this.chart, required this.press,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    // final height = isLandscape ? size.height * 0.85 : size.height * 0.45;
    final screenSize = MediaQuery.of(context).size;
    final double portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;
    return InkWell(
      onTap: press,
      child: Container(
        height:portraitHeight * 0.45,
        width: double.infinity,
        child: Card(
          color: Color(0xFFffffff),
          // elevation: 5, // Shadow effect for the card
          //margin: EdgeInsets.only(bottom: 24), // Space between cards
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 16, // Font size for the text
                        // fontWeight: FontWeight.bold, // Bold text
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    InkWell(
                      onTap: press,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black,
                      ),
                    )

                  ],
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: size.width * 0.80,
                      height: portraitHeight *0.28,
                      child: chart,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            t1,
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: color
                            ),
                          ),

                          SizedBox(width: 5,),
                          Text(
                            t2,
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Text(
                        datetime,
                        style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: t2fontsize,
                            fontWeight: FontWeight.bold,
                            color: color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class CustomCardspo2 extends StatelessWidget {
  final String title;
  final String t1,t2;
  final String datetime;
  final double t2fontsize;
  final Widget chart;
  final VoidCallback press;
  final Color color;

  CustomCardspo2({
    required this.title,
    required this.datetime,
    required this.color,
    required this.t1,
    required this.t2,
    required this.t2fontsize,
    required this.chart, required this.press,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final height = isLandscape ? size.width * 0.65 : size.height * 0.65;
    return InkWell(
      onTap: press,
      child: Container(
        height: height,
        width: double.infinity,
        child: Card(
          color: Color(0xFFffffff),
          // elevation: 5, // Shadow effect for the card
         // margin: EdgeInsets.only(bottom: 24), // Space between cards
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16, // Font size for the text
                          // fontWeight: FontWeight.bold, // Bold text
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    InkWell(
                      onTap: press,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black,
                      ),
                    )

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        // Chart aligned to right
                        Container(
                          width: size.width * 0.80,
                        height: isLandscape
                        ? size.width * 0.30 // scale with width in landscape
                            : size.height * 0.30,
                          child: chart,
                        ),
                        const SizedBox(height: 5),
                        // Legend centered within chart width
                        Center(
                          child: Container(
                            width: size.width * 0.55,
                            child: Column(
                              children: [
                                _buildLegendspo2(
                                  context,
                                  const Color(0xFFD1FCD1),
                                  const Color(0xFF64EE64),
                                  AppText.spo2_n,
                                  AppText.spo2_np,
                                ),
                                const SizedBox(height: 5),
                                _buildLegendspo2(
                                  context,
                                  const Color(0xFFFAF0CC),
                                  const Color(0xFFF5D666),
                                  AppText.spo2_h,
                                  AppText.spo2_mp,
                                ),
                                const SizedBox(height: 5),
                                _buildLegendspo2(
                                  context,
                                  const Color(0xFFF6CCCC),
                                  const Color(0xFFF38F8F),
                                  AppText.spo2_l,
                                  AppText.spo2_lp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            t1,
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: color
                            ),
                          ),

                          SizedBox(width: 5,),
                          Text(
                            t2,
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Text(
                        datetime,
                        style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: t2fontsize,
                            fontWeight: FontWeight.bold,
                            color: color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );



  }

  Widget _buildLegendspo2(
      BuildContext context,
      Color backgroundColor,
      Color borderColor,
      String percentage,
     String label
     // String label,
      ) {
    double width = MediaQuery.of(context).size.width*0.52;

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color:borderColor,width: 1.0 )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            percentage,
            style: Apptextstyle.s11wbcB,
          ),
          //SizedBox(width: 10),
          Text(
              label,
              style:Apptextstyle.s11wbcB
            //overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


}


class CustomCardsleep extends StatelessWidget {
  final String title;
  final String t1,t2;
  final String datetime;
  final double t2fontsize;
  final String? deepPercentage;
  final String? lightPercentage;
  final String? middlePercentage;
  final Widget chart;
  final VoidCallback press;
  final Color color;

  CustomCardsleep({
    required this.title,
    required this.datetime,
    required this.color,
    required this.t1,
    required this.t2,
    required this.t2fontsize,
    required this.chart,
    required this.deepPercentage,
    required this.middlePercentage,
    required this.lightPercentage,
    required this.press,
  });



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    // final height = isLandscape ? size.height * 0.95 : size.height * 0.60;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final height = isLandscape ? size.width * 0.60 : size.height * 0.60;
    return InkWell(
      onTap: press,
      child: Container(
        height: height,
        width: double.infinity,
        child: Card(
          color: Color(0xFFffffff),
          // elevation: 5, // Shadow effect for the card
          margin: EdgeInsets.only(bottom: 24), // Space between cards
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16, // Font size for the text
                          // fontWeight: FontWeight.bold, // Bold text
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    InkWell(
                      onTap: press,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black,
                      ),
                    )

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: size.width * 0.80,
                          height: isLandscape
                              ? size.width * 0.30 // scale with width in landscape
                              : size.height * 0.30,
                          child: chart,
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: Container(
                            width: size.width * 0.60,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center, // or start
                              children: [
                                _buildLegendPercentageBox(
                                  context,
                                  const Color(0xFFb5e78c),
                                  deepPercentage ?? '',
                                  AppText.deep,
                                ),
                                const SizedBox(height: 5),
                                _buildLegendPercentageBox(
                                  context,
                                  const Color(0xFFef989e),
                                  middlePercentage ?? '',
                                  AppText.middle,
                                ),
                                const SizedBox(height: 5),
                                _buildLegendPercentageBox(
                                  context,
                                  const Color(0xFFa4bce7),
                                  lightPercentage ?? '',
                                  AppText.light,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // crossAxisAlignment: CrossAxisAlignment.end,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            t1,
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: color
                            ),
                          ),

                          SizedBox(width: 5,),
                          Text(
                            t2,
                            style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5,),
                      Text(
                        datetime,
                        style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: t2fontsize,
                            fontWeight: FontWeight.bold,
                            color: color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendPercentageBox(
      BuildContext context,
      Color backgroundColor,
      String percentage,
      String label,
      ) {
    double width = MediaQuery.of(context).size.width*0.45;

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            percentage,
            style: Apptextstyle.s11wbcB,
          ),
          //SizedBox(width: 10),
          Text(
              label,
              style:Apptextstyle.s11wbcB
            //overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendvalues(Color color, Color Color1,String label) {
    return Container(
      decoration: BoxDecoration(
        color:  color,
        border: Border.all(
          color: Color1, // Border color for Deep Sleep
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style:Apptextstyle.s10wbcB
      ),
    );
  }
}