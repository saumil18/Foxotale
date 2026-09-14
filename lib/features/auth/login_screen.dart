import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../access/role.dart';
import '../../theme/fox_theme.dart';
import '../../widgets/fox_brand_text.dart';

enum _Method { emailPassword, mobileOtp }

/// Sign-in for the Staff App.
///
/// NOTE: no authentication is implemented. Every field here is validated for
/// shape only and any well-formed input signs in. Wire this to a real identity
/// provider before it goes anywhere near a real property — in particular the
/// single-device rule below is presented to the user but is enforced only by
/// the backend session store, never by this screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSignedIn});

  final ValueChanged<FoxRole> onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _mobile = TextEditingController();
  final _otp = TextEditingController();

  _Method _method = _Method.emailPassword;
  FoxRole _role = FoxRole.gmHm;
  bool _obscure = true;
  bool _otpSent = false;
  int _resendIn = 0;
  Timer? _ticker;

  String? _emailError;
  String? _passwordError;
  String? _mobileError;
  String? _otpError;

  @override
  void dispose() {
    _ticker?.cancel();
    _email.dispose();
    _password.dispose();
    _mobile.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _ticker?.cancel();
    setState(() => _resendIn = 30);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  void _sendOtp() {
    final digits = _mobile.text.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _mobileError = digits.length == 10
          ? null
          : 'Enter the 10 digits of your mobile number.';
    });
    if (_mobileError != null) return;
    setState(() => _otpSent = true);
    _startResendCountdown();
  }

  void _submit() {
    if (_method == _Method.emailPassword) {
      final email = _email.text.trim();
      setState(() {
        _emailError = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
            ? null
            : 'Enter a valid email address, like name@foxotalehotels.com';
        _passwordError = _password.text.length >= 8
            ? null
            : 'Password must be at least 8 characters.';
      });
      if (_emailError != null || _passwordError != null) return;
    } else {
      if (!_otpSent) {
        _sendOtp();
        return;
      }
      setState(() {
        _otpError = _otp.text.trim().length == 6
            ? null
            : 'Enter the 6-digit code we sent you.';
      });
      if (_otpError != null) return;
    }
    widget.onSignedIn(_role);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;

    return Scaffold(
      // White, not the brand cream: this screen carries six input controls,
      // and the fields need a ground they can separate from.
      backgroundColor: c.surfaceBase,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          children: [
            _BrandHeader(),
            const SizedBox(height: 32),
            _RoleSelect(
              role: _role,
              onChanged: (r) => setState(() => _role = r),
            ),
            const SizedBox(height: 20),
            SegmentedButton<_Method>(
              segments: const [
                ButtonSegment(
                    value: _Method.emailPassword, label: Text('Email')),
                ButtonSegment(
                    value: _Method.mobileOtp, label: Text('Mobile OTP')),
              ],
              selected: {_method},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() {
                _method = s.first;
                _otpSent = false;
              }),
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(t.bodySm),
                foregroundColor: WidgetStateProperty.resolveWith((st) =>
                    st.contains(WidgetState.selected)
                        ? c.onBrand
                        : c.textSecondary),
                backgroundColor: WidgetStateProperty.resolveWith((st) =>
                    st.contains(WidgetState.selected)
                        ? c.brandAction
                        : c.surfaceBase),
              ),
            ),
            const SizedBox(height: 20),
            if (_method == _Method.emailPassword)
              _EmailForm(
                email: _email,
                password: _password,
                obscure: _obscure,
                emailError: _emailError,
                passwordError: _passwordError,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
              )
            else
              _MobileForm(
                mobile: _mobile,
                otp: _otp,
                otpSent: _otpSent,
                mobileError: _mobileError,
                otpError: _otpError,
                resendIn: _resendIn,
                onSendOtp: _sendOtp,
                onChangeNumber: () => setState(() {
                  _otpSent = false;
                  _otp.clear();
                  _otpError = null;
                }),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              child: Text(_method == _Method.mobileOtp && !_otpSent
                  ? 'Send OTP'
                  : 'Sign in'),
            ),
            const SizedBox(height: 12),
            _SingleDeviceNotice(),
            const SizedBox(height: 28),
            _Divider(label: 'New to FoxOtale?'),
            const SizedBox(height: 16),
            _AppleButton(onPressed: () => widget.onSignedIn(_role)),
            const SizedBox(height: 10),
            _GoogleButton(onPressed: () => widget.onSignedIn(_role)),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => widget.onSignedIn(_role),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 52),
                side: BorderSide(color: c.border),
                foregroundColor: c.textPrimary,
              ),
              child: const Text('Sign up manually'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/brand/fox_mark.png',
              width: 64, height: 64, fit: BoxFit.cover),
        ),
        const SizedBox(height: 14),
        FoxBrandText('FoxOtale', style: t.wordmark.copyWith(fontSize: 30)),
        const SizedBox(height: 2),
        Text('STAFF APP',
            style: t.label.copyWith(color: c.brandAction, letterSpacing: 3)),
        const SizedBox(height: 8),
        Text('Stay Original, Live the Tale',
            style: TextStyle(
                fontFamily: 'Lora', fontSize: 13, color: c.textTertiary)),
      ],
    );
  }
}

