import 'package:equatable/equatable.dart';

/// Carousel banner on Home ("We are now at Central Boulevard").
class PromoBanner extends Equatable {
  const PromoBanner({
    required this.id,
    required this.title,
    this.badge,
    this.imageUrl,
    this.imageAsset,
  });

  final String id;
  final String title;

  /// Small pill above the title, e.g. "New shop" or "50% off".
  final String? badge;
  final String? imageUrl;
  final String? imageAsset;

  @override
  List<Object?> get props => [id, title, badge, imageUrl, imageAsset];
}
