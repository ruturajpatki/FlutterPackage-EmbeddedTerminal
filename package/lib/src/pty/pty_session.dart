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

/// An abstract interface representing a cross-platform pseudo-terminal (PTY) session.
///
/// This isolates the core terminal logic from the platform-specific PTY implementation
/// and wraps the third-party dependency.
abstract class PtySession {
  /// Stream of binary output data produced by the PTY.
  Stream<List<int>> get output;

  /// Writes string input (typically keystrokes) to the PTY.
  void write(String data);

  /// Writes raw bytes to the PTY.
  void writeBytes(List<int> data);

  /// Informs the PTY of a terminal resize.
  void resize(int columns, int rows);

  /// Waits for the underlying process inside the PTY to exit.
  /// Returns the process exit code.
  Future<int> waitForExit();

  /// Kills/Terminates the PTY process.
  void kill();

  /// Disposes of any resources held by the PTY session.
  void dispose();
}
