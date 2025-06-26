import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String?> onChanged;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Color dropdownColor;
  final SizedBox trailingIcon;

  const CustomDropdownButton({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.backgroundColor = Colors.white,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(8),
    this.textStyle,
    this.dropdownColor = Colors.white,
    this.trailingIcon = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              elevation: 1,
              value: value,
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style:
                            textStyle ??
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              dropdownColor: dropdownColor,
              icon: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(borderRadius),
              isDense: true,
              padding: EdgeInsets.zero,
              style:
                  textStyle ??
                  const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
