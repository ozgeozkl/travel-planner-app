// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get emptyFieldsError => 'Please enter your email and password.';

  @override
  String get emailVerifyError => 'Please verify your account by clicking the link sent to your email.';

  @override
  String get loginSuccess => 'Login successful! Redirecting to the map...';

  @override
  String get loginSubtitle => 'Log in to start planning your travels';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailRequiredForReset => 'Please enter your email address above first.';

  @override
  String get passwordResetSent => 'Password reset link has been sent to your email.';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get loginButton => 'Login';

  @override
  String get noAccountRegister => 'Don\'t have an account? Register now.';

  @override
  String get registerEmptyFieldsError => 'Please fill in the email and password fields.';

  @override
  String get registerSuccessMsg => 'Registration successful! Please click the verification link sent to your email address.';

  @override
  String get registerAppBarTitle => 'Create New Account';

  @override
  String get registerTitle => 'Join Us';

  @override
  String get registerSubtitle => 'Create a free account to start building your travel map';

  @override
  String get registerEmailLabel => 'Email Address';

  @override
  String get registerPasswordLabel => 'Password (At least 6 characters)';

  @override
  String get registerButton => 'Register and Send Verification Code';

  @override
  String get locationServicesDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionDenied => 'Location permission denied.';

  @override
  String get locationPermissionDeniedForever => 'Location permissions are permanently denied.';

  @override
  String get locationFetchFailed => 'Could not get location.';

  @override
  String get mapAddPlaceTitle => 'Add New Place';

  @override
  String get mapEditPlaceTitle => 'Edit Place';

  @override
  String get placeNameHint => 'Place Name (Required)';

  @override
  String get placeNameLabel => 'Place Name';

  @override
  String get placeNoteHint => 'Your notes about here...';

  @override
  String get placeNoteLabel => 'Note (Optional)';

  @override
  String get addPhotoLabel => 'Add Photo';

  @override
  String get selectPinColorLabel => 'Select Pin Color:';

  @override
  String get processingDataWait => 'Processing data...\nPlease wait.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get savedSuccessfully => 'Saved successfully!';

  @override
  String get errorOccurred => 'An error occurred.';

  @override
  String get updatedSuccessfully => 'Updated successfully!';

  @override
  String get noNoteAdded => 'No note added.';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String deletePlaceWithPhoto(String title) {
    return '$title and its photo will be permanently deleted.';
  }

  @override
  String deletePlaceOnly(String title) {
    return '$title will be deleted.';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get noSavedPlacesYet => 'No places saved yet.';

  @override
  String get mySavedPlaces => 'My Saved Places';

  @override
  String get addressLoadingOrNotFound => 'Loading address or not found...';

  @override
  String get placeNotFoundLongPress => 'Place not found. LONG PRESS on the map to add it yourself!';

  @override
  String get myTravelMapTitle => 'My Travel Map';

  @override
  String get myProfileTooltip => 'My Profile';

  @override
  String get savedPlacesTooltip => 'Saved Places';

  @override
  String get searchCityOrPlaceHint => 'Search city or place...';

  @override
  String get plannerCreateTripTitle => 'Plan a New Trip';

  @override
  String get plannerTripTitleLabel => 'Trip Title (e.g. Rome Holiday)';

  @override
  String get plannerSelectDateRange => 'Select Date Range';

  @override
  String get plannerFillAllFieldsError => 'Please fill in all fields.';

  @override
  String get plannerCreateButton => 'Create';

  @override
  String get plannerTripArchived => 'Trip moved to archive.';

  @override
  String get plannerTripUnarchived => 'Trip moved to active plans.';

  @override
  String get plannerDeleteTripTitle => 'Delete Trip';

  @override
  String plannerDeleteTripConfirm(String title) {
    return 'Are you sure you want to delete the trip \"$title\"?';
  }

  @override
  String get plannerAppBarTitle => 'My Travel Plans';

  @override
  String get plannerTabActive => 'Planned';

  @override
  String get plannerTabPast => 'Past / Archive';

  @override
  String get plannerNoPastTrips => 'No past trips found.';

  @override
  String get plannerNoActiveTrips => 'You have no planned trips yet.';

  @override
  String get plannerMoveToActive => 'Move to Active';

  @override
  String get plannerMoveToArchive => 'Move to Archive';

  @override
  String plannerPlaceCount(int count) {
    return '$count Places';
  }

  @override
  String get plannerCompleted => 'Completed';

  @override
  String get plannerNewTripFab => 'New Trip';

  @override
  String get tripThemeSelectTitle => 'Select Trip Theme';

  @override
  String get tripSmartDistributionSuccess => '🔒 Smart distribution completed while keeping pinned places!';

  @override
  String get tripNotesSavedSuccess => 'Notes saved successfully!';

  @override
  String tripSelectPlaceForDay(int dayIndex) {
    return 'Select Place for Day $dayIndex';
  }

  @override
  String get tripAllPlacesAssignedOrEmpty => 'All places are assigned or the pool is empty.';

  @override
  String get tripThemeSelectTooltip => 'Select Theme Color';

  @override
  String get tripTabPinPool => 'Pin Pool';

  @override
  String get tripTabDailyPlan => 'Daily Plan';

  @override
  String get tripTabNotes => 'Notes';

  @override
  String get tripNoPlacesOnMapYet => 'No places saved on the map yet.';

  @override
  String get tripSmartDistributeTitle => 'Smart Distribute';

  @override
  String get tripSmartDistributeSubtitle => 'Keep pinned, distribute the rest by proximity';

  @override
  String get tripSmartDistributeStartButton => 'Start';

  @override
  String tripDayNumber(int dayNum) {
    return 'Day $dayNum';
  }

  @override
  String get tripNoPlanForThisDay => 'No plan for this day.';

  @override
  String get tripUnlockTooltip => 'Unlock';

  @override
  String get tripLockToThisDayTooltip => 'Pin to This Day';

  @override
  String tripMoveToDay(int dayNum) {
    return 'Move to Day $dayNum';
  }

  @override
  String tripAddPlaceToDay(int dayNum) {
    return 'Add Place to Day $dayNum';
  }

  @override
  String get tripSeeRouteOnMap => 'See Route on Map';

  @override
  String get tripNotesHint => 'Jot down everything that comes to mind here...';

  @override
  String get tripSaveNotesButton => 'Save Notes';

  @override
  String tripBulkMoveDayTitle(int dayIndex) {
    return 'Bulk Move Day $dayIndex';
  }

  @override
  String get tripBulkMoveDayContent => 'Which day do you want to move all places from this day to?';

  @override
  String get tripBulkMoveTargetDayLabel => 'Target Day';

  @override
  String get tripBulkMoveMoveAllButton => 'Move All';

  @override
  String get galleryAppBarTitle => 'My Memory Album';

  @override
  String get galleryNoPhotosYet => 'You haven\'t added any memories with photos yet.';

  @override
  String get profileAppBarTitle => 'My Profile';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String get profilePhotoUploadFailed => 'Could not upload photo.';

  @override
  String get profileStatSavedPlaces => 'Saved Places';

  @override
  String get profileStatPhotos => 'Photos';

  @override
  String get profileMenuTripPlanner => 'Trip Planner';

  @override
  String get profileMenuPastTrips => 'Past Trips';

  @override
  String get profileMenuLogout => 'Log Out';

  @override
  String get savedListAppBarTitle => 'Saved Places';

  @override
  String get savedListEmptyText => 'No saved places yet.';

  @override
  String get savedListNoAddress => 'Address not found';

  @override
  String get settingsSecurityAuthTitle => 'Security Verification';

  @override
  String get settingsSecurityAuthSubtitle => 'You must enter your current password for this critical action.';

  @override
  String get settingsEmailLabel => 'Email';

  @override
  String get settingsCurrentPasswordLabel => 'Current Password';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsVerify => 'Verify';

  @override
  String get settingsWrongPassword => 'You entered an incorrect password.';

  @override
  String get settingsChangePasswordTitle => 'Change Password';

  @override
  String get settingsNewPasswordLabel => 'New Password';

  @override
  String get settingsPasswordLengthError => 'Password must be at least 6 characters.';

  @override
  String get settingsPasswordUpdateSuccess => 'Your password has been successfully updated.';

  @override
  String get settingsPasswordUpdateError => 'Failed to update password.';

  @override
  String get settingsUpdate => 'Update';

  @override
  String get settingsChangeEmailTitle => 'Change Email';

  @override
  String get settingsNewEmailLabel => 'New Email Address';

  @override
  String get settingsInvalidEmailError => 'Please enter a valid email address.';

  @override
  String get settingsVerificationSentTitle => 'Verification Sent 📩';

  @override
  String get settingsVerificationSentBody => 'We have sent a verification link to your new email address.\n\nPlease check your inbox and click the link. Your current email will remain visible until you confirm.';

  @override
  String get settingsGotIt => 'Got it';

  @override
  String get settingsEmailUpdateError => 'Failed to update email. It might be used by another account.';

  @override
  String get settingsDeleteAccountTitle => 'Delete Account Permanently';

  @override
  String get settingsDeleteAccountWarning => 'When you delete your account, all your saved places and memories will be permanently deleted. This action cannot be undone.';

  @override
  String get settingsDeleteAccountConfirm => 'Delete My Account';

  @override
  String get settingsDeleteAccountError => 'Failed to delete account.';

  @override
  String get settingsAppBarTitle => 'Settings';

  @override
  String get settingsAppLanguage => 'App Language';

  @override
  String get authErrorSignUp => 'An error occurred during registration.';

  @override
  String get authErrorWeakPassword => 'Your password is too weak. Please choose a stronger password with at least 6 characters.';

  @override
  String get authErrorEmailInUse => 'An account already exists with this email address.';

  @override
  String get authErrorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authErrorUnexpected => 'An unexpected error occurred.';

  @override
  String get authErrorSignIn => 'Sign in failed.';

  @override
  String get authErrorInvalidCredential => 'Your email or password is incorrect. Please check again.';

  @override
  String get authErrorInvalidEmailFormat => 'Please enter a valid email address format.';

  @override
  String get authErrorUserDisabled => 'This user account has been disabled by the system.';

  @override
  String get authErrorVerificationEmail => 'Failed to send verification email.';

  @override
  String get authErrorPasswordReset => 'Failed to send password reset link.';

  @override
  String get authErrorInvalidEmailReset => 'You entered an invalid email address.';

  @override
  String get authErrorSignOut => 'An error occurred while signing out.';

  @override
  String get dbErrorAddPin => 'Failed to save the location.';

  @override
  String get dbErrorPinIdNotFound => 'The ID of the pin to update could not be found.';

  @override
  String get dbErrorUpdatePin => 'Failed to update the location.';

  @override
  String get dbErrorDeletePin => 'Failed to delete the location.';

  @override
  String get placesFallbackType => 'Place';

  @override
  String get appTitle => 'Travel Planner';

  @override
  String get securityApprovalTitle => 'Security Verification';

  @override
  String emailNotVerifiedMessage(String email) {
    return 'You have registered but have not yet verified the $email address.';
  }

  @override
  String get checkInboxMessage => 'Please check your inbox (or spam folder) and click the verification link. You can log in again after verifying.';

  @override
  String get returnToLoginButton => 'Return to Login';
}
