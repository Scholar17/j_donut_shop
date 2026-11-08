import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'J\'Donuts'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Round food for\nevery mood'**
  String get onboardingTitle;

  /// No description provided for @letsGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get letsGetStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @legalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you acknowledge that you have read and agree to our '**
  String get legalPrefix;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon'**
  String comingSoon(String feature);

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @phoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone\nnumber'**
  String get phoneTitle;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'09 xxx xxx xxx'**
  String get phoneHint;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Myanmar mobile number'**
  String get phoneInvalid;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This number isn\'t registered yet.'**
  String get phoneNotRegistered;

  /// No description provided for @registerInstead.
  ///
  /// In en, this message translates to:
  /// **'Register instead'**
  String get registerInstead;

  /// No description provided for @phoneAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This number is already registered.'**
  String get phoneAlreadyRegistered;

  /// No description provided for @logInInstead.
  ///
  /// In en, this message translates to:
  /// **'Log in instead'**
  String get logInInstead;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent 6 digit OTP to {phone}'**
  String otpSentTo(String phone);

  /// No description provided for @otpTestHint.
  ///
  /// In en, this message translates to:
  /// **'For testing, use code {code}'**
  String otpTestHint(String code);

  /// No description provided for @otpDidNotReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpDidNotReceive;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'resend in {time} min'**
  String otpResendIn(String time);

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// No description provided for @otpWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong code. {remaining, plural, =1{1 attempt left} other{{remaining} attempts left}}'**
  String otpWrong(int remaining);

  /// No description provided for @otpLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes. Tap Resend to get a new code.'**
  String get otpLocked;

  /// No description provided for @otpIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits'**
  String get otpIncomplete;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your\nname?'**
  String get nameTitle;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use {max} characters or fewer'**
  String nameTooLong(int max);

  /// No description provided for @nameInvalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'Use letters and spaces only'**
  String get nameInvalidCharacters;

  /// No description provided for @dobTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your\ndate of birth?'**
  String get dobTitle;

  /// No description provided for @monthHint.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthHint;

  /// No description provided for @dayHint.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayHint;

  /// No description provided for @yearHint.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearHint;

  /// No description provided for @dobInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'This date doesn\'t exist'**
  String get dobInvalidDate;

  /// No description provided for @dobInFuture.
  ///
  /// In en, this message translates to:
  /// **'Date of birth can\'t be in the future'**
  String get dobInFuture;

  /// No description provided for @dobTooYoung.
  ///
  /// In en, this message translates to:
  /// **'You must be at least {age} years old'**
  String dobTooYoung(int age);

  /// No description provided for @dobIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter month, day and year'**
  String get dobIncomplete;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the\nworld of J\'donuts'**
  String get welcomeTitle;

  /// No description provided for @letsExplore.
  ///
  /// In en, this message translates to:
  /// **'Let\'s explore'**
  String get letsExplore;

  /// No description provided for @memberTier.
  ///
  /// In en, this message translates to:
  /// **'{tier} member'**
  String memberTier(String tier);

  /// No description provided for @pointsToNextTier.
  ///
  /// In en, this message translates to:
  /// **'{points} points left to become {tier} Member'**
  String pointsToNextTier(String points, String tier);

  /// No description provided for @topTierReached.
  ///
  /// In en, this message translates to:
  /// **'You\'re at our top tier!'**
  String get topTierReached;

  /// No description provided for @seasonalSpecials.
  ///
  /// In en, this message translates to:
  /// **'Seasonal specials'**
  String get seasonalSpecials;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @orderAgain.
  ///
  /// In en, this message translates to:
  /// **'Order again'**
  String get orderAgain;

  /// No description provided for @nearbyShops.
  ///
  /// In en, this message translates to:
  /// **'There are {count} J\'Donut shops near you.'**
  String nearbyShops(int count);

  /// No description provided for @exploreNow.
  ///
  /// In en, this message translates to:
  /// **'Explore now'**
  String get exploreNow;

  /// No description provided for @orderOnline.
  ///
  /// In en, this message translates to:
  /// **'Order Online'**
  String get orderOnline;

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String percentOff(int percent);

  /// No description provided for @sectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get sectionEmpty;

  /// No description provided for @sectionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this section'**
  String get sectionError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline · showing saved data'**
  String get offlineBanner;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get backOnline;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newBadge;

  /// No description provided for @whatsThis.
  ///
  /// In en, this message translates to:
  /// **'What\'s this?'**
  String get whatsThis;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @priceMmk.
  ///
  /// In en, this message translates to:
  /// **'{price} MMK'**
  String priceMmk(String price);

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'{quantity} × {name} added to cart'**
  String addedToCart(int quantity, String name);

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'This product isn\'t available'**
  String get productNotFound;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'J\' Donuts Rewards'**
  String get rewardsTitle;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @youAreHereNow.
  ///
  /// In en, this message translates to:
  /// **'You\'re here now'**
  String get youAreHereNow;

  /// No description provided for @ptsRemainingToBecome.
  ///
  /// In en, this message translates to:
  /// **'{points} pts Remaining\nto become {tier}'**
  String ptsRemainingToBecome(String points, String tier);

  /// No description provided for @youllBeHereSoon.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be here soon'**
  String get youllBeHereSoon;

  /// No description provided for @tierReached.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get tierReached;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get totalPoints;

  /// No description provided for @eatMoreEarnMore.
  ///
  /// In en, this message translates to:
  /// **'Eat more earn more'**
  String get eatMoreEarnMore;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @earn.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earn;

  /// No description provided for @pointsShort.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsShort(String points);

  /// No description provided for @noChallenges.
  ///
  /// In en, this message translates to:
  /// **'No challenges right now'**
  String get noChallenges;

  /// No description provided for @noGifts.
  ///
  /// In en, this message translates to:
  /// **'No gifts yet. Keep earning!'**
  String get noGifts;

  /// No description provided for @tierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get tierSilver;

  /// No description provided for @tierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get tierBronze;

  /// No description provided for @tierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get tierGold;

  /// No description provided for @tierPlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get tierPlatinum;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navReward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get navReward;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @placeholderScreen.
  ///
  /// In en, this message translates to:
  /// **'{feature} is on the way'**
  String placeholderScreen(String feature);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageMyanmar.
  ///
  /// In en, this message translates to:
  /// **'မြန်မာ'**
  String get languageMyanmar;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out of J\'Donuts?'**
  String get logOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network.'**
  String get errorNetwork;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} notifications'**
  String notificationsLabel(int count);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @phoneNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Verify the new number first'**
  String get phoneNotVerified;

  /// No description provided for @verifyNewNumber.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a code to verify your new number'**
  String get verifyNewNumber;

  /// No description provided for @photoPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the photo'**
  String get photoPickFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
