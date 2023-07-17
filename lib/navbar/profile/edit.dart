import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/responsive.dart';

class EditProfile extends StatefulWidget {
  final UserModel? user;
  final VoidCallback? onClose;

  static const String route = '/';
  EditProfile({Key? key, required this.user, this.onClose}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      desktopBuilder: (context) => EditProfileDesktop(),
      mobileBuilder: (context) => EditProfileMobile(
        onClose: widget.onClose,
      ),
    );
  }
}

class EditProfileMobile extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const EditProfileMobile({Key? key, this.onClose}) : super(key: key);

  @override
  _EditProfileMobileState createState() => _EditProfileMobileState();
}

class _EditProfileMobileState extends ConsumerState<EditProfileMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final user = ref.watch(userNotifierProvider);
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _joinedController.text = user.created_at!.formatDate();
    });
  }

  ValueNotifier<bool?> _validNotifier = ValueNotifier<bool?>(null);
  ValueNotifier<Response> _responseNotifier =
      ValueNotifier<Response>(Response(state: RequestState.none));
  String error = '';
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _joinedController = TextEditingController();

  @override
  void dispose() {
    _validNotifier.dispose();
    _responseNotifier.dispose();
    super.dispose();
  }

  Future<void> validateUsername(String username) async {
    _validNotifier.value = null;
    RegExp usernamePattern = new RegExp(r"^[a-zA-Z0-9_]{5,}$");
    if (username.isEmpty || !usernamePattern.hasMatch(username)) {
      error = 'Username should contain letters, numbers and underscores with minimum 5 characters';
      _validNotifier.value = false;
      return;
    } else {
      final bool isUsernameValid = await UserService.isUsernameValid(username);
      if (isUsernameValid) {
        error = 'Username is available';
      } else {
        error = 'Username is not available';
      }
      _validNotifier.value = isUsernameValid;
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = ref.watch(userNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: ValueListenableBuilder<Response>(
          valueListenable: _responseNotifier,
          builder: (BuildContext context, Response request, Widget? child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: 16.0.topHorizontalPadding,
                      child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          child: CircularAvatar(
                            url: '${user!.avatarUrl}',
                            radius: 40,
                          )),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.center,
                  //   child: TextButton(
                  //     child: Text('Edit Avatar'),
                  //     onPressed: () {},
                  //   ),
                  // ),
                  24.0.vSpacer(),
                  VHTextfield(
                    hint: 'Name',
                    controller: _nameController,
                    isReadOnly: true,
                  ),
                  ValueListenableBuilder<bool?>(
                      valueListenable: _validNotifier,
                      builder: (BuildContext context, bool? isValid, Widget? child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            VHTextfield(
                              hint: 'Username',
                              isReadOnly: request.state == RequestState.active,
                              controller: _usernameController,
                              onChanged: (username) {
                                user = ref.watch(userNotifierProvider);
                                if (user.username == username) {
                                  _validNotifier.value = null;
                                  return;
                                }
                                validateUsername(username);
                              },
                            ),
                            isValid == null
                                ? SizedBox.shrink()
                                : Padding(
                                    padding: 16.0.bottomLeftPadding,
                                    child: Text(error,
                                        style: TextStyle(
                                            color:
                                                isValid ? colorScheme.primary : colorScheme.error)),
                                  ),
                          ],
                        );
                      }),
                  VHTextfield(
                    hint: 'Email',
                    controller: _emailController,
                    isReadOnly: true,
                  ),
                  VHTextfield(
                    hint: 'Joined',
                    controller: _joinedController,
                    isReadOnly: true,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: 16.0.allPadding,
                      child: VHButton(
                          height: 48,
                          width: 200,
                          isLoading: request.state == RequestState.active,
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            if (_validNotifier.value == null || !_validNotifier.value!) return;
                            _responseNotifier.value =
                                Response(didSucced: false, state: RequestState.active);
                            final userName = _usernameController.text.trim();
                            final editedUser = user!.copyWith(username: userName);
                            final success = await UserService.updateUser(editedUser);
                            if (success) {
                              _responseNotifier.value =
                                  Response(state: RequestState.done, didSucced: true);
                              _validNotifier.value = null;
                              user.setUser(editedUser);
                              NavbarNotifier.showSnackBar(context, 'success updating user! ');
                            } else {
                              _responseNotifier.value =
                                  Response(state: RequestState.done, didSucced: false);
                              NavbarNotifier.showSnackBar(context, 'error updating user! ');
                            }
                            Future.delayed(Duration(seconds: 2), () {
                              widget.onClose!();
                              Navigate.popView(context);
                            });
                          },
                          label: 'Save'),
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}

class EditProfileDesktop extends StatefulWidget {
  const EditProfileDesktop({Key? key}) : super(key: key);

  @override
  State<EditProfileDesktop> createState() => _EditProfileDesktopState();
}

class _EditProfileDesktopState extends State<EditProfileDesktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Edit Profile Desktop'),
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
  final Function(String)? onChanged;

  const VHTextfield(
      {super.key,
      required this.hint,
      this.controller,
      this.isReadOnly = false,
      this.hasLabel = true,
      this.onChanged,
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
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              readOnly: widget.isReadOnly,
              maxLines: widget.maxLines,
              onChanged: (x) {
                if (widget.onChanged != null) {
                  widget.onChanged!(x);
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
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
