import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CustomPinCodeField extends StatelessWidget {
  final BuildContext appContext;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  const CustomPinCodeField({
    super.key,
    required this.appContext,
    required this.onChanged,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: appContext,
      length: 5,
      obscureText: false,
      keyboardType: TextInputType.number,
      autoFocus: true,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.underline,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 40,
        activeColor: Colors.black,
        inactiveColor: Colors.black,
        selectedColor: Colors.black,
      ),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
