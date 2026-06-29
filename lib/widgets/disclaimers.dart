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
        "This app integrates with Apple Health to securely read and sync your fitness and wellness data. "
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.redAccent, size: 16),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  "Data synced with Apple Health",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Disclaimer: For fitness and wellness use only. Not for medical diagnosis.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
