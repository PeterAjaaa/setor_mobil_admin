import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setor_mobil_admin/pages/admin_dashboard_screen.dart';
import 'package:setor_mobil_admin/pages/order_management_screen.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  int _selectedBottomNavIndex = 2;

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id' : 1,
      'name': 'Honda Beat',
      'type' : 'Motorcycle',
      'price': '50000',
      'status': 'Available',
      'rating': 4.8,
      'order': 124
    },
    {
      'id' : 2,
      'name': 'Yamaha Aerox',
      'type' : 'Motorcycle',
      'price': '75000',
      'status': 'Rented',
      'rating': 4.9,
      'order': 89
    },
    {
      'id' : 3,
      'name': 'Honda Vario',
      'type' : 'Motorcycle',
      'price': '60000',
      'status': 'Maintenance',
      'rating': 4.7,
      'order': 156
    },
    {
      'id' : 4,
      'name': 'Toyota Avanza',
      'type' : 'Car',
      'price': '300000',
      'status': 'Available',
      'rating': 4.8,
      'order': 78
    },
    {
      'id' : 5,
      'name': 'Honda Brio',
      'type' : 'Car',
      'price': '250000',
      'status': 'Rented',
      'rating': 4.6,
      'order': 45
    },
    {
      'id' : 6,
      'name': 'Daihatsu Xenia',
      'type' : 'Car',
      'price': '200000',
      'status': 'Rented',
      'rating': 4.7,
      'order': 50
    },
    {
      'id' : 7,
      'name': 'Suzuki Ertiga',
      'type' : 'Car',
      'price': '320000',
      'status': 'Available',
      'rating': 4.8,
      'order': 98
    },
    {
      'id' : 8,
      'name':'Honda PCX',
      'type' : 'Motorcycle',
      'price': '85000',
      'status': 'Available',
      'rating': 4.9,
      'order': 44
    },
    {
      'id' : 9,
      'name': 'Yamaha NMAX',
      'type' : 'Motorcycle',
      'price': '90000',
      'status': 'Maintenance',
      'rating': 4.8,
      'order': 76
    },
    {
      'id' : 10,
      'name': 'Toyota Innova',
      'type' : 'Car',
      'price': '400000',
      'status': 'Maintenance',
      'rating': 4.8,
      'order': 114
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredVehicles {
    var filtered = _vehicles;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((v) => v['type'] == _selectedFilter).toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((v) =>
        v['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'Available':
        return {'label': 'Available', 'color': Colors.green};
      case 'Rented':
        return {'label': 'Rented', 'color': Colors.orange};
      case 'Maintenance':
        return {'label': 'Maintenance', 'color': Colors.red};
      default:
        return {'label': status, 'color': Colors.grey};
    }
  }

  void _handleAddVehicle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add vehicle functionality not implemented.')),
    );
  }

void _handleViewDetail(Map<String, dynamic> vehicle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(vehicle['name']),
      content: Text('Vehicle detail will be displayed here.'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

  void _handleEditVehicle(Map<String, dynamic> vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit vehicle functionality not implemented.')),
    );
  }

  void _handleDeleteVehicle(Map<String, dynamic> vehicle) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete vehicle ${vehicle['name']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Vehicle ${vehicle['name']} deleted.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _vehicles.where((v) => v['status'] == 'Available').length;
    final rentedCount = _vehicles.where((v) => v['status'] == 'Rented').length;
    final maintenanceCount = _vehicles.where((v) => v['status'] == 'Maintenance').length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF0D9488)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Management',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_vehicles.length} Vehicles',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD1FAE5),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _handleAddVehicle,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                              color: Colors.white,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            color: Color(0xFF059669),
                            size: 24,
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 16),

                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  SizedBox(height: 12),

                  Row(
                    children: [
                      _buildStatMini('${_vehicles.length}', 'Total', Colors.blue),
                      SizedBox(width: 8),
                      _buildStatMini('$rentedCount', 'Available', Colors.green),
                      SizedBox(width: 8),
                      _buildStatMini('$maintenanceCount', 'Rented', Colors.orange),
                      SizedBox(width: 8),
                      _buildStatMini('$availableCount', 'Maintenance', Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 2)),
              ),
              child: Row(
                children: [
                  _buildFilterButton('All', 'All'),
                  SizedBox(width: 8),
                  _buildFilterButton('Motorcycle', 'Motorcycle'),
                  SizedBox(width: 8),
                  _buildFilterButton('Car', 'Car'),
                ],
              ),
            ),

            Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: _filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = _filteredVehicles[index];
                return _buildVehicleCard(vehicle);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStatMini(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFD1FAE5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedFilter = filter),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Color(0xFF059669) : Colors.grey[100],
          foregroundColor: isSelected ? Colors.white : Colors.grey[600],
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final statusConfig = _getStatusConfig(vehicle['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF059669).withOpacity(0.2),
                      Color(0xFF0D9488).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    vehicle['type'] == 'Motorcycle'
                        ? Icons.two_wheeler
                        : Icons.directions_car,
                    size: 28,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle['name'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      vehicle['type'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '${vehicle['rating']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${vehicle['orders']})',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusConfig['label'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusConfig['color'],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children:[
                Text(
                  'Price',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                  Text(
                    'Rp ${vehicle['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                  ),
                ),
                Text(
                  ' /day',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ], 
            ),
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Detail',
                  Icons.visibility_outlined,
                  Colors.blue,
                  () => _handleViewDetail(vehicle),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'Edit',
                  Icons.edit_outlined,
                  Color(0xFF059669),
                  () => _handleEditVehicle(vehicle),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  'Delete',
                  Icons.delete_outlined,
                  Colors.red,
                  () => _handleDeleteVehicle(vehicle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard, 'Dashboard', 0),
              _buildNavItem(Icons.shopping_bag, 'Orders', 1),
              _buildNavItem(Icons.directions_car, 'Vehicles', 2),
              _buildNavItem(Icons.people, 'Users', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
            );
          }

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderManagementScreen()),
            );
          }
        });
      },

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Color(0xFF059669) : Colors.grey[400],
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Color(0xFF059669) : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}