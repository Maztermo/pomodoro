import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro/views/set_timer_preset_button.dart';

/// TODO: remove the container and just set the whole background color.
/// that way the user can decide the ratio of the pomo timer.
/// TODO: add option to change font
/// TODO: add option to make font different size

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 25);
  bool isBreakPom = false;
  bool isPlaying = false;
  bool isOnPlayer = true;
  bool isSettingTimer = false;
  bool isSettingDesign = false;

  String style1 = 'Roboto Mono';
  String style2 = 'Anton';
  String style3 = 'Space Grotesk';

  String selectedFontFamily = 'Roboto Mono';

  FontWeight selectedFontWeight = FontWeight.w300;

  Color mainColor = Colors.blueGrey[900]!;
  Color backgroundColor = Colors.blueGrey;
  Color white70 = Colors.white70;
  Color colorPicker = Colors.blue;

  var controller = TextEditingController();

  void startTimer() {
    isPlaying = true;
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    isPlaying = false;
    setState(() => countdownTimer?.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 25));
  }

  void setTimerTo(int x) {
    stopTimer();
    isSettingTimer = false;
    isOnPlayer = true;
    setState(() => myDuration = Duration(minutes: x));
  }

  void goToSetTimer() {
    setState(() {
      isOnPlayer = false;
      isSettingDesign = false;
      isSettingTimer = true;
    });
  }

  void changeColor({required bool main}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: colorPicker,
                onColorChanged: (color) => setState(() {
                  colorPicker = color;
                }),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text(
                  'Ok',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  setState(() {
                    (main)
                        ? mainColor = colorPicker
                        : backgroundColor = colorPicker;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds == 0) {
        stopTimer();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    TextStyle largeTextStyle = GoogleFonts.getFont(
      selectedFontFamily,
      fontSize: 150,
      fontWeight: selectedFontWeight,
      color: mainColor,
    );
    TextStyle smallerTextStyle = GoogleFonts.getFont(
      selectedFontFamily,
      fontSize: 72,
      fontWeight: selectedFontWeight,
      color: white70,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            //  borderRadius: BorderRadius.circular(8),
          ),
          width: 1200,
          height: 480,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (isOnPlayer)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FittedBox(
                          child: Text(
                            (myDuration.inMinutes < 60)
                                ? '$minutes:$seconds'
                                : '$hours:$minutes:$seconds',
                            style: largeTextStyle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: (isPlaying) ? stopTimer : startTimer,
                        child: (isPlaying)
                            ? Icon(
                                Icons.pause,
                                size: 190,
                                color: mainColor,
                              )
                            : Icon(
                                Icons.play_arrow,
                                size: 190,
                                color: mainColor,
                              ),
                      ),
                      const SizedBox(width: 15),
                      InkWell(
                        onTap: goToSetTimer,
                        child: Icon(
                          Icons.settings,
                          size: 144,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                if (isOnPlayer && isBreakPom)
                  Text(
                    "Break Pom",
                    style: GoogleFonts.getFont(
                      selectedFontFamily,
                      fontSize: 72,
                      color: mainColor,
                    ),
                  ),
                if (isSettingTimer)
                  // Top row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isBreakPom = !isBreakPom;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(4)),
                            width: 270,
                            height: 132,
                            child: Center(
                                child: Text(
                              (isBreakPom) ? "Break" : "Pom",
                              style: GoogleFonts.getFont(
                                selectedFontFamily,
                                fontSize: 72,
                                color: mainColor,
                              ),
                            )),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(width: 1),
                          ),
                          width: 410,
                          height: 132,
                          child: Center(
                            child: TextField(
                              controller: controller,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.only(bottom: 8),
                                hintText: 'Custom:',
                                hintStyle: GoogleFonts.getFont(
                                  selectedFontFamily,
                                  fontSize: 72,
                                  color: mainColor,
                                ),
                              ),
                              style: GoogleFonts.getFont(
                                selectedFontFamily,
                                fontSize: 72,
                                color: mainColor,
                              ),
                              onSubmitted: (x) {
                                setTimerTo(int.parse(x));
                                controller.clear();
                              },
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => changeColor(main: true),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(4)),
                            width: 132,
                            height: 132,
                            child: Center(
                                child: Icon(
                              Icons.format_color_text_rounded,
                              color: mainColor,
                              size: 72,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (isSettingTimer) // Bottom row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80.0),
                    child: Row(
                      children: [
                        SetTimerPresetButton(
                          minutes: 5,
                          func: () => setTimerTo(5),
                          textStyle: smallerTextStyle,
                          textColor: mainColor,
                        ),
                        const SizedBox(width: 15),
                        SetTimerPresetButton(
                          minutes: 10,
                          func: () => setTimerTo(10),
                          textStyle: smallerTextStyle,
                          textColor: mainColor,
                        ),
                        const SizedBox(width: 15),
                        SetTimerPresetButton(
                          minutes: 15,
                          func: () => setTimerTo(15),
                          textStyle: smallerTextStyle,
                          textColor: mainColor,
                        ),
                        const SizedBox(width: 15),
                        SetTimerPresetButton(
                          minutes: 25,
                          func: () => setTimerTo(25),
                          textStyle: smallerTextStyle,
                          textColor: mainColor,
                        ),
                        const SizedBox(width: 15),
                        SetTimerPresetButton(
                          minutes: 50,
                          func: () => setTimerTo(50),
                          textStyle: smallerTextStyle,
                          textColor: mainColor,
                        ),
                        const SizedBox(width: 15),
                        InkWell(
                          onTap: () => changeColor(main: false),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(4)),
                            width: 132,
                            height: 132,
                            child: Center(
                                child: Icon(
                              Icons.format_color_fill,
                              color: mainColor,
                              size: 72,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
              ]),
        ),
      ),
    );
  }
}
