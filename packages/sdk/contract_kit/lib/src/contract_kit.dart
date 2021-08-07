import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';

late Credentials credentials;
late Web3Client ethClient;
late Client client;

Future<void> initializeCLient(
    {required String rpcUrl, required String privateKey}) async {
  client = Client();
  ethClient = Web3Client(rpcUrl, client);

  credentials = await ethClient.credentialsFromPrivateKey(privateKey);
}

Future<void> getUserAccount() async {
  final myAddress = await credentials.extractAddress();
  final balance = await ethClient.getBalance(myAddress);
  final gasPrice = await ethClient.getGasPrice();
  final tx = await ethClient.getTransactionCount(myAddress);
  print(myAddress);
  print(balance);
  print(gasPrice);
  print(tx);
}

Future<void> createAccount() async {
  var rng = Random.secure();
  final account = EthPrivateKey.createRandom(rng);

  final pk = bytesToHex(account.privateKey);
  print('Account Adress : ${account.address}');
  print('PrivateKey : ' + pk);
}

Future<void> makeTransaction() async {
  await ethClient.sendTransaction(
    credentials,
    Transaction(
      to: EthereumAddress.fromHex('0xC91...3706'),
      gasPrice: EtherAmount.inWei(BigInt.one),
      maxGas: 100000,
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
    ),
  );
}
