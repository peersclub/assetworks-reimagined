import 'package:flutter/cupertino.dart';

class IOSStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final ValueChanged<int>? onStepTapped;
  
  const IOSStepper({
    Key? key,
    required this.currentStep,
    required this.steps,
    this.onStepTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentStep;
        final isCompleted = index < currentStep;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => onStepTapped?.call(index),
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive
                        ? CupertinoColors.systemBlue
                        : CupertinoColors.systemGrey5,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            CupertinoIcons.checkmark,
                            size: 16,
                            color: CupertinoColors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? CupertinoColors.white
                                  : CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive
                        ? CupertinoColors.label
                        : CupertinoColors.systemGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}