// Copyright (c) 2021 ippee
// This source code is under the MIT License.
// See http://opensource.org/licenses/mit-license.php

library dart_clipboard;

import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class Clipboard extends ClipboardOperator {
  late final ClipboardOperator _clip;

  Clipboard() {
    if (Platform.isWindows) {
      _clip = _WinClipboard();
    } else if (Platform.isMacOS) {
      _clip = _MacClipboard();
    } else if (Platform.isLinux) {
      _clip = _LinuxClipboard();
    } else {
      throw OSError('${Platform.operatingSystem} is not suppoerted');
    }
  }

  @override
  String getContents() {
    return _clip.getContents();
  }

  @override
  Future<void> setContents(String contents) {
    return _clip.setContents(contents);
  }
}

abstract class ClipboardOperator {
  String getContents();
  Future<void> setContents(String contents);
}

class _WinClipboard extends ClipboardOperator {
  @override
  String getContents() {
    OpenClipboard(NULL);

    var hglb = GetClipboardData(CF_TEXT);
    if (hglb == NULL) return '';

    var ptstr = GlobalLock(hglb);
    var result = ptstr.cast<Utf8>().toDartString();

    GlobalUnlock(hglb);
    CloseClipboard();

    return result;
  }

  @override
  Future<void> setContents(String contents) async {
    var hMem = contents.toNativeUtf8().address;

    OpenClipboard(NULL);
    EmptyClipboard();
    SetClipboardData(CF_TEXT, hMem);
    CloseClipboard();
  }
}

class _MacClipboard extends ClipboardOperator {
  @override
  String getContents() {
    // TODO: implement getContents
    throw UnimplementedError();
  }

  @override
  Future<void> setContents(String contents) async {
    // TODO: implement setContents
  }
}

class _LinuxClipboard extends ClipboardOperator {
  @override
  String getContents() {
    var result =
        Process.runSync('/usr/bin/xclip', ['-o', '-selection', 'clipboard']);

    if (result.exitCode != 0) {
      throw ProcessException(
          '/usr/bin/xclip',
          ['-o', '-selection', 'clipboard'],
          result.stderr.toString(),
          result.exitCode);
    }

    return result.stdout.toString();
  }

  @override
  Future<void> setContents(String contents) async {
    return await Process.start('/usr/bin/xclip', ['-selection', 'clipboard'])
        .then((process) {
      process.stdin.write(contents);
      process.stdin.close();
    });
  }
}
