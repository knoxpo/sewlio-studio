/// Barley — minimal Stacked-style MVVM.
///
/// A view owns exactly one [BarleyViewModel]; the model holds all
/// state and logic, calls [BarleyViewModel.notify] after changes, and
/// the [BarleyView] rebuilds. Views stay declarative: gestures and
/// dialogs forward to model methods, never mutate state themselves.
library;

import 'package:flutter/widgets.dart';

/// Base class for view models: [ChangeNotifier] plus busy/error
/// conveniences and a disposed guard so async completions can't notify
/// a dead listener tree.
abstract class BarleyViewModel extends ChangeNotifier {
  var _disposed = false;
  var _busy = false;
  Object? _error;

  bool get disposed => _disposed;
  bool get isBusy => _busy;
  Object? get error => _error;
  bool get hasError => _error != null;

  /// Rebuild the view. Safe to call after dispose (no-op).
  void notify() {
    if (!_disposed) notifyListeners();
  }

  @protected
  void setBusy(bool value) {
    _busy = value;
    notify();
  }

  @protected
  void setError(Object? value) {
    _error = value;
    notify();
  }

  /// Runs [work] with busy state around it, capturing thrown errors
  /// into [error] instead of propagating.
  Future<void> runBusy(Future<void> Function() work) async {
    setBusy(true);
    setError(null);
    try {
      await work();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  /// Called once when the owning [BarleyView] is mounted.
  void onReady() {}

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Builds a view around a [BarleyViewModel] (Stacked's
/// ViewModelBuilder.reactive): creates the model once, calls
/// [BarleyViewModel.onReady] after the first frame, rebuilds on every
/// [BarleyViewModel.notify], and disposes the model with the view.
class BarleyView<T extends BarleyViewModel> extends StatefulWidget {
  const BarleyView({
    super.key,
    required this.create,
    required this.builder,
    this.disposeModel = true,
  });

  /// Creates the view model (called once per view lifetime).
  final T Function() create;

  final Widget Function(BuildContext context, T model) builder;

  /// Set false when the model outlives the view (owned elsewhere).
  final bool disposeModel;

  @override
  State<BarleyView<T>> createState() => _BarleyViewState<T>();
}

class _BarleyViewState<T extends BarleyViewModel> extends State<BarleyView<T>> {
  late final T model;

  @override
  void initState() {
    super.initState();
    model = widget.create();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) model.onReady();
    });
  }

  @override
  void dispose() {
    if (widget.disposeModel) model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => widget.builder(context, model),
    );
  }
}
