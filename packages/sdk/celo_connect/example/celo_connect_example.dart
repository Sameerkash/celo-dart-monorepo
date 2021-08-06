import 'package:celo_connect/celo_connect.dart';

void main() async {
  const figmentApiKey = '';
  const privateKey = '';

  final apiUrl =
      'https://celo-alfajores--rpc.datahub.figment.io/apikey/$figmentApiKey/';
  await initializeCLient(rpcUrl: apiUrl, privateKey: privateKey);
  await getUserAccount();
}
