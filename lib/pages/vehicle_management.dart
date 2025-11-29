import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:setor_mobil_admin/auth/admlogin_screen.dart';
import 'package:setor_mobil_admin/pages/admin_dashboard_screen.dart';
import 'package:setor_mobil_admin/pages/admin_profile_screen.dart';
import 'package:setor_mobil_admin/pages/order_management_screen.dart';
import 'package:setor_mobil_admin/pages/add_vehicle_screen.dart';
import 'package:setor_mobil_admin/pages/edit_vehicle_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  final _secureStorage = FlutterSecureStorage();
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final int _selectedBottomNavIndex = 2;
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdmloginScreen()),
          );
        }
        return;
      }

      List<Map<String, dynamic>> allVehicles = [];

      // Fetch cars
      final carsResponse = await http.get(
        Uri.parse('https://api.intracrania.com/cars'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (carsResponse.statusCode == 200) {
        final carsData = jsonDecode(carsResponse.body);
        if (carsData['data'] != null) {
          final carsList = List<Map<String, dynamic>>.from(carsData['data']);
          // Add type field to each car
          for (var car in carsList) {
            car['type'] = 'Car';
            car['name'] = '${car['brand']} ${car['model']}';
            allVehicles.add(car);
          }
        }
      } else if (carsResponse.statusCode == 401) {
        _handleUnauthorized();
        return;
      }

      // Fetch motorcycles
      final motorcyclesResponse = await http.get(
        Uri.parse('https://api.intracrania.com/motorcycles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (motorcyclesResponse.statusCode == 200) {
        final motorcyclesData = jsonDecode(motorcyclesResponse.body);
        if (motorcyclesData['data'] != null) {
          final motorcyclesList = List<Map<String, dynamic>>.from(
            motorcyclesData['data'],
          );
          // Add type field to each motorcycle
          for (var moto in motorcyclesList) {
            moto['type'] = 'Motorcycle';
            moto['name'] = '${moto['brand']} ${moto['model']}';
            allVehicles.add(moto);
          }
        }
      } else if (motorcyclesResponse.statusCode == 401) {
        _handleUnauthorized();
        return;
      }

      setState(() {
        _vehicles = allVehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleUnauthorized() async {
    await _secureStorage.delete(key: 'jwt_token');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session expired. Please login again.'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdmloginScreen()),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredVehicles {
    var filtered = _vehicles;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((v) => v['type'] == _selectedFilter).toList();
    }

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (v) => v['name'].toString().toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _handleAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddVehicleScreen()),
    );

    if (result == true) {
      _fetchVehicles();
    }
  }

  void _handleViewDetail(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle['name']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add vehicle image to the dialog with caching
              if (vehicle['image_url'] != null)
                Container(
                  height: 180,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: vehicle['image_url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          vehicle['type'] == 'Car'
                              ? Icons.directions_car
                              : Icons.motorcycle,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
              Text('Registration: ${vehicle['registration_num']}'),
              SizedBox(height: 8),
              Text('Brand: ${vehicle['brand']}'),
              SizedBox(height: 8),
              Text('Model: ${vehicle['model']}'),
              SizedBox(height: 8),
              Text('Year: ${vehicle['year']}'),
              SizedBox(height: 8),
              Text('Type: ${vehicle['type']}'),
              SizedBox(height: 8),
              Text('Price/Day: Rp ${_formatPrice(vehicle['price_per_day'])}'),
              SizedBox(height: 8),
              Text('Status: ${vehicle['status']}'),
              // Replace the spread operator with this approach
              _buildDescriptionSection(vehicle),
            ],
          ),
        ),
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

  // Add this helper method to build the description section
  Widget _buildDescriptionSection(Map<String, dynamic> vehicle) {
    if (vehicle['description'] != null &&
        vehicle['description'].toString().isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Text('Description:'),
          SizedBox(height: 4),
          Text(
            vehicle['description'],
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      );
    }
    return SizedBox.shrink(); // Return an empty widget if there's no description
  }

  void _handleEditVehicle(Map<String, dynamic> vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditVehicleScreen(vehicle: vehicle),
      ),
    ).then((result) {
      // If result is true, refresh the vehicle list
      if (result == true) {
        _fetchVehicles();
      }
    });
  }

  // Updated delete functionality
  void _handleDeleteVehicle(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle['name']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteVehicle(vehicle);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // New method to handle the actual deletion
  Future<void> _deleteVehicle(Map<String, dynamic> vehicle) async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        _handleUnauthorized();
        return;
      }

      // Determine the correct endpoint based on vehicle type
      final endpoint = vehicle['type'] == 'Car'
          ? 'https://api.intracrania.com/cars/delete/${vehicle['id']}'
          : 'https://api.intracrania.com/motorcycles/delete/${vehicle['id']}';

      final response = await http.delete(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${vehicle['type']} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the vehicle list
          _fetchVehicles();
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete ${vehicle['type']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _vehicles
        .where((v) => v['status'] == 'Available')
        .length;
    final rentedCount = _vehicles.where((v) => v['status'] == 'Rented').length;
    final maintenanceCount = _vehicles
        .where((v) => v['status'] == 'Maintenance')
        .length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                      ),
                      SizedBox(width: 8),
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
                                color: Colors.black.withValues(alpha: 0.1),
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
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 20,
                      ),
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
                      _buildStatMini(
                        '${_vehicles.length}',
                        'Total',
                        Colors.blue,
                      ),
                      SizedBox(width: 8),
                      _buildStatMini(
                        '$availableCount',
                        'Available',
                        Colors.green,
                      ),
                      SizedBox(width: 8),
                      _buildStatMini('$rentedCount', 'Rented', Colors.orange),
                      SizedBox(width: 8),
                      _buildStatMini(
                        '$maintenanceCount',
                        'Maintenance',
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 2),
                ),
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
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF059669),
                      ),
                    )
                  : RefreshIndicator(
                      color: Color(0xFF059669),
                      onRefresh: _fetchVehicles,
                      child: _filteredVehicles.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 100),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No vehicles found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _filteredVehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = _filteredVehicles[index];
                                return _buildVehicleCard(vehicle);
                              },
                            ),
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
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Color(0xFFD1FAE5)),
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final statusConfig = _getStatusConfig(vehicle['status']);
    final isCar = vehicle['type'] == 'Car';
    final vehicleImage = vehicle['image_url'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle image section with caching
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: vehicleImage != null
                  ? CachedNetworkImage(
                      imageUrl: vehicleImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          isCar ? Icons.directions_car : Icons.motorcycle,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        isCar ? Icons.directions_car : Icons.motorcycle,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF059669).withValues(alpha: 0.2),
                      Color(0xFF0D9488).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    vehicle['type'] == 'Motorcycle'
                        ? Icons.two_wheeler
                        : Icons.directions_car,
                    size: 24,
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${vehicle['type']} • ${vehicle['year']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusConfig['label'],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusConfig['color'],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  'Price',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Spacer(),
                Text(
                  'Rp ${_formatPrice(vehicle['price_per_day'])}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
                Text(
                  ' /day',
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
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
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard, 'Dashboard', 0),
              _buildNavItem(Icons.shopping_bag, 'Orders', 1),
              _buildNavItem(Icons.directions_car, 'Vehicles', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedBottomNavIndex == index;
    return Flexible(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrderManagementScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminProfileScreen()),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? Color(0xFF059669) : Colors.grey[400],
              ),
              SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Color(0xFF059669) : Colors.grey[400],
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
