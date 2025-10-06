import 'package:flutter/material.dart';

class CustomLinearStepper extends StatefulWidget {
  final int currentStep;
  final List<String> steps;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;
  final Function(int) onStepTapped;

  const CustomLinearStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    this.activeColor = Colors.blue,
    this.inactiveColor = const Color(0xFFD6D6D6),
    this.animationDuration = const Duration(milliseconds: 400),
    required this.onStepTapped,
  });

  @override
  _CustomLinearStepperState createState() => _CustomLinearStepperState();
}

class _CustomLinearStepperState extends State<CustomLinearStepper> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(CustomLinearStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      // Auto-scroll to the current step
      _scrollToCurrentStep();
    }
  }

  void _scrollToCurrentStep() {
    final stepWidth = 116.0; // Width of each step label (100 + 8 + 8 padding)
    final totalSteps = widget.steps.length;
    final currentStep = widget.currentStep.clamp(0, totalSteps - 1);
    final targetOffset = currentStep * stepWidth;

    // Calculate max scroll extent
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    // Ensure the target offset is within bounds
    final scrollOffset = targetOffset.clamp(0.0, maxScrollExtent);

    // Animate to the current step
    _scrollController.animateTo(
      scrollOffset,
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSteps = widget.steps.length;

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
                  color: widget.inactiveColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Filled portion
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final progress = (widget.currentStep / (totalSteps - 1))
                      .clamp(0.0, 1.0);
                  return AnimatedContainer(
                    duration: widget.animationDuration,
                    height: 6,
                    width: width * progress,
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // --- Step Labels with Scrolling ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            controller: _scrollController,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final isActive = index <= widget.currentStep;
                return GestureDetector(
                  onTap: () {
                    widget.onStepTapped(
                      index,
                    ); // Call callback to update current step
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 100, // Fixed width for each step label
                      child: Text(
                        widget.steps[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive ? widget.activeColor : Colors.grey,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
