part of 'package:web3dart/web3dart.dart';

class _SigningInput {
  _SigningInput(
      {required this.transaction, required this.credentials, this.chainId});

  final Transaction transaction;
  final Credentials credentials;
  final int? chainId;
}

Future<_SigningInput> _fillMissingData({
  required Credentials credentials,
  required Transaction transaction,
  int? chainId,
  bool loadChainIdFromNetwork = false,
  Web3Client? client,
}) async {
  if (loadChainIdFromNetwork && chainId != null) {
    throw ArgumentError(
        "You can't specify loadChainIdFromNetwork and specify a custom chain id!");
  }

  final sender = transaction.from ?? await credentials.extractAddress();
  var gasPrice = transaction.gasPrice;
  var nonce = transaction.nonce;
  if (gasPrice == null || nonce == null) {
    if (client == null) {
      throw ArgumentError("Can't find suitable gas price and nonce from client "
          'because no client is set. Please specify a gas price on the '
          'transaction.');
    }
    gasPrice ??= await client.getGasPrice();
    nonce ??= await client.getTransactionCount(sender,
        atBlock: const BlockNum.pending());
  }

  // final gateWayFee = transaction.gateWayFee ?? 0;

  // final gatewayFeeRecipient = transaction.gatewayFeeRecipient ?? '0';

  // final feeCurrency =
  //     transaction.feeCurrency ?? '0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1';

  final maxGas = transaction.maxGas ??
      await client!
          .estimateGas(
            sender: sender,
            to: transaction.to,
            data: transaction.data,
            value: transaction.value,
            gasPrice: gasPrice,
          )
          .then((bigInt) => bigInt.toInt());

  // apply default values to null fields
  final modifiedTransaction = transaction.copyWith(
      value: transaction.value ?? EtherAmount.zero(),
      maxGas: maxGas,
      from: sender,
      data: transaction.data ?? Uint8List(0),
      gasPrice: gasPrice,
      nonce: nonce,
      // gateWayFee: gateWayFee,
      // gatewayFeeRecipient: gatewayFeeRecipient,
      // feeCurrency: feeCurrency
      );

  int resolvedChainId;
  if (!loadChainIdFromNetwork) {
    resolvedChainId = chainId!;
  } else {
    if (client == null) {
      throw ArgumentError(
          "Can't load chain id from network when no client is set");
    }

    resolvedChainId = await client.getNetworkId();
  }

  return _SigningInput(
    transaction: modifiedTransaction,
    credentials: credentials,
    chainId: resolvedChainId,
  );
}

Future<Uint8List> _signTransaction(
    Transaction transaction, Credentials c, int? chainId) async {
  final innerSignature =
      chainId == null ? null : MsgSignature(BigInt.zero, BigInt.zero, chainId);

  final encoded =
      uint8ListFromList(rlp.encode(_encodeToRlp(transaction, innerSignature)));
  final signature = await c.signToSignature(encoded, chainId: chainId);
  final hash =
      uint8ListFromList(rlp.encode(_encodeToRlp(transaction, signature)));

  print('''
    nonce: ${transaction.nonce},
    gasPrice:  ${transaction.gasPrice},
    gas:  ${transaction.maxGas},
    to:  ${transaction.to},
    value:  ${transaction.value},
    feeCurrency:  ${transaction.feeCurrency},
    gatewayFeeRecipient:  ${transaction.gatewayFeeRecipient},
    gatewayFee:  ${transaction.gateWayFee},
    v:  ${intToHex(signature.v)},
    r: ${bigIntToHex(signature.r)},
    s: ${bigIntToHex(signature.s)},
    raw : ${bytesToHex(hash)}
  ''');

  return Uint8List.fromList([1, 2, 3]);
}

