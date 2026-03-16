import 'package:flutter/material.dart';
import 'package:spacebook/list_your_space_page.dart';
import 'package:spacebook/services/api_service.dart';

const Color _green = Color(0xFF3F6B00);

class MySpacesPage extends StatefulWidget {
  const MySpacesPage({super.key});

  @override
  State<MySpacesPage> createState() => _MySpacesPageState();
}

class _MySpacesPageState extends State<MySpacesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _mySpaces = [];
  List<dynamic> _receivedBookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final spaces = await ApiService.getMySpaces();
      final bookings = await ApiService.getBookingsForMySpaces();
      setState(() {
        _mySpaces = spaces;
        _receivedBookings = bookings;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Spaces',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: _green),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListYourSpacePage()),
            ).then((_) => _loadData()),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: _green,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'My Listings'),
                Tab(text: 'Bookings Received'),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : TabBarView(
              controller: _tabController,
              children: [
                _MyListingsTab(spaces: _mySpaces, onRefresh: _loadData),
                _BookingsReceivedTab(bookings: _receivedBookings),
              ],
            ),
    );
  }
}

// ── My Listings Tab ────────────────────────────────────────────────────────────

class _MyListingsTab extends StatelessWidget {
  final List<dynamic> spaces;
  final VoidCallback onRefresh;

  const _MyListingsTab({required this.spaces, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (spaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No spaces listed yet',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Tap + to add your first space',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: spaces.length,
      itemBuilder: (_, i) => _SpaceCard(space: spaces[i], onRefresh: onRefresh),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  final dynamic space;
  final VoidCallback onRefresh;

  const _SpaceCard({required this.space, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(
              space['image_url'] ?? '',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        space['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: const TextStyle(
                          color: _green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  space['area'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${space['price_per_hr']}/hr',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _green,
                      ),
                    ),
                    Text(
                      space['category'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Delete button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Remove Listing'),
                          content: const Text(
                              'Are you sure you want to remove this space?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Remove',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ApiService.deleteSpace(space['id']);
                        onRefresh();
                      }
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    label: const Text('Remove Listing',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bookings Received Tab ──────────────────────────────────────────────────────

class _BookingsReceivedTab extends StatelessWidget {
  final List<dynamic> bookings;

  const _BookingsReceivedTab({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No bookings yet',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Bookings for your spaces will appear here',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _BookingReceivedCard(booking: bookings[i]),
    );
  }
}

class _BookingReceivedCard extends StatelessWidget {
  final dynamic booking;

  const _BookingReceivedCard({required this.booking});

  Color get _statusColor {
    switch (booking['status']) {
      case 'CONFIRMED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      case 'COMPLETED': return Colors.grey;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  booking['space_title'] ?? booking['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['status'] ?? '',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Booked by
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Booked by: ${booking['user_name'] ?? 'User'}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${booking['booking_date'] ?? ''} | ${booking['time_slot'] ?? ''}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${booking['total_price'] ?? 0}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }
}