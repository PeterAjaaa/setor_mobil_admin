import 'package:fl_chart/fl_chart.dart';
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
                    children: [
                      _buildStatsGrid(),
                      SizedBox(height: 24),
                      _buildChartsSection(),
                      SizedBox(height: 20),
                    ],
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

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistic Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 16),

        Container(
          height: 250,
          padding: EdgeInsets.all(16),
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
          child:
              _isLoadingVehicles ||
                  _isLoadingActiveOrders ||
                  _isLoadingUsers ||
                  _isLoadingPendingOrders
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xFF059669)),
                )
              : _buildBarCharts(),
        ),

        SizedBox(height: 16),

        Container(
          height: 280,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child:
                    _isLoadingVehicles ||
                        _isLoadingActiveOrders ||
                        _isLoadingUsers ||
                        _isLoadingPendingOrders
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF059669),
                        ),
                      )
                    : _buildPieChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarCharts() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue() * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label = '';
              switch (group.x.toInt()) {
                case 0:
                  label = 'Vehicles';
                  break;
                case 1:
                  label = 'Active Orders';
                  break;
                case 2:
                  label = 'Users';
                  break;
                case 3:
                  label = 'Pending Orders';
                  break;
              }
              return BarTooltipItem(
                '$label\n${rod.toY.toInt()}',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Vehicles';
                    break;
                  case 1:
                    text = 'Active Orders';
                    break;
                  case 2:
                    text = 'Users';
                    break;
                  case 3:
                    text = 'Pending Orders';
                    break;
                  default:
                    text = '';
                    break;
                }
                return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(text, style: style),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxValue() / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200], strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: _totalVehicles.toDouble(),
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.withOpacity(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: _activeOrders.toDouble(),
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.withOpacity(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: _totalUsers.toDouble(),
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: _pendingOrders.toDouble(),
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.orange.withOpacity(0.7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final total = _totalVehicles + _activeOrders + _totalUsers + _pendingOrders;

    if (total == 0) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: _totalVehicles.toDouble(),
                  title:
                      '${((_totalVehicles / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: _activeOrders.toDouble(),
                  title:
                      '${((_activeOrders / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.purple,
                  value: _totalUsers.toDouble(),
                  title: '${((_totalUsers / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: _pendingOrders.toDouble(),
                  title:
                      '${((_pendingOrders / total) * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Vehicles', Colors.blue, _totalVehicles),
              SizedBox(height: 8),
              _buildLegendItem('Active Orders', Colors.green, _activeOrders),
              SizedBox(height: 8),
              _buildLegendItem('Users', Colors.purple, _totalUsers),
              SizedBox(height: 8),
              _buildLegendItem('Pending', Colors.orange, _pendingOrders),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getMaxValue() {
    final values = [
      _totalVehicles.toDouble(),
      _activeOrders.toDouble(),
      _totalUsers.toDouble(),
      _pendingOrders.toDouble(),
    ];
    final max = values.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 10 : max;
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
