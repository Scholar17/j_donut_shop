/// Which entry path the user chose on Onboarding.
enum AuthMode {
  /// "Let's get started": Phone → OTP → Name → Date of birth → Welcome.
  register,

  /// "Already have an account? Log in": Phone → OTP → Home.
  login,

  /// Edit profile: verify a new number before it replaces the current one.
  changePhone,
}
