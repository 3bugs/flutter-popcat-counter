import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popcat/model/counter_model.dart';

//data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wgARCAOEAAEDAREAAhEBAxEB/8QAHAAAAgMBAQEBAAAAAAAAAAAAAgMAAQQFBggH/8QAGgEBAQEBAQEBAAAAAAAAAAAAAgADAQQFBv/aAAwDAQACEAMQAAAA/P8A8191tHqSSYtt+Z6A50c+9Dz69DzLdTGJ1sa6a52dB29B6DXPoak6KhoqmhixiJcrNHAvRKLhLykJeWK+eq+Uz39hyX0bzX01eg0ugbURDxRpwyonKlSpRVRKxxFmA5dENVdWfbTKe1n2YlWk3QO1tHbaYsZasOvcHleajZJElyOtduiz1Z423aaxWfEvlkGZlNozEOPXX1Tlshsk8GNJPeyrDuo+1pxvZxmhO5CTiR5jNejP/8QAKxAAAQEHAgQGAwAAAAAAAAAAABIBAhARExRhFVEDIWKBBBcgMFOSUnGR/9oACAEBAAE/AECISKRTwUMFvkps2LUTFLS2c3LDpLRhYOiRMOfpT6UnIW7uw1zrPOXhfkz7Gp+P6jyte+I0Dhlr0li6U8Qn7KmZOQvJUgkmVBQppImdyngQ0ovbNP5BbMlbJVbBAmKSZ2EnLZgl0UKbkSIEQTCmJFExeRbBTScEwmJKZ2EsJCv2XeC5e+DiGteJ3c+p/8QAHREAAgMBAAMBAAAAAAAAAAAAABEBEBIgAhMhMP/aAAgBAgEBPwCkIUDrQ+FAhGRSLpCp8uByO9QO1BqaZ9/B9fRCgZqKQhRWoHJkcGpM2hCPp7fEcnrk3ApGPhjnhCilyhU6dIVf/8QAGxEAAgMBAQEAAAAAAAAAAAAAABEBECASITD/2gAIAQMBAT8Ay6QpyhnUU50x7Z6K0LLEe/FU5tQIUCH8VIxHU0xXzhHUac4VrPmXTHX/2Q==

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const title = 'POPCAT';
  static const decreaseButtonLabel = 'DECREASE';
  static const resetButtonLabel = 'RESET';
  static const resetDialogTitle = 'RESET COUNTER';
  static const resetDialogText = 'Are you sure?';
  static const resetDialogOk = 'OK';
  static const resetDialogCancel = 'Cancel';
  static const lowerNumberFontSize = 120.0;
  static const upperNumberFontSize = 140.0;

  var _isPop = false;
  var _counter = Counter();

  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
    _controller.dispose();
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
          SafeArea(
            child: Column(
              children: [
                _buildText(title, 80.0, 2.0),
                _buildCounter(),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      _isPop ? "assets/images/op.webp" : "assets/images/p.webp",
                    ),
                  ),
                ),
              ],
            ),
          ),
          // gesture detector and buttons layer
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTapDown: (TapDownDetails tapDownDetails) {
                    setState(() {
                      _counter.updateValue(1);
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
                      setState(() {
                        _counter.updateValue(-1);
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
        end: (Random().nextInt(2) == 0 ? 1 : -1) * Random().nextDouble() * 0.08,
      ).animate(_controller),
      child: _buildText(
        _counter.value.toString(),
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
                setState(() {
                  _counter.resetValue();
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
