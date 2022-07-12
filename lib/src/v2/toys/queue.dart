import 'dart:async';
import 'package:dartx/dartx.dart';

class CommandQueueItem<T> {
  CommandQueueItem(this.payload, this.completer);
  final T payload;
  Timer? timeout;
  final Completer<T> completer;
}

class QueueListener<T> {
  QueueListener({required this.onExecute, required this.match});
  final Future<Object?> Function(T command) onExecute;
  final bool Function(T commandA, T commandB) match;
}

class Queue<T> {
  Queue(this.queueListener);

  final List<CommandQueueItem<T>> waitingForResponseQueue = [];
  final List<CommandQueueItem<T>> commandQueue = [];
  final QueueListener<T> queueListener;

  void onCommandProcessed(T payloadReceived) {
    final lastCommand = waitingForResponseQueue.firstOrNullWhere(
      (command) => queueListener.match(command.payload, payloadReceived),
    );
    if (lastCommand != null) {
      removeFromWaiting(lastCommand);
      lastCommand.completer.complete(payloadReceived);
    } else {
      print('PACKET RECEIVED BUT NOT EXECUTING $payloadReceived');
    }
  }

  Future<T> queue(T payload) {
    final completer = Completer<T>();

    commandQueue.add(CommandQueueItem(payload, completer));
    processCommand();

    return completer.future;
  }

  /// Be careful not to exceed 255 as seq will return to 0 and it can collide.
  void processCommand() {
    final command = commandQueue.removeAt(0);
    queueListener.onExecute(command.payload);
    waitingForResponseQueue.add(command);
    command.timeout =
        Timer(5000.milliseconds, () => onCommandTimedOut(command));
  }

  void removeFromWaiting(CommandQueueItem<T> command) {
    final index = waitingForResponseQueue.indexOf(command);
    if (index >= 0) {
      waitingForResponseQueue.removeAt(index);
      command.timeout?.cancel();
    }
  }

  void onCommandTimedOut(CommandQueueItem<T> command) {
    handleQueueError('Command Timed Out', command);
    removeFromWaiting(command);
  }

  void handleQueueError(String error, CommandQueueItem<T> command) {
    command.completer.completeError(error);
  }
}
