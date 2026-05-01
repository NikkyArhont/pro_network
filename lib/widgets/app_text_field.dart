import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const AppTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType,
    this.onChanged,
    this.prefix,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center both prefix and input
        children: [
          if (prefix != null) const SizedBox(width: 10), 
          if (prefix != null) 
            Container( // Ensures prefix respects exact centering
              height: 35,
              alignment: Alignment.center,
              child: prefix!,
            ),
          // We removed the SizedBox(width: 8) entirely.
          Expanded(
            child: Padding(
              // Move padding completely outside TextField to prevent asymmetrical contentPadding baseline bugs!
              padding: EdgeInsets.only(
                left: prefix == null ? 10 : 4, // Added tiny 4px indent just so cursor doesn't literally overlap the 7
                right: 10,
              ),
              child: SizedBox(
                height: 35, 
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  onChanged: onChanged,
                  cursorColor: Colors.white,
                  textAlignVertical: TextAlignVertical.center, // Safely centered 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    isDense: true,
                    contentPadding: EdgeInsets.zero, // EXACT 0 for all borders allows math-perfect centering
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF637B7E),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





