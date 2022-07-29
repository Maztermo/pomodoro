import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pomodoro/views/set_timer_preset_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? countdownTimer;
  bool timerIsTicking = false;
  Duration myDuration = const Duration(minutes: 25);
  bool isBreakPom = false;
  bool isSettingTimer = false;
  bool customFieldHasFocus = false;
  bool showSettings = false;
  int previousMinutes = 25;

  String style1 = 'Roboto Mono';
  String style2 = 'Anton';
  String style3 = 'Space Grotesk';

  String selectedFontFamily = 'Roboto Mono';

  FontWeight selectedFontWeight = FontWeight.w300;

  Color mainColor = Colors.blueGrey[900]!;
  Color backgroundColor = Colors.blueGrey;
  Color colorPicker = Colors.blue;

  final double smallGap = 12;

  var controller = TextEditingController();

  void startTimer() {
    timerIsTicking = true;
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
    setState(() {});
  }

  void pauseTimer() {
    timerIsTicking = false;
    setState(() => countdownTimer?.cancel());
  }

  void resetTimer() {
    timerIsTicking = false;
    pauseTimer();
    setState(() => myDuration = const Duration(minutes: 25));
  }

  void setTimerTo(int x) {
    timerIsTicking = false;
    pauseTimer();
    previousMinutes = x;
    setState(() => myDuration = Duration(minutes: x));
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

  Future playAudioPlayer() async {
    await player.setVolume(0.3);
    await player.play();
    await player.pause();
    await player.setClip(
        start: Duration(seconds: 0), end: Duration(seconds: 3));
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds == 0 || seconds < 0) {
        pauseTimer();
        playAudioPlayer();
        myDuration = const Duration(seconds: 0);
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  Icon returnPlayPauseOrRepeatIcon() {
    if (timerIsTicking) {
      return Icon(
        Icons.pause,
        size: 190,
        color: mainColor,
      );
    } else if (!timerIsTicking && myDuration == const Duration(seconds: 0)) {
      return Icon(
        Icons.replay,
        size: 150,
        color: mainColor,
      );
    } else {
      return Icon(
        Icons.play_arrow,
        size: 190,
        color: mainColor,
      );
    }
  }

  late AudioPlayer player;

  @override
  void initState() {
    player = AudioPlayer();
    player.setAsset('audio/finished.mp3');
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
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
                      onTap: () {
                        if (timerIsTicking) {
                          pauseTimer();
                        } else if (!timerIsTicking &&
                            myDuration == const Duration(seconds: 0)) {
                          setTimerTo(previousMinutes);
                        } else {
                          startTimer();
                        }
                      },
                      child: returnPlayPauseOrRepeatIcon(),
                    ),
                    const SizedBox(width: 15),
                    InkWell(
                      onTap: () => setState(() {
                        showSettings = !showSettings;
                      }),
                      child: Icon(
                        Icons.settings,
                        size: 144,
                        color: mainColor,
                      ),
                    ),
                  ],
                ),
                if (showSettings)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SetTimerPresetButton(
                        minutes: 5,
                        func: () => setTimerTo(5),
                        textColor: mainColor,
                      ),
                      const SizedBox(width: 15),
                      SetTimerPresetButton(
                        minutes: 10,
                        func: () => setTimerTo(10),
                        textColor: mainColor,
                      ),
                      const SizedBox(width: 15),
                      SetTimerPresetButton(
                        minutes: 15,
                        func: () => setTimerTo(15),
                        textColor: mainColor,
                      ),
                      const SizedBox(width: 15),
                      SetTimerPresetButton(
                        minutes: 25,
                        func: () => setTimerTo(25),
                        textColor: mainColor,
                      ),
                      const SizedBox(width: 15),
                      SetTimerPresetButton(
                        minutes: 50,
                        func: () => setTimerTo(50),
                        textColor: mainColor,
                      ),
                      SizedBox(width: smallGap),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(width: 1),
                        ),
                        height: 64,
                        width: 210,
                        child: Center(
                          child: Focus(
                            onFocusChange: (value) {
                              setState(() {
                                customFieldHasFocus = value;
                              });
                            },
                            child: TextField(
                              controller: controller,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: customFieldHasFocus ? '' : 'Custom:',
                                hintStyle: GoogleFonts.getFont(
                                  selectedFontFamily,
                                  fontSize: 32,
                                  color: mainColor,
                                ),
                              ),
                              style: GoogleFonts.getFont(
                                selectedFontFamily,
                                fontSize: 32,
                                color: mainColor,
                              ),
                              onSubmitted: (x) {
                                setTimerTo(int.parse(x));
                                controller.clear();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: smallGap,
                ),
                if (showSettings)
                  SizedBox(
                    width: 600,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
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
                              height: 64,
                              child: Center(
                                  child: Text(
                                (isBreakPom) ? "Mode: break" : "Mode: work",
                                style: GoogleFonts.getFont(
                                  selectedFontFamily,
                                  fontSize: 32,
                                  color: mainColor,
                                ),
                              )),
                            ),
                          ),
                        ),
                        SizedBox(width: smallGap),
                        CustomIconButton(
                          onTap: () => changeColor(main: true),
                          mainColor: mainColor,
                          iconData: Icons.format_color_text_rounded,
                        ),
                        SizedBox(width: smallGap),
                        CustomIconButton(
                          onTap: () => changeColor(main: false),
                          mainColor: mainColor,
                          iconData: Icons.format_color_fill,
                        ),
                      ],
                    ),
                  ),
                if (isBreakPom && !showSettings)
                  Text(
                    "Break Timer",
                    style: GoogleFonts.getFont(
                      selectedFontFamily,
                      fontSize: 72,
                      color: mainColor,
                    ),
                  ),
              ]),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    Key? key,
    required this.mainColor,
    required this.iconData,
    required this.onTap,
  }) : super(key: key);

  final Color mainColor;
  final IconData iconData;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(4)),
        width: 64,
        height: 64,
        child: Center(
            child: Icon(
          iconData,
          color: mainColor,
          size: 32,
        )),
      ),
    );
  }
}
