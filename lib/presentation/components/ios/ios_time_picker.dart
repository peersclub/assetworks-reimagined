import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/theme/ios18_theme.dart';

class iOSTimePicker extends StatefulWidget {
  final DateTime initialTime;
  final Function(DateTime) onTimeChanged;
  final CupertinoDatePickerMode mode;
  final int minuteInterval;
  final bool use24hFormat;
  
  const iOSTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
    this.mode = CupertinoDatePickerMode.time,
    this.minuteInterval = 1,
    this.use24hFormat = false,
  });
  
  @override
  State<iOSTimePicker> createState() => _iOSTimePickerState();
}

class _iOSTimePickerState extends State<iOSTimePicker> {
  late DateTime _selectedTime;
  
  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216,
      child: CupertinoDatePicker(
        mode: widget.mode,
        initialDateTime: widget.initialTime,
        minuteInterval: widget.minuteInterval,
        use24hFormat: widget.use24hFormat,
        onDateTimeChanged: (DateTime newTime) {
          HapticFeedback.selectionFeedback();
          setState(() {
            _selectedTime = newTime;
          });
          widget.onTimeChanged(newTime);
        },
      ),
    );
  }
}

// Time picker in a modal
class iOSTimePickerModal extends StatefulWidget {
  final DateTime initialTime;
  final String title;
  final Function(DateTime) onConfirm;
  final bool use24hFormat;
  
  const iOSTimePickerModal({
    super.key,
    required this.initialTime,
    required this.title,
    required this.onConfirm,
    this.use24hFormat = false,
  });
  
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialTime,
    String title = 'Select Time',
    bool use24hFormat = false,
  }) async {
    return showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime tempTime = initialTime;
        
        return Container(
          height: 300,
          color: iOS18Theme.primaryBackground.resolveFrom(context),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: iOS18Theme.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: iOS18Theme.systemRed),
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: iOS18Theme.label.resolveFrom(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context, tempTime);
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: iOS18Theme.systemBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: use24hFormat,
                  onDateTimeChanged: (DateTime newTime) {
                    HapticFeedback.selectionFeedback();
                    tempTime = newTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  State<iOSTimePickerModal> createState() => _iOSTimePickerModalState();
}

class _iOSTimePickerModalState extends State<iOSTimePickerModal> {
  late DateTime _tempTime;
  
  @override
  void initState() {
    super.initState();
    _tempTime = widget.initialTime;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: iOS18Theme.primaryBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: widget.initialTime,
              use24hFormat: widget.use24hFormat,
              onDateTimeChanged: (DateTime newTime) {
                HapticFeedback.selectionFeedback();
                setState(() {
                  _tempTime = newTime;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: iOS18Theme.systemRed),
            ),
          ),
          Text(
            widget.title,
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onConfirm(_tempTime);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: iOS18Theme.systemBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Inline time picker field
class iOSTimePickerField extends StatefulWidget {
  final DateTime initialTime;
  final String label;
  final Function(DateTime) onTimeChanged;
  final bool use24hFormat;
  
  const iOSTimePickerField({
    super.key,
    required this.initialTime,
    required this.label,
    required this.onTimeChanged,
    this.use24hFormat = false,
  });
  
  @override
  State<iOSTimePickerField> createState() => _iOSTimePickerFieldState();
}

class _iOSTimePickerFieldState extends State<iOSTimePickerField> {
  late DateTime _selectedTime;
  
  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }
  
  String _formatTime(DateTime time) {
    final hour = widget.use24hFormat
        ? time.hour.toString().padLeft(2, '0')
        : (time.hour % 12 == 0 ? 12 : time.hour % 12).toString();
    final minute = time.minute.toString().padLeft(2, '0');
    final period = widget.use24hFormat ? '' : (time.hour < 12 ? ' AM' : ' PM');
    return '$hour:$minute$period';
  }
  
  void _showTimePicker() {
    HapticFeedback.selectionFeedback();
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return iOSTimePickerModal(
          initialTime: _selectedTime,
          title: widget.label,
          use24hFormat: widget.use24hFormat,
          onConfirm: (DateTime newTime) {
            setState(() {
              _selectedTime = newTime;
            });
            widget.onTimeChanged(newTime);
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.clock,
              color: iOS18Theme.systemBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              _formatTime(_selectedTime),
              style: TextStyle(
                color: iOS18Theme.systemBlue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_right,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Timer countdown picker
class iOSTimerPicker extends StatefulWidget {
  final Duration initialDuration;
  final Function(Duration) onDurationChanged;
  final CupertinoTimerPickerMode mode;
  final int minuteInterval;
  final int secondInterval;
  
  const iOSTimerPicker({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
    this.mode = CupertinoTimerPickerMode.hms,
    this.minuteInterval = 1,
    this.secondInterval = 1,
  });
  
  @override
  State<iOSTimerPicker> createState() => _iOSTimerPickerState();
}

class _iOSTimerPickerState extends State<iOSTimerPicker> {
  late Duration _selectedDuration;
  
  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 216,
      child: CupertinoTimerPicker(
        mode: widget.mode,
        initialTimerDuration: widget.initialDuration,
        minuteInterval: widget.minuteInterval,
        secondInterval: widget.secondInterval,
        onTimerDurationChanged: (Duration newDuration) {
          HapticFeedback.selectionFeedback();
          setState(() {
            _selectedDuration = newDuration;
          });
          widget.onDurationChanged(newDuration);
        },
      ),
    );
  }
}