import 'package:flutter/material.dart';
import 'package:motivegold/utils/helps/common_function.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({super.key, this.text = ""});
  //text is the total text of our expandable widget
  final String text;
  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  late String textToDisplay;
  @override
  void initState() {
    //if the text has more than a certain number of characters, the text we display will consist of that number of characters;
    //if it's not longer we display all the text
    motivePrint(widget.text.length);

    //we arbitrarily chose 25 as the length
    textToDisplay =
    widget.text.length > 200 ? "${widget.text.substring(0,200)}..." : widget.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(textToDisplay),
      onTap: () {
        // print('${textToDisplay.length}');

        //if the text is not expanded we show it all
        if (widget.text.length > 200 && textToDisplay.length <= 203) {
          setState(() {
            // print('clicked');
            textToDisplay = widget.text;
          });
        }
        //else if the text is already expanded we contract it back
        else if (widget.text.length > 200 && textToDisplay.length > 203) {
          setState(() {
            textToDisplay = "${widget.text.substring(0,200)}...";
          });
        }


      },
    );
  }
}