import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/profile/presentation/edit_profile_controller.dart';
import 'package:vocabhub/profile/presentation/edit_profile_state.dart';
import 'package:vocabhub/profile/presentation/profile_providers.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class EditProfile extends StatefulWidget {
  static const String route = '/edit-profile';
  final VoidCallback? onClose;

  EditProfile({Key? key, this.onClose}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      desktopBuilder: (context) => EditProfileMobile(onClose: widget.onClose),
      mobileBuilder: (context) => EditProfileMobile(onClose: widget.onClose),
    );
  }
}

/// Edit-profile form. Owns an [EditProfileController] (profile island under
/// `lib/profile/`); the widget keeps only the text fields + navigation.
class EditProfileMobile extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const EditProfileMobile({Key? key, this.onClose}) : super(key: key);

  @override
  _EditProfileMobileState createState() => _EditProfileMobileState();
}

class _EditProfileMobileState extends ConsumerState<EditProfileMobile> {
  late final EditProfileController _controller;
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _joinedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userNotifierProvider);
    _controller = EditProfileController(
      checkUsername: ref.read(checkUsernameProvider),
      updateProfile: ref.read(updateProfileProvider),
      deleteAccount: ref.read(deleteAccountProvider),
      currentUsername: user.username,
    );
    _nameController.text = user.name;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _joinedController.text = user.created_at?.formatDate() ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _joinedController.dispose();
    super.dispose();
  }

  void _close() {
    widget.onClose?.call();
    Navigate.popView(context);
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    final state = _controller.state;
    if (state.isPristine) {
      NavbarNotifier.showSnackBar(context, 'Nothing to update, closing...');
      Future.delayed(const Duration(seconds: 1), _close);
      return;
    }
    if (!state.canSave) return; // empty / invalid / taken / still checking

    final user = ref.read(userNotifierProvider);
    final updated = await _controller.save(user, _usernameController.text);
    if (!mounted) return;
    if (updated != null) {
      await authController.setUser(updated);
      if (!mounted) return;
      NavbarNotifier.showSnackBar(context, 'Profile updated');
    } else {
      NavbarNotifier.showSnackBar(context, 'Could not update profile');
    }
    Future.delayed(const Duration(seconds: 1), _close);
  }

  Future<void> _onDelete() async {
    FocusScope.of(context).unfocus();
    await showDialog(
      context: context,
      builder: (dialogContext) => VocabAlert(
        title: 'Are you sure you want to delete your account?',
        subtitle: 'Note: This action cannot be undone',
        actionTitle1: 'Confirm Account Deletion',
        actionTitle2: 'Cancel',
        onAction1: () async {
          Navigator.of(dialogContext).pop();
          final user = ref.read(userNotifierProvider);
          showCircularIndicator(context);
          final ok = await _controller.deleteAccount(user);
          if (!mounted) return;
          stopCircularIndicator(context);
          if (ok) {
            showToast('You will be logged out!');
            await Future.delayed(const Duration(seconds: 1));
            if (!mounted) return;
            Navigate.pushAndPopAll(context, AppSignIn());
          } else {
            NavbarNotifier.showSnackBar(context, 'Could not delete account');
          }
        },
        onAction2: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  String? _usernameMessage(UsernameStatus status) => switch (status) {
        UsernameStatus.empty => 'Username cannot be empty',
        UsernameStatus.invalid => userNameConstraints,
        UsernameStatus.taken => 'Username is not available',
        UsernameStatus.available => 'Username is available',
        UsernameStatus.checking || UsernameStatus.idle => null,
      };

  bool _isErrorStatus(UsernameStatus status) =>
      status == UsernameStatus.empty ||
      status == UsernameStatus.invalid ||
      status == UsernameStatus.taken;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final apptheme = ref.watch(appThemeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: Colors.transparent),
      body: GestureDetector(
        onTap: () => removeFocus(context),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final state = _controller.state;
            final message = _usernameMessage(state.usernameStatus);
            return ListView(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: 16.0.topHorizontalPadding,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                      child: CircularAvatar(
                        url: '${user.avatarUrl}',
                        name: user.name.initals(),
                        radius: 40,
                      ),
                    ),
                  ),
                ),
                24.0.vSpacer(),
                VHTextfield(hint: 'Name', controller: _nameController, isReadOnly: true),
                VHTextfield(
                  hint: 'Username',
                  controller: _usernameController,
                  isReadOnly: state.isSaving,
                  onChanged: _controller.onUsernameChanged,
                ),
                if (message != null)
                  Padding(
                    padding: 16.0.bottomLeftPadding,
                    child: Text(
                      message,
                      style: TextStyle(
                        color:
                            _isErrorStatus(state.usernameStatus) ? Colors.red : colorScheme.primary,
                      ),
                    ),
                  ),
                if (state.usernameStatus == UsernameStatus.checking)
                  Padding(
                    padding: 16.0.leftPadding,
                    child: LoadingWidget(radius: 24, width: 1.5),
                  ),
                VHTextfield(hint: 'Email', controller: _emailController, isReadOnly: true),
                VHTextfield(hint: 'Joined', controller: _joinedController, isReadOnly: true),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: 16.0.allPadding,
                    child: VHButton(
                      height: 48,
                      width: 200,
                      isLoading: state.isSaving,
                      onTap: _onSave,
                      label: 'Save',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: 80.0.bottomPadding,
                    child: VHButton(
                      height: 48,
                      width: 200,
                      label: 'Delete Account',
                      backgroundColor: Colors.transparent,
                      foregroundColor: apptheme.isDark ? Colors.white : Colors.black,
                      onTap: _onDelete,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class VHTextfield extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final bool hasLabel;
  final int maxLines;
  final bool autoFocus;
  final Function(String)? onChanged;

  const VHTextfield(
      {super.key,
      required this.hint,
      this.controller,
      this.isReadOnly = false,
      this.hasLabel = true,
      this.onChanged,
      this.autoFocus = false,
      this.maxLines = 1,
      this.keyboardType = TextInputType.text});

  @override
  State<VHTextfield> createState() => _VHTextfieldState();
}

class _VHTextfieldState extends State<VHTextfield> {
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  late TextEditingController _controller;

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        !widget.hasLabel
            ? SizedBox.shrink()
            : Padding(
                padding: 16.0.horizontalPadding,
                child: Text(
                  widget.hint,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
        Card(
          color: Theme.of(context).colorScheme.surface,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              readOnly: widget.isReadOnly,
              maxLines: widget.maxLines,
              autofocus: widget.autoFocus,
              onChanged: (x) {
                if (widget.onChanged != null) {
                  widget.onChanged!(x);
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Colors.transparent,
                hintText: widget.hint,
              ),
            ),
          ),
        ),
        if (widget.hasLabel) 6.0.vSpacer()
      ],
    );
  }
}
