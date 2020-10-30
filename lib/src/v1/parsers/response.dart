import 'package:freezed_annotation/freezed_annotation.dart';
part 'response.freezed.dart';

@freezed
abstract class APIV1 with _$APIV1 {
  const factory APIV1({
    int idCode,
    String desc,
    int did,
    int cid,
    String event,
    List<APIField> fields,
  }) = _APIV1;
}

@freezed
abstract class APIField with _$APIField {
  const factory APIField({
    String name,
    String type,
    int bitmask,
    String maskField,
    String sensor,
    int rangeBottom,
    int rangeTop,
    String units,
    int mask,
    @Default(0) int from,
    @nullable @Default(0) int to,
    String format,
    Map<int, dynamic> values,
  }) = _APIField;
}
