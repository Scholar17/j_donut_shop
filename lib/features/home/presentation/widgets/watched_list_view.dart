import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'section_message.dart';

/// Vertical list fed by a local-database stream, with the three states every
/// screen needs: skeletons while loading, a message when empty, and an
/// error message with Retry (which re-subscribes) when the stream fails.
class WatchedListView<T> extends StatefulWidget {
  const WatchedListView({
    required this.watch,
    required this.itemBuilder,
    required this.skeleton,
    super.key,
  });

  /// Opens the stream; called again on Retry.
  final Stream<List<T>> Function() watch;
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// One placeholder row, repeated while loading.
  final Widget skeleton;

  static const _skeletonCount = 3;

  @override
  State<WatchedListView<T>> createState() => _WatchedListViewState<T>();
}

class _WatchedListViewState<T> extends State<WatchedListView<T>> {
  // Held in state so a rebuild does not re-subscribe.
  late Stream<List<T>> _stream = widget.watch();

  void _retry() => setState(() => _stream = widget.watch());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _message(SectionMessage.error(onRetry: _retry));
        }
        final items = snapshot.data;
        if (items != null && items.isEmpty) {
          return _message(const SectionMessage.empty());
        }
        return ListView.separated(
          padding: _padding(context),
          itemCount: items?.length ?? WatchedListView._skeletonCount,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => items == null
              ? widget.skeleton
              : widget.itemBuilder(context, items[i]),
        );
      },
    );
  }

  Widget _message(Widget message) => ListView(
    padding: _padding(context).copyWith(left: 0, right: 0),
    children: [message],
  );

  /// Gutter on the sides; the bottom clears the nav bar (extendBody).
  EdgeInsets _padding(BuildContext context) => EdgeInsets.fromLTRB(
    AppSpacing.pageGutter,
    AppSpacing.xs,
    AppSpacing.pageGutter,
    MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
  );
}
