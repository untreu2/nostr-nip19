import 'dart:convert';
import 'package:bech32/bech32.dart';

String decodeBasicBech32(String value, String expectedPrefix) {
  final codec = Bech32Codec();
  final bech32Data = codec.decode(value, value.length);
  if (bech32Data.hrp != expectedPrefix) {
    throw Exception("Invalid $expectedPrefix format.");
  }
  final decoded = convertBits(bech32Data.data, 5, 8, false);
  if (decoded == null) {
    throw Exception("Invalid $expectedPrefix data.");
  }
  return bytesToHex(decoded);
}

String encodeBasicBech32(String hexstr, String prefix) {
  List<int> keyBytes;
  try {
    keyBytes = hexStringToBytes(hexstr);
  } catch (e) {
    throw Exception("Invalid hex string.");
  }
  final data = convertBits(keyBytes, 8, 5, true);
  if (data == null) {
    throw Exception("Error converting bits.");
  }
  final bech32Data = Bech32(prefix, data);
  final codec = Bech32Codec();
  return codec.encode(bech32Data);
}

Map<String, dynamic> decodeTlvBech32Full(String value, String expectedPrefix) {
  final codec = Bech32Codec();
  final bech32Data = codec.decode(value, value.length);
  if (bech32Data.hrp != expectedPrefix) {
    throw Exception("Invalid $expectedPrefix format.");
  }
  final decoded = convertBits(bech32Data.data, 5, 8, false);
  if (decoded == null) {
    throw Exception("Invalid TLV data.");
  }

  int i = 0;
  Map<String, dynamic> result = {
    "type_0_main": null,
    "relays": <String>[],
    "author": null,
    "kind": null,
  };

  while (i < decoded.length) {
    int t = decoded[i];
    int l = decoded[i + 1];
    List<int> v = decoded.sublist(i + 2, i + 2 + l);

    if (t == 0) {
      result["type_0_main"] = bytesToHex(v);
    } else if (t == 1) {
      try {
        String relay = utf8.decode(v);
        (result["relays"] as List<String>).add(relay);
      } catch (e) {
        (result["relays"] as List<String>).add("<invalid ascii>");
      }
    } else if (t == 2) {
      result["author"] = bytesToHex(v);
    } else if (t == 3) {
      if (l == 4) {
        int kind = 0;
        for (var byte in v) {
          kind = (kind << 8) + byte;
        }
        result["kind"] = kind;
      }
    }
    i += 2 + l;
  }

  if (result["type_0_main"] == null) {
    throw Exception("Missing required TLV type 0.");
  }

  return result;
}

List<int>? convertBits(List<int> data, int fromBits, int toBits, bool pad) {
  int acc = 0;
  int bits = 0;
  final int maxv = (1 << toBits) - 1;
  List<int> ret = [];

  for (var value in data) {
    if (value < 0 || (value >> fromBits) != 0) {
      return null;
    }
    acc = (acc << fromBits) | value;
    bits += fromBits;
    while (bits >= toBits) {
      bits -= toBits;
      ret.add((acc >> bits) & maxv);
    }
  }
  if (pad) {
    if (bits > 0) {
      ret.add((acc << (toBits - bits)) & maxv);
    }
  } else if (bits >= fromBits || ((acc << (toBits - bits)) & maxv) != 0) {
    return null;
  }
  return ret;
}

String bytesToHex(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('');
}

List<int> hexStringToBytes(String hex) {
  if (hex.length % 2 != 0) {
    throw FormatException("Hex string length must be even.");
  }
  List<int> bytes = [];
  for (int i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return bytes;
}
