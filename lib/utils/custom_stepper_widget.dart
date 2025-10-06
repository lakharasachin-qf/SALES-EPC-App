import 'package:flutter/material.dart';

class CustomLinearStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;

  const CustomLinearStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    this.activeColor = Colors.blue,
    this.inactiveColor = const Color(0xFFD6D6D6),
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    final totalSteps = steps.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // --- Progress Bar ---
          Stack(
            children: [
              // Background line
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: inactiveColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Filled portion
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final progress = (currentStep / (totalSteps - 1)).clamp(
                    0.0,
                    1.0,
                  );
                  return AnimatedContainer(
                    duration: animationDuration,
                    height: 6,
                    width: width * progress,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // --- Step Labels ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              return Flexible(
                child: Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? activeColor : Colors.grey,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
