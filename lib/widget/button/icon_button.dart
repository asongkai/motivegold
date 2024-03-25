import 'package:flutter/material.dart';

class SimpleRoundIconButton extends StatelessWidget {
  final Color backgroundColor;
  final Text buttonText;
  final Icon icon;
  final Color? iconColor;
  final Alignment iconAlignment;
  final Function? onPressed;

  const SimpleRoundIconButton(
      {super.key, this.backgroundColor = Colors.redAccent,
        this.buttonText = const Text("REQUIRED TEXT"),
        this.icon = const Icon(Icons.email),
        this.iconColor,
        this.iconAlignment = Alignment.centerLeft,
        this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
                  overlayColor: MaterialStateProperty.all(backgroundColor),
                  backgroundColor:
                  MaterialStateProperty.all(backgroundColor),
                ),
                child: Row(
                  children: <Widget>[
                    iconAlignment == Alignment.centerLeft
                        ? Transform.translate(
                      offset: const Offset(-10.0, 0.0),
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(28.0)),
                            // splashColor: Colors.white,
                            // color: Colors.white,
                          ),

                          child: Icon(
                            icon.icon,
                            color: iconColor ?? backgroundColor,
                          ),
                          onPressed: () => {},
                        ),
                      ),
                    )
                        : Container(),
                    iconAlignment == Alignment.centerLeft
                        ? Container()
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                      child: buttonText,
                    ),
                    iconAlignment == Alignment.centerRight
                        ? Container()
                        : Container(),
                    iconAlignment == Alignment.centerRight
                        ? Transform.translate(
                      offset: const Offset(10.0, 0.0),
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(28.0)),
                            // splashColor: Colors.white,
                            // color: Colors.white,
                          ),
                          child: Icon(
                            icon.icon,
                            color: iconColor == null
                                ? backgroundColor
                                : iconColor,
                          ),
                          onPressed: () => {},
                        ),
                      ),
                    )
                        : Container()
                  ],
                ),
                onPressed: () => onPressed!(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}