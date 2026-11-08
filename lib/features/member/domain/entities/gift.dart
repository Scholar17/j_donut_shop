import 'package:equatable/equatable.dart';

/// A reward the member can redeem with points (Gift tab; display only).
class Gift extends Equatable {
  const Gift({required this.id, required this.title, required this.costPoints});

  final String id;
  final String title;
  final int costPoints;

  bool isAffordable(int memberPoints) => memberPoints >= costPoints;

  @override
  List<Object?> get props => [id, title, costPoints];
}
