// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$APIV1 {
  String get desc => throw _privateConstructorUsedError;
  String get event => throw _privateConstructorUsedError;
  List<APIField> get fields => throw _privateConstructorUsedError;
  int? get did => throw _privateConstructorUsedError;
  int? get cid => throw _privateConstructorUsedError;
  int? get idCode => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $APIV1CopyWith<APIV1> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $APIV1CopyWith<$Res> {
  factory $APIV1CopyWith(APIV1 value, $Res Function(APIV1) then) =
      _$APIV1CopyWithImpl<$Res>;
  $Res call(
      {String desc,
      String event,
      List<APIField> fields,
      int? did,
      int? cid,
      int? idCode});
}

/// @nodoc
class _$APIV1CopyWithImpl<$Res> implements $APIV1CopyWith<$Res> {
  _$APIV1CopyWithImpl(this._value, this._then);

  final APIV1 _value;
  // ignore: unused_field
  final $Res Function(APIV1) _then;

  @override
  $Res call({
    Object? desc = freezed,
    Object? event = freezed,
    Object? fields = freezed,
    Object? did = freezed,
    Object? cid = freezed,
    Object? idCode = freezed,
  }) {
    return _then(_value.copyWith(
      desc: desc == freezed
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      event: event == freezed
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as String,
      fields: fields == freezed
          ? _value.fields
          : fields // ignore: cast_nullable_to_non_nullable
              as List<APIField>,
      did: did == freezed
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as int?,
      cid: cid == freezed
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as int?,
      idCode: idCode == freezed
          ? _value.idCode
          : idCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
abstract class _$$_APIV1CopyWith<$Res> implements $APIV1CopyWith<$Res> {
  factory _$$_APIV1CopyWith(_$_APIV1 value, $Res Function(_$_APIV1) then) =
      __$$_APIV1CopyWithImpl<$Res>;
  @override
  $Res call(
      {String desc,
      String event,
      List<APIField> fields,
      int? did,
      int? cid,
      int? idCode});
}

/// @nodoc
class __$$_APIV1CopyWithImpl<$Res> extends _$APIV1CopyWithImpl<$Res>
    implements _$$_APIV1CopyWith<$Res> {
  __$$_APIV1CopyWithImpl(_$_APIV1 _value, $Res Function(_$_APIV1) _then)
      : super(_value, (v) => _then(v as _$_APIV1));

  @override
  _$_APIV1 get _value => super._value as _$_APIV1;

  @override
  $Res call({
    Object? desc = freezed,
    Object? event = freezed,
    Object? fields = freezed,
    Object? did = freezed,
    Object? cid = freezed,
    Object? idCode = freezed,
  }) {
    return _then(_$_APIV1(
      desc: desc == freezed
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      event: event == freezed
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as String,
      fields: fields == freezed
          ? _value._fields
          : fields // ignore: cast_nullable_to_non_nullable
              as List<APIField>,
      did: did == freezed
          ? _value.did
          : did // ignore: cast_nullable_to_non_nullable
              as int?,
      cid: cid == freezed
          ? _value.cid
          : cid // ignore: cast_nullable_to_non_nullable
              as int?,
      idCode: idCode == freezed
          ? _value.idCode
          : idCode // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$_APIV1 implements _APIV1 {
  const _$_APIV1(
      {required this.desc,
      required this.event,
      required final List<APIField> fields,
      this.did,
      this.cid,
      this.idCode})
      : _fields = fields;

  @override
  final String desc;
  @override
  final String event;
  final List<APIField> _fields;
  @override
  List<APIField> get fields {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fields);
  }

  @override
  final int? did;
  @override
  final int? cid;
  @override
  final int? idCode;

  @override
  String toString() {
    return 'APIV1(desc: $desc, event: $event, fields: $fields, did: $did, cid: $cid, idCode: $idCode)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_APIV1 &&
            const DeepCollectionEquality().equals(other.desc, desc) &&
            const DeepCollectionEquality().equals(other.event, event) &&
            const DeepCollectionEquality().equals(other._fields, _fields) &&
            const DeepCollectionEquality().equals(other.did, did) &&
            const DeepCollectionEquality().equals(other.cid, cid) &&
            const DeepCollectionEquality().equals(other.idCode, idCode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(desc),
      const DeepCollectionEquality().hash(event),
      const DeepCollectionEquality().hash(_fields),
      const DeepCollectionEquality().hash(did),
      const DeepCollectionEquality().hash(cid),
      const DeepCollectionEquality().hash(idCode));

  @JsonKey(ignore: true)
  @override
  _$$_APIV1CopyWith<_$_APIV1> get copyWith =>
      __$$_APIV1CopyWithImpl<_$_APIV1>(this, _$identity);
}

abstract class _APIV1 implements APIV1 {
  const factory _APIV1(
      {required final String desc,
      required final String event,
      required final List<APIField> fields,
      final int? did,
      final int? cid,
      final int? idCode}) = _$_APIV1;

  @override
  String get desc;
  @override
  String get event;
  @override
  List<APIField> get fields;
  @override
  int? get did;
  @override
  int? get cid;
  @override
  int? get idCode;
  @override
  @JsonKey(ignore: true)
  _$$_APIV1CopyWith<_$_APIV1> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$APIField {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get format => throw _privateConstructorUsedError;
  int? get bitmask => throw _privateConstructorUsedError;
  String? get units => throw _privateConstructorUsedError;
  Map<int, dynamic>? get values => throw _privateConstructorUsedError;
  int? get mask => throw _privateConstructorUsedError;
  String? get maskField => throw _privateConstructorUsedError;
  String? get sensor => throw _privateConstructorUsedError;
  int? get rangeBottom => throw _privateConstructorUsedError;
  int? get rangeTop => throw _privateConstructorUsedError;
  int get from => throw _privateConstructorUsedError;
  int? get to => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $APIFieldCopyWith<APIField> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $APIFieldCopyWith<$Res> {
  factory $APIFieldCopyWith(APIField value, $Res Function(APIField) then) =
      _$APIFieldCopyWithImpl<$Res>;
  $Res call(
      {String name,
      String type,
      String? format,
      int? bitmask,
      String? units,
      Map<int, dynamic>? values,
      int? mask,
      String? maskField,
      String? sensor,
      int? rangeBottom,
      int? rangeTop,
      int from,
      int? to});
}

/// @nodoc
class _$APIFieldCopyWithImpl<$Res> implements $APIFieldCopyWith<$Res> {
  _$APIFieldCopyWithImpl(this._value, this._then);

  final APIField _value;
  // ignore: unused_field
  final $Res Function(APIField) _then;

  @override
  $Res call({
    Object? name = freezed,
    Object? type = freezed,
    Object? format = freezed,
    Object? bitmask = freezed,
    Object? units = freezed,
    Object? values = freezed,
    Object? mask = freezed,
    Object? maskField = freezed,
    Object? sensor = freezed,
    Object? rangeBottom = freezed,
    Object? rangeTop = freezed,
    Object? from = freezed,
    Object? to = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      format: format == freezed
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      bitmask: bitmask == freezed
          ? _value.bitmask
          : bitmask // ignore: cast_nullable_to_non_nullable
              as int?,
      units: units == freezed
          ? _value.units
          : units // ignore: cast_nullable_to_non_nullable
              as String?,
      values: values == freezed
          ? _value.values
          : values // ignore: cast_nullable_to_non_nullable
              as Map<int, dynamic>?,
      mask: mask == freezed
          ? _value.mask
          : mask // ignore: cast_nullable_to_non_nullable
              as int?,
      maskField: maskField == freezed
          ? _value.maskField
          : maskField // ignore: cast_nullable_to_non_nullable
              as String?,
      sensor: sensor == freezed
          ? _value.sensor
          : sensor // ignore: cast_nullable_to_non_nullable
              as String?,
      rangeBottom: rangeBottom == freezed
          ? _value.rangeBottom
          : rangeBottom // ignore: cast_nullable_to_non_nullable
              as int?,
      rangeTop: rangeTop == freezed
          ? _value.rangeTop
          : rangeTop // ignore: cast_nullable_to_non_nullable
              as int?,
      from: from == freezed
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as int,
      to: to == freezed
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
abstract class _$$_APIFieldCopyWith<$Res> implements $APIFieldCopyWith<$Res> {
  factory _$$_APIFieldCopyWith(
          _$_APIField value, $Res Function(_$_APIField) then) =
      __$$_APIFieldCopyWithImpl<$Res>;
  @override
  $Res call(
      {String name,
      String type,
      String? format,
      int? bitmask,
      String? units,
      Map<int, dynamic>? values,
      int? mask,
      String? maskField,
      String? sensor,
      int? rangeBottom,
      int? rangeTop,
      int from,
      int? to});
}

/// @nodoc
class __$$_APIFieldCopyWithImpl<$Res> extends _$APIFieldCopyWithImpl<$Res>
    implements _$$_APIFieldCopyWith<$Res> {
  __$$_APIFieldCopyWithImpl(
      _$_APIField _value, $Res Function(_$_APIField) _then)
      : super(_value, (v) => _then(v as _$_APIField));

  @override
  _$_APIField get _value => super._value as _$_APIField;

  @override
  $Res call({
    Object? name = freezed,
    Object? type = freezed,
    Object? format = freezed,
    Object? bitmask = freezed,
    Object? units = freezed,
    Object? values = freezed,
    Object? mask = freezed,
    Object? maskField = freezed,
    Object? sensor = freezed,
    Object? rangeBottom = freezed,
    Object? rangeTop = freezed,
    Object? from = freezed,
    Object? to = freezed,
  }) {
    return _then(_$_APIField(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      format: format == freezed
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      bitmask: bitmask == freezed
          ? _value.bitmask
          : bitmask // ignore: cast_nullable_to_non_nullable
              as int?,
      units: units == freezed
          ? _value.units
          : units // ignore: cast_nullable_to_non_nullable
              as String?,
      values: values == freezed
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as Map<int, dynamic>?,
      mask: mask == freezed
          ? _value.mask
          : mask // ignore: cast_nullable_to_non_nullable
              as int?,
      maskField: maskField == freezed
          ? _value.maskField
          : maskField // ignore: cast_nullable_to_non_nullable
              as String?,
      sensor: sensor == freezed
          ? _value.sensor
          : sensor // ignore: cast_nullable_to_non_nullable
              as String?,
      rangeBottom: rangeBottom == freezed
          ? _value.rangeBottom
          : rangeBottom // ignore: cast_nullable_to_non_nullable
              as int?,
      rangeTop: rangeTop == freezed
          ? _value.rangeTop
          : rangeTop // ignore: cast_nullable_to_non_nullable
              as int?,
      from: from == freezed
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as int,
      to: to == freezed
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$_APIField implements _APIField {
  const _$_APIField(
      {required this.name,
      required this.type,
      this.format,
      this.bitmask,
      this.units,
      final Map<int, dynamic>? values,
      this.mask,
      this.maskField,
      this.sensor,
      this.rangeBottom,
      this.rangeTop,
      this.from = 0,
      this.to})
      : _values = values;

  @override
  final String name;
  @override
  final String type;
  @override
  final String? format;
  @override
  final int? bitmask;
  @override
  final String? units;
  final Map<int, dynamic>? _values;
  @override
  Map<int, dynamic>? get values {
    final value = _values;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int? mask;
  @override
  final String? maskField;
  @override
  final String? sensor;
  @override
  final int? rangeBottom;
  @override
  final int? rangeTop;
  @override
  @JsonKey()
  final int from;
  @override
  final int? to;

  @override
  String toString() {
    return 'APIField(name: $name, type: $type, format: $format, bitmask: $bitmask, units: $units, values: $values, mask: $mask, maskField: $maskField, sensor: $sensor, rangeBottom: $rangeBottom, rangeTop: $rangeTop, from: $from, to: $to)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_APIField &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.type, type) &&
            const DeepCollectionEquality().equals(other.format, format) &&
            const DeepCollectionEquality().equals(other.bitmask, bitmask) &&
            const DeepCollectionEquality().equals(other.units, units) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            const DeepCollectionEquality().equals(other.mask, mask) &&
            const DeepCollectionEquality().equals(other.maskField, maskField) &&
            const DeepCollectionEquality().equals(other.sensor, sensor) &&
            const DeepCollectionEquality()
                .equals(other.rangeBottom, rangeBottom) &&
            const DeepCollectionEquality().equals(other.rangeTop, rangeTop) &&
            const DeepCollectionEquality().equals(other.from, from) &&
            const DeepCollectionEquality().equals(other.to, to));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(type),
      const DeepCollectionEquality().hash(format),
      const DeepCollectionEquality().hash(bitmask),
      const DeepCollectionEquality().hash(units),
      const DeepCollectionEquality().hash(_values),
      const DeepCollectionEquality().hash(mask),
      const DeepCollectionEquality().hash(maskField),
      const DeepCollectionEquality().hash(sensor),
      const DeepCollectionEquality().hash(rangeBottom),
      const DeepCollectionEquality().hash(rangeTop),
      const DeepCollectionEquality().hash(from),
      const DeepCollectionEquality().hash(to));

  @JsonKey(ignore: true)
  @override
  _$$_APIFieldCopyWith<_$_APIField> get copyWith =>
      __$$_APIFieldCopyWithImpl<_$_APIField>(this, _$identity);
}

abstract class _APIField implements APIField {
  const factory _APIField(
      {required final String name,
      required final String type,
      final String? format,
      final int? bitmask,
      final String? units,
      final Map<int, dynamic>? values,
      final int? mask,
      final String? maskField,
      final String? sensor,
      final int? rangeBottom,
      final int? rangeTop,
      final int from,
      final int? to}) = _$_APIField;

  @override
  String get name;
  @override
  String get type;
  @override
  String? get format;
  @override
  int? get bitmask;
  @override
  String? get units;
  @override
  Map<int, dynamic>? get values;
  @override
  int? get mask;
  @override
  String? get maskField;
  @override
  String? get sensor;
  @override
  int? get rangeBottom;
  @override
  int? get rangeTop;
  @override
  int get from;
  @override
  int? get to;
  @override
  @JsonKey(ignore: true)
  _$$_APIFieldCopyWith<_$_APIField> get copyWith =>
      throw _privateConstructorUsedError;
}
