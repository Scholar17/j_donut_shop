import '../../../l10n/generated/app_localizations.dart';
import '../domain/entities/tier.dart';

extension TierLabel on TierLevel {
  String label(AppLocalizations l10n) => switch (this) {
    TierLevel.bronze => l10n.tierBronze,
    TierLevel.silver => l10n.tierSilver,
    TierLevel.gold => l10n.tierGold,
    TierLevel.platinum => l10n.tierPlatinum,
  };
}
