import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool isInteger;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixText,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
    this.validator,
    this.isInteger = false,
    this.autovalidateMode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  String _previousText = ''; // Initialisation correcte

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // Sauvegarder le texte actuel quand le champ obtient le focus
      _previousText = widget.controller.text;
    } else {
      // Validation quand le champ perd le focus
      if (widget.autovalidateMode == AutovalidateMode.onUserInteraction ||
          widget.autovalidateMode == AutovalidateMode.always) {
        setState(() {}); // Force la validation
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return null;

    final cleanedValue = value.replaceAll(' ', '');
    if (cleanedValue.isEmpty) return 'Veuillez entrer une valeur';

    if (widget.isInteger) {
      if (int.tryParse(cleanedValue) == null) {
        return 'Veuillez entrer un nombre entier valide';
      }
    } else {
      if (double.tryParse(cleanedValue) == null) {
        return 'Veuillez entrer un nombre valide';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer le type de clavier
    TextInputType effectiveKeyboardType = widget.keyboardType ?? TextInputType.text;
    if (widget.isInteger) {
      effectiveKeyboardType = TextInputType.numberWithOptions(
        decimal: false,
        signed: false,
      );
    }

    // Déterminer les input formatters
    List<TextInputFormatter> inputFormatters = [];

    if (widget.isInteger) {
      // Seulement pour les entiers: chiffres uniquement
      inputFormatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (effectiveKeyboardType == TextInputType.number ||
        (effectiveKeyboardType is TextInputType &&
            effectiveKeyboardType.decimal == true)) {
      // Pour les nombres décimaux: chiffres et point
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')));
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: effectiveKeyboardType,
      maxLines: widget.maxLines,
      obscureText: widget.obscureText,
      inputFormatters: inputFormatters,
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixText: widget.prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        errorMaxLines: 2, // Permet d'afficher les messages d'erreur sur 2 lignes
      ),
      validator: (value) {
        // Validation pour les nombres si isInteger est true OU si le clavier est numérique
        if (widget.isInteger ||
            effectiveKeyboardType == TextInputType.number ||
            (effectiveKeyboardType is TextInputType && effectiveKeyboardType.decimal == true)) {
          final numberValidation = _validateNumber(value);
          if (numberValidation != null) {
            return numberValidation;
          }
        }

        // Validation personnalisée fournie
        if (widget.validator != null) {
          return widget.validator!(value);
        }

        return null;
      },
      onChanged: (value) {
        // Validation en temps réel
        if (widget.autovalidateMode == AutovalidateMode.onUserInteraction ||
            widget.autovalidateMode == AutovalidateMode.always) {
          setState(() {});
        }
      },
    );
  }
}