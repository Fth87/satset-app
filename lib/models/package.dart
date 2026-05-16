enum PackageStatus { pending, clarification, delivered }
enum UserRole { courier, dispatcher }

class DeliveryPackage {
  const DeliveryPackage({
    required this.id,
    required this.recipient,
    required this.address,
    required this.status,
    required this.priority,
    required this.eta,
    required this.confidence,
    required this.cluster,
    this.phone,
  });

  final String id;
  final String recipient;
  final String address;
  final PackageStatus status;
  final String priority;
  final String eta;
  final int confidence;
  final String cluster;
  final String? phone;
}

class OperatorProfile {
  const OperatorProfile({
    required this.name,
    required this.id,
    required this.zone,
    required this.vehicle,
    required this.role,
  });

  final String name;
  final String id;
  final String zone;
  final String vehicle;
  final UserRole role;
}

class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });

  final String sender;
  final String text;
  final String time;
}
