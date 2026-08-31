class InvitationEntity {
  final String id;
  final String invitationCode;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  const InvitationEntity({
    required this.id,
    required this.invitationCode,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
}
