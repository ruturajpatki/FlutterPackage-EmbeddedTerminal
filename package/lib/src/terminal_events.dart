/*
 * Package: Flutter-EmbeddedTerminal
 * Author: Ruturaj V Patki
 * Email: ruturajvpatki@zohomail.com
 *
 * Copyright 2026 Ruturaj V Patki
 * Originally authored by Ruturaj V Patki.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/// Base class for all EmbeddedTerminal command lifecycle events.
abstract class EmbeddedTerminalEvent {
  /// The command string that was triggered.
  final String command;

  /// The working directory where the command was executed.
  final String? workingDirectory;

  /// The timestamp when the command run started.
  final DateTime startTime;

  EmbeddedTerminalEvent({
    required this.command,
    this.workingDirectory,
    required this.startTime,
  });
}

/// Event triggered when a command begins execution.
class CmdRunStartEvent extends EmbeddedTerminalEvent {
  CmdRunStartEvent({
    required super.command,
    super.workingDirectory,
    required super.startTime,
  });

  @override
  String toString() {
    return 'CmdRunStartEvent(command: "$command", workingDirectory: "$workingDirectory", startTime: $startTime)';
  }
}

/// Event triggered when a command execution completes.
class CmdRunCompleteEvent extends EmbeddedTerminalEvent {
  /// The exit code returned by the command execution.
  final int exitCode;

  /// The timestamp when the command run finished.
  final DateTime completionTime;

  /// The duration of the command run.
  final Duration duration;

  /// Indicates whether the command completed successfully (exit code 0).
  final bool isSuccess;

  CmdRunCompleteEvent({
    required super.command,
    super.workingDirectory,
    required super.startTime,
    required this.exitCode,
    required this.completionTime,
    required this.duration,
  }) : isSuccess = exitCode == 0;

  @override
  String toString() {
    return 'CmdRunCompleteEvent(command: "$command", exitCode: $exitCode, duration: $duration, isSuccess: $isSuccess)';
  }
}

/// Event triggered when a command fails to start or encounters an infrastructure error.
class CmdRunErrorEvent extends EmbeddedTerminalEvent {
  /// User-friendly error message description.
  final String errorMessage;

  /// The underlying exception or error object, if available.
  final Object? underlyingError;

  /// The exit code of the process if available.
  final int? exitCode;

  /// The duration of execution before the error, if available.
  final Duration? duration;

  CmdRunErrorEvent({
    required super.command,
    super.workingDirectory,
    required super.startTime,
    required this.errorMessage,
    this.underlyingError,
    this.exitCode,
    this.duration,
  });

  @override
  String toString() {
    return 'CmdRunErrorEvent(command: "$command", errorMessage: "$errorMessage", exitCode: $exitCode, duration: $duration)';
  }
}
