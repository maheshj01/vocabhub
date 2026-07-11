import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:vocabhub/controller/auth_controller.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/auth_flow.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';

/// Phone authentication: number entry → OTP → (add email). Identity is Firebase;
/// the profile lands in Supabase keyed on email. Because email is the account
/// key, a phone user must add a verified email (by linking Google) to finish —
/// this is what converges phone and Google sign-ins onto the same account.
class PhoneAuthPage extends StatefulWidget {
  static const String route = '/phone-auth';
  const PhoneAuthPage({Key? key}) : super(key: key);

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

enum _Step { enterPhone, enterOtp, linkEmail }

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  late final PhoneController _phoneController;
  final _otpController = TextEditingController();
  final _analytics = Analytics.instance;

  _Step _step = _Step.enterPhone;
  bool _busy = false;
  bool _phoneValid = false;
  String? _verificationId;
  String _sentToDisplay = '';

  @override
  void initState() {
    super.initState();
    _phoneController = PhoneController(
      initialValue: PhoneNumber(isoCode: _detectDefaultCountry(), nsn: ''),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Defaults the country selector to the device's region setting
  /// (Settings > Language & Region on iOS/Android), falling back to US.
  /// This is a better signal than SIM/locale-language and needs no
  /// permissions or network call, unlike IP-based geolocation.
  IsoCode _detectDefaultCountry() {
    try {
      final regionCode = WidgetsBinding.instance.platformDispatcher.locale.countryCode;
      if (regionCode != null && regionCode.isNotEmpty) {
        return IsoCode.values.byName(regionCode.toUpperCase());
      }
    } catch (_) {
      // Unrecognized region code (e.g. locale has no country) — fall through.
    }
    return IsoCode.US;
  }

  void _setBusy(bool value) {
    if (mounted) setState(() => _busy = value);
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendCode() async {
    final phoneNumber = _phoneController.value;
    if (phoneNumber == null || !phoneNumber.isValid()) {
      showError('Enter a valid phone number');
      return;
    }
    // E.164 format, e.g. +14155550123
    final e164 = '+${phoneNumber.countryCode}${phoneNumber.nsn}';
    _sentToDisplay = phoneNumber.international;

    _setBusy(true);
    await authController.startPhoneVerification(
      phoneNumber: e164,
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
        showError(error);
      },
    );
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (code.length < 6 || _verificationId == null) {
      showError('Enter the 6-digit code');
      return;
    }
    _setBusy(true);
    final result = await authController.verifyOtp(
      verificationId: _verificationId!,
      smsCode: code,
      fcmToken: pushNotificationService.fcmToken,
    );
    if (!mounted) return;
    // Phone proven but no email yet → require the email step to finish.
    if (result.outcome == AuthOutcome.needsEmail) {
      setState(() {
        _step = _Step.linkEmail;
        _busy = false;
      });
      return;
    }
    _setBusy(false);
    await handleAuthResult(context, result, _analytics);
  }

  Future<void> _linkEmail() async {
    _setBusy(true);
    final result = await authController.linkEmailWithGoogle(
      fcmToken: pushNotificationService.fcmToken,
    );
    _setBusy(false);
    if (!mounted) return;
    if (result.outcome == AuthOutcome.success) {
      await handleAuthResult(context, result, _analytics);
    } else {
      showError(result.errorMessage ?? 'Could not add your email. Please try again.');
    }
  }

  /// Abandons an incomplete phone sign-up (no email linked) and signs out.
  Future<void> _cancelLinkEmail() async {
    await authController.signOut();
    if (mounted) Navigator.of(context).maybePop();
  }

  String get _title => switch (_step) {
        _Step.enterPhone => 'Sign in with phone',
        _Step.enterOtp => 'Verify code',
        _Step.linkEmail => 'Add your email',
      };

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(_title),
          leading: BackButton(
            onPressed: () {
              switch (_step) {
                case _Step.enterOtp:
                  setState(() => _step = _Step.enterPhone);
                  break;
                case _Step.linkEmail:
                  _cancelLinkEmail();
                  break;
                case _Step.enterPhone:
                  Navigator.of(context).maybePop();
                  break;
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: switch (_step) {
              _Step.enterPhone => _phoneStep(),
              _Step.enterOtp => _otpStep(),
              _Step.linkEmail => _linkEmailStep(),
            },
          ),
        ),
      ),
    );
  }

  Widget _phoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        40.0.vSpacer(),
        Text('We\'ll send you a one-time code by SMS.',
            style: Theme.of(context).textTheme.titleMedium),
        32.0.vSpacer(),
        PhoneFormField(
          controller: _phoneController,
          autofocus: true,
          enabled: !_busy,
          countrySelectorNavigator: const CountrySelectorNavigator.bottomSheet(),
          decoration: const InputDecoration(
            labelText: 'Phone number',
            border: OutlineInputBorder(),
          ),
          validator: PhoneValidator.compose([
            PhoneValidator.required(context),
            PhoneValidator.validMobile(context),
          ]),
          onChanged: (phoneNumber) {
            setState(() => _phoneValid = phoneNumber.isValid());
          },
        ),
        24.0.vSpacer(),
        VHButton(
          width: double.infinity,
          label: 'Send code',
          isLoading: _busy,
          onTap: _phoneValid ? _sendCode : null,
        ),
      ],
    );
  }

  Widget _otpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        40.0.vSpacer(),
        Text('Enter the code we sent to $_sentToDisplay',
            style: Theme.of(context).textTheme.titleMedium),
        32.0.vSpacer(),
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
        VHButton(width: double.infinity, label: 'Verify', isLoading: _busy, onTap: _verifyCode),
        12.0.vSpacer(),
        TextButton(onPressed: _busy ? null : _sendCode, child: const Text('Resend code')),
      ],
    );
  }

  Widget _linkEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        40.0.vSpacer(),
        Text('One last step', style: Theme.of(context).textTheme.titleLarge),
        12.0.vSpacer(),
        Text(
          'Add an email to finish setting up your account. This lets us sync your '
          'bookmarks and contributions, and keeps one account whether you sign in '
          'with phone or Google. We\'ll use your Google account to verify it.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        32.0.vSpacer(),
        VHButton(
          width: double.infinity,
          label: 'Continue with Google',
          isLoading: _busy,
          onTap: _linkEmail,
        ),
        12.0.vSpacer(),
        TextButton(onPressed: _busy ? null : _cancelLinkEmail, child: const Text('Cancel')),
      ],
    );
  }
}
