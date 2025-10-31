import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/challan.dart';
import '../services/database_service.dart';
import '../services/challan_pdf_service.dart';
import '../theme/app_theme.dart';

class CreateChallanScreen extends StatefulWidget {
  const CreateChallanScreen({super.key});

  @override
  State<CreateChallanScreen> createState() => _CreateChallanScreenState();
}

class _CreateChallanScreenState extends State<CreateChallanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromCompanyController = TextEditingController(
    text: 'Biryani By Flame (Fyro Foods)',
  );
  final _toCompanyController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<ChallanItemInput> _items = [];

  @override
  void dispose() {
    _fromCompanyController.dispose();
    _toCompanyController.dispose();
    _deliveryAddressController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(ChallanItemInput());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChallan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate all items
    bool allItemsValid = true;
    for (var item in _items) {
      if (!item.isValid()) {
        allItemsValid = false;
        break;
      }
    }

    if (!allItemsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all item details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final challan = Challan(
      id: const Uuid().v4(),
      challanNumber: DatabaseService.getNextChallanNumber(),
      date: _selectedDate,
      fromCompany: _fromCompanyController.text,
      toCompany: _toCompanyController.text,
      deliveryAddress: _deliveryAddressController.text,
      items: _items
          .map((item) => ChallanItem(
                description: item.descriptionController.text,
                quantity: int.parse(item.quantityController.text),
                unit: item.unitController.text,
              ))
          .toList(),
      remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      createdAt: DateTime.now(),
    );

    await DatabaseService.saveChallan(challan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challan saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Show dialog to preview or print
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Challan Created'),
          content: const Text('What would you like to do?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ChallanPdfService.shareChallan(challan);
              },
              child: const Text('Share PDF'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ChallanPdfService.printChallan(challan);
              },
              child: const Text('Print'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Delivery Challan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChallan,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.orange),
                title: const Text('Challan Date'),
                subtitle: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: 16),

            // From Company
            TextFormField(
              controller: _fromCompanyController,
              cursorColor: AppTheme.secondaryGold,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'From Company',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // To Company
            TextFormField(
              controller: _toCompanyController,
              cursorColor: AppTheme.secondaryGold,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'To Company',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter recipient company';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Delivery Address
            TextFormField(
              controller: _deliveryAddressController,
              cursorColor: AppTheme.secondaryGold,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter delivery address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items List
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Item ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: item.descriptionController,
                        cursorColor: AppTheme.secondaryGold,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: item.quantityController,
                              cursorColor: AppTheme.secondaryGold,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: item.unitController,
                              cursorColor: AppTheme.secondaryGold,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                                isDense: true,
                                hintText: 'pcs, kg, etc.',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            if (_items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No items added yet.\nClick "Add Item" to start.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Remarks
            TextFormField(
              controller: _remarksController,
              cursorColor: AppTheme.secondaryGold,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveChallan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Challan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChallanItemInput {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  bool isValid() {
    return descriptionController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        unitController.text.isNotEmpty &&
        int.tryParse(quantityController.text) != null;
  }

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}
