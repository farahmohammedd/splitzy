// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseDto {

 String get description;/// In piastres.
 int get amount; String get currency;/// The paying member's id.
 String get paidBy;/// Stored by name: `equal` or `custom`.
 SplitType get splitType;/// Every member's share in piastres, by member id.
 Map<String, int> get shares;/// `null` while a just-written server timestamp is still pending. The
/// data source writes the server's time instead of this value.
@TimestampConverter() DateTime? get createdAt;
/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseDtoCopyWith<ExpenseDto> get copyWith => _$ExpenseDtoCopyWithImpl<ExpenseDto>(this as ExpenseDto, _$identity);

  /// Serializes this ExpenseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseDto&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paidBy, paidBy) || other.paidBy == paidBy)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&const DeepCollectionEquality().equals(other.shares, shares)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,amount,currency,paidBy,splitType,const DeepCollectionEquality().hash(shares),createdAt);

@override
String toString() {
  return 'ExpenseDto(description: $description, amount: $amount, currency: $currency, paidBy: $paidBy, splitType: $splitType, shares: $shares, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExpenseDtoCopyWith<$Res>  {
  factory $ExpenseDtoCopyWith(ExpenseDto value, $Res Function(ExpenseDto) _then) = _$ExpenseDtoCopyWithImpl;
@useResult
$Res call({
 String description, int amount, String currency, String paidBy, SplitType splitType, Map<String, int> shares,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$ExpenseDtoCopyWithImpl<$Res>
    implements $ExpenseDtoCopyWith<$Res> {
  _$ExpenseDtoCopyWithImpl(this._self, this._then);

  final ExpenseDto _self;
  final $Res Function(ExpenseDto) _then;

/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? amount = null,Object? currency = null,Object? paidBy = null,Object? splitType = null,Object? shares = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paidBy: null == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as String,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseDto].
extension ExpenseDtoPatterns on ExpenseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseDto value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseDto value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  int amount,  String currency,  String paidBy,  SplitType splitType,  Map<String, int> shares, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that.description,_that.amount,_that.currency,_that.paidBy,_that.splitType,_that.shares,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  int amount,  String currency,  String paidBy,  SplitType splitType,  Map<String, int> shares, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ExpenseDto():
return $default(_that.description,_that.amount,_that.currency,_that.paidBy,_that.splitType,_that.shares,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  int amount,  String currency,  String paidBy,  SplitType splitType,  Map<String, int> shares, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseDto() when $default != null:
return $default(_that.description,_that.amount,_that.currency,_that.paidBy,_that.splitType,_that.shares,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseDto extends ExpenseDto {
  const _ExpenseDto({required this.description, required this.amount, required this.currency, required this.paidBy, required this.splitType, required final  Map<String, int> shares, @TimestampConverter() this.createdAt}): _shares = shares,super._();
  factory _ExpenseDto.fromJson(Map<String, dynamic> json) => _$ExpenseDtoFromJson(json);

@override final  String description;
/// In piastres.
@override final  int amount;
@override final  String currency;
/// The paying member's id.
@override final  String paidBy;
/// Stored by name: `equal` or `custom`.
@override final  SplitType splitType;
/// Every member's share in piastres, by member id.
 final  Map<String, int> _shares;
/// Every member's share in piastres, by member id.
@override Map<String, int> get shares {
  if (_shares is EqualUnmodifiableMapView) return _shares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_shares);
}

/// `null` while a just-written server timestamp is still pending. The
/// data source writes the server's time instead of this value.
@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseDtoCopyWith<_ExpenseDto> get copyWith => __$ExpenseDtoCopyWithImpl<_ExpenseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseDto&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.paidBy, paidBy) || other.paidBy == paidBy)&&(identical(other.splitType, splitType) || other.splitType == splitType)&&const DeepCollectionEquality().equals(other._shares, _shares)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,amount,currency,paidBy,splitType,const DeepCollectionEquality().hash(_shares),createdAt);

@override
String toString() {
  return 'ExpenseDto(description: $description, amount: $amount, currency: $currency, paidBy: $paidBy, splitType: $splitType, shares: $shares, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExpenseDtoCopyWith<$Res> implements $ExpenseDtoCopyWith<$Res> {
  factory _$ExpenseDtoCopyWith(_ExpenseDto value, $Res Function(_ExpenseDto) _then) = __$ExpenseDtoCopyWithImpl;
@override @useResult
$Res call({
 String description, int amount, String currency, String paidBy, SplitType splitType, Map<String, int> shares,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$ExpenseDtoCopyWithImpl<$Res>
    implements _$ExpenseDtoCopyWith<$Res> {
  __$ExpenseDtoCopyWithImpl(this._self, this._then);

  final _ExpenseDto _self;
  final $Res Function(_ExpenseDto) _then;

/// Create a copy of ExpenseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? amount = null,Object? currency = null,Object? paidBy = null,Object? splitType = null,Object? shares = null,Object? createdAt = freezed,}) {
  return _then(_ExpenseDto(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,paidBy: null == paidBy ? _self.paidBy : paidBy // ignore: cast_nullable_to_non_nullable
as String,splitType: null == splitType ? _self.splitType : splitType // ignore: cast_nullable_to_non_nullable
as SplitType,shares: null == shares ? _self._shares : shares // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
