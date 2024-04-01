import 'package:filipay/components/mycolors.dart';
import 'package:flutter/material.dart';

class darkblueButton extends StatelessWidget {
  const darkblueButton(
      {super.key, required this.thisFunction, required this.label});
  final void Function() thisFunction;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              )),
          onPressed: thisFunction,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${label.toUpperCase()}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }
}
