// Copyright (c) 2021 ippee
// This source code is under the MIT License.
// See http://opensource.org/licenses/mit-license.php

import 'package:test/test.dart';
import 'package:dart_clipboard2/dart_clipboard2.dart';

void main() {
  test('set/get clipboard contents', () async {
    var contents = "All the world's a stage";

    var clip = Clipboard();
    await clip.setContents(contents).whenComplete(() {
      var result = clip.getContents();
      expect(result, equals(contents));
    });
  });
}
