import 'dart:typed_data';
import 'types.dart';

class UserIO {
  final CommandEncoder _encode;
  final CommandEncoder _encodeAnimatronics;
  UserIO(CommandGenerator generator)
      : _encode = generator(DeviceId.userIO),
        _encodeAnimatronics = generator(DeviceId.animatronics);
  Command allLEDsRaw(List<int> payload) => _encode(
      CommandPartial(commandId: UserIOCommandIds.allLEDs, payload: payload));
  Command setBackLedIntensity(int i) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x01, i]));
  Command setMainLedBlueIntensity(int b) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x08, b]));
  Command setMainLedColor(int r, int g, int b) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x70, r, g, b]));
  Command setMainLedGreenIntensity(int g) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x04, g]));
  Command setMainLedRedIntensity(int r) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x02, r]));
  Command playAudioFile(int idx) => _encode(CommandPartial(
      commandId: UserIOCommandIds.playAudioFile, payload: [idx, 0x00, 0x00]));
  Command turnDome(Uint8List angle) => _encodeAnimatronics(CommandPartial(
      commandId: AnimatronicsCommandIds.domePosition,
      payload: [angle[1], angle[0], 0x00, 0x00]));
  Command setStance(int stance) => _encodeAnimatronics(CommandPartial(
      commandId: AnimatronicsCommandIds.shoulderAction, payload: [stance]));
  Command playAnimation(int animation) => _encodeAnimatronics(CommandPartial(
      commandId: AnimatronicsCommandIds.animationBundle,
      payload: [0x00, animation]));

  /// Set R2D2 main LED color based on RGB vales (each can range between 0 and 255)
  /// same like front LED color
  Command setR2D2LEDColor(int r, int g, int b) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs,
      payload: [0x00, 0x77, r, g, b, r, g, b]));

  /// Set R2D2 front LED color based on RGB vales (each can range between 0 and 255)
  /// same like main LED color
  Command setR2D2FrontLEDColor(int r, int g, int b) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x07, r, g, b]));

  /// Set R2D2 back LED color based on RGB vales (each can range between 0 and 255)
  Command setR2D2BackLEDcolor(int r, int g, int b) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x70, r, g, b]));

  /// Set R2D2 the holo projector intensity based on 0-255 values
  Command setR2D2HoloProjectorIntensity(int i) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x80, i]));

  /// Set R2D2 the logic displays intensity based on 0-255 values
  Command setR2D2LogicDisplaysIntensity(int i) => _encode(CommandPartial(
      commandId: UserIOCommandIds.allLEDs, payload: [0x00, 0x08, i]));

  /// R2D2 Waddle
  /// R2D2 waddles 3 = start waddle, 0 = stop waddle
  Command setR2D2Waddle(int waddle) => _encodeAnimatronics(CommandPartial(
      commandId: AnimatronicsCommandIds.shoulderAction, payload: [waddle]));
  Command playR2D2Sound(int hex1, int hex2) => _encode(CommandPartial(
      commandId: UserIOCommandIds.playAudioFile, payload: [hex1, hex2, 0x00]));
  Command startIdleLedAnimation() => _encode(
      CommandPartial(commandId: UserIOCommandIds.startIdleLedAnimation));
  Command setAudioVolume(int vol) => _encode(
      CommandPartial(commandId: UserIOCommandIds.audioVolume, payload: [vol]));
}
