import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popcat/models/counter_model.dart';
import 'package:popcat/utils/my_prefs.dart';

//data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wgARCAOEAAEDAREAAhEBAxEB/8QAHAAAAgMBAQEBAAAAAAAAAAAAAgMAAQQFBggH/8QAGgEBAQEBAQEBAAAAAAAAAAAAAgADAQQFBv/aAAwDAQACEAMQAAAA/P8A8191tHqSSYtt+Z6A50c+9Dz69DzLdTGJ1sa6a52dB29B6DXPoak6KhoqmhixiJcrNHAvRKLhLykJeWK+eq+Uz39hyX0bzX01eg0ugbURDxRpwyonKlSpRVRKxxFmA5dENVdWfbTKe1n2YlWk3QO1tHbaYsZasOvcHleajZJElyOtduiz1Z423aaxWfEvlkGZlNozEOPXX1Tlshsk8GNJPeyrDuo+1pxvZxmhO5CTiR5jNejP/8QAKxAAAQEHAgQGAwAAAAAAAAAAABIBAhARExRhFVEDIWKBBBcgMFOSUnGR/9oACAEBAAE/AECISKRTwUMFvkps2LUTFLS2c3LDpLRhYOiRMOfpT6UnIW7uw1zrPOXhfkz7Gp+P6jyte+I0Dhlr0li6U8Qn7KmZOQvJUgkmVBQppImdyngQ0ovbNP5BbMlbJVbBAmKSZ2EnLZgl0UKbkSIEQTCmJFExeRbBTScEwmJKZ2EsJCv2XeC5e+DiGteJ3c+p/8QAHREAAgMBAAMBAAAAAAAAAAAAABEBEBIgAhMhMP/aAAgBAgEBPwCkIUDrQ+FAhGRSLpCp8uByO9QO1BqaZ9/B9fRCgZqKQhRWoHJkcGpM2hCPp7fEcnrk3ApGPhjnhCilyhU6dIVf/8QAGxEAAgMBAQEAAAAAAAAAAAAAABEBECASITD/2gAIAQMBAT8Ay6QpyhnUU50x7Z6K0LLEe/FU5tQIUCH8VIxHU0xXzhHUac4VrPmXTHX/2Q==

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const title = 'POPCAT';
  static const decreaseButtonLabel = 'COUNT DOWN';
  static const resetButtonLabel = 'RESET';
  static const resetDialogTitle = 'RESET COUNTER';
  static const resetDialogText = 'Are you sure?';
  static const resetDialogOk = 'OK';
  static const resetDialogCancel = 'CANCEL';
  static const titleFontSize = 70.0;
  static const lowerNumberFontSize = 100.0;
  static const upperNumberFontSize = 120.0;

  var _isPop = false;
  Counter? _counter;

  late Animation<double> _animation;
  late AnimationController _controller;
  static AudioCache audioCache = AudioCache();

  Uint8List? soundPopBytes, soundWoopBytes, soundCoinBytes;

  @override
  void initState() {
    super.initState();

    Counter.createFromPref().then((counter) {
      setState(() {
        _counter = counter;
      });
    });

    _loadSoundFile('sounds/pop2.mp3').then((bytes) {
      soundPopBytes = bytes;
    });
    _loadSoundFile('sounds/woop_out.mp3').then((bytes) {
      soundWoopBytes = bytes;
    });
    _loadSoundFile('sounds/coin.wav').then((bytes) {
      soundCoinBytes = bytes;
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 60),
    );

    _animation = Tween<double>(
      begin: lowerNumberFontSize,
      end: upperNumberFontSize,
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background layer
          Transform.scale(
            scale: 1.1,
            child: Transform.rotate(
              angle: -0.0523599, // 3 degrees
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          // title, counter, and cat image layer
          if (_counter != null)
            SafeArea(
              child: Column(
                children: [
                  _buildText(title, titleFontSize, 2.0),
                  _buildCounter(),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        _isPop
                            ? "assets/images/op.webp"
                            : "assets/images/p.webp",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // gesture detector and buttons layer
          if (_counter != null)
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapDown: (TapDownDetails tapDownDetails) {
                      _playSound(soundPopBytes);
                      setState(() {
                        _counter!.updateValue(1);
                        _isPop = true;
                        _controller.forward();
                      });
                    },
                    onTapUp: (TapUpDetails tapUpDetails) {
                      setState(() {
                        _isPop = false;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(decreaseButtonLabel, () {
                        _playSound(soundWoopBytes, volume: 0.2);
                        setState(() {
                          _counter!.updateValue(-1);
                          _controller.forward();
                        });
                      }),
                      _buildButton(resetButtonLabel, () {
                        _showResetDialog();
                      }),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildCounter() {
    return RotationTransition(
      turns: Tween(
        begin: 0.0,
        // random angle including sign (+/-)
        end: (Random().nextInt(2) == 0 ? 1 : -1) * Random().nextDouble() * 0.05,
      ).animate(_controller),
      child: _buildText(
        _counter!.value.toString(),
        // animate font size from lowerNumberFontSize to upperNumberFontSize
        _animation.value,
        // animate font stroke width from 2.0 to 4.0 based on font size
        2.0 +
            2.0 *
                (_animation.value - lowerNumberFontSize) /
                (upperNumberFontSize - lowerNumberFontSize),
      ),
    );
  }

  Widget _buildText(String text, double fontSize, double strokeWidth) {
    return Stack(
      children: [
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String label, Function onClick) {
    return TextButton(
      onPressed: () {
        onClick();
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        //minimumSize: Size(50, 30),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<Uint8List> _loadSoundFile(String filePath) async {
    return await (await audioCache.loadAsFile(filePath)).readAsBytes();
  }

  void _playSound(Uint8List? bytes, {double volume = 1.0}) {
    if (bytes != null) audioCache.playBytes(bytes, volume: volume);
  }

  Future<void> _showResetDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(resetDialogTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(resetDialogText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(resetDialogCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(resetDialogOk),
              onPressed: () {
                _playSound(soundCoinBytes, volume: 0.2);
                setState(() {
                  _counter!.resetValue();
                  _controller.forward();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
