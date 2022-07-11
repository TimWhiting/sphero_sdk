// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'utils.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$RGB {
  int get red => throw _privateConstructorUsedError;
  int get green => throw _privateConstructorUsedError;
  int get blue => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RGBCopyWith<RGB> get copyWith => throw _privateConstructorUsedError;
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
    Object? red = freezed,
    Object? green = freezed,
    Object? blue = freezed,
  }) {
    return _then(_value.copyWith(
      red: red == freezed
          ? _value.red
          : red // ignore: cast_nullable_to_non_nullable
              as int,
      green: green == freezed
          ? _value.green
          : green // ignore: cast_nullable_to_non_nullable
              as int,
      blue: blue == freezed
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$$_RGBCopyWith<$Res> implements $RGBCopyWith<$Res> {
  factory _$$_RGBCopyWith(_$_RGB value, $Res Function(_$_RGB) then) =
      __$$_RGBCopyWithImpl<$Res>;
  @override
  $Res call({int red, int green, int blue});
}

/// @nodoc
class __$$_RGBCopyWithImpl<$Res> extends _$RGBCopyWithImpl<$Res>
    implements _$$_RGBCopyWith<$Res> {
  __$$_RGBCopyWithImpl(_$_RGB _value, $Res Function(_$_RGB) _then)
      : super(_value, (v) => _then(v as _$_RGB));

  @override
  _$_RGB get _value => super._value as _$_RGB;

  @override
  $Res call({
    Object? red = freezed,
    Object? green = freezed,
    Object? blue = freezed,
  }) {
    return _then(_$_RGB(
      red: red == freezed
          ? _value.red
          : red // ignore: cast_nullable_to_non_nullable
              as int,
      green: green == freezed
          ? _value.green
          : green // ignore: cast_nullable_to_non_nullable
              as int,
      blue: blue == freezed
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_RGB implements _RGB {
  const _$_RGB({required this.red, required this.green, required this.blue});

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
        (other.runtimeType == runtimeType &&
            other is _$_RGB &&
            const DeepCollectionEquality().equals(other.red, red) &&
            const DeepCollectionEquality().equals(other.green, green) &&
            const DeepCollectionEquality().equals(other.blue, blue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(red),
      const DeepCollectionEquality().hash(green),
      const DeepCollectionEquality().hash(blue));

  @JsonKey(ignore: true)
  @override
  _$$_RGBCopyWith<_$_RGB> get copyWith =>
      __$$_RGBCopyWithImpl<_$_RGB>(this, _$identity);
}

abstract class _RGB implements RGB {
  const factory _RGB(
      {required final int red,
      required final int green,
      required final int blue}) = _$_RGB;

  @override
  int get red;
  @override
  int get green;
  @override
  int get blue;
  @override
  @JsonKey(ignore: true)
  _$$_RGBCopyWith<_$_RGB> get copyWith => throw _privateConstructorUsedError;
}
