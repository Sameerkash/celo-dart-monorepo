import 'package:contract_kit/contract_kit.dart';

void main() async {
  // const figmentApiKey = '';
  const privateKey =
      '682f883ada7bbcaf65fc5fd6fc8e372580bbdef043ec814e4b153d698f8c0b51';

  final apiUrl = 'http://localhost:8545';
  //     'https://celo-alfajores--rpc.datahub.figment.io/apikey/$figmentApiKey/';
  await initializeCLient(rpcUrl: apiUrl, privateKey: privateKey);
  await getUserAccount();

  // await createAccount();
}