List<dynamic> _encodeToRlp(Transaction transaction, MsgSignature? signature) {
  final list = [
    transaction.nonce,
    transaction.gasPrice?.getInWei,
    transaction.maxGas,
    // transaction.feeCurrency,
    // transaction.gatewayFeeRecipient,
    // transaction.gateWayFee,
  ];

  if (transaction.to != null) {
    list.add(transaction.to!.addressBytes);
  } else {
    list.add('');
  }

  list..add(transaction.value?.getInWei)..add(transaction.data);

  if (signature != null) {
    list..add(signature.v)..add(signature.r)..add(signature.s);
  }

  return list;
}

Future<Uint8List> signCeloTransaction(
    Transaction transaction, Credentials c, int? chainId) async {
  final innerSignature =
      chainId == null ? null : MsgSignature(BigInt.zero, BigInt.zero, chainId);

  final rawTx = encodeRlp(transaction, chainId!, innerSignature);
  final encodeChainId = chainIdTransformationForSigning(chainId);

  final signature = await c.signToSignature(rawTx, chainId: encodeChainId);
  final result = encodeRlp(transaction, chainId, signature);

  final hash = getHashFromEncoded(rawTx);

  print('''
    nonce: ${transaction.nonce},
    gasPrice:  ${transaction.gasPrice},
    gas:  ${transaction.maxGas},
    to:  ${transaction.to},
    value:  ${transaction.value},
    feeCurrency:  ${transaction.feeCurrency},
    gatewayFeeRecipient:  ${transaction.gatewayFeeRecipient},
    gatewayFee:  ${transaction.gateWayFee},
    v:  ${intToHex(signature.v)},
    r: ${bigIntToHex(signature.r)},
    s: ${bigIntToHex(signature.s)},
    hash : ${bytesToHex(hash)}
    raw : ${bytesToHex(rawTx)}
  ''');
  return result;
}

Uint8List encodeRlp(
    Transaction transaction, int chainId, MsgSignature? innerSignature) {
  final tx = [
    transaction.nonce,
    transaction.gasPrice?.getInWei,
    transaction.maxGas,
    transaction.feeCurrency,
    transaction.gatewayFeeRecipient,
    transaction.gateWayFee,
    transaction.value?.getInWei,
    transaction.data,
    intToHex(chainId),
    '0x',
    '0x',
  ];

  if (innerSignature != null) {
    tx..add(innerSignature.v)..add(innerSignature.r)..add(innerSignature.s);
  }

  final rlpEncoded = Rlp.encode(tx);

  return rlpEncoded;
}

int chainIdTransformationForSigning(int chainId) => chainId * 2 + 35;

Uint8List getHashFromEncoded(Uint8List rlpEncoded) => keccak256(rlpEncoded);

/*
const encode = tree => {
  const padEven = str => str.length % 2 === 0 ? str : "0" + str;

  const uint = num => padEven(num.toString(16));

  const length = (len, add) => len < 56 ? uint(add + len) : uint(add + uint(len).length / 2 + 55) + uint(len);

  const dataTree = tree => {
    if (typeof tree === "string") {
      const hex = tree.slice(2);
      const pre = hex.length != 2 || hex >= "80" ? length(hex.length / 2, 128) : "";
      return pre + hex;
    } else {
      const hex = tree.map(dataTree).join("");
      const pre = length(hex.length / 2, 192);
      return pre + hex;
    }
  };

  return "0x" + dataTree(tree);
};
*/

String padEven(String str) => str.length % 2 == 0 ? str : '0$str';

String uint(num number) => padEven(intToHex(number));

String length(int len, int add) => len < 56
    ? uint(add + len)
    : uint(add + uint(len).length / 2 + 55) + uint(len);

String encode(dynamic tree) {
  String data(dynamic tree) {
    if (tree is String) {
      final hex = tree.substring(0, 2);

      final pre = hex.length != 2 || int.tryParse(hex)! >= int.parse('80')
          ? length(hex.length ~/ 2, 128)
          : '';

      return pre + hex;
    } else {
      final hex = tree.map(encode).join('');
      final pre = length(hex.length ~/ 2 as int, 192);

      return hex + pre as String;
    }
  }

  return '0x ${data(tree)}';
}
