import 'package:uuid/uuid.dart';
import '../models/challan.dart';
import '../services/database_service.dart';

/// Helper function to create a pre-filled Deloitte challan
/// Call this from your app to quickly create the challan with all items
Future<Challan> createDeloitteChallan() async {
  final challan = Challan(
    id: const Uuid().v4(),
    challanNumber: DatabaseService.getNextChallanNumber(),
    date: DateTime.now(),
    fromCompany: 'Biryani By Flame (Fyro Foods)',
    toCompany: 'Hungerox',
    deliveryAddress:
        'Deloitte India, DLF Cyber City Building 10B, 7th Floor, Gurgaon, Haryana, 122002',
    items: [
      ChallanItem(description: 'Handi', quantity: 2, unit: 'pcs'),
      ChallanItem(description: 'Pan', quantity: 2, unit: 'pcs'),
      ChallanItem(description: 'Pan wale spoon', quantity: 3, unit: 'pcs'),
      ChallanItem(description: 'Handi spoon', quantity: 2, unit: 'pcs'),
      ChallanItem(description: 'Chopping board', quantity: 1, unit: 'pcs'),
      ChallanItem(description: 'Chaku (Knife)', quantity: 2, unit: 'pcs'),
      ChallanItem(description: 'Box', quantity: 15, unit: 'pcs'),
      ChallanItem(
          description: 'Gulab jamun container', quantity: 1, unit: 'pcs'),
      ChallanItem(
          description: 'Double ka meetha container', quantity: 1, unit: 'pcs'),
      ChallanItem(
        description: 'Bottles (kevda water, rose water, ghee)',
        quantity: 6,
        unit: 'pcs',
      ),
      ChallanItem(description: '350 ml container', quantity: 25, unit: 'pcs'),
      ChallanItem(description: '750 ml container', quantity: 30, unit: 'pcs'),
      ChallanItem(description: '1000 ml container', quantity: 20, unit: 'pcs'),
      ChallanItem(description: '100 ml container', quantity: 50, unit: 'pcs'),
      ChallanItem(description: 'Tissue paper', quantity: 5, unit: 'packets'),
      ChallanItem(description: 'Carry bag', quantity: 50, unit: 'pcs'),
      ChallanItem(description: 'Microwave', quantity: 2, unit: 'pcs'),
      ChallanItem(description: 'Electric board', quantity: 2, unit: 'pcs'),
      ChallanItem(description: 'Microwave bowl', quantity: 1, unit: 'pcs'),
    ],
    remarks:
        'Equipment and supplies for biryani stall setup at Deloitte India office',
    createdAt: DateTime.now(),
  );

  // Save to database
  await DatabaseService.saveChallan(challan);

  return challan;
}
