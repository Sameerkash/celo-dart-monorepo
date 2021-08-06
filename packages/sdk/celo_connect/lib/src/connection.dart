import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

late Credentials credentials;
late Web3Client ethClient;

Future<void> initializeCLient(
    {required String rpcUrl, required String privateKey}) async {
  final httpClient = Client();
  ethClient = Web3Client(rpcUrl, httpClient);

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
