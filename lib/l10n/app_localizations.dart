import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @emptyFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get emptyFieldsError;

  /// No description provided for @emailVerifyError.
  ///
  /// In en, this message translates to:
  /// **'Please verify your account by clicking the link sent to your email.'**
  String get emailVerifyError;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful! Redirecting to the map...'**
  String get loginSuccess;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to start planning your travels'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailRequiredForReset.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address above first.'**
  String get emailRequiredForReset;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link has been sent to your email.'**
  String get passwordResetSent;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register now.'**
  String get noAccountRegister;

  /// No description provided for @registerEmptyFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the email and password fields.'**
  String get registerEmptyFieldsError;

  /// No description provided for @registerSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please click the verification link sent to your email address.'**
  String get registerSuccessMsg;

  /// No description provided for @registerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get registerAppBarTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a free account to start building your travel map'**
  String get registerSubtitle;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password (At least 6 characters)'**
  String get registerPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register and Send Verification Code'**
  String get registerButton;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get locationPermissionDeniedForever;

  /// No description provided for @locationFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get location.'**
  String get locationFetchFailed;

  /// No description provided for @mapAddPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Place'**
  String get mapAddPlaceTitle;

  /// No description provided for @mapEditPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Place'**
  String get mapEditPlaceTitle;

  /// No description provided for @placeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Place Name (Required)'**
  String get placeNameHint;

  /// No description provided for @placeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Place Name'**
  String get placeNameLabel;

  /// No description provided for @placeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Your notes about here...'**
  String get placeNoteHint;

  /// No description provided for @placeNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get placeNoteLabel;

  /// No description provided for @addPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhotoLabel;

  /// No description provided for @selectPinColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Pin Color:'**
  String get selectPinColorLabel;

  /// No description provided for @processingDataWait.
  ///
  /// In en, this message translates to:
  /// **'Processing data...\nPlease wait.'**
  String get processingDataWait;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully!'**
  String get savedSuccessfully;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorOccurred;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully!'**
  String get updatedSuccessfully;

  /// No description provided for @noNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'No note added.'**
  String get noNoteAdded;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @deletePlaceWithPhoto.
  ///
  /// In en, this message translates to:
  /// **'{title} and its photo will be permanently deleted.'**
  String deletePlaceWithPhoto(String title);

  /// No description provided for @deletePlaceOnly.
  ///
  /// In en, this message translates to:
  /// **'{title} will be deleted.'**
  String deletePlaceOnly(String title);

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @noSavedPlacesYet.
  ///
  /// In en, this message translates to:
  /// **'No places saved yet.'**
  String get noSavedPlacesYet;

  /// No description provided for @mySavedPlaces.
  ///
  /// In en, this message translates to:
  /// **'My Saved Places'**
  String get mySavedPlaces;

  /// No description provided for @addressLoadingOrNotFound.
  ///
  /// In en, this message translates to:
  /// **'Loading address or not found...'**
  String get addressLoadingOrNotFound;

  /// No description provided for @placeNotFoundLongPress.
  ///
  /// In en, this message translates to:
  /// **'Place not found. LONG PRESS on the map to add it yourself!'**
  String get placeNotFoundLongPress;

  /// No description provided for @myTravelMapTitle.
  ///
  /// In en, this message translates to:
  /// **'My Travel Map'**
  String get myTravelMapTitle;

  /// No description provided for @myProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfileTooltip;

  /// No description provided for @savedPlacesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedPlacesTooltip;

  /// No description provided for @searchCityOrPlaceHint.
  ///
  /// In en, this message translates to:
  /// **'Search city or place...'**
  String get searchCityOrPlaceHint;

  /// No description provided for @plannerCreateTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a New Trip'**
  String get plannerCreateTripTitle;

  /// No description provided for @plannerTripTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip Title (e.g. Rome Holiday)'**
  String get plannerTripTitleLabel;

  /// No description provided for @plannerSelectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get plannerSelectDateRange;

  /// No description provided for @plannerFillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get plannerFillAllFieldsError;

  /// No description provided for @plannerCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get plannerCreateButton;

  /// No description provided for @plannerTripArchived.
  ///
  /// In en, this message translates to:
  /// **'Trip moved to archive.'**
  String get plannerTripArchived;

  /// No description provided for @plannerTripUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Trip moved to active plans.'**
  String get plannerTripUnarchived;

  /// No description provided for @plannerDeleteTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Trip'**
  String get plannerDeleteTripTitle;

  /// No description provided for @plannerDeleteTripConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the trip \"{title}\"?'**
  String plannerDeleteTripConfirm(String title);

  /// No description provided for @plannerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'My Travel Plans'**
  String get plannerAppBarTitle;

  /// No description provided for @plannerTabActive.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get plannerTabActive;

  /// No description provided for @plannerTabPast.
  ///
  /// In en, this message translates to:
  /// **'Past / Archive'**
  String get plannerTabPast;

  /// No description provided for @plannerNoPastTrips.
  ///
  /// In en, this message translates to:
  /// **'No past trips found.'**
  String get plannerNoPastTrips;

  /// No description provided for @plannerNoActiveTrips.
  ///
  /// In en, this message translates to:
  /// **'You have no planned trips yet.'**
  String get plannerNoActiveTrips;

  /// No description provided for @plannerMoveToActive.
  ///
  /// In en, this message translates to:
  /// **'Move to Active'**
  String get plannerMoveToActive;

  /// No description provided for @plannerMoveToArchive.
  ///
  /// In en, this message translates to:
  /// **'Move to Archive'**
  String get plannerMoveToArchive;

  /// No description provided for @plannerPlaceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Places'**
  String plannerPlaceCount(int count);

  /// No description provided for @plannerCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get plannerCompleted;

  /// No description provided for @plannerNewTripFab.
  ///
  /// In en, this message translates to:
  /// **'New Trip'**
  String get plannerNewTripFab;

  /// No description provided for @tripThemeSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Trip Theme'**
  String get tripThemeSelectTitle;

  /// No description provided for @tripSmartDistributionSuccess.
  ///
  /// In en, this message translates to:
  /// **'🔒 Smart distribution completed while keeping pinned places!'**
  String get tripSmartDistributionSuccess;

  /// No description provided for @tripNotesSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notes saved successfully!'**
  String get tripNotesSavedSuccess;

  /// No description provided for @tripSelectPlaceForDay.
  ///
  /// In en, this message translates to:
  /// **'Select Place for Day {dayIndex}'**
  String tripSelectPlaceForDay(int dayIndex);

  /// No description provided for @tripAllPlacesAssignedOrEmpty.
  ///
  /// In en, this message translates to:
  /// **'All places are assigned or the pool is empty.'**
  String get tripAllPlacesAssignedOrEmpty;

  /// No description provided for @tripThemeSelectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select Theme Color'**
  String get tripThemeSelectTooltip;

  /// No description provided for @tripTabPinPool.
  ///
  /// In en, this message translates to:
  /// **'Pin Pool'**
  String get tripTabPinPool;

  /// No description provided for @tripTabDailyPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily Plan'**
  String get tripTabDailyPlan;

  /// No description provided for @tripTabNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get tripTabNotes;

  /// No description provided for @tripNoPlacesOnMapYet.
  ///
  /// In en, this message translates to:
  /// **'No places saved on the map yet.'**
  String get tripNoPlacesOnMapYet;

  /// No description provided for @tripSmartDistributeTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Distribute'**
  String get tripSmartDistributeTitle;

  /// No description provided for @tripSmartDistributeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep pinned, distribute the rest by proximity'**
  String get tripSmartDistributeSubtitle;

  /// No description provided for @tripSmartDistributeStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get tripSmartDistributeStartButton;

  /// No description provided for @tripDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {dayNum}'**
  String tripDayNumber(int dayNum);

  /// No description provided for @tripNoPlanForThisDay.
  ///
  /// In en, this message translates to:
  /// **'No plan for this day.'**
  String get tripNoPlanForThisDay;

  /// No description provided for @tripUnlockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get tripUnlockTooltip;

  /// No description provided for @tripLockToThisDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pin to This Day'**
  String get tripLockToThisDayTooltip;

  /// No description provided for @tripMoveToDay.
  ///
  /// In en, this message translates to:
  /// **'Move to Day {dayNum}'**
  String tripMoveToDay(int dayNum);

  /// No description provided for @tripAddPlaceToDay.
  ///
  /// In en, this message translates to:
  /// **'Add Place to Day {dayNum}'**
  String tripAddPlaceToDay(int dayNum);

  /// No description provided for @tripSeeRouteOnMap.
  ///
  /// In en, this message translates to:
  /// **'See Route on Map'**
  String get tripSeeRouteOnMap;

  /// No description provided for @tripNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Jot down everything that comes to mind here...'**
  String get tripNotesHint;

  /// No description provided for @tripSaveNotesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Notes'**
  String get tripSaveNotesButton;

  /// No description provided for @tripBulkMoveDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk Move Day {dayIndex}'**
  String tripBulkMoveDayTitle(int dayIndex);

  /// No description provided for @tripBulkMoveDayContent.
  ///
  /// In en, this message translates to:
  /// **'Which day do you want to move all places from this day to?'**
  String get tripBulkMoveDayContent;

  /// No description provided for @tripBulkMoveTargetDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Day'**
  String get tripBulkMoveTargetDayLabel;

  /// No description provided for @tripBulkMoveMoveAllButton.
  ///
  /// In en, this message translates to:
  /// **'Move All'**
  String get tripBulkMoveMoveAllButton;

  /// No description provided for @galleryAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'My Memory Album'**
  String get galleryAppBarTitle;

  /// No description provided for @galleryNoPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any memories with photos yet.'**
  String get galleryNoPhotosYet;

  /// No description provided for @profileAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileAppBarTitle;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo.'**
  String get profilePhotoUploadFailed;

  /// No description provided for @profileStatSavedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get profileStatSavedPlaces;

  /// No description provided for @profileStatPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get profileStatPhotos;

  /// No description provided for @profileMenuTripPlanner.
  ///
  /// In en, this message translates to:
  /// **'Trip Planner'**
  String get profileMenuTripPlanner;

  /// No description provided for @profileMenuPastTrips.
  ///
  /// In en, this message translates to:
  /// **'Past Trips'**
  String get profileMenuPastTrips;

  /// No description provided for @profileMenuLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileMenuLogout;

  /// No description provided for @savedListAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedListAppBarTitle;

  /// No description provided for @savedListEmptyText.
  ///
  /// In en, this message translates to:
  /// **'No saved places yet.'**
  String get savedListEmptyText;

  /// No description provided for @savedListNoAddress.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get savedListNoAddress;

  /// No description provided for @settingsSecurityAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Verification'**
  String get settingsSecurityAuthTitle;

  /// No description provided for @settingsSecurityAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You must enter your current password for this critical action.'**
  String get settingsSecurityAuthSubtitle;

  /// No description provided for @settingsEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmailLabel;

  /// No description provided for @settingsCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get settingsCurrentPasswordLabel;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get settingsVerify;

  /// No description provided for @settingsWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'You entered an incorrect password.'**
  String get settingsWrongPassword;

  /// No description provided for @settingsChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePasswordTitle;

  /// No description provided for @settingsNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get settingsNewPasswordLabel;

  /// No description provided for @settingsPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get settingsPasswordLengthError;

  /// No description provided for @settingsPasswordUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully updated.'**
  String get settingsPasswordUpdateSuccess;

  /// No description provided for @settingsPasswordUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password.'**
  String get settingsPasswordUpdateError;

  /// No description provided for @settingsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get settingsUpdate;

  /// No description provided for @settingsChangeEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get settingsChangeEmailTitle;

  /// No description provided for @settingsNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New Email Address'**
  String get settingsNewEmailLabel;

  /// No description provided for @settingsInvalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get settingsInvalidEmailError;

  /// No description provided for @settingsVerificationSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Sent 📩'**
  String get settingsVerificationSentTitle;

  /// No description provided for @settingsVerificationSentBody.
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification link to your new email address.\n\nPlease check your inbox and click the link. Your current email will remain visible until you confirm.'**
  String get settingsVerificationSentBody;

  /// No description provided for @settingsGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get settingsGotIt;

  /// No description provided for @settingsEmailUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update email. It might be used by another account.'**
  String get settingsEmailUpdateError;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Permanently'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'When you delete your account, all your saved places and memories will be permanently deleted. This action cannot be undone.'**
  String get settingsDeleteAccountWarning;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account.'**
  String get settingsDeleteAccountError;

  /// No description provided for @settingsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAppBarTitle;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsAppLanguage;

  /// No description provided for @authErrorSignUp.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during registration.'**
  String get authErrorSignUp;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password is too weak. Please choose a stronger password with at least 6 characters.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email address.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get authErrorUnexpected;

  /// No description provided for @authErrorSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get authErrorSignIn;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'Your email or password is incorrect. Please check again.'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorInvalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address format.'**
  String get authErrorInvalidEmailFormat;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled by the system.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email.'**
  String get authErrorVerificationEmail;

  /// No description provided for @authErrorPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset link.'**
  String get authErrorPasswordReset;

  /// No description provided for @authErrorInvalidEmailReset.
  ///
  /// In en, this message translates to:
  /// **'You entered an invalid email address.'**
  String get authErrorInvalidEmailReset;

  /// No description provided for @authErrorSignOut.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while signing out.'**
  String get authErrorSignOut;

  /// No description provided for @dbErrorAddPin.
  ///
  /// In en, this message translates to:
  /// **'Failed to save the location.'**
  String get dbErrorAddPin;

  /// No description provided for @dbErrorPinIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'The ID of the pin to update could not be found.'**
  String get dbErrorPinIdNotFound;

  /// No description provided for @dbErrorUpdatePin.
  ///
  /// In en, this message translates to:
  /// **'Failed to update the location.'**
  String get dbErrorUpdatePin;

  /// No description provided for @dbErrorDeletePin.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the location.'**
  String get dbErrorDeletePin;

  /// No description provided for @placesFallbackType.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get placesFallbackType;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Planner'**
  String get appTitle;

  /// No description provided for @securityApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Verification'**
  String get securityApprovalTitle;

  /// No description provided for @emailNotVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have registered but have not yet verified the {email} address.'**
  String emailNotVerifiedMessage(String email);

  /// No description provided for @checkInboxMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox (or spam folder) and click the verification link. You can log in again after verifying.'**
  String get checkInboxMessage;

  /// No description provided for @returnToLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Return to Login'**
  String get returnToLoginButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
