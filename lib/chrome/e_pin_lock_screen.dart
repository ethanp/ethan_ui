import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'e_privacy_chrome.dart';

/// 4-digit PIN pad. Calls [onUnlocked] when [pin] matches.
class const EPinLockScreen({
  super.key,
  required final String pin,
  required final VoidCallback onUnlocked,
}) extends StatefulWidget {
  @override
  State<EPinLockScreen> createState() => _EPinLockScreenState();
}

class _EPinLockScreenState()
    extends State<EPinLockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  bool _showError = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _appendPinDigit(String digit) {
    if (_enteredPin.length >= 4) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += digit;
      _showError = false;
    });

    if (_enteredPin.length == 4) _validatePin();
  }

  void _deleteLastPinDigit() {
    if (_enteredPin.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      _showError = false;
    });
  }

  void _validatePin() {
    if (_enteredPin == widget.pin) {
      HapticFeedback.mediumImpact();
      widget.onUnlocked();
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() => _showError = true);
    _shakeController.forward().then((_) {
      _shakeController.reset();
      setState(() => _enteredPin = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EPrivacyChrome.lockBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Text('Enter PIN', style: EPrivacyChrome.title),
            const SizedBox(height: 8),
            if (_showError)
              const Text('Incorrect PIN', style: EPrivacyChrome.error)
            else
              const SizedBox(height: 20),
            const SizedBox(height: 32),
            _shakingPinIndicator(),
            const Spacer(),
            _numberPad(),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _shakingPinIndicator() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final double shake = _showError
            ? (1 - _shakeAnimation.value) *
                  10 *
                  ((_shakeController.value * 10).floor() % 2 == 0 ? 1 : -1)
            : 0.0;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: _enteredPinIndicator(),
    );
  }

  Widget _enteredPinIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final bool isFilled = index < _enteredPin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? (_showError
                      ? EPrivacyChrome.danger
                      : EPrivacyChrome.filledDot)
                : Colors.transparent,
            border: Border.all(
              color: _showError
                  ? EPrivacyChrome.danger
                  : EPrivacyChrome.textSecondary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _numberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _digitRow(const ['1', '2', '3']),
          const SizedBox(height: 16),
          _digitRow(const ['4', '5', '6']),
          const SizedBox(height: 16),
          _digitRow(const ['7', '8', '9']),
          const SizedBox(height: 16),
          _digitRow(const ['', '0', 'delete']),
        ],
      ),
    );
  }

  Widget _digitRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [for (final String key in keys) _padKey(key)],
    );
  }

  Widget _padKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 80, height: 80);
    if (key == 'delete') return _deleteButton();
    return _digitButton(key);
  }

  Widget _digitButton(String digit) {
    return GestureDetector(
      onTap: () => _appendPinDigit(digit),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: EPrivacyChrome.keyFill,
        ),
        child: Center(child: Text(digit, style: EPrivacyChrome.digit)),
      ),
    );
  }

  Widget _deleteButton() {
    return GestureDetector(
      onTap: _deleteLastPinDigit,
      child: const SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: EPrivacyChrome.textSecondary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
