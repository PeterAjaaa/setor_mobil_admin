import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:setor_mobil_admin/auth/admlogin_screen.dart';
import 'package:setor_mobil_admin/pages/admin_profile_screen.dart';
import 'package:setor_mobil_admin/pages/order_management_screen.dart';
import 'package:setor_mobil_admin/pages/vehicle_management.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _secureStorage = FlutterSecureStorage();
  int _selectedBottomNavIndex = 0;
  int _totalVehicles = 0;
  int _activeOrders = 0;
  int _totalUsers = 0;
  int _pendingOrders = 0;
  bool _isLoadingVehicles = true;
  bool _isLoadingActiveOrders = true;
  bool _isLoadingUsers = true;
  bool _isLoadingPendingOrders = true;

  final List<Map<String, dynamic>> _stats = [
    {
      'label': 'Total Vehicles',
      'value': '0',
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    {
      'label': 'Active Orders',
      'value': '0',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
    },
    {
      'label': 'Users Total',
      'value': '0',
      'icon': Icons.people,
      'color': Colors.purple,
    },
    {
      'label': 'Pending Orders',
      'value': '0',
      'icon': Icons.warning,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchTotalVehicles(),
      _fetchActiveOrders(),
      _fetchTotalUsers(),
      _fetchPendingOrders(),
    ]);
  }

  Future<void> _fetchTotalVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
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

      final carsResponse = await http.get(
        Uri.parse('https://api.intracrania.com/cars'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final motorcyclesResponse = await http.get(
        Uri.parse('https://api.intracrania.com/motorcycles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      int carsCount = 0;
      int motorcyclesCount = 0;

      if (carsResponse.statusCode == 200) {
        final carsData = jsonDecode(carsResponse.body);
        if (carsData['data'] != null) {
          carsCount = (carsData['data'] as List).length;
        }
      } else if (carsResponse.statusCode == 401) {
        _handleUnauthorized();
        return;
      }

      if (motorcyclesResponse.statusCode == 200) {
        final motorcyclesData = jsonDecode(motorcyclesResponse.body);
        if (motorcyclesData['data'] != null) {
          motorcyclesCount = (motorcyclesData['data'] as List).length;
        }
      } else if (motorcyclesResponse.statusCode == 401) {
        _handleUnauthorized();
        return;
      }

      setState(() {
        _totalVehicles = carsCount + motorcyclesCount;
        _stats[0]['value'] = _totalVehicles.toString();
        _isLoadingVehicles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch vehicles: Network error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchActiveOrders() async {
    setState(() {
      _isLoadingActiveOrders = true;
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

      final ordersResponse = await http.get(
        Uri.parse('https://api.intracrania.com/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (ordersResponse.statusCode == 200) {
        final ordersData = jsonDecode(ordersResponse.body);
        if (ordersData['data'] != null) {
          final orders = ordersData['data'] as List;
          final activeCount = orders
              .where((order) => order['status'] == 'Active')
              .length;

          setState(() {
            _activeOrders = activeCount;
            _stats[1]['value'] = _activeOrders.toString();
            _isLoadingActiveOrders = false;
          });
        }
      } else if (ordersResponse.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else {
        setState(() {
          _isLoadingActiveOrders = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingActiveOrders = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch active orders: Network error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchTotalUsers() async {
    setState(() {
      _isLoadingUsers = true;
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

      final usersResponse = await http.get(
        Uri.parse('https://api.intracrania.com/users/count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (usersResponse.statusCode == 200) {
        final usersData = jsonDecode(usersResponse.body);
        if (usersData['data'] != null) {
          setState(() {
            _totalUsers = usersData['data'];
            _stats[2]['value'] = _totalUsers.toString();
            _isLoadingUsers = false;
          });
        }
      } else if (usersResponse.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch users: Network error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchPendingOrders() async {
    setState(() {
      _isLoadingPendingOrders = true;
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

      final ordersResponse = await http.get(
        Uri.parse('https://api.intracrania.com/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (ordersResponse.statusCode == 200) {
        final ordersData = jsonDecode(ordersResponse.body);
        if (ordersData['data'] != null) {
          final orders = ordersData['data'] as List;
          final pendingCount = orders
              .where((order) => order['status'] == 'Pending')
              .length;

          setState(() {
            _pendingOrders = pendingCount;
            _stats[3]['value'] = _pendingOrders.toString();
            _isLoadingPendingOrders = false;
          });
        }
      } else if (ordersResponse.statusCode == 401) {
        _handleUnauthorized();
        return;
      } else {
        setState(() {
          _isLoadingPendingOrders = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPendingOrders = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch pending orders: Network error'),
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _secureStorage.delete(key: 'jwt_token');

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdmloginScreen()),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF059669)),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: Color(0xFF059669),
                onRefresh: _fetchAllData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildStatsGrid(), SizedBox(height: 20)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 2),
                Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 13, color: Color(0xFFD1FAE5)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _handleLogout,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.logout, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(_stats[0], 0)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard(_stats[1], 1)),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(_stats[2], 2)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard(_stats[3], 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    final isVehicleStat = index == 0;
    final isActiveOrderStat = index == 1;
    final isUserStat = index == 2;
    final isPendingOrderStat = index == 3;

    final isLoading =
        (isVehicleStat && _isLoadingVehicles) ||
        (isActiveOrderStat && _isLoadingActiveOrders) ||
        (isUserStat && _isLoadingUsers) ||
        (isPendingOrderStat && _isLoadingPendingOrders);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [stat['color'], stat['color'].withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat['icon'], color: Colors.white, size: 20),
          ),
          SizedBox(height: 12),
          Text(
            stat['label'],
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF059669),
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat['value'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
        ],
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
          setState(() {
            _selectedBottomNavIndex = index;

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderManagementScreen(),
                ),
              );
            }

            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleManagementScreen(),
                ),
              );
            }

            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminProfileScreen()),
              );
            }
          });
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
