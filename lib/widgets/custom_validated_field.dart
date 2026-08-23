import 'package:flutter/material.dart';

class CustomValidatedField extends StatelessWidget {
  final String? label;
  final Widget child;
  final String? Function()? validator;
  final double? height;
  final EdgeInsetsGeometry padding;

  const CustomValidatedField({
    super.key,
    this.label,
    required this.child,
    this.validator,
    this.height,
    this.padding = const EdgeInsets.only(bottom: 24.0),
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator != null ? (_) => validator!() : null,
      builder: (FormFieldState<String> state) {
        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8.0),
              ],
              if (height != null) SizedBox(height: height, child: child) else child,
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
