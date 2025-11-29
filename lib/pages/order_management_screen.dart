import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:setor_mobil_admin/auth/admlogin_screen.dart';
import 'package:setor_mobil_admin/pages/admin_dashboard_screen.dart';
import 'package:setor_mobil_admin/pages/admin_profile_screen.dart';
import 'package:setor_mobil_admin/pages/vehicle_management.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final _secureStorage = FlutterSecureStorage();
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final int _selectedBottomNavIndex = 1;
  List<Map<String, dynamic>> _orders = [];
  Map<int, Map<String, dynamic>> _cars = {};
  Map<int, Map<String, dynamic>> _motorcycles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([_fetchOrders(), _fetchVehicles()]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchVehicles() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        return;
      }

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
          setState(() {
            _cars = {for (var car in carsList) car['id']: car};
          });
        }
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
          setState(() {
            _motorcycles = {for (var moto in motorcyclesList) moto['id']: moto};
          });
        }
      }
    } catch (e) {
      // Silent fail for vehicles, orders will still work
    }
  }

  Future<void> _fetchOrders() async {
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

      final response = await http.get(
        Uri.parse('https://api.intracrania.com/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          setState(() {
            _orders = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch orders'),
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

  List<Map<String, dynamic>> get _filteredOrders {
    var filtered = _orders;

    if (_selectedFilter != 'All') {
      filtered = filtered.where((o) => o['status'] == _selectedFilter).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((o) => o['id'].toString().toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  String _getVehicleName(Map<String, dynamic> order) {
    if (order['car_id'] != null) {
      final car = _cars[order['car_id']];
      if (car != null) {
        return '${car['brand']} ${car['model']} (${car['year']})';
      }
      return 'Car #${order['car_id']}';
    } else if (order['motorcycle_id'] != null) {
      final motorcycle = _motorcycles[order['motorcycle_id']];
      if (motorcycle != null) {
        return '${motorcycle['brand']} ${motorcycle['model']} (${motorcycle['year']})';
      }
      return 'Motorcycle #${order['motorcycle_id']}';
    }
    return 'Unknown Vehicle';
  }

  String _getVehicleType(Map<String, dynamic> order) {
    if (order['car_id'] != null) {
      return 'Car';
    } else if (order['motorcycle_id'] != null) {
      return 'Motorcycle';
    }
    return 'Unknown';
  }

  String? _getVehicleImage(Map<String, dynamic> order) {
    if (order['car_id'] != null) {
      final car = _cars[order['car_id']];
      if (car != null && car['image_url'] != null) {
        return car['image_url'];
      }
    } else if (order['motorcycle_id'] != null) {
      final motorcycle = _motorcycles[order['motorcycle_id']];
      if (motorcycle != null && motorcycle['image_url'] != null) {
        return motorcycle['image_url'];
      }
    }
    return null;
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'Active':
        return {'label': 'Active', 'color': Colors.green};
      case 'Pending':
        return {'label': 'Pending', 'color': Colors.orange};
      case 'Completed':
        return {'label': 'Completed', 'color': Colors.blue};
      case 'Cancelled':
        return {'label': 'Cancelled', 'color': Colors.red};
      default:
        return {'label': 'Unknown', 'color': Colors.grey};
    }
  }

  String _formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _handleViewDetail(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add vehicle image to the dialog with caching
              if (_getVehicleImage(order) != null)
                Container(
                  height: 180,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _getVehicleImage(order)!,
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
                          _getVehicleType(order) == 'Car'
                              ? Icons.directions_car
                              : Icons.motorcycle,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
              Text('Order ID: ${order['id']}'),
              SizedBox(height: 8),
              Text('User ID: ${order['user_id']}'),
              SizedBox(height: 8),
              Text('Vehicle: ${_getVehicleName(order)}'),
              SizedBox(height: 8),
              Text('Type: ${_getVehicleType(order)}'),
              SizedBox(height: 8),
              Text('Duration: ${order['duration']} days'),
              SizedBox(height: 8),
              Text('Start: ${_formatDate(order['start_date'])}'),
              SizedBox(height: 8),
              Text('Return: ${_formatDate(order['return_date'])}'),
              SizedBox(height: 8),
              Text('Price: ${_formatPrice(order['price'])}'),
              SizedBox(height: 8),
              Text('Status: ${order['status']}'),
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

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        _handleUnauthorized();
        return;
      }

      final response = await http.put(
        Uri.parse('https://api.intracrania.com/orders/update/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await _fetchAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #$orderId updated to $newStatus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleApproveOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Order'),
        content: Text(
          'Are you sure you want to approve order #${order['id']}?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order['id'], 'Active');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _handleRejectOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Order'),
        content: Text('Are you sure you want to reject order #${order['id']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order['id'], 'Cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _orders.length;
    final activeCount = _orders.where((o) => o['status'] == 'Active').length;
    final pendingCount = _orders.where((o) => o['status'] == 'Pending').length;
    final completedCount = _orders
        .where((o) => o['status'] == 'Completed')
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Orders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$allCount Orders Total',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD1FAE5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by Order ID...',
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
                      _buildStatMini('$allCount', 'All'),
                      SizedBox(width: 8),
                      _buildStatMini('$activeCount', 'Active'),
                      SizedBox(width: 8),
                      _buildStatMini('$pendingCount', 'Pending'),
                      SizedBox(width: 8),
                      _buildStatMini('$completedCount', 'Done'),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton('All'),
                    SizedBox(width: 8),
                    _buildFilterButton('Active'),
                    SizedBox(width: 8),
                    _buildFilterButton('Pending'),
                    SizedBox(width: 8),
                    _buildFilterButton('Completed'),
                    SizedBox(width: 8),
                    _buildFilterButton('Cancelled'),
                  ],
                ),
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
                      onRefresh: _fetchAllData,
                      child: _filteredOrders.isEmpty
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
                                        'No orders found',
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
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                return _buildOrderCard(order);
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

  Widget _buildStatMini(String value, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
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

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF059669) : Colors.grey[100],
        foregroundColor: isSelected ? Colors.white : Colors.grey[600],
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusConfig = _getStatusConfig(order['status']);
    final isVehicleCar = order['car_id'] != null;
    final vehicleImage = _getVehicleImage(order);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order['id']}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                          isVehicleCar
                              ? Icons.directions_car
                              : Icons.motorcycle,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        isVehicleCar ? Icons.directions_car : Icons.motorcycle,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isVehicleCar ? Icons.directions_car : Icons.motorcycle,
                  size: 24,
                  color: Color(0xFF059669),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getVehicleName(order),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${order['duration']} days rental',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start: ${_formatDate(order['start_date'])}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Return: ${_formatDate(order['return_date'])}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Text(
                  _formatPrice(order['price']),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          _buildActions(order),
        ],
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> order) {
    if (order['status'] == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Detail',
              Icons.visibility_outlined,
              Colors.blue,
              () => _handleViewDetail(order),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              'Approve',
              Icons.check_circle_outline,
              Colors.green,
              () => _handleApproveOrder(order),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              'Reject',
              Icons.cancel_outlined,
              Colors.red,
              () => _handleRejectOrder(order),
            ),
          ),
        ],
      );
    } else {
      return _buildActionButton(
        'View Detail',
        Icons.visibility_outlined,
        Colors.blue,
        () => _handleViewDetail(order),
      );
    }
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
            color: Colors.black.withOpacity(0.05),
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
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VehicleManagementScreen(),
              ),
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
