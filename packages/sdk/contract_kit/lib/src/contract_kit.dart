import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
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
  final balance = await ethClient.getBalance(
      EthereumAddress.fromHex('0x874069fa1eb16d44d622f2e0ca25eea172369bc1'));
  final gasPrice = await ethClient.getGasPrice();
  final tx = await ethClient.getTransactionCount(myAddress);
  print('Address :  $myAddress');
  print(balance);
  print(gasPrice);
  print(tx);
}

Future<void> createAccount() async {
  var rng = Random.secure();
  final account = EthPrivateKey.createRandom(rng);

  final pk = bytesToHex(account.privateKey);
  print('Account Adress : ${account.address}');
  print('Private Key : ' + pk);
}

Future<void> makeTransaction({required String address}) async {
  await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(address),
        gasPrice: EtherAmount.inWei(BigInt.parse('5000000000')),
        maxGas: 1000000,
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
      ),
      chainId: 44787);
}



//0x5A5057f59546f319fB7c21B3FA2Bd5e5a5E7c535