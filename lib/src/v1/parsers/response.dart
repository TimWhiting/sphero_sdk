import 'package:freezed_annotation/freezed_annotation.dart';
part 'response.freezed.dart';

@freezed
class APIV1 with _$APIV1 {
  const factory APIV1({
    required String desc,
    required String event,
    required List<APIField> fields,
    int? did,
    int? cid,
    int? idCode,
  }) = _APIV1;
}

@freezed
class APIField with _$APIField {
  const factory APIField({
    required String name,
    required String type,
    String? format,
    int? bitmask,
    String? units,
    Map<int, dynamic>? values,
    int? mask,
    String? maskField,
    String? sensor,
    int? rangeBottom,
    int? rangeTop,
    @Default(0) int from,
    int? to,
  }) = _APIField;
}
