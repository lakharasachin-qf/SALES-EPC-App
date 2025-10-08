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
  CustomLinearStepperState createState() => CustomLinearStepperState();
}

class CustomLinearStepperState extends State<CustomLinearStepper> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(CustomLinearStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _scrollToCurrentStep();
    }
  }

  void _scrollToCurrentStep() {
    final stepWidth = 116.0; // Width of each step label
    final totalSteps = widget.steps.length;
    final currentStep = widget.currentStep.clamp(0, totalSteps - 1);
    final targetOffset = currentStep * stepWidth;

    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final scrollOffset = targetOffset.clamp(0.0, maxScrollExtent);

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
          // --- Circles and Step-Based Progress Bar ---
          SizedBox(
            height: 30,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fullWidth = constraints.maxWidth;
                final stepWidth = fullWidth / (totalSteps - 1);
                final filledWidth = stepWidth * widget.currentStep;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background line
                    Positioned(
                      top: 12,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.inactiveColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Filled line (step-based)
                    Positioned(
                      top: 12,
                      left: 0,
                      child: AnimatedContainer(
                        duration: widget.animationDuration,
                        height: 6,
                        width: filledWidth,
                        decoration: BoxDecoration(
                          color: widget.activeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Step circles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(totalSteps, (index) {
                        final isActive = index <= widget.currentStep;
                        return GestureDetector(
                          onTap: () => widget.onStepTapped(index),
                          child: AnimatedContainer(
                            duration: widget.animationDuration,
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? widget.activeColor
                                  : widget.inactiveColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
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
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.onStepTapped(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 100,
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
