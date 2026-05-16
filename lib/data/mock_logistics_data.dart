import '../models/package.dart';

const mockUser = OperatorProfile(
  name: 'Budi Santoso',
  id: 'C-88291',
  zone: 'Surabaya Selatan',
  vehicle: 'Van - L 1234 XY',
);

const mockPackages = [
  DeliveryPackage(
    id: 'PKG-001',
    recipient: 'Ahmad Yani',
    address: 'Jl. Margorejo Indah No. 12, Surabaya',
    status: PackageStatus.pending,
    priority: 'high',
    eta: '10:30',
    confidence: 98,
    cluster: 'Cluster A',
  ),
  DeliveryPackage(
    id: 'PKG-002',
    recipient: 'Siti Aminah',
    address: 'Jl. Jemursari II/45',
    status: PackageStatus.clarification,
    priority: 'medium',
    eta: '11:15',
    confidence: 45,
    cluster: 'Cluster A',
  ),
  DeliveryPackage(
    id: 'PKG-003',
    recipient: 'Budi Jaya',
    address: 'Rungkut Asri Timur XVIII',
    status: PackageStatus.delivered,
    priority: 'low',
    eta: '09:00',
    confidence: 100,
    cluster: 'Cluster B',
  ),
  DeliveryPackage(
    id: 'PKG-004',
    recipient: 'Diana Sari',
    address: 'Kutisari Selatan No. 8',
    status: PackageStatus.pending,
    priority: 'medium',
    eta: '13:00',
    confidence: 92,
    cluster: 'Cluster C',
  ),
];

const mockChat = [
  ChatMessage(
    sender: 'ai',
    text:
        'Halo Bpk/Ibu Siti, kami dari Smart Logistics. Alamat Jl. Jemursari II/45 kurang lengkap bloknya.',
    time: '08:15',
  ),
  ChatMessage(
    sender: 'customer',
    text: 'Oh iya mas, itu Blok C no 45 ya.',
    time: '08:20',
  ),
  ChatMessage(
    sender: 'ai',
    text: 'Baik, alamat telah diupdate menjadi Jl. Jemursari II Blok C No 45.',
    time: '08:21',
  ),
];
