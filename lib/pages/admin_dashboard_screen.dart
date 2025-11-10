import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:setor_mobil_admin/auth/admlogin_screen.dart';
import 'package:setor_mobil_admin/pages/order_management_screen.dart';
import 'package:setor_mobil_admin/pages/vehicle_management.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedPeriod = 'today';
  int _selectedBottomNavIndex = 0;

  final List<Map<String, dynamic>> _stats = [
    {
      'label': 'Total Vehicles',
      'value': '156',
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'change': '+12',
    },
    {
      'label': 'Active Orders',
      'value': '42',
      'icon': Icons.shopping_cart,
      'color': Colors.orange,
      'change': '+5',
    },
    {
      'label': 'Users Total',
      'value': '1.2K',
      'icon': Icons.people,
      'color': Colors.purple,
      'change': '+89',
    },
    {
      'label': 'Todays Revenue',
      'value': '12.5M',
      'icon': Icons.attach_money,
      'color': Colors.green,
      'change': '+2.3M',
    },
  ];

  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': 'ORD-001',
      'customer': 'John Doe',
      'vehicle': 'Honda Beat',
      'status': 'Active',
      'amount': 'Rp 165.000',
    },
    {
      'id': 'ORD-002',
      'customer': 'Jane Smith',
      'vehicle': 'Toyota Avanza',
      'status': 'Pending',
      'amount': 'Rp 915.000',
    },
    {
      'id': 'ORD-003',
      'customer': 'Bob Johnson',
      'vehicle': 'Yamaha NMAX',
      'status': 'Completed',
      'amount': 'Rp 285.000',
    },
    {
      'id': 'ORD-004',
      'customer': 'Alice Brown',
      'vehicle': 'Yamaha NMAX',
      'status': 'Cancelled',
      'amount': 'Rp 285.000',
    },
  ];

  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'warning',
      'message': '5 vehicles are due for maintenance.',
      'time': '2 hrs ago',
    },
    {
      'type': 'info',
      'message': '12 orders waiting for approval.',
      'time': '30 min ago',
    },
  ];

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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdmloginScreen()),
              );
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(),
                    SizedBox(height: 24),

                    _buildAlerts(),
                    SizedBox(height: 24),

                    _buildRecentOrders(),
                    SizedBox(height: 24),

                    _buildQuickActions(),
                    SizedBox(height: 80),
                  ],
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Admin Panel',
                    style: TextStyle(fontSize: 13, color: Color(0xFFD1FAE5)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _handleLogout,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Row(
            children: [
              _buildPeriodButton('today', 'Today'),
              SizedBox(width: 8),
              _buildPeriodButton('week', 'This Week'),
              SizedBox(width: 8),
              _buildPeriodButton('month', 'This Month'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedPeriod = period),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.2),
          foregroundColor: isSelected ? Color(0xFF059669) : Colors.white,
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

  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _stats.length,
      itemBuilder: (context, index) {
        final stat = _stats[index];
        return Container(
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
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stat['value'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      stat['change'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 12),
        ..._alerts.map((alert) {
          final isWarning = alert['type'] == 'warning';
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWarning ? Colors.orange.shade50 : Colors.blue.shade50,
              border: Border.all(
                color: isWarning
                    ? Colors.orange.shade200
                    : Colors.blue.shade200,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: isWarning
                      ? Colors.orange.shade700
                      : Colors.blue.shade700,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['message'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        alert['time'],
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all orders screen
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Color(0xFF059669)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ..._recentOrders.map((order) {
          final status = order['status'] ?? 'Active';
          final isActive = status == 'Active';
          final isCompleted = status == 'Completed';
          final isPending = status == 'Pending';
          final isCancelled = status == 'Cancelled';

          Color bgColor;
          Color textColor;
          String label;

          if (isPending) {
            bgColor = Colors.yellow.shade100;
            textColor = Colors.yellow.shade700;
            label = 'Pending';
          } else if (isCompleted) {
            bgColor = Colors.blue.shade100;
            textColor = Colors.blue.shade700;
            label = 'Completed';
          } else if (isCancelled) {
            bgColor = Colors.red.shade100;
            textColor = Colors.red.shade700;
            label = 'Cancelled';
          } else {
            bgColor = Colors.green.shade100;
            textColor = Colors.green.shade700;
            label = 'Active';
          }

          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['id'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['customer'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          order['vehicle'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      order['amount'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                'Add\nVehicle',
                Icons.directions_car,
                [Colors.blue, Colors.blue.shade600],
                () {},
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton('View\nUsers', Icons.people, [
                Colors.purple,
                Colors.purple.shade600,
              ], () {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
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

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderManagementScreen()),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VehicleManagementScreen()),
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
