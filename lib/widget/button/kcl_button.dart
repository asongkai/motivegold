import 'package:flutter/material.dart';

class KclButton extends StatelessWidget {
  const KclButton({
    super.key,
    this.text,
    this.color,
    this.icon,
    this.fullWidth = false,
    this.block = false,
    this.isLoading = false,
    this.enabled = true,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    required this.onTap,
  });

  final String? text;
  final Color? color;
  final IconData? icon;
  final bool fullWidth;
  final bool block;
  final bool isLoading;
  final bool enabled;
  final ButtonSize size;
  final ButtonVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: fullWidth ? double.infinity : null,
      height: _getButtonHeight(),
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(colorScheme),
          foregroundColor: _getForegroundColor(colorScheme),
          disabledBackgroundColor: colorScheme.outline.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          elevation: variant == ButtonVariant.elevated ? 3 : 0,
          shadowColor: colorScheme.shadow.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: variant == ButtonVariant.outlined
                ? BorderSide(
                    color: color ?? colorScheme.primary,
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          padding: _getPadding(),
          minimumSize: Size(0, _getButtonHeight()),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getForegroundColor(colorScheme),
                    ),
                  ),
                )
              : _buildButtonContent(colorScheme),
        ),
      ),
    );
  }

  Widget _buildButtonContent(ColorScheme colorScheme) {
    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _getIconSize(),
            color: _getForegroundColor(colorScheme),
          ),
          const SizedBox(width: 8),
          Text(
            text!,
            style: TextStyle(
              fontFamily: 'NotoSansLao',
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    } else if (icon != null) {
      return Icon(
        icon,
        size: _getIconSize(),
        color: _getForegroundColor(colorScheme),
      );
    } else {
      return Text(
        text ?? '',
        style: TextStyle(
          fontFamily: 'NotoSansLao',
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (color != null) return color!;

    switch (variant) {
      case ButtonVariant.primary:
        return colorScheme.primary;
      case ButtonVariant.secondary:
        return colorScheme.secondary;
      case ButtonVariant.outlined:
        return Colors.transparent;
      case ButtonVariant.text:
        return Colors.transparent;
      case ButtonVariant.elevated:
        return colorScheme.surface;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    switch (variant) {
      case ButtonVariant.primary:
        return colorScheme.onPrimary;
      case ButtonVariant.secondary:
        return colorScheme.onSecondary;
      case ButtonVariant.outlined:
        return color ?? colorScheme.primary;
      case ButtonVariant.text:
        return color ?? colorScheme.primary;
      case ButtonVariant.elevated:
        return colorScheme.onSurface;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 18;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

enum ButtonSize { small, medium, large }

enum ButtonVariant { primary, secondary, outlined, text, elevated }
