import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const CustomSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF239B56),
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: const Color(0xFF239B56),
                  overlayColor: const Color(0xFF239B56).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: value,
                  onChanged: onChanged,
                  min: 0.0,
                  max: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 45,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
