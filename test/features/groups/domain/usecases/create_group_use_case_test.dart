import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/domain/failures/group_failure.dart';
import 'package:splitzy/features/groups/domain/repositories/group_repository.dart';
import 'package:splitzy/features/groups/domain/usecases/create_group_use_case.dart';
import 'package:splitzy/features/groups/domain/validation/group_validation.dart';

class _MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late _MockGroupRepository repository;
  late CreateGroupUseCase createGroup;

  setUp(() {
    repository = _MockGroupRepository();
    createGroup = CreateGroupUseCase(repository);
    when(
      () => repository.createGroup(
        ownerId: any(named: 'ownerId'),
        ownerName: any(named: 'ownerName'),
        name: any(named: 'name'),
        memberNames: any(named: 'memberNames'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> createWith({
    String ownerName = 'Farah',
    String name = 'Trip to Dahab',
    List<String> memberNames = const ['Sara', 'Mona'],
  }) {
    return createGroup(
      ownerId: 'u1',
      ownerName: ownerName,
      name: name,
      memberNames: memberNames,
    );
  }

  void verifyNothingCreated() {
    verifyNever(
      () => repository.createGroup(
        ownerId: any(named: 'ownerId'),
        ownerName: any(named: 'ownerName'),
        name: any(named: 'name'),
        memberNames: any(named: 'memberNames'),
      ),
    );
  }

  Future<void> expectRejected(
    Future<void> Function() action,
    GroupValidationError error,
  ) async {
    await expectLater(
      action,
      throwsA(isA<InvalidGroupInput>().having((f) => f.error, 'error', error)),
    );
    verifyNothingCreated();
  }

  group('CreateGroupUseCase', () {
    test('creates the group with trimmed names, in order', () async {
      await createWith(
        ownerName: ' Farah ',
        name: '  Trip to Dahab ',
        memberNames: [' Sara', 'Mona  '],
      );

      verify(
        () => repository.createGroup(
          ownerId: 'u1',
          ownerName: 'Farah',
          name: 'Trip to Dahab',
          memberNames: ['Sara', 'Mona'],
        ),
      ).called(1);
    });

    test('rejects a missing group name without creating anything', () {
      return expectRejected(
        () => createWith(name: '   '),
        GroupValidationError.nameRequired,
      );
    });

    test('rejects a group with no other member', () {
      return expectRejected(
        () => createWith(memberNames: []),
        GroupValidationError.tooFewMembers,
      );
    });

    test('rejects a blank member name', () {
      return expectRejected(
        () => createWith(memberNames: ['Sara', ' ']),
        GroupValidationError.memberNameRequired,
      );
    });

    test("rejects a member named like the owner, ignoring case", () {
      return expectRejected(
        () => createWith(memberNames: ['farah']),
        GroupValidationError.duplicateMemberName,
      );
    });

    test('checks the group name before the members', () {
      return expectRejected(
        () => createWith(name: '', memberNames: []),
        GroupValidationError.nameRequired,
      );
    });

    test('passes on the failure the repository reports', () async {
      when(
        () => repository.createGroup(
          ownerId: any(named: 'ownerId'),
          ownerName: any(named: 'ownerName'),
          name: any(named: 'name'),
          memberNames: any(named: 'memberNames'),
        ),
      ).thenThrow(const NetworkFailure());

      await expectLater(createWith, throwsA(isA<NetworkFailure>()));
    });
  });
}
