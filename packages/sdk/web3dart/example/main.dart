import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const String privateKey =
    'bc5e0fa74788d3a1b3f90fcc30d828d4d349a676ab013fe1cd2a78adbea4cf1e';
const String rpcUrl = 'https://alfajores-forno.celo-testnet.org';

//0x2BA7a50cd197310f2DE7ff990BF51eB0B93c15B9
Future<void> main() async {
  // start a client we can use to send transactions
  final client = Web3Client(rpcUrl, Client());

  final credentials = await client.credentialsFromPrivateKey(privateKey);
  final address = credentials.address;

  print(address.hexEip55);
  print(await client.getBalance(address));

  await client.signTransaction(
    credentials,
    Transaction(
      to: EthereumAddress.fromHex('0x9a8e698171364db8e0F5Fe30f658F233F1347F6a'),
      gasPrice: EtherAmount.inWei(BigInt.parse('5000000000')),
      maxGas: 200000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
      gateWayFee: 1,
      nonce: 1,
      data: Uint8List.fromList([123, 345]),
      gatewayFeeRecipient: '0x0000000000000000000000000000000000000000',
      feeCurrency:
          '0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1', // cUSD Alfajores contract address
    ),
    chainId: 44787,
  );

  // final tx = await client.sendTransaction(
  //   credentials,
  //   Transaction(
  //     to: EthereumAddress.fromHex('0x9a8e698171364db8e0F5Fe30f658F233F1347F6a'),
  //     gasPrice: EtherAmount.inWei(BigInt.parse('5000000000')),
  //     maxGas: 200000,
  //     value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
  //     gateWayFee: 1,
  //     nonce: 1,
  //     data: Uint8List.fromList([123, 345]),
  //     gatewayFeeRecipient: '0x0000000000000000000000000000000000000000',
  //     feeCurrency:
  //         '0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1', // cUSD Alfajores contract address
  //   ),
  //   chainId: 44787,
  // );

  // print('''
  // tx : "$tx"
  // ''');

  await client.dispose();
}
