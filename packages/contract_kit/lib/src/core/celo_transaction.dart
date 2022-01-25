import 'dart:typed_data';

import 'package:web3dart/web3dart.dart';

/// [CeloTransaction] is similar to an Eth [Transaction] but with three extra fields:
/// namely, [feeCurrency], [gateWayFeeRecipient], and [gatewayFee].
class CeloTransaction extends Transaction {
  final String? feeCurrency;
  final String? gatewayFeeRecipient;
  final String? gatewayFee;

  CeloTransaction({
    EthereumAddress? to,
    EtherAmount? value,
    int? nonce,
    EtherAmount? gasPrice,
    EtherUnit? gasLimit,
    Uint8List? data,
    EthereumAddress? from,
    EtherAmount? maxPriorityFeePerGas,
    EtherAmount? maxFeePerGas,
    this.feeCurrency,
    this.gatewayFeeRecipient,
    this.gatewayFee,
  }) : super(
          to: to,
          value: value,
          nonce: nonce,
          gasPrice: gasPrice,
          data: data,
          from: from,
          maxPriorityFeePerGas: maxPriorityFeePerGas,
          maxFeePerGas: maxFeePerGas,
        );

  CeloTransaction.callContract({
    required DeployedContract contract,
    required ContractFunction function,
    required List<dynamic> parameters,
    required EtherAmount value,
    required int nonce,
    required EtherAmount gasPrice,
    EthereumAddress? from,
    EtherAmount? maxPriorityFeePerGas,
    EtherAmount? maxFeePerGas,
    this.feeCurrency,
    this.gatewayFeeRecipient,
    this.gatewayFee,
  }) : super(
          to: contract.address,
          data: function.encodeCall(parameters),
        );

  @override
  CeloTransaction copyWith({
    EthereumAddress? from,
    EthereumAddress? to,
    int? maxGas,
    EtherAmount? gasPrice,
    EtherAmount? value,
    Uint8List? data,
    int? nonce,
    EtherAmount? maxPriorityFeePerGas,
    EtherAmount? maxFeePerGas,
    String? feeCurrency,
    String? gatewayFeeRecipient,
    String? gatewayFee,
  }) {
    return CeloTransaction(
      to: to ?? this.to,
      value: value ?? this.value,
      nonce: nonce ?? this.nonce,
      gasPrice: gasPrice ?? this.gasPrice,
      data: data ?? this.data,
      from: from ?? this.from,
      maxPriorityFeePerGas: maxPriorityFeePerGas ?? this.maxPriorityFeePerGas,
      maxFeePerGas: maxFeePerGas ?? this.maxFeePerGas,
      feeCurrency: feeCurrency ?? this.feeCurrency,
      gatewayFeeRecipient: gatewayFeeRecipient ?? this.gatewayFeeRecipient,
      gatewayFee: gatewayFee ?? this.gatewayFee,
    );
  }

  @override
  bool get isEIP1559 => maxFeePerGas != null && maxPriorityFeePerGas != null;
}
