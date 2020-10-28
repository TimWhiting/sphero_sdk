// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
class _$APIV1TearOff {
  const _$APIV1TearOff();

// ignore: unused_element
  _APIV1 call(
      {int idCode,
      String desc,
      int did,
      int cid,
      String event,
      List<APIField> fields}) {
    return _APIV1(
      idCode: idCode,
      desc: desc,
      did: did,
      cid: cid,
      event: event,
      fields: fields,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $APIV1 = _$APIV1TearOff();

/// @nodoc
mixin _$APIV1 {
  int get idCode;
  String get desc;
  int get did;
  int get cid;
  String get event;
  List<APIField> get fields;

  $APIV1CopyWith<APIV1> get copyWith;
}

/// @nodoc
abstract class $APIV1CopyWith<$Res> {
  factory $APIV1CopyWith(APIV1 value, $Res Function(APIV1) then) =
      _$APIV1CopyWithImpl<$Res>;
  $Res call(
      {int idCode,
      String desc,
      int did,
      int cid,
      String event,
      List<APIField> fields});
}

/// @nodoc
class _$APIV1CopyWithImpl<$Res> implements $APIV1CopyWith<$Res> {
  _$APIV1CopyWithImpl(this._value, this._then);

  final APIV1 _value;
  // ignore: unused_field
  final $Res Function(APIV1) _then;

  @override
  $Res call({
    Object idCode = freezed,
    Object desc = freezed,
    Object did = freezed,
    Object cid = freezed,
    Object event = freezed,
    Object fields = freezed,
  }) {
    return _then(_value.copyWith(
      idCode: idCode == freezed ? _value.idCode : idCode as int,
      desc: desc == freezed ? _value.desc : desc as String,
      did: did == freezed ? _value.did : did as int,
      cid: cid == freezed ? _value.cid : cid as int,
      event: event == freezed ? _value.event : event as String,
      fields: fields == freezed ? _value.fields : fields as List<APIField>,
    ));
  }
}

/// @nodoc
abstract class _$APIV1CopyWith<$Res> implements $APIV1CopyWith<$Res> {
  factory _$APIV1CopyWith(_APIV1 value, $Res Function(_APIV1) then) =
      __$APIV1CopyWithImpl<$Res>;
  @override
  $Res call(
      {int idCode,
      String desc,
      int did,
      int cid,
      String event,
      List<APIField> fields});
}

/// @nodoc
class __$APIV1CopyWithImpl<$Res> extends _$APIV1CopyWithImpl<$Res>
    implements _$APIV1CopyWith<$Res> {
  __$APIV1CopyWithImpl(_APIV1 _value, $Res Function(_APIV1) _then)
      : super(_value, (v) => _then(v as _APIV1));

  @override
  _APIV1 get _value => super._value as _APIV1;

  @override
  $Res call({
    Object idCode = freezed,
    Object desc = freezed,
    Object did = freezed,
    Object cid = freezed,
    Object event = freezed,
    Object fields = freezed,
  }) {
    return _then(_APIV1(
      idCode: idCode == freezed ? _value.idCode : idCode as int,
      desc: desc == freezed ? _value.desc : desc as String,
      did: did == freezed ? _value.did : did as int,
      cid: cid == freezed ? _value.cid : cid as int,
      event: event == freezed ? _value.event : event as String,
      fields: fields == freezed ? _value.fields : fields as List<APIField>,
    ));
  }
}

/// @nodoc
class _$_APIV1 implements _APIV1 {
  const _$_APIV1(
      {this.idCode, this.desc, this.did, this.cid, this.event, this.fields});

  @override
  final int idCode;
  @override
  final String desc;
  @override
  final int did;
  @override
  final int cid;
  @override
  final String event;
  @override
  final List<APIField> fields;

  @override
  String toString() {
    return 'APIV1(idCode: $idCode, desc: $desc, did: $did, cid: $cid, event: $event, fields: $fields)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _APIV1 &&
            (identical(other.idCode, idCode) ||
                const DeepCollectionEquality().equals(other.idCode, idCode)) &&
            (identical(other.desc, desc) ||
                const DeepCollectionEquality().equals(other.desc, desc)) &&
            (identical(other.did, did) ||
                const DeepCollectionEquality().equals(other.did, did)) &&
            (identical(other.cid, cid) ||
                const DeepCollectionEquality().equals(other.cid, cid)) &&
            (identical(other.event, event) ||
                const DeepCollectionEquality().equals(other.event, event)) &&
            (identical(other.fields, fields) ||
                const DeepCollectionEquality().equals(other.fields, fields)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(idCode) ^
      const DeepCollectionEquality().hash(desc) ^
      const DeepCollectionEquality().hash(did) ^
      const DeepCollectionEquality().hash(cid) ^
      const DeepCollectionEquality().hash(event) ^
      const DeepCollectionEquality().hash(fields);

  @override
  _$APIV1CopyWith<_APIV1> get copyWith =>
      __$APIV1CopyWithImpl<_APIV1>(this, _$identity);
}

abstract class _APIV1 implements APIV1 {
  const factory _APIV1(
      {int idCode,
      String desc,
      int did,
      int cid,
      String event,
      List<APIField> fields}) = _$_APIV1;

  @override
  int get idCode;
  @override
  String get desc;
  @override
  int get did;
  @override
  int get cid;
  @override
  String get event;
  @override
  List<APIField> get fields;
  @override
  _$APIV1CopyWith<_APIV1> get copyWith;
}

/// @nodoc
class _$APIFieldTearOff {
  const _$APIFieldTearOff();

// ignore: unused_element
  _APIField call(
      {String name,
      String type,
      int bitmask,
      String maskField,
      String sensor,
      int rangeBottom,
      int rangeTop,
      String units,
      int mask,
      int from,
      int to,
      String format,
      Map<int, dynamic> values}) {
    return _APIField(
      name: name,
      type: type,
      bitmask: bitmask,
      maskField: maskField,
      sensor: sensor,
      rangeBottom: rangeBottom,
      rangeTop: rangeTop,
      units: units,
      mask: mask,
      from: from,
      to: to,
      format: format,
      values: values,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $APIField = _$APIFieldTearOff();

/// @nodoc
mixin _$APIField {
  String get name;
  String get type;
  int get bitmask;
  String get maskField;
  String get sensor;
  int get rangeBottom;
  int get rangeTop;
  String get units;
  int get mask;
  int get from;
  int get to;
  String get format;
  Map<int, dynamic> get values;

  $APIFieldCopyWith<APIField> get copyWith;
}

/// @nodoc
abstract class $APIFieldCopyWith<$Res> {
  factory $APIFieldCopyWith(APIField value, $Res Function(APIField) then) =
      _$APIFieldCopyWithImpl<$Res>;
  $Res call(
      {String name,
      String type,
      int bitmask,
      String maskField,
      String sensor,
      int rangeBottom,
      int rangeTop,
      String units,
      int mask,
      int from,
      int to,
      String format,
      Map<int, dynamic> values});
}

/// @nodoc
class _$APIFieldCopyWithImpl<$Res> implements $APIFieldCopyWith<$Res> {
  _$APIFieldCopyWithImpl(this._value, this._then);

  final APIField _value;
  // ignore: unused_field
  final $Res Function(APIField) _then;

  @override
  $Res call({
    Object name = freezed,
    Object type = freezed,
    Object bitmask = freezed,
    Object maskField = freezed,
    Object sensor = freezed,
    Object rangeBottom = freezed,
    Object rangeTop = freezed,
    Object units = freezed,
    Object mask = freezed,
    Object from = freezed,
    Object to = freezed,
    Object format = freezed,
    Object values = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed ? _value.name : name as String,
      type: type == freezed ? _value.type : type as String,
      bitmask: bitmask == freezed ? _value.bitmask : bitmask as int,
      maskField: maskField == freezed ? _value.maskField : maskField as String,
      sensor: sensor == freezed ? _value.sensor : sensor as String,
      rangeBottom:
          rangeBottom == freezed ? _value.rangeBottom : rangeBottom as int,
      rangeTop: rangeTop == freezed ? _value.rangeTop : rangeTop as int,
      units: units == freezed ? _value.units : units as String,
      mask: mask == freezed ? _value.mask : mask as int,
      from: from == freezed ? _value.from : from as int,
      to: to == freezed ? _value.to : to as int,
      format: format == freezed ? _value.format : format as String,
      values: values == freezed ? _value.values : values as Map<int, dynamic>,
    ));
  }
}

/// @nodoc
abstract class _$APIFieldCopyWith<$Res> implements $APIFieldCopyWith<$Res> {
  factory _$APIFieldCopyWith(_APIField value, $Res Function(_APIField) then) =
      __$APIFieldCopyWithImpl<$Res>;
  @override
  $Res call(
      {String name,
      String type,
      int bitmask,
      String maskField,
      String sensor,
      int rangeBottom,
      int rangeTop,
      String units,
      int mask,
      int from,
      int to,
      String format,
      Map<int, dynamic> values});
}

/// @nodoc
class __$APIFieldCopyWithImpl<$Res> extends _$APIFieldCopyWithImpl<$Res>
    implements _$APIFieldCopyWith<$Res> {
  __$APIFieldCopyWithImpl(_APIField _value, $Res Function(_APIField) _then)
      : super(_value, (v) => _then(v as _APIField));

  @override
  _APIField get _value => super._value as _APIField;

  @override
  $Res call({
    Object name = freezed,
    Object type = freezed,
    Object bitmask = freezed,
    Object maskField = freezed,
    Object sensor = freezed,
    Object rangeBottom = freezed,
    Object rangeTop = freezed,
    Object units = freezed,
    Object mask = freezed,
    Object from = freezed,
    Object to = freezed,
    Object format = freezed,
    Object values = freezed,
  }) {
    return _then(_APIField(
      name: name == freezed ? _value.name : name as String,
      type: type == freezed ? _value.type : type as String,
      bitmask: bitmask == freezed ? _value.bitmask : bitmask as int,
      maskField: maskField == freezed ? _value.maskField : maskField as String,
      sensor: sensor == freezed ? _value.sensor : sensor as String,
      rangeBottom:
          rangeBottom == freezed ? _value.rangeBottom : rangeBottom as int,
      rangeTop: rangeTop == freezed ? _value.rangeTop : rangeTop as int,
      units: units == freezed ? _value.units : units as String,
      mask: mask == freezed ? _value.mask : mask as int,
      from: from == freezed ? _value.from : from as int,
      to: to == freezed ? _value.to : to as int,
      format: format == freezed ? _value.format : format as String,
      values: values == freezed ? _value.values : values as Map<int, dynamic>,
    ));
  }
}

/// @nodoc
class _$_APIField implements _APIField {
  const _$_APIField(
      {this.name,
      this.type,
      this.bitmask,
      this.maskField,
      this.sensor,
      this.rangeBottom,
      this.rangeTop,
      this.units,
      this.mask,
      this.from,
      this.to,
      this.format,
      this.values});

  @override
  final String name;
  @override
  final String type;
  @override
  final int bitmask;
  @override
  final String maskField;
  @override
  final String sensor;
  @override
  final int rangeBottom;
  @override
  final int rangeTop;
  @override
  final String units;
  @override
  final int mask;
  @override
  final int from;
  @override
  final int to;
  @override
  final String format;
  @override
  final Map<int, dynamic> values;

  @override
  String toString() {
    return 'APIField(name: $name, type: $type, bitmask: $bitmask, maskField: $maskField, sensor: $sensor, rangeBottom: $rangeBottom, rangeTop: $rangeTop, units: $units, mask: $mask, from: $from, to: $to, format: $format, values: $values)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _APIField &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.bitmask, bitmask) ||
                const DeepCollectionEquality()
                    .equals(other.bitmask, bitmask)) &&
            (identical(other.maskField, maskField) ||
                const DeepCollectionEquality()
                    .equals(other.maskField, maskField)) &&
            (identical(other.sensor, sensor) ||
                const DeepCollectionEquality().equals(other.sensor, sensor)) &&
            (identical(other.rangeBottom, rangeBottom) ||
                const DeepCollectionEquality()
                    .equals(other.rangeBottom, rangeBottom)) &&
            (identical(other.rangeTop, rangeTop) ||
                const DeepCollectionEquality()
                    .equals(other.rangeTop, rangeTop)) &&
            (identical(other.units, units) ||
                const DeepCollectionEquality().equals(other.units, units)) &&
            (identical(other.mask, mask) ||
                const DeepCollectionEquality().equals(other.mask, mask)) &&
            (identical(other.from, from) ||
                const DeepCollectionEquality().equals(other.from, from)) &&
            (identical(other.to, to) ||
                const DeepCollectionEquality().equals(other.to, to)) &&
            (identical(other.format, format) ||
                const DeepCollectionEquality().equals(other.format, format)) &&
            (identical(other.values, values) ||
                const DeepCollectionEquality().equals(other.values, values)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(bitmask) ^
      const DeepCollectionEquality().hash(maskField) ^
      const DeepCollectionEquality().hash(sensor) ^
      const DeepCollectionEquality().hash(rangeBottom) ^
      const DeepCollectionEquality().hash(rangeTop) ^
      const DeepCollectionEquality().hash(units) ^
      const DeepCollectionEquality().hash(mask) ^
      const DeepCollectionEquality().hash(from) ^
      const DeepCollectionEquality().hash(to) ^
      const DeepCollectionEquality().hash(format) ^
      const DeepCollectionEquality().hash(values);

  @override
  _$APIFieldCopyWith<_APIField> get copyWith =>
      __$APIFieldCopyWithImpl<_APIField>(this, _$identity);
}

abstract class _APIField implements APIField {
  const factory _APIField(
      {String name,
      String type,
      int bitmask,
      String maskField,
      String sensor,
      int rangeBottom,
      int rangeTop,
      String units,
      int mask,
      int from,
      int to,
      String format,
      Map<int, dynamic> values}) = _$_APIField;

  @override
  String get name;
  @override
  String get type;
  @override
  int get bitmask;
  @override
  String get maskField;
  @override
  String get sensor;
  @override
  int get rangeBottom;
  @override
  int get rangeTop;
  @override
  String get units;
  @override
  int get mask;
  @override
  int get from;
  @override
  int get to;
  @override
  String get format;
  @override
  Map<int, dynamic> get values;
  @override
  _$APIFieldCopyWith<_APIField> get copyWith;
}
