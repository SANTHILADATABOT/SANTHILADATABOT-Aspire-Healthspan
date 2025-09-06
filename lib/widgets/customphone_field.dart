import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CustomPhoneField extends StatelessWidget {
  final String initialCountryCode;
  final bool isPhoneValid;
  final VoidCallback? onEnterPressed;
  final Function(String completeNumber, bool isValid) onChanged;

  const CustomPhoneField({
    super.key,
    required this.initialCountryCode,
    required this.isPhoneValid,
    required this.onChanged,
    required this.onEnterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      keyboardType: TextInputType.phone,
      flagsButtonPadding: const EdgeInsets.all(4),
      dropdownIconPosition: IconPosition.trailing,
      dropdownIcon: const Icon(
        Icons.arrow_drop_down,
        size: 15.0,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        counterText: '',
        errorText: isPhoneValid ? null : 'Please enter a valid phone number',
      ),
      initialCountryCode: initialCountryCode,
      onChanged: (phoneno) {
        String number = phoneno.completeNumber;
        bool isValid = number.length >= 10;
        onChanged(number, isValid);
      },
      onSubmitted: (value) { // ✅ catches Enter + NumpadEnter
        if (kIsWeb && onEnterPressed != null) {
          onEnterPressed!();
        }
      },
      autovalidateMode: AutovalidateMode.disabled,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
