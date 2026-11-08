// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'J\'Donuts';

  @override
  String get onboardingTitle => 'စိတ်ကြိုက်တိုင်းအတွက်\nဝိုင်းဝိုင်းလေးတွေ';

  @override
  String get letsGetStarted => 'စတင်ကြစို့';

  @override
  String get alreadyHaveAccount => 'အကောင့်ရှိပြီးသားလား?';

  @override
  String get logIn => 'ဝင်ရောက်ရန်';

  @override
  String get legalPrefix => 'ဆက်လက်ခြင်းဖြင့် ကျွန်ုပ်တို့၏ ';

  @override
  String get termsOfUse => 'အသုံးပြုမှုစည်းမျဉ်းများ';

  @override
  String get and => ' နှင့် ';

  @override
  String get privacyPolicy => 'ကိုယ်ရေးအချက်အလက်မူဝါဒ';

  @override
  String comingSoon(String feature) {
    return '$feature မကြာမီ ရရှိပါမည်';
  }

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get facebook => 'Facebook';

  @override
  String get continueLabel => 'ဆက်လုပ်မည်';

  @override
  String get back => 'နောက်သို့';

  @override
  String get phoneTitle => 'သင့်ဖုန်းနံပါတ်\nထည့်ပါ';

  @override
  String get phoneHint => '09 xxx xxx xxx';

  @override
  String get phoneInvalid => 'မှန်ကန်သော မြန်မာဖုန်းနံပါတ် ထည့်ပါ';

  @override
  String get phoneRequired => 'ဖုန်းနံပါတ် လိုအပ်ပါသည်';

  @override
  String get phoneNotRegistered => 'ဤနံပါတ်ဖြင့် စာရင်းမသွင်းရသေးပါ။';

  @override
  String get registerInstead => 'စာရင်းသွင်းမည်';

  @override
  String get phoneAlreadyRegistered => 'ဤနံပါတ်ဖြင့် စာရင်းသွင်းပြီးဖြစ်သည်။';

  @override
  String get logInInstead => 'ဝင်ရောက်မည်';

  @override
  String get otpTitle => 'နံပါတ်ကို အတည်ပြုပါ';

  @override
  String otpSentTo(String phone) {
    return '$phone သို့ ဂဏန်း ၆ လုံးပါ OTP ပို့ထားပါသည်';
  }

  @override
  String otpTestHint(String code) {
    return 'စမ်းသပ်ရန် ကုဒ် $code ကို သုံးပါ';
  }

  @override
  String get otpDidNotReceive => 'ကုဒ် မရရှိဘူးလား?';

  @override
  String otpResendIn(String time) {
    return '$time မိနစ်အတွင်း ပြန်ပို့မည်';
  }

  @override
  String get otpResend => 'ကုဒ် ပြန်ပို့ရန်';

  @override
  String otpWrong(int remaining) {
    return 'ကုဒ်မှားနေပါသည်။ $remaining ကြိမ် ကျန်ပါသည်';
  }

  @override
  String get otpLocked =>
      'မှားယွင်းမှု များလွန်းပါသည်။ ကုဒ်အသစ်ရယူရန် ပြန်ပို့ကို နှိပ်ပါ။';

  @override
  String get otpIncomplete => 'ဂဏန်း ၆ လုံးလုံး ထည့်ပါ';

  @override
  String get nameTitle => 'သင့်အမည်က\nဘာလဲ?';

  @override
  String get firstNameHint => 'အမည်';

  @override
  String get lastNameHint => 'မျိုးရိုးအမည်';

  @override
  String get nameRequired => 'အမည် လိုအပ်ပါသည်';

  @override
  String nameTooLong(int max) {
    return 'စာလုံး $max လုံးအောက် ထည့်ပါ';
  }

  @override
  String get nameInvalidCharacters => 'စာလုံးနှင့် space သာ ထည့်ပါ';

  @override
  String get dobTitle => 'သင့်မွေးနေ့က\nဘယ်နေ့လဲ?';

  @override
  String get monthHint => 'လ';

  @override
  String get dayHint => 'ရက်';

  @override
  String get yearHint => 'ခုနှစ်';

  @override
  String get dobInvalidDate => 'ဤရက်စွဲ မရှိပါ';

  @override
  String get dobInFuture => 'မွေးနေ့သည် အနာဂတ်ရက် မဖြစ်ရပါ';

  @override
  String dobTooYoung(int age) {
    return 'အသက် $age နှစ်နှင့်အထက် ဖြစ်ရပါမည်';
  }

  @override
  String get dobIncomplete => 'လ၊ ရက်နှင့် ခုနှစ် ထည့်ပါ';

  @override
  String get welcomeTitle => 'J\'donuts ကမ္ဘာမှ\nကြိုဆိုပါသည်';

  @override
  String get letsExplore => 'စူးစမ်းကြစို့';

  @override
  String memberTier(String tier) {
    return '$tier အဖွဲ့ဝင်';
  }

  @override
  String pointsToNextTier(String points, String tier) {
    return '$tier အဖွဲ့ဝင်ဖြစ်ရန် $points မှတ် ကျန်ပါသည်';
  }

  @override
  String get topTierReached => 'အမြင့်ဆုံးအဆင့်သို့ ရောက်ပါပြီ!';

  @override
  String get seasonalSpecials => 'ရာသီအထူးများ';

  @override
  String get popular => 'လူကြိုက်များ';

  @override
  String get orderAgain => 'ထပ်မှာရန်';

  @override
  String nearbyShops(int count) {
    return 'သင့်အနီးတွင် J\'Donut ဆိုင် $count ဆိုင် ရှိပါသည်။';
  }

  @override
  String get exploreNow => 'ယခုကြည့်ရှုရန်';

  @override
  String get orderOnline => 'အွန်လိုင်းမှာရန်';

  @override
  String percentOff(int percent) {
    return '$percent% လျှော့';
  }

  @override
  String get sectionEmpty => 'ဘာမှ မရှိသေးပါ';

  @override
  String get sectionError => 'ဤကဏ္ဍကို ဖွင့်၍မရပါ';

  @override
  String get retry => 'ပြန်ကြိုးစားရန်';

  @override
  String get offlineBanner => 'အော့ဖ်လိုင်း · သိမ်းထားသောဒေတာ ပြသနေသည်';

  @override
  String get backOnline => 'ပြန်လည်ချိတ်ဆက်ပြီး';

  @override
  String get newBadge => 'အသစ်';

  @override
  String get whatsThis => 'ဒါဘာလဲ?';

  @override
  String get addToCart => 'ခြင်းထဲထည့်ရန်';

  @override
  String priceMmk(String price) {
    return '$price ကျပ်';
  }

  @override
  String addedToCart(int quantity, String name) {
    return '$name $quantity ခု ခြင်းထဲ ထည့်ပြီး';
  }

  @override
  String get productNotFound => 'ဤပစ္စည်း မရရှိနိုင်ပါ';

  @override
  String get decreaseQuantity => 'အရေအတွက် လျှော့ရန်';

  @override
  String get increaseQuantity => 'အရေအတွက် တိုးရန်';

  @override
  String get rewardsTitle => 'J\' Donuts ဆုလာဘ်များ';

  @override
  String get rewards => 'ဆုလာဘ်';

  @override
  String get youAreHereNow => 'ယခု ဤအဆင့်တွင် ရှိသည်';

  @override
  String ptsRemainingToBecome(String points, String tier) {
    return '$tier ဖြစ်ရန်\n$points မှတ် ကျန်သည်';
  }

  @override
  String get youllBeHereSoon => 'မကြာမီ ရောက်ပါမည်';

  @override
  String get tierReached => 'ရရှိပြီး';

  @override
  String get totalPoints => 'စုစုပေါင်းမှတ်';

  @override
  String get eatMoreEarnMore => 'များများစား များများရ';

  @override
  String get gift => 'လက်ဆောင်';

  @override
  String get earn => 'ရယူ';

  @override
  String pointsShort(String points) {
    return '$points မှတ်';
  }

  @override
  String get noChallenges => 'ယခု စိန်ခေါ်မှု မရှိပါ';

  @override
  String get noGifts => 'လက်ဆောင် မရှိသေးပါ။ ဆက်စုပါ!';

  @override
  String get tierSilver => 'ငွေ';

  @override
  String get tierBronze => 'ကြေး';

  @override
  String get tierGold => 'ရွှေ';

  @override
  String get tierPlatinum => 'ပလက်တီနမ်';

  @override
  String get navHome => 'ပင်မ';

  @override
  String get navReward => 'ဆုလာဘ်';

  @override
  String get navScan => 'စကင်န်';

  @override
  String get navWallet => 'ပိုက်ဆံအိတ်';

  @override
  String get navSettings => 'ဆက်တင်';

  @override
  String placeholderScreen(String feature) {
    return '$feature မကြာမီ ရောက်လာပါမည်';
  }

  @override
  String get settingsTitle => 'ဆက်တင်များ';

  @override
  String get appearance => 'အသွင်အပြင်';

  @override
  String get themeSystem => 'စနစ်အတိုင်း';

  @override
  String get themeLight => 'အလင်း';

  @override
  String get themeDark => 'အမှောင်';

  @override
  String get language => 'ဘာသာစကား';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMyanmar => 'မြန်မာ';

  @override
  String get logOut => 'ထွက်ရန်';

  @override
  String get logOutConfirm => 'J\'Donuts မှ ထွက်မလား?';

  @override
  String get cancel => 'မလုပ်တော့ပါ';

  @override
  String get errorGeneric => 'တစ်ခုခု မှားယွင်းနေပါသည်။ ထပ်ကြိုးစားပါ။';

  @override
  String get errorNetwork => 'ချိတ်ဆက်မှု မရှိပါ။ ကွန်ရက်ကို စစ်ဆေးပါ။';

  @override
  String notificationsLabel(int count) {
    return 'အသိပေးချက် $count ခု';
  }

  @override
  String get profile => 'ပရိုဖိုင်';

  @override
  String get editProfile => 'ပရိုဖိုင် ပြင်ရန်';

  @override
  String get changePhoto => 'ဓာတ်ပုံ ပြောင်းရန်';

  @override
  String get takePhoto => 'ဓာတ်ပုံ ရိုက်ရန်';

  @override
  String get chooseFromGallery => 'ဓာတ်ပုံပြခန်းမှ ရွေးရန်';

  @override
  String get removePhoto => 'ဓာတ်ပုံ ဖယ်ရှားရန်';

  @override
  String get save => 'သိမ်းမည်';

  @override
  String get profileSaved => 'ပရိုဖိုင် သိမ်းပြီးပါပြီ';

  @override
  String get phoneNumberLabel => 'ဖုန်းနံပါတ်';

  @override
  String get firstNameLabel => 'အမည်';

  @override
  String get lastNameLabel => 'မျိုးရိုးအမည်';

  @override
  String get phoneNotVerified => 'နံပါတ်အသစ်ကို အရင် အတည်ပြုပါ';

  @override
  String get verifyNewNumber => 'နံပါတ်အသစ်ကို အတည်ပြုရန် ကုဒ် ပို့ပေးပါမည်';

  @override
  String get photoPickFailed => 'ဓာတ်ပုံ ဖွင့်၍မရပါ';
}
