import 'package:flutter/material.dart';
import '../models/challan.dart';
import '../services/database_service.dart';
import '../services/challan_pdf_service.dart';
import 'create_challan_screen.dart';

class ChallansListScreen extends StatefulWidget {
  const ChallansListScreen({super.key});

  @override
  State<ChallansListScreen> createState() => _ChallansListScreenState();
}

class _ChallansListScreenState extends State<ChallansListScreen> {
  List<Challan> _challans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallans();
  }

  Future<void> _loadChallans() async {
    setState(() {
      _isLoading = true;
    });

    final challans = DatabaseService.getRecentChallans();

    setState(() {
      _challans = challans;
      _isLoading = false;
    });
  }

  Future<void> _deleteChallan(Challan challan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Challan'),
        content:
            Text('Are you sure you want to delete ${challan.challanNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService.deleteChallan(challan.id);
      _loadChallans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challan deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Challans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChallans,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _challans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No challans yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first delivery challan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _challans.length,
                  itemBuilder: (context, index) {
                    final challan = _challans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          challan.challanNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'To: ${challan.toCompany}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Date: ${challan.date.day.toString().padLeft(2, '0')}-${challan.date.month.toString().padLeft(2, '0')}-${challan.date.year}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.blue),
                              onPressed: () async {
                                await ChallanPdfService.shareChallan(challan);
                              },
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.print, color: Colors.green),
                              onPressed: () async {
                                await ChallanPdfService.printChallan(challan);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteChallan(challan),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('From', challan.fromCompany),
                                const Divider(),
                                _buildDetailRow('To', challan.toCompany),
                                const Divider(),
                                _buildDetailRow(
                                    'Address', challan.deliveryAddress),
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text(
                                  'Items:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...challan.items.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${idx + 1}. ',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(item.description),
                                        ),
                                        Text(
                                          '${item.quantity} ${item.unit}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                if (challan.remarks != null &&
                                    challan.remarks!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  _buildDetailRow('Remarks', challan.remarks!),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateChallanScreen(),
            ),
          );
          _loadChallans();
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('New Challan'),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
