import 'response.dart';

final RES_PARSER = {
  "0:2": APIV1(
    desc: "Get Version",
    did: 0x00,
    cid: 0x02,
    event: "version",
    fields: [
      APIField(name: "recv", type: "number", from: 0, to: 1),
      APIField(name: "mdl", type: "number", from: 1, to: 2),
      APIField(name: "hw", type: "number", from: 2, to: 3),
      APIField(name: "msaVer", type: "number", from: 3, to: 4),
      APIField(name: "msaRev", type: "number", from: 4, to: 5),
      APIField(name: "bl", type: "number", format: "hex", from: 5, to: 6),
      APIField(name: "bas", type: "number", format: "hex", from: 6, to: 7),
      APIField(name: "macro", type: "number", format: "hex", from: 7, to: 8),
      APIField(name: "apiMaj", type: "number", from: 8, to: 9),
      APIField(name: "apiMin", type: "number", from: 9, to: 10),
    ],
  ),
  "0:11": APIV1(
    desc: "Get Bluetooth Info",
    did: 0x00,
    cid: 0x11,
    event: "bluetoothInfo",
    fields: [
      APIField(name: "name", type: "string", format: "ascii", from: 0, to: 16),
      APIField(
          name: "btAddress", type: "string", format: "ascii", from: 16, to: 28),
      APIField(name: "separator", type: "number", from: 28, to: 29),
      APIField(name: "colors", type: "number", format: "hex", from: 29, to: 32)
    ],
  ),
  "0:13": APIV1(
    desc: "Get Auto-reconnect Info",
    did: 0x00,
    cid: 0x13,
    event: "autoReconnectInfo",
    fields: [
      APIField(name: "flag", type: "number", from: 0, to: 1),
      APIField(name: "time", type: "number", from: 1, to: 2),
    ],
  ),
  "0:20": APIV1(
      desc: "Get Power State Info",
      did: 0x00,
      cid: 0x20,
      event: "powerStateInfo",
      fields: [
        APIField(name: "recVer", type: "number", from: 0, to: 1),
        APIField(
            name: "batteryState",
            type: "predefined",
            from: 1,
            to: 2,
            values: {
              0x01: "Battery Charging",
              0x02: "Battery OK",
              0x03: "Battery Low",
              0x04: "Battery Critical"
            }),
        APIField(name: "batteryVoltage", type: "number", from: 2, to: 4),
        APIField(name: "chargeCount", type: "number", from: 4, to: 6),
        APIField(name: "secondsSinceCharge", type: "number", from: 6, to: 8)
      ]),
  "0:23": APIV1(
      desc: "Get Voltage Trip Points",
      did: 0x00,
      cid: 0x23,
      event: "voltageTripPoints",
      fields: [
        APIField(name: "vLow", type: "number", from: 0, to: 2),
        APIField(name: "vCrit", type: "number", from: 2, to: 4)
      ]),
  "0:41": APIV1(
      desc: "Level 2 Diagnostics",
      did: 0x00,
      cid: 0x41,
      event: "level2Diagnostics",
      fields: [
        APIField(name: "recVer", type: "number", from: 0, to: 2),
        APIField(name: "rxGood", type: "number", from: 3, to: 7),
        APIField(name: "rxBadDID", type: "number", from: 7, to: 11),
        APIField(name: "rxBadDlen", type: "number", from: 11, to: 15),
        APIField(name: "rxBadCID", type: "number", from: 15, to: 19),
        APIField(name: "rxBadCheck", type: "number", from: 19, to: 23),
        APIField(name: "rxBufferOvr", type: "number", from: 23, to: 27),
        APIField(name: "txMsg", type: "number", from: 27, to: 31),
        APIField(name: "txBufferOvr", type: "number", from: 31, to: 35),
        APIField(name: "lastBootReason", type: "number", from: 35, to: 36),
        APIField(
            name: "bootCounters",
            type: "number",
            format: "hex",
            from: 36,
            to: 68),
        APIField(name: "chargeCount", type: "number", from: 70, to: 72),
        APIField(name: "secondsSinceCharge", type: "number", from: 72, to: 74),
        APIField(name: "secondsOn", type: "number", from: 74, to: 78),
        APIField(name: "distanceRolled", type: "number", from: 78, to: 82),
        APIField(name: "sensorFailures", type: "number", from: 82, to: 84),
        APIField(name: "gyroAdjustCount", type: "number", from: 84, to: 88)
      ]),
  "0:51": APIV1(
      desc: "Poll Packet Times",
      did: 0x00,
      cid: 0x51,
      event: "packetTimes",
      fields: [
        APIField(name: "t1", type: "number", from: 0, to: 4),
        APIField(name: "t2", type: "number", from: 4, to: 8),
        APIField(name: "t3", type: "number", from: 8, to: 12)
      ]),
  "2:7": APIV1(
      desc: "Get Chassis Id",
      did: 0x02,
      cid: 0x07,
      event: "chassisId",
      fields: [
        APIField(
          name: "chassisId",
          type: "number",
        )
      ]),
  "2:15": APIV1(
      desc: "Read Locator",
      did: 0x02,
      cid: 0x15,
      event: "readLocator",
      fields: [
        APIField(name: "xpos", type: "signed", from: 0, to: 2),
        APIField(name: "ypos", type: "signed", from: 2, to: 4),
        APIField(name: "xvel", type: "number", from: 4, to: 6),
        APIField(name: "yvel", type: "number", from: 6, to: 8),
        APIField(name: "sog", type: "number", from: 8, to: 10)
      ]),
  "2:22": APIV1(
      desc: "Get RGB LED",
      did: 0x02,
      cid: 0x22,
      event: "rgbLedColor",
      fields: [
        APIField(name: "color", type: "number", format: "hex", from: 0, to: 3),
        APIField(name: "red", type: "number", from: 0, to: 1),
        APIField(name: "green", type: "number", from: 1, to: 2),
        APIField(name: "blue", type: "number", from: 2, to: 3)
      ]),
  "2:36": APIV1(
      desc: "Get Permanent Option Flags",
      did: 0x02,
      cid: 0x36,
      event: "permanentOptionFlags",
      fields: [
        APIField(
            name: "sleepOnCharger",
            type: "predefined",
            mask: 0x01,
            values: {0x00: false, 0x01: true}),
        APIField(
            name: "vectorDrive",
            type: "predefined",
            mask: 0x02,
            values: {0x00: false, 0x02: true}),
        APIField(
            name: "selfLevelOnCharger",
            type: "predefined",
            mask: 0x04,
            values: {0x00: false, 0x04: true}),
        APIField(
            name: "tailLedAlwaysOn",
            type: "predefined",
            mask: 0x08,
            values: {0x00: false, 0x08: true}),
        APIField(
            name: "motionTimeouts",
            type: "predefined",
            mask: 0x10,
            values: {0x00: false, 0x10: true}),
        APIField(
            name: "retailDemoOn",
            type: "predefined",
            mask: 0x20,
            values: {0x00: false, 0x20: true}),
        APIField(
            name: "awakeSensitivityLight",
            type: "predefined",
            mask: 0x40,
            values: {0x00: false, 0x40: true}),
        APIField(
            name: "awakeSensitivityHeavy",
            type: "predefined",
            mask: 0x80,
            values: {0x00: false, 0x80: true}),
        APIField(
            name: "gyroMaxAsyncMsg",
            type: "predefined",
            mask: 0x100,
            values: {0x00: false, 0x100: true})
      ]),
  "2:38": APIV1(
      desc: "Get Temporal Option Flags",
      did: 0x02,
      cid: 0x38,
      event: "temporalOptionFlags",
      fields: [
        APIField(
            name: "stopOnDisconnect",
            type: "predefined",
            mask: 0x01,
            values: {0x00: false, 0x01: true})
      ]),
  "2:44": APIV1(
      desc: "Get Device Mode",
      did: 0x02,
      cid: 0x44,
      event: "deviceMode",
      fields: [
        APIField(
            name: "mode",
            type: "predefined",
            values: {0x00: "Normal", 0x01: "User Hack"})
      ]),
  "2:48": APIV1(
      desc: "Refill Bank",
      did: 0x02,
      cid: 0x48,
      event: "refillBank",
      fields: [
        APIField(name: "coresRemaining", type: "number"),
      ]),
  "2:49": APIV1(
      desc: "Buy Consumable",
      did: 0x02,
      cid: 0x49,
      event: "buyConsumable",
      fields: [
        APIField(name: "qtyRemaining", type: "number", from: 0, to: 1),
        APIField(name: "coresRemaining", type: "number", from: 1, to: 5)
      ]),
  "2:4A": APIV1(
      desc: "Use Consumable",
      did: 0x02,
      cid: 0x4A,
      event: "buyConsumable",
      fields: [
        APIField(name: "id", type: "number", from: 0, to: 1),
        APIField(name: "qtyRemaining", type: "number", from: 1, to: 2)
      ]),
  "2:4B": APIV1(
      desc: "Grant Cores",
      did: 0x02,
      cid: 0x4B,
      event: "grantCores",
      fields: [
        APIField(
          name: "coresRemaining",
          type: "number",
        )
      ]),
  "2:4C": APIV1(desc: "Add XP", did: 0x02, cid: 0x4C, event: "addXp", fields: [
    APIField(
      name: "toNextLevel",
      type: "number",
    )
  ]),
  "2:4D": APIV1(
      desc: "Level up Attr",
      did: 0x02,
      cid: 0x4D,
      event: "levelUpAttr",
      fields: [
        APIField(name: "attrId", type: "number", from: 0, to: 1),
        APIField(name: "attrLevel", type: "number", from: 1, to: 2),
        APIField(name: "attrPtsRemaining", type: "number", from: 2, to: 4)
      ]),
  "2:4E": APIV1(
      desc: "GET PWD SEED",
      did: 0x02,
      cid: 0x4E,
      event: "passwordSeed",
      fields: [APIField(name: "seed", type: "number")]),
  "2:55": APIV1(
      desc: "Abort Macro",
      did: 0x02,
      cid: 0x55,
      event: "abortMacro",
      fields: [
        APIField(name: "id", type: "number", from: 0, to: 1),
        APIField(name: "cmdNum", type: "number", from: 1, to: 3)
      ]),
  "2:56": APIV1(
      desc: "Get Macro Status",
      did: 0x02,
      cid: 0x55,
      event: "macroStatus",
      fields: [
        APIField(name: "idCode", type: "number", from: 0, to: 1),
        APIField(name: "cmdNum", type: "number", from: 1, to: 3)
      ])
};
