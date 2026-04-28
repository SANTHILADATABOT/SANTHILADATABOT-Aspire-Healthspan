import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';

class MedicalDisclaimerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.d_appbar),
          SizedBox(width: 10),
          Text("Health Disclaimer", style: Apptextstyle.s18wbcB),
        ],
      ),
      content: Text(
        "This application is designed for fitness and wellness monitoring only. "
        "It is NOT intended for medical diagnosis, treatment, or prevention of any disease. "
        "Always seek the advice of a physician or other qualified health provider with any questions "
        "regarding a medical condition. Results are for trend monitoring and should not be used as clinical data.",
        style: Apptextstyle.s13wbcgrey,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("I Understand", style: TextStyle(color: AppColors.others, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class DisclaimerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Center(
        child: Text(
          "Disclaimer: For fitness and wellness use only. Not for medical diagnosis.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
