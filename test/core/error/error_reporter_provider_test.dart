import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/injection_container.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_error_reporter.dart';

void main() {
  group('errorReporterProvider', () {
    test('fails fast when the injection container did not supply it', () {
      final container = ProviderContainer.test();

      expect(() => container.read(errorReporterProvider), throwsA(anything));
    });

    test('exposes the reporter supplied by the injection container', () async {
      final repository = FakeAuthRepository();
      addTearDown(repository.dispose);
      final reporter = FakeErrorReporter();
      final container = ProviderContainer.test(
        overrides: InjectionContainer(
          authRepository: repository,
          errorReporter: reporter,
        ).overrides,
      );

      final provided = container.read(errorReporterProvider);
      await provided.recordNonFatal(
        StateError('unexpected'),
        StackTrace.empty,
        reason: 'Testing',
      );

      expect(provided, same(reporter));
      expect(reporter.nonFatal.single.reason, 'Testing');
    });
  });
}
