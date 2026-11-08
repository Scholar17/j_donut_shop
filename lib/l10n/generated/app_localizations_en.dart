// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'J\'Donuts';

  @override
  String get onboardingTitle => 'Round food for\nevery mood';

  @override
  String get letsGetStarted => 'Let\'s get started';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log in';

  @override
  String get legalPrefix =>
      'By continuing, you acknowledge that you have read and agree to our ';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String comingSoon(String feature) {
    return '$feature is coming soon';
  }

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get facebook => 'Facebook';

  @override
  String get continueLabel => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get phoneTitle => 'Enter your phone\nnumber';

  @override
  String get phoneHint => '09 xxx xxx xxx';

  @override
  String get phoneInvalid => 'Enter a valid Myanmar mobile number';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneNotRegistered => 'This number isn\'t registered yet.';

  @override
  String get registerInstead => 'Register instead';

  @override
  String get phoneAlreadyRegistered => 'This number is already registered.';

  @override
  String get logInInstead => 'Log in instead';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String otpSentTo(String phone) {
    return 'We\'ve sent 6 digit OTP to $phone';
  }

  @override
  String otpTestHint(String code) {
    return 'For testing, use code $code';
  }

  @override
  String get otpDidNotReceive => 'Didn\'t receive the code?';

  @override
  String otpResendIn(String time) {
    return 'resend in $time min';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String otpWrong(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining attempts left',
      one: '1 attempt left',
    );
    return 'Wrong code. $_temp0';
  }

  @override
  String get otpLocked => 'Too many wrong codes. Tap Resend to get a new code.';

  @override
  String get otpIncomplete => 'Enter all 6 digits';

  @override
  String get nameTitle => 'What\'s your\nname?';

  @override
  String get firstNameHint => 'First Name';

  @override
  String get lastNameHint => 'Last Name';

  @override
  String get nameRequired => 'First name is required';

  @override
  String nameTooLong(int max) {
    return 'Use $max characters or fewer';
  }

  @override
  String get nameInvalidCharacters => 'Use letters and spaces only';

  @override
  String get dobTitle => 'What\'s your\ndate of birth?';

  @override
  String get monthHint => 'Month';

  @override
  String get dayHint => 'Day';

  @override
  String get yearHint => 'Year';

  @override
  String get dobInvalidDate => 'This date doesn\'t exist';

  @override
  String get dobInFuture => 'Date of birth can\'t be in the future';

  @override
  String dobTooYoung(int age) {
    return 'You must be at least $age years old';
  }

  @override
  String get dobIncomplete => 'Enter month, day and year';

  @override
  String get welcomeTitle => 'Welcome to the\nworld of J\'donuts';

  @override
  String get letsExplore => 'Let\'s explore';

  @override
  String memberTier(String tier) {
    return '$tier member';
  }

  @override
  String pointsToNextTier(String points, String tier) {
    return '$points points left to become $tier Member';
  }

  @override
  String get topTierReached => 'You\'re at our top tier!';

  @override
  String get seasonalSpecials => 'Seasonal specials';

  @override
  String get popular => 'Popular';

  @override
  String get orderAgain => 'Order again';

  @override
  String nearbyShops(int count) {
    return 'There are $count J\'Donut shops near you.';
  }

  @override
  String get exploreNow => 'Explore now';

  @override
  String get orderOnline => 'Order Online';

  @override
  String percentOff(int percent) {
    return '$percent% off';
  }

  @override
  String get sectionEmpty => 'Nothing here yet';

  @override
  String get sectionError => 'Couldn\'t load this section';

  @override
  String get retry => 'Retry';

  @override
  String get offlineBanner => 'You\'re offline · showing saved data';

  @override
  String get backOnline => 'Back online';

  @override
  String get newBadge => 'New';

  @override
  String get whatsThis => 'What\'s this?';

  @override
  String get addToCart => 'Add to cart';

  @override
  String priceMmk(String price) {
    return '$price MMK';
  }

  @override
  String addedToCart(int quantity, String name) {
    return '$quantity × $name added to cart';
  }

  @override
  String get productNotFound => 'This product isn\'t available';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get rewardsTitle => 'J\' Donuts Rewards';

  @override
  String get rewards => 'Rewards';

  @override
  String get youAreHereNow => 'You\'re here now';

  @override
  String ptsRemainingToBecome(String points, String tier) {
    return '$points pts Remaining\nto become $tier';
  }

  @override
  String get youllBeHereSoon => 'You\'ll be here soon';

  @override
  String get tierReached => 'Unlocked';

  @override
  String get totalPoints => 'Total points';

  @override
  String get eatMoreEarnMore => 'Eat more earn more';

  @override
  String get gift => 'Gift';

  @override
  String get earn => 'Earn';

  @override
  String pointsShort(String points) {
    return '$points pts';
  }

  @override
  String get noChallenges => 'No challenges right now';

  @override
  String get noGifts => 'No gifts yet. Keep earning!';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get navHome => 'Home';

  @override
  String get navReward => 'Reward';

  @override
  String get navScan => 'Scan';

  @override
  String get navWallet => 'Wallet';

  @override
  String get navSettings => 'Settings';

  @override
  String placeholderScreen(String feature) {
    return '$feature is on the way';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMyanmar => 'မြန်မာ';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutConfirm => 'Log out of J\'Donuts?';

  @override
  String get cancel => 'Cancel';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No connection. Check your network.';

  @override
  String notificationsLabel(int count) {
    return '$count notifications';
  }
}
