import 'package:flutter/material.dart';
import 'package:spacebook/data/booking_data.dart';
import 'package:spacebook/models/booking_frame_model.dart';
import 'package:spacebook/widgets/booking_tip_widget.dart';
import 'package:spacebook/services/api_service.dart';

const Color _green = Color(0xFF3F6B00);

// ─── Main Page ─────────────────────────────────────────────────────────────────

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Start on Upcoming (index 0). Change to 1 to default to Completed.
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
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
          'My Bookings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
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
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingsList( isUpcoming: true),
          _BookingsList( isUpcoming: false),
        ],
      ),
    );
  }
}

// ─── Bookings List ─────────────────────────────────────────────────────────────
class _BookingsList extends StatefulWidget {
  final bool isUpcoming;
  const _BookingsList({required this.isUpcoming});

  @override
  State<_BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<_BookingsList> {
  List<BookingModel> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final data = await ApiService.getMyBookings();
      final filtered = data.where((b) => widget.isUpcoming
          ? b['status'] == 'CONFIRMED'
          : b['status'] == 'COMPLETED').toList();

      setState(() {
        _bookings = filtered.map((b) => BookingModel(
          id: b['id'].toString(),
          title: b['title'] ?? '',
          date: b['booking_date'] ?? '',
          price: '₹${b['total_price'] ?? 0}',
          imageUrl: b['image_url'] ?? '',
          status: b['status'] ?? '',
        )).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }
    if (_bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          ..._bookings.map((b) => _BookingCard(booking: b, isUpcoming: widget.isUpcoming)),
          const SizedBox(height: 4),
          const NearbyTipCard(),
        ],
      ),
    );
  }
}
// ─── Booking Card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isUpcoming;

  const _BookingCard({required this.booking, required this.isUpcoming});

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
          // ── Image + badge ──
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  booking.imageUrl,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 170,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image,
                        size: 50, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      booking.date,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Price + action ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _green,
                      ),
                    ),
                    isUpcoming
                        ? const _UpcomingActions()
                        : const _RebookButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Upcoming Actions ─────────────────────────────────────────────────────────

class _UpcomingActions extends StatelessWidget {
  const _UpcomingActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Direction icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.navigation_outlined,
              color: _green, size: 20),
        ),
        const SizedBox(width: 10),
        // View Details button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: const Text(
            'View Details',
            style:
                TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ─── Rebook Button ─────────────────────────────────────────────────────────────

class _RebookButton extends StatelessWidget {
  const _RebookButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      ),
      child: const Text(
        'Rebook',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}


