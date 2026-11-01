import 'dart:async';

/// App-wide channel for errors the user should see. [EErrorBanner] shows the
/// latest one as a copyable, emailable toast with recent log lines attached.
///
/// Push from `catch` blocks with a short prefix naming the operation:
///
/// ```dart
/// try {
///   await goalsRepository.saveGoal(goal);
/// } catch (error) {
///   errorBus.add('Save goal: $error');
///   rethrow;
/// }
/// ```
///
/// [AppErrorCapture] pushes every uncaught error here too.
final errorBus = StreamController<String>.broadcast();
