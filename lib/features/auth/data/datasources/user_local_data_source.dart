import '../../../../objectbox.g.dart';
import '../models/user_entity.dart';

/// ObjectBox access for users; the only class that touches the user box.
class UserLocalDataSource {
  UserLocalDataSource(Store store) : _box = store.box<UserEntity>();

  final Box<UserEntity> _box;

  UserEntity? findByPhone(String phone) =>
      _box.query(UserEntity_.phone.equals(phone)).build().findFirst();

  UserEntity? findById(String userId) =>
      _box.query(UserEntity_.userId.equals(userId)).build().findFirst();

  Future<void> save(UserEntity user) => _box.putAsync(user);
}
