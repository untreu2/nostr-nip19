# nostr_nip19

> A Dart library for encoding and decoding Nostr [NIP-19](https://github.com/nostr-protocol/nips/blob/master/19.md) identifiers using Bech32.

This package provides easy-to-use utilities to encode and decode Nostr keys and identifiers such as `npub`, `nsec`, `note`, `nprofile`, and `nevent` using the Bech32 format.

## Features

- Encode hex strings into NIP-19 Bech32 formats (`npub`, `nsec`, `note`)
- Decode Bech32 strings back into raw hex format
- Decode TLV-based Bech32 identifiers (`nprofile`, `nevent`)

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  nostr_nip19: ^0.1.0
```

Then run:

```bash
dart pub get
```

---

## Usage

### Import the library

```dart
import 'package:nostr_nip19/nostr_nip19.dart';
```

### Decode basic identifiers

```dart
final pubkeyHex = decodeBasicBech32("npub1...", "npub");
final privkeyHex = decodeBasicBech32("nsec1...", "nsec");
final noteIdHex = decodeBasicBech32("note1...", "note");
```

### Encode hex to NIP-19 formats

```dart
final npub = encodeBasicBech32("<64-char-hex>", "npub");
final nsec = encodeBasicBech32("<64-char-hex>", "nsec");
final note = encodeBasicBech32("<64-char-hex>", "note");
```

### Decode `nprofile`

```dart
final result = decodeTlvBech32Full("nprofile1...");
print(result["type_0_main"]); // hex pubkey
print(result["relays"]);      // list of relay URLs
```

### Decode `nevent`

```dart
final result = decodeTlvBech32Full("nevent1...");
print(result["type_0_main"]); // hex event id
print(result["relays"]);      // list of relay URLs
print(result["author"]);      // author pubkey (if available)
print(result["kind"]);        // event kind (if available)
```

---

## CLI Tool (optional)

You can run the built-in CLI tool:

```bash
dart run bin/nostr-nip19.dart
```
