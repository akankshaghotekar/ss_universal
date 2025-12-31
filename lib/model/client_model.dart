class ClientModel {
  final String clientSrNo;
  final String clientName;

  ClientModel({required this.clientSrNo, required this.clientName});

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientSrNo: json['clientsrno']?.toString() ?? '',
      clientName: json['client_name'] ?? '',
    );
  }
}
