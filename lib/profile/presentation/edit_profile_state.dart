/// UI status of the username field as the user types.
enum UsernameStatus { idle, empty, checking, available, taken, invalid }

/// Immutable UI state for the edit-profile form. The controller rewrites it.
class EditProfileState {
  final UsernameStatus usernameStatus;
  final bool isSaving;
  final bool isDeleting;

  const EditProfileState({
    this.usernameStatus = UsernameStatus.idle,
    this.isSaving = false,
    this.isDeleting = false,
  });

  /// Only a validated, available username is worth saving.
  bool get canSave => usernameStatus == UsernameStatus.available;

  /// No edit yet (unchanged from the original) — closing is a no-op.
  bool get isPristine => usernameStatus == UsernameStatus.idle;

  bool get isBusy => isSaving || isDeleting;

  EditProfileState copyWith({
    UsernameStatus? usernameStatus,
    bool? isSaving,
    bool? isDeleting,
  }) {
    return EditProfileState(
      usernameStatus: usernameStatus ?? this.usernameStatus,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}
