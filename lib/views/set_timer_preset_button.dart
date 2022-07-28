import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetTimerPresetButton extends StatelessWidget {
  final int minutes;
  final Function func;
  final TextStyle textStyle;
  final Color textColor;

  const SetTimerPresetButton({
    Key? key,
    required this.minutes,
    required this.func,
    required this.textStyle,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => func(),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          width: 132,
          height: 132,
          child: Center(
              child: Text(
            "$minutes",
            style: GoogleFonts.robotoMono(fontSize: 72, color: textColor),
          )),
        ),
      ),
    );
  }
}
