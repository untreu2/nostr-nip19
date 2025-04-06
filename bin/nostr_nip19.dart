import 'dart:io';
import 'package:nostr_nip19/nostr_nip19.dart';

void main() {
  print("Supported formats:");
  print(" - Decode: npub, nsec, note, nprofile, nevent");
  print(" - Encode: hex → npub / nsec / note");

  stdout.write("Enter a bech32 string or 64-char hex key: ");
  String? userInput = stdin.readLineSync()?.trim();

  if (userInput == null || userInput.isEmpty) {
    print("No input provided.");
    return;
  }

  try {
    if (userInput.startsWith("npub")) {
      print(
        "→ Decoded Public Key (hex): ${decodeBasicBech32(userInput, "npub")}",
      );
    } else if (userInput.startsWith("nsec")) {
      print(
        "→ Decoded Private Key (hex): ${decodeBasicBech32(userInput, "nsec")}",
      );
    } else if (userInput.startsWith("note")) {
      print("→ Decoded Note ID (hex): ${decodeBasicBech32(userInput, "note")}");
    } else if (userInput.startsWith("nprofile")) {
      Map<String, dynamic> result = decodeTlvBech32Full(userInput, "nprofile");
      print("→ Decoded nprofile:");
      print("  pubkey (type 0): ${result["type_0_main"]}");
      for (var relay in result["relays"]) {
        print("  relay (type 1): $relay");
      }
    } else if (userInput.startsWith("nevent")) {
      Map<String, dynamic> result = decodeTlvBech32Full(userInput, "nevent");
      print("→ Decoded nevent:");
      print("  event id (type 0): ${result["type_0_main"]}");
      for (var relay in result["relays"]) {
        print("  relay (type 1): $relay");
      }
      if (result["author"] != null) {
        print("  author pubkey (type 2): ${result["author"]}");
      }
      if (result["kind"] != null) {
        print("  kind (type 3): ${result["kind"]}");
      }
    } else if (userInput.length == 64) {
      stdout.write("Convert to which format? (npub/nsec/note): ");
      String? target = stdin.readLineSync()?.trim().toLowerCase();
      if (target != null &&
          (target == "npub" || target == "nsec" || target == "note")) {
        print("→ Encoded $target: ${encodeBasicBech32(userInput, target)}");
      } else {
        print("Unsupported target format.");
      }
    } else {
      print("Unrecognized input.");
    }
  } catch (e) {
    print("Error: $e");
  }
}
