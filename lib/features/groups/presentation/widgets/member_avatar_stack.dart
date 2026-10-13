import 'package:flutter/material.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/presentation/widgets/member_avatar.dart';

/// A group's first [maxVisible] members as overlapping avatars, then "+N" for
/// the rest, as in the design reference. The first member is the owner.
class MemberAvatarStack extends StatelessWidget {
  const MemberAvatarStack({
    super.key,
    required this.members,
    required this.maxVisible,
    this.radius = 12,
  });

  /// How much each avatar overlaps the previous one, as a fraction of its
  /// diameter (measured from the design reference).
  static const double _overlap = 0.25;

  final List<Member> members;
  final int maxVisible;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The ring matches the card behind, so overlapping avatars stay apart.
    final ring = scheme.surface;
    final visible = members.take(maxVisible).toList();
    final hidden = members.length - visible.length;

    final avatars = <Widget>[
      for (final (i, member) in visible.indexed)
        MemberAvatar(
          name: member.name,
          // Members after the owner start the color cycle from the first.
          index: i - 1,
          isOwner: i == 0,
          radius: radius,
          ringColor: ring,
        ),
      if (hidden > 0) _MoreBubble(count: hidden, radius: radius, ring: ring),
    ];

    final diameter = (radius + MemberAvatar.ringWidth) * 2;
    final step = diameter * (1 - _overlap);

    // The member count is shown next to it, so the avatars add nothing.
    return ExcludeSemantics(
      child: SizedBox(
        width: diameter + step * (avatars.length - 1),
        height: diameter,
        child: Stack(
          children: [
            for (final (i, avatar) in avatars.indexed)
              Positioned(left: step * i, child: avatar),
          ],
        ),
      ),
    );
  }
}

/// "+N": the number of members not shown.
class _MoreBubble extends StatelessWidget {
  const _MoreBubble({
    required this.count,
    required this.radius,
    required this.ring,
  });

  final int count;
  final double radius;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: MemberAvatar.ringWidth),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: scheme.outline,
        child: FittedBox(
          child: Text(
            '+$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
