import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/session_usecases.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.user, {this.pendingWelcome = false});

  final AuthUser user;

  /// True right after registration until "Let's explore" is tapped; the
  /// router guard uses it to show Welcome once. Not persisted: a relaunch
  /// goes straight to Home.
  final bool pendingWelcome;

  @override
  List<Object?> get props => [user, pendingWelcome];
}

/// App-wide session. The router listens to it; screens never navigate on
/// sign-in/out themselves.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._restoreSession, this._logOut)
    : super(const SessionUnauthenticated());

  final RestoreSession _restoreSession;
  final LogOut _logOut;

  /// Called once before the first frame so the guard knows where to start.
  Future<void> restore() async {
    final user = await _restoreSession();
    emit(
      user == null
          ? const SessionUnauthenticated()
          : SessionAuthenticated(user),
    );
  }

  void signedIn(AuthUser user, {bool isNewUser = false}) =>
      emit(SessionAuthenticated(user, pendingWelcome: isNewUser));

  /// Edited profile saved: keep the pending-welcome flag as it was.
  void userUpdated(AuthUser user) {
    final current = state;
    if (current is SessionAuthenticated) {
      emit(SessionAuthenticated(user, pendingWelcome: current.pendingWelcome));
    }
  }

  void welcomeCompleted() {
    final current = state;
    if (current is SessionAuthenticated) {
      emit(SessionAuthenticated(current.user));
    }
  }

  Future<void> logOut() async {
    await _logOut();
    emit(const SessionUnauthenticated());
  }
}
