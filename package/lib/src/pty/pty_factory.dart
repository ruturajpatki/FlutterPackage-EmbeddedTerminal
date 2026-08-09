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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_pty/flutter_pty.dart';
import 'pty_session.dart';

/// Concrete implementation of [PtySession] wrapping the `flutter_pty` package's [Pty].
class FlutterPtySession implements PtySession {
  final Pty _pty;
  late final StreamController<List<int>> _outputController;
  StreamSubscription<Uint8List>? _subscription;

  FlutterPtySession(this._pty) {
    _outputController = StreamController<List<int>>.broadcast();
    _subscription = _pty.output.listen(
      (data) {
        if (!_outputController.isClosed) {
          _outputController.add(data);
        }
      },
      onError: (err) {
        if (!_outputController.isClosed) {
          _outputController.addError(err);
        }
      },
      onDone: () {
        if (!_outputController.isClosed) {
          _outputController.close();
        }
      },
    );
  }

  @override
  Stream<List<int>> get output => _outputController.stream;

  @override
  void write(String data) {
    _pty.write(Uint8List.fromList(utf8.encode(data)));
  }

  @override
  void writeBytes(List<int> data) {
    _pty.write(Uint8List.fromList(data));
  }

  @override
  void resize(int columns, int rows) {
    _pty.resize(columns, rows);
  }

  @override
  Future<int> waitForExit() {
    return _pty.exitCode;
  }

  @override
  void kill() {
    try {
      _pty.kill();
    } catch (_) {
      // Ignore process termination errors if already dead
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _outputController.close();
    kill();
  }
}

/// Factory to spawn platform-appropriate [PtySession] instances.
class PtyFactory {
  /// Hook to allow unit tests to inject a mock PTY factory.
  static PtySession Function({
    String? command,
    String? workingDirectory,
    Map<String, String>? environment,
    int columns,
    int rows,
  })?
  mockFactory;

  /// Spawns a new [PtySession] running either a command through the default shell
  /// or starting an interactive shell session.
  static PtySession start({
    String? command,
    String? workingDirectory,
    Map<String, String>? environment,
    int columns = 80,
    int rows = 25,
  }) {
    if (mockFactory != null) {
      return mockFactory!(
        command: command,
        workingDirectory: workingDirectory,
        environment: environment,
        columns: columns,
        rows: rows,
      );
    }
    String executable;
    List<String> arguments = [];

    // Ensure we merge and preserve parent environment variables like PATH.
    final mergedEnvironment = Map<String, String>.from(Platform.environment);
    if (environment != null) {
      mergedEnvironment.addAll(environment);
    }

    if (Platform.isWindows) {
      executable = 'powershell.exe';
      if (command != null && command.trim().isNotEmpty) {
        // Run command in powershell and propagate its exit code.
        arguments = ['-NoProfile', '-Command', '$command; exit \$LASTEXITCODE'];
      } else {
        arguments = ['-NoProfile'];
      }
    } else {
      // macOS / Linux
      final shell =
          Platform.environment['SHELL'] ??
          (Platform.isMacOS ? '/bin/zsh' : '/bin/bash');
      executable = shell;
      if (command != null && command.trim().isNotEmpty) {
        arguments = ['-c', command];
      }
    }

    try {
      final pty = Pty.start(
        executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        environment: mergedEnvironment,
        columns: columns,
        rows: rows,
      );
      return FlutterPtySession(pty);
    } catch (e) {
      // Fallback for Windows if powershell is missing/unavailable
      if (Platform.isWindows && executable == 'powershell.exe') {
        try {
          executable = 'cmd.exe';
          if (command != null && command.trim().isNotEmpty) {
            arguments = ['/c', command];
          } else {
            arguments = [];
          }
          final pty = Pty.start(
            executable,
            arguments: arguments,
            workingDirectory: workingDirectory,
            environment: mergedEnvironment,
            columns: columns,
            rows: rows,
          );
          return FlutterPtySession(pty);
        } catch (_) {}
      }
      rethrow;
    }
  }
}