class _RoleSelect extends StatelessWidget {
  const _RoleSelect({required this.role, required this.onChanged});

  final FoxRole role;
  final ValueChanged<FoxRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SIGN IN AS', style: t.overline.copyWith(color: c.textMin)),
        const SizedBox(height: 6),
        DropdownButtonFormField<FoxRole>(
          initialValue: role,
          isExpanded: true,
          style: t.body.copyWith(color: c.textPrimary),
          icon: Icon(Icons.expand_more, color: c.textTertiary),
          decoration: const InputDecoration(),
          items: [
            for (final r in FoxRole.values)
              DropdownMenuItem(
                value: r,
                child: Text('${r.label} · ${r.scope}',
                    overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (r) {
            if (r != null) onChanged(r);
          },
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text.toUpperCase(),
            style: context.type.overline.copyWith(color: context.fox.textMin)),
      );
}

class _EmailForm extends StatelessWidget {
  const _EmailForm({
    required this.email,
    required this.password,
    required this.obscure,
    required this.onToggleObscure,
    this.emailError,
    this.passwordError,
  });

  final TextEditingController email;
  final TextEditingController password;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? emailError;
  final String? passwordError;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Work email'),
        TextField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          style: context.type.body.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: 'name@foxotalehotels.com',
            errorText: emailError,
          ),
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Password'),
        TextField(
          controller: password,
          obscureText: obscure,
          style: context.type.body.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: 'At least 8 characters',
            errorText: passwordError,
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: c.textTertiary,
              ),
              tooltip: obscure ? 'Show password' : 'Hide password',
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('Forgot password?'),
          ),
        ),
      ],
    );
  }
}

class _MobileForm extends StatelessWidget {
  const _MobileForm({
    required this.mobile,
    required this.otp,
    required this.otpSent,
    required this.resendIn,
    required this.onSendOtp,
    required this.onChangeNumber,
    this.mobileError,
    this.otpError,
  });

  final TextEditingController mobile;
  final TextEditingController otp;
  final bool otpSent;
  final int resendIn;
  final VoidCallback onSendOtp;
  final VoidCallback onChangeNumber;
  final String? mobileError;
  final String? otpError;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;

    if (!otpSent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Mobile number'),
          TextField(
            controller: mobile,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: context.type.body.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: '98765 43210',
              prefixText: '+91  ',
              prefixStyle: t.body.copyWith(color: c.textSecondary),
              errorText: mobileError,
            ),
          ),
          const SizedBox(height: 6),
          Text('We will text you a 6-digit code.',
              style: t.caption.copyWith(color: c.textMin)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Code sent to +91 ${mobile.text}',
                  style: t.bodySm.copyWith(color: c.textSecondary)),
            ),
            TextButton(onPressed: onChangeNumber, child: const Text('Change')),
          ],
        ),
        const SizedBox(height: 8),
        const _FieldLabel('Enter code'),
        TextField(
          controller: otp,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          style: t.figureLg.copyWith(letterSpacing: 12, color: c.textPrimary),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: t.figureLg
                .copyWith(letterSpacing: 12, color: c.textDisabled),
            errorText: otpError,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: resendIn > 0
              ? Text('Resend code in ${resendIn}s',
                  style: t.caption.copyWith(color: c.textMin))
              : TextButton(
                  onPressed: onSendOtp, child: const Text('Resend code')),
        ),
      ],
    );
  }
}

/// The single-session rule is a product promise, so it is stated before the
/// user commits rather than discovered when they are signed out elsewhere.
class _SingleDeviceNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.infoTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.phonelink_lock_outlined, size: 16, color: c.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'One device at a time. Signing in here signs you out of any '
              'other device using this email or mobile number.',
              style: context.type.caption.copyWith(color: c.info),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return Row(
      children: [
        Expanded(child: Divider(color: c.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FoxBrandText(label,
              style: context.type.caption.copyWith(color: c.textMin)),
        ),
        Expanded(child: Divider(color: c.divider)),
      ],
    );
  }
}

class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
      ),
      icon: const Icon(Icons.apple, size: 22),
      label: const Text('Sign up with Apple'),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        side: BorderSide(color: c.border),
        foregroundColor: c.textPrimary,
        backgroundColor: c.surfaceBase,
      ),
      // Placeholder mark. Replace with Google's official asset before release —
      // their branding guidelines require it.
      icon: const Text(
        'G',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
        ),
      ),
      label: const Text('Sign up with Google'),
    );
  }
}
