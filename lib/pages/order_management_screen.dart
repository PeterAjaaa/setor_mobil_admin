import 'package:flutter/material.dart';
import 'package:setor_mobil_admin/pages/admin_dashboard_screen.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  int _selectedBottomNavIndex = 1;

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '0RD-001',
      'customer': 'John Doe',
      'vehicle': 'Honda Beat',
      'type': 'Motorcycle',
      'status': 'Active',
      'startDate': 'Nov 15 2025',
      'endDate': 'Nov 17 2025',
      'amount': 'Rp 165.000',
      'phone': '081234567890',
    },
    {
      'id': '0RD-002',
      'customer': 'Jane Smith',
      'vehicle': 'Toyota Avanza',
      'type': 'Car',
      'status': 'Pending',
      'startDate': 'Nov 20 2025',
      'endDate': 'Nov 22 2025',
      'amount': 'Rp 915.000',
      'phone': '081234567890',
    },
    {
      'id': '0RD-003',
      'customer': 'Bob Johnson',
      'vehicle': 'Yamaha NMAX',
      'type': 'Motorcycle',
      'status': 'Completed',
      'startDate': 'Nov 10 2025',
      'endDate': 'Nov 12 2025',
      'amount': 'Rp 285.000',
      'phone': '081234567890',
    },
    {
      'id': '0RD-004',
      'customer': 'Alice Brown',
      'vehicle': 'Yamaha NMAX',
      'type': 'Motorcycle',
      'status': 'Cancelled',
      'startDate': 'Nov 10 2025',
      'endDate': 'Nox 12 2025',
      'amount': 'Rp 285.000',
      'phone': '081234567890',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredOrders {
    var filtered = _orders;

    if (_selectedFilter != 'all') {
      filtered = filtered.where((o) => o['status'] == _selectedFilter).toList();
    }

    if (_searchController.text.isEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (o) =>
                o['id'].toString().toLowerCase().contains(query) ||
                o['customer'].toString().toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
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

  void _handleViewDetail(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail ${order['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer: ${order['customer']}'),
              Text('Phone: ${order['phone']}'),
              Text('Vehicle: ${order['vehicle']}'),
              Text('Status: ${_getStatusConfig(order['status'])['label']}'),
              Text('Amount: ${order['amount']}'),
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

  void _handleApproveOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Order'),
        content: Text('Are you sure you want to approve order ${order['id']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _orders.indexWhere((o) => o['id'] == order['id']);
                _orders[index]['status'] = 'Active';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order['id']} approved.')),
              );
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
        content: Text('Are you sure you want to reject order ${order['id']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _orders.indexWhere((o) => o['id'] == order['id']);
                _orders[index]['status'] = 'Cancelled';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order['id']} rejected.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _handleCompleteOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Order'),
        content: Text(
          'Are you sure you want to complete order ${order['id']}?',
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
              setState(() {
                final index = _orders.indexWhere((o) => o['id'] == order['id']);
                _orders[index]['status'] = 'Completed';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order['id']} completed.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          '${_orders.length} Orders Total',
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
                      hintText: 'Search ID or customer name...',
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
                      _buildStatMini('${_orders.length}', 'All Orders'),
                      SizedBox(width: 8),
                      _buildStatMini('$activeCount', 'Active'),
                      SizedBox(width: 8),
                      _buildStatMini('$pendingCount', 'Pending'),
                      SizedBox(width: 8),
                      _buildStatMini('$completedCount', 'Completed'),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    _buildFilterButton('all', 'All'),
                    SizedBox(width: 8),
                    _buildFilterButton('active', 'Active'),
                    SizedBox(width: 8),
                    _buildFilterButton('pending', 'Pending'),
                    SizedBox(width: 8),
                    _buildFilterButton('completed', 'Completed'),
                    SizedBox(width: 8),
                    _buildFilterButton('cancelled', 'Cancelled'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  return _buildOrderCard(order);
                },
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Color(0xFFD1FAE5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ElevatedButton(
      onPressed: () => setState(() => _selectedFilter = filter),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF059669) : Colors.grey[100],
        foregroundColor: isSelected ? Colors.white : Colors.grey[600],
        elevation: 0,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['id'],
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusConfig['color'],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFF059669).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 18, color: Color(0xFF059669)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['customer'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      order['phone'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  order['type'] == 'Motorcycle'
                      ? Icons.motorcycle
                      : Icons.directions_car,
                  size: 24,
                  color: Color(0xFF059669),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['vehicle'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      order['type'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.blue),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    Text(
                      'Rp ${order['amount'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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
    } else if (order['status'] == 'Active') {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Detail',
              Icons.visibility_outlined,
              Colors.purple,
              () => _handleCompleteOrder(order),
            ),
          ),
        ],
      );
    } else {
      return _buildActionButton(
        'Detail',
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
