// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupDto _$GroupDtoFromJson(Map<String, dynamic> json) => _GroupDto(
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  members: (json['members'] as List<dynamic>)
      .map((e) => MemberDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$GroupDtoToJson(_GroupDto instance) => <String, dynamic>{
  'ownerId': instance.ownerId,
  'name': instance.name,
  'members': instance.members,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

_MemberDto _$MemberDtoFromJson(Map<String, dynamic> json) =>
    _MemberDto(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$MemberDtoToJson(_MemberDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
