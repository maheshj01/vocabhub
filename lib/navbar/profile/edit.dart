import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/services.dart';
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
      desktopBuilder: (context) => EditProfileMobile(),
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

  ValueNotifier<Response> _validNotifier =
      ValueNotifier<Response>(Response(state: RequestState.none));
  ValueNotifier<Response> _responseNotifier =
      ValueNotifier<Response>(Response(state: RequestState.none));
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

  Future<void> showDeleteConfirmation(Function onDelete) async {
    // drafts found in local storage
    await showDialog(
        context: context,
        builder: (x) => VocabAlert(
            title: 'Are you sure you want to delete your account?',
            subtitle: 'Note: This action cannot be undone',
            actionTitle1: 'Confirm Account Deletion',
            actionTitle2: 'Cancel',
            onAction1: () {
              onDelete();
            },
            onAction2: () async {
              Navigator.of(context).pop();
            }));
  }

  Future<void> validateUsername(String username) async {
    _validNotifier.value = Response(state: RequestState.active, didSucced: true);
    RegExp usernamePattern = new RegExp(r"^[a-zA-Z0-9_]{3,}$");
    if (username.length < 3 || !usernamePattern.hasMatch(username)) {
      _validNotifier.value =
          Response(data: userNameConstraints, state: RequestState.error, didSucced: false);
      return;
    } else {
      final bool isUsernameValid = await UserService.isUsernameValid(username);
      if (isUsernameValid) {
        _validNotifier.value =
            Response(state: RequestState.done, data: 'Username is available', didSucced: true);
      } else {
        _validNotifier.value =
            Response(state: RequestState.error, data: 'Username is not available', didSucced: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = ref.watch(userNotifierProvider);
    final apptheme = ref.read(appThemeProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () {
          removeFocus(context);
        },
        child: ValueListenableBuilder<Response>(
            valueListenable: _responseNotifier,
            builder: (BuildContext context, Response request, Widget? child) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: 16.0.topHorizontalPadding,
                            child: CircleAvatar(
                                radius: 46,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                child: CircularAvatar(
                                  url: '${user.avatarUrl}',
                                  name: user.name.initals(),
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
                        ValueListenableBuilder<Response>(
                            valueListenable: _validNotifier,
                            builder: (BuildContext context, Response response, Widget? child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  VHTextfield(
                                    hint: 'Username',
                                    isReadOnly: request.state == RequestState.active,
                                    controller: _usernameController,
                                    onChanged: (username) {
                                      if (username.isEmpty) {
                                        _validNotifier.value = Response(
                                            state: RequestState.error,
                                            data: 'Username cannot be empty',
                                            didSucced: true);
                                      } else {
                                        if (user.username == username) {
                                          _validNotifier.value =
                                              Response(state: RequestState.none, didSucced: true);
                                          return;
                                        }
// wait few seconds before validating username
                                        Future.delayed(Duration(milliseconds: 300), () {
                                          validateUsername(username);
                                        });
                                      }
                                    },
                                  ),
                                  response.state == RequestState.none ||
                                          response.state == RequestState.active
                                      ? SizedBox.shrink()
                                      : Padding(
                                          padding: 16.0.bottomLeftPadding,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(response.data as String,
                                                    style: TextStyle(
                                                        color: response.state != RequestState.error
                                                            ? colorScheme.primary
                                                            : Colors.red)),
                                              ),
                                            ],
                                          ),
                                        ),
                                  response.state == RequestState.active
                                      ? LoadingWidget(radius: 24, width: 1.5)
                                      : SizedBox.shrink()
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
                                  if (_validNotifier.value.state == RequestState.none) {
                                    NavbarNotifier.showSnackBar(
                                        context, 'Nothing to update, closing...');
                                    Future.delayed(Duration(seconds: 2), () {
                                      widget.onClose!();
                                      Navigate.popView(context);
                                    });
                                    return;
                                  }
                                  if (_validNotifier.value.state == RequestState.error) return;
                                  _responseNotifier.value =
                                      Response(didSucced: false, state: RequestState.active);
                                  final userName = _usernameController.text.trim();
                                  final editedUser = user.copyWith(username: userName);
                                  final success = await UserService.updateUser(editedUser);
                                  if (success) {
                                    _responseNotifier.value =
                                        Response(state: RequestState.done, didSucced: true);
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
                                // isLoading: request.state == RequestState.active,
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  showDeleteConfirmation(() async {
                                    showCircularIndicator(context);
                                    await UserService.deleteUser(user);
                                    showToast('You will be logged out!');
                                    await Future.delayed(Duration(seconds: 2));
                                    stopCircularIndicator(context);
                                    Navigate.pushAndPopAll(context, AppSignIn());
                                  });
                                  // show a dialog to confirm
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
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
          color: widget.isReadOnly
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.surface,
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
