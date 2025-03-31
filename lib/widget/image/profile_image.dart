import 'package:flutter/material.dart';

class ProfilePhoto extends StatelessWidget {
  /// Sets the total width and height of the widget.
  final double totalWidth;

  /// Sets the width of the outer edge of the ProfilePhoto. Default is 0. (inset from totalWidth).
  final int outlineWidth;

  /// Sets the radius of ProfilePhoto. Defualt is 10. (for a circle set equal to totalWidth).
  final double cornerRadius;

  /// Sets the color of the outer edge. If outlineWidth == 0, this doesn't do anything.
  final Color outlineColor;

  /// Sets the main color to show if there is no image.
  final Color color;

  /// onTap callback.
  final VoidCallback? onTap;

  /// onLongPress callback.
  final VoidCallback? onLongPress;

  /// users name, which can be showed or not in various ways using nameDisplayOptions.
  final String name;

  /// Font to use if a name is visible.
  final String? fontFamily;

  /// Font color to use if a name is visible.
  final Color? fontColor;

  /// Sets various ways a name can be shown. Defualt is initials.
  final NameDisplayOptions? nameDisplayOption;

  /// Sets the font weight of the name if visible.
  final FontWeight? fontWeight;

  /// Sets spacing (top, right, bottom & left) around name if its visible. Defualt is 10.
  final int textPadding;

  /// Image to be displayed.
  final ImageProvider? image;

  /// Bool to set if the name should be visible. By default, true if there is no image, false if there is an image set.
  final bool? showName;

  /// Image to be shown as a badge in the corner of the ProfilePhoto.
  final ImageProvider? badgeImage;

  /// Size of the badge. Default is 0.
  final double badgeSize;

  /// Alignment of the badge. Default is bottom right.
  final Alignment badgeAlignment;

  const ProfilePhoto({
    required this.totalWidth,
    required this.color,
    this.outlineWidth = 0,
    this.cornerRadius = 10,
    this.outlineColor = Colors.lightBlue,
    this.onTap,
    this.onLongPress,
    this.name = '',
    this.nameDisplayOption = NameDisplayOptions.initials,
    this.fontColor,
    this.fontFamily,
    this.fontWeight,
    this.textPadding = 10,
    this.image,
    this.showName,
    this.badgeAlignment = Alignment.bottomRight,
    this.badgeImage,
    this.badgeSize = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String initials = '';
    String firstName = '';
    String lastName = '';
    String textToShow = '';
    bool showText = true;
    String nameFile = name;

    if (nameFile != '') {
      if (nameFile.trim().contains(' ')) {
        nameFile = name.trim();
        firstName = name.substring(0, name.indexOf(' '));
        lastName = name.substring(name.indexOf(' ') + 1, name.length);
        initials =
        '${name.substring(0, 1)}${name.substring(name.indexOf(' ') + 1, name.indexOf(' ') + 2)}';
      } else {
        firstName = name;
        lastName = name;
        initials = name.substring(0, 1);
      }
    } else {
      initials = ' ';
    }

    switch (nameDisplayOption) {
      case NameDisplayOptions.firstName:
        textToShow = firstName;
        break;
      case NameDisplayOptions.lastName:
        textToShow = lastName;
        break;
      case NameDisplayOptions.initials:
        textToShow = initials;
        break;
      case NameDisplayOptions.dontChange:
        textToShow = name;
        break;
      case NameDisplayOptions.splitFullName:
        textToShow = '$firstName\r\n$lastName';
        break;
      default:
        textToShow = ' ';
        break;
    }

    if (image != null) {
      showText = showName == null ? false : showName!;
    } else if (image == null) {
      showText = showName == null ? true : showName!;
    }

    return GestureDetector(
      onTap: onTap ?? () {},
      onLongPress: onLongPress ?? () {},
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background circle as outline
          Container(
            width: totalWidth,
            height: totalWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              color: outlineColor,
            ),
          ),

          // circle on top for main circle
          Container(
            width: (totalWidth) - (outlineWidth * 2) > 0
                ? (totalWidth) - (outlineWidth * 2)
                : 0,
            height: (totalWidth) - (outlineWidth * 2) > 0
                ? (totalWidth) - (outlineWidth * 2)
                : 0,
            decoration: BoxDecoration(
              borderRadius: cornerRadius - outlineWidth > 0
                  ? BorderRadius.circular(cornerRadius - (outlineWidth))
                  : BorderRadius.circular(cornerRadius),
              color: color,
            ),
            child: image != null
                ? ClipRRect(
              borderRadius: cornerRadius - outlineWidth > 0
                  ? BorderRadius.circular(cornerRadius - (outlineWidth))
                  : BorderRadius.circular(cornerRadius),
              child: Image(image: image!, fit: BoxFit.cover, ),
            )
                : null,
          ),

          // Top text layer
          if (showText)
            Container(
              width: (totalWidth) - (outlineWidth * 2) - (textPadding * 2) > 0
                  ? (totalWidth) - (outlineWidth * 2) - (textPadding * 2)
                  : 0,
              height: (totalWidth) - (outlineWidth * 2) - (textPadding * 2) > 0
                  ? (totalWidth) - (outlineWidth * 2) - (textPadding * 2)
                  : 0,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  textToShow,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 200,
                    fontWeight: fontWeight,
                    color: fontColor,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
            ),
          // if there is a badgeImage to show
          if (badgeImage != null)
            SizedBox(
              width: totalWidth,
              height: totalWidth,
              child: Align(
                alignment: badgeAlignment,
                child: SizedBox(
                  width: badgeSize,
                  height: badgeSize,
                  child: badgeImage != null ? Image(image: badgeImage!) : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Display options for nameDisplayOption
///
/// firstName only shows the first name.
/// lastName only shows the last name.
/// splitFullName shows first name and last name on 2 lines.
/// initals shows the users initals.
/// dontChange shows the name exactly as typed.
enum NameDisplayOptions {
  firstName,
  lastName,
  splitFullName,
  initials,
  dontChange
}