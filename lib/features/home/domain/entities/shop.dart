import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  const Shop({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String address;
  final String? imageUrl;
  final String? imageAsset;

  @override
  List<Object?> get props => [id, name, address, imageUrl, imageAsset];
}
