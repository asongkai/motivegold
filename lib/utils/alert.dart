import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Alert {
  static error(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return _showModernDialog(
      context: context,
      type: AlertType.error,
      title: title,
      message: message,
      primaryButtonText: buttonText,
      primaryAction: action ?? () {},
    );
  }

  static warning(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return _showModernDialog(
      context: context,
      type: AlertType.warning,
      title: title,
      message: message,
      primaryButtonText: buttonText,
      primaryAction: action ?? () {},
      showCloseIcon: true,
      showOnlyPrimaryButton: true, // Warning only shows one button like original
    );
  }

  static info(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return _showModernDialog(
      context: context,
      type: AlertType.info,
      title: title,
      message: message,
      primaryButtonText: buttonText,
      primaryAction: action ?? () {},
      secondaryButtonText: 'ยกเลิก',
      showCloseIcon: true,
    );
  }

  static success(
      BuildContext context, String title, String message, String buttonText,
      {Function()? action}) {
    return _showModernDialog(
      context: context,
      type: AlertType.success,
      title: title,
      message: message,
      primaryButtonText: buttonText,
      primaryAction: action ?? () {},
    );
  }

  static Future<void> _showModernDialog({
    required BuildContext context,
    required AlertType type,
    required String title,
    required String message,
    required String primaryButtonText,
    Function()? primaryAction,
    String? secondaryButtonText,
    bool showCloseIcon = false,
    bool showOnlyPrimaryButton = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return ModernAlertDialog(
          type: type,
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          primaryAction: primaryAction,
          secondaryButtonText: showOnlyPrimaryButton ? null : secondaryButtonText,
          showCloseIcon: showCloseIcon,
        );
      },
    );
  }
}

enum AlertType { error, warning, info, success }

class ModernAlertDialog extends StatefulWidget {
  final AlertType type;
  final String title;
  final String message;
  final String primaryButtonText;
  final Function()? primaryAction;
  final String? secondaryButtonText;
  final bool showCloseIcon;

  const ModernAlertDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    this.primaryAction,
    this.secondaryButtonText,
    this.showCloseIcon = false,
  });

  @override
  State<ModernAlertDialog> createState() => _ModernAlertDialogState();
}

class _ModernAlertDialogState extends State<ModernAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  AlertConfig get _config {
    switch (widget.type) {
      case AlertType.error:
        return AlertConfig(
          primaryColor: Colors.red[600]!,
          backgroundColor: Colors.red[50]!,
          icon: Icons.error_outline,
          gradientColors: [Colors.red[400]!, Colors.red[600]!],
        );
      case AlertType.warning:
        return AlertConfig(
          primaryColor: Colors.orange[600]!,
          backgroundColor: Colors.orange[50]!,
          icon: Icons.warning_amber_outlined,
          gradientColors: [Colors.orange[400]!, Colors.orange[600]!],
        );
      case AlertType.info:
        return AlertConfig(
          primaryColor: Colors.blue[600]!,
          backgroundColor: Colors.blue[50]!,
          icon: Icons.info_outline,
          gradientColors: [Colors.blue[400]!, Colors.blue[600]!],
        );
      case AlertType.success:
        return AlertConfig(
          primaryColor: Colors.green[600]!,
          backgroundColor: Colors.green[50]!,
          icon: Icons.check_circle_outline,
          gradientColors: [Colors.green[400]!, Colors.green[600]!],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.95;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                width: dialogWidth,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: config.primaryColor.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact Header with icon
                    _buildCompactHeader(config),

                    // Scrollable Content
                    Flexible(
                      child: _buildContent(config),
                    ),

                    // Buttons
                    _buildButtons(config),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactHeader(AlertConfig config) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Compact Icon
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.7 + (value * 0.3), // Smaller scale range
                child: Container(
                  width: 48, // Reduced from 80
                  height: 48, // Reduced from 80
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    config.icon,
                    size: 24, // Reduced from 40
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // Title - now inline with icon
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.sp, // Reduced from 20.sp
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          // Close icon if needed - positioned at the end
          if (widget.showCloseIcon)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(6), // Slightly larger touch target
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18, // Slightly smaller
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(AlertConfig config) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16), // Adjusted padding
        child: Column(
          children: [
            // Message
            SelectableText(
              widget.message,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Decorative line - smaller
            const SizedBox(height: 16), // Reduced spacing
            Container(
              width: 40, // Reduced from 60
              height: 2, // Reduced from 3
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: config.gradientColors),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(AlertConfig config) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: widget.secondaryButtonText != null
          ? Row(
        children: [
          // Secondary button (Cancel)
          Expanded(
            child: SizedBox(
              height: 48, // Reduced from 52
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: config.primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14), // Slightly reduced
                  ),
                ),
                child: Text(
                  widget.secondaryButtonText!,
                  style: TextStyle(
                    fontSize: 15.sp, // Slightly reduced
                    fontWeight: FontWeight.w600,
                    color: config.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12), // Reduced spacing
          // Primary button (OK)
          Expanded(
            child: SizedBox(
              height: 48, // Reduced from 52
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.primaryAction?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14), // Slightly reduced
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: config.gradientColors),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      widget.primaryButtonText,
                      style: TextStyle(
                        fontSize: 15.sp, // Slightly reduced
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : SizedBox(
        width: double.infinity,
        height: 48, // Reduced from 52
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.primaryAction?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // Slightly reduced
            ),
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: config.gradientColors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                widget.primaryButtonText,
                style: TextStyle(
                  fontSize: 15.sp, // Slightly reduced
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlertConfig {
  final Color primaryColor;
  final Color backgroundColor;
  final IconData icon;
  final List<Color> gradientColors;

  AlertConfig({
    required this.primaryColor,
    required this.backgroundColor,
    required this.icon,
    required this.gradientColors,
  });
}