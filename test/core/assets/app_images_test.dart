import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/assets/app_images.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppImages', () {
    for (final path in AppImages.all) {
      test('$path is bundled and loadable', () async {
        final data = await rootBundle.load(path);

        expect(data.lengthInBytes, greaterThan(0));
      });
    }
  });
}
