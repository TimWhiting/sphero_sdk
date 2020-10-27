// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'utils.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$RGBTearOff {
  const _$RGBTearOff();

// ignore: unused_element
  _RGB call({int red, int green, int blue}) {
    return _RGB(
      red: red,
      green: green,
      blue: blue,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $RGB = _$RGBTearOff();

/// @nodoc
mixin _$RGB {
  int get red;
  int get green;
  int get blue;

  $RGBCopyWith<RGB> get copyWith;
}

/// @nodoc
abstract class $RGBCopyWith<$Res> {
  factory $RGBCopyWith(RGB value, $Res Function(RGB) then) =
      _$RGBCopyWithImpl<$Res>;
  $Res call({int red, int green, int blue});
}

/// @nodoc
class _$RGBCopyWithImpl<$Res> implements $RGBCopyWith<$Res> {
  _$RGBCopyWithImpl(this._value, this._then);

  final RGB _value;
  // ignore: unused_field
  final $Res Function(RGB) _then;

  @override
  $Res call({
    Object red = freezed,
    Object green = freezed,
    Object blue = freezed,
  }) {
    return _then(_value.copyWith(
      red: red == freezed ? _value.red : red as int,
      green: green == freezed ? _value.green : green as int,
      blue: blue == freezed ? _value.blue : blue as int,
    ));
  }
}

/// @nodoc
abstract class _$RGBCopyWith<$Res> implements $RGBCopyWith<$Res> {
  factory _$RGBCopyWith(_RGB value, $Res Function(_RGB) then) =
      __$RGBCopyWithImpl<$Res>;
  @override
  $Res call({int red, int green, int blue});
}

/// @nodoc
class __$RGBCopyWithImpl<$Res> extends _$RGBCopyWithImpl<$Res>
    implements _$RGBCopyWith<$Res> {
  __$RGBCopyWithImpl(_RGB _value, $Res Function(_RGB) _then)
      : super(_value, (v) => _then(v as _RGB));

  @override
  _RGB get _value => super._value as _RGB;

  @override
  $Res call({
    Object red = freezed,
    Object green = freezed,
    Object blue = freezed,
  }) {
    return _then(_RGB(
      red: red == freezed ? _value.red : red as int,
      green: green == freezed ? _value.green : green as int,
      blue: blue == freezed ? _value.blue : blue as int,
    ));
  }
}

/// @nodoc
class _$_RGB implements _RGB {
  const _$_RGB({this.red, this.green, this.blue});

  @override
  final int red;
  @override
  final int green;
  @override
  final int blue;

  @override
  String toString() {
    return 'RGB(red: $red, green: $green, blue: $blue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _RGB &&
            (identical(other.red, red) ||
                const DeepCollectionEquality().equals(other.red, red)) &&
            (identical(other.green, green) ||
                const DeepCollectionEquality().equals(other.green, green)) &&
            (identical(other.blue, blue) ||
                const DeepCollectionEquality().equals(other.blue, blue)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(red) ^
      const DeepCollectionEquality().hash(green) ^
      const DeepCollectionEquality().hash(blue);

  @override
  _$RGBCopyWith<_RGB> get copyWith =>
      __$RGBCopyWithImpl<_RGB>(this, _$identity);
}

abstract class _RGB implements RGB {
  const factory _RGB({int red, int green, int blue}) = _$_RGB;

  @override
  int get red;
  @override
  int get green;
  @override
  int get blue;
  @override
  _$RGBCopyWith<_RGB> get copyWith;
}
