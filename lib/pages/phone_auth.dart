import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/auth_flow.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/button.dart';

/// Phone authentication: number entry → OTP verification, both driven through
/// [AuthController]. Identity is Firebase; the profile lands in Supabase keyed
/// on the Firebase uid — same as Google sign-in.
class PhoneAuthPage extends StatefulWidget {
  static const String route = '/phone-auth';
  const PhoneAuthPage({Key? key}) : super(key: key);

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

enum _Step { enterPhone, enterOtp }

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _analytics = Analytics.instance;

  _Step _step = _Step.enterPhone;
  bool _busy = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _setBusy(bool value) {
    if (mounted) setState(() => _busy = value);
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!_isValidE164(phone)) {
      NavbarNotifier.showSnackBar(context, 'Enter a valid phone number in the format +14155550123');
      return;
    }
    _setBusy(true);
    await authController.startPhoneVerification(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        if (mounted) {
          setState(() {
            _step = _Step.enterOtp;
            _busy = false;
          });
        }
      },
      onError: (error) {
        _setBusy(false);
        if (mounted) NavbarNotifier.showSnackBar(context, error);
      },
    );
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.length < 6 || _verificationId == null) {
      NavbarNotifier.showSnackBar(context, 'Enter the 6-digit code');
      return;
    }
    _setBusy(true);
    final result = await authController.verifyOtp(
      verificationId: _verificationId!,
      smsCode: code,
      fcmToken: pushNotificationService.fcmToken,
    );
    _setBusy(false);
    if (!mounted) return;
    await handleAuthResult(context, result, _analytics);
  }

  /// Minimal E.164 sanity check (`+` followed by 8–15 digits).
  bool _isValidE164(String value) => RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(value);

  @override
  Widget build(BuildContext context) {
    final isOtp = _step == _Step.enterOtp;
    return Scaffold(
      appBar: AppBar(
        title: Text(isOtp ? 'Verify code' : 'Sign in with phone'),
        leading: BackButton(
          onPressed: () {
            if (isOtp) {
              setState(() => _step = _Step.enterPhone);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              40.0.vSpacer(),
              Text(
                isOtp
                    ? 'Enter the code we sent to ${_phoneController.text.trim()}'
                    : 'We\'ll send you a one-time code by SMS.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              32.0.vSpacer(),
              if (!isOtp)
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  enabled: !_busy,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '+14155550123',
                    border: OutlineInputBorder(),
                  ),
                )
              else
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  enabled: !_busy,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: '6-digit code',
                    border: OutlineInputBorder(),
                  ),
                ),
              24.0.vSpacer(),
              VHButton(
                width: double.infinity,
                label: isOtp ? 'Verify' : 'Send code',
                isLoading: _busy,
                onTap: isOtp ? _verifyCode : _sendCode,
              ),
              if (isOtp) ...[
                12.0.vSpacer(),
                TextButton(
                  onPressed: _busy ? null : _sendCode,
                  child: const Text('Resend code'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
