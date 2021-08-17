part of 'package:web3dart/web3dart.dart';


/// Ethereum Address
/// ignore: unused_element
class _Address {
  /// Internal string representation of the address (with leading 0x)
  final String _address;

  /// _Address
  _Address(this._address);

  /// Encode the address as a 20 byte Uint8List
  Uint8List toBytes() {
    return Uint8List.fromList(hex.decode(_address.substring(2)))
      ..sublist(0, 20);
  }

  @override
  String toString() {
    return _address;
  }
}

var _byteMask = BigInt.from(0xff);

/// Decode a BigInt from bytes in big-endian encoding.
BigInt decodeBigInt(Uint8List bytes) {
  var result = BigInt.from(0);
  for (var i = 0; i < bytes.length; i++) {
    result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
  }
  return result;
}

/// Encode a BigInt into bytes using big-endian encoding.
Uint8List encodeBigInt(BigInt number) {
  // Not handling negative numbers. Decide how you want to do that.
  final size = (number.bitLength + 7) >> 3;
  final result = Uint8List(size);
  for (var i = 0; i < size; i++) {
    result[size - i - 1] = (number & _byteMask).toInt();
    number = number >> 8;
  }
  return result;
}

/// RLP Recursive Length Prefix (Encoder only)
class Rlp {
  static Uint8List _maybeEncodeLength(Uint8List input) {
    if (input.length == 1 && input.first < 0x80) {
      return input;
    } else {
      return mergeAsUint8List(_encodeLength(input.length, 0x80), input);
    }
  }

  static Uint8List _encodeNonListType(dynamic input) {
    if (input is _Address) {
      return input.toBytes();
    }

    if (input is String) {
      return Uint8List.fromList(input.codeUnits);
    }

    if (input is int) {
      return encodeInt(input);
    }

    if (input is BigInt) {
      return encodeBigInt(input);
    }

    throw 'Invalid Input Type';
  }

  static Uint8List _encodeLength(int len, int offset) {
    if (len < 56) {
      return Uint8List.fromList([len + offset]);
    } else {
      final binary = _toBinary(len);
      return mergeAsUint8List([binary.length + offset + 55], binary);
    }
  }

  static Uint8List _toBinary(int x) {
    if (x == 0) {
      return Uint8List(0);
    } else {
      return mergeAsUint8List(_toBinary(x ~/ 256), [x % 256]);
    }
  }

  /// Encodes the input as a Uint8List
  static Uint8List encode(dynamic input) {
    if (input is List) {
      final output = BytesBuilder();
      input.forEach((i) {
        return output.add(encode(i));
      });
      return mergeAsUint8List(
          _encodeLength(output.length, 0xc0), output.toBytes());
    }

    return Rlp._maybeEncodeLength(Rlp._encodeNonListType(input));
  }
}

/// Converts an integer into a hex string
String _intToHex(int i) {
  final hexStr = i.toRadixString(16);
  return hexStr.length % 2 == 0 ? hexStr : '0$hexStr';
}

/// Merge/Concatentate two Lists as a Uint8List
Uint8List mergeAsUint8List(List<int> a, List<int> b) {
  final output = BytesBuilder();
  output.add(a);
  output.add(b);
  return output.toBytes();
}

/// Encode an int into bytes
Uint8List encodeInt(int i) {
  if (i == 0) {
    return Uint8List(0);
  } else {
    final hexStr = _intToHex(i);
    return Uint8List.fromList(hex.decoder.convert(hexStr));
  }
}
