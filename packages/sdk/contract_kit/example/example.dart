import 'package:contract_kit/contract_kit.dart';

void main() async {
  // const figmentApiKey = '';
  const privateKey =
      // to
      // '0x1f2c1dcebff6161f16a9d7fd3525fa601a11ef00539616e5e4049c29c73c2c43';
      // from
      'bc5e0fa74788d3a1b3f90fcc30d828d4d349a676ab013fe1cd2a78adbea4cf1e';

  final apiUrl = 'https://alfajores-forno.celo-testnet.org';
  // 'http://localhost:8545';
  //     'https://celo-alfajores--rpc.datahub.figment.io/apikey/$figmentApiKey/';
  await initializeCLient(rpcUrl: apiUrl, privateKey: privateKey);

  await getUserAccount();

  // await createAccount();

  // await makeTransaction(address: '0x3e87A98897E8Fae0b31B03d3216952140D82b3DE');
}


/// add additional Transation parameters
/// RPC Methods for cUSD, cEUR
///







/*
0x710dfbd8742744aa1312135cddf921ebfb7cc0f2
EtherAmount: 0 wei
EtherAmount: 500000000 wei
0

After funding
(base) sameerkashyap@Sam-MacBook-Pro example % dart celo_connect_example.dart
0x710dfbd8742744aa1312135cddf921ebfb7cc0f2
EtherAmount: 5000000000000000000 wei
EtherAmount: 500000000 wei


*/