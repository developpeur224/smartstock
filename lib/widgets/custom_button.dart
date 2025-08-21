import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outlined }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool expanded; // Nouveau paramètre pour contrôler l'expansion

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.expanded = false, // Par défaut, pas d'expansion
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = _getButtonStyle(context);

    // Créer le widget bouton de base
    Widget buttonChild = ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: isLoading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : Text(
        text,
        style: _getTextStyle(context),
      ),
    );

    // Si expanded est true, on entoure le bouton avec un SizedBox.expand
    if (expanded) {
      return SizedBox(
        width: double.infinity, // Prend toute la largeur
        child: buttonChild,
      );
    }

    return buttonChild;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case ButtonVariant.outlined:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Theme.of(context).primaryColor),
          ),
        );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
      case ButtonVariant.secondary:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
      case ButtonVariant.outlined:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        );
    }
  }
}