import 'package:flutter/material.dart';
import 'package:spacebook/data/booking_data.dart';
import 'package:spacebook/models/booking_frame_model.dart';
import 'package:spacebook/widgets/booking_tip_widget.dart';
import 'package:spacebook/services/api_service.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'My Bookings',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).textTheme.titleLarge?.color,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
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
          ? b['status'] == 'FUNCTIONAL'
          : b['status'] == 'COMPLETED').toList();

      setState(() {
        _bookings = filtered.map((b) => BookingModel(
          id: b['id'].toString(),
          title: b['title'] ?? '',
          date: b['booking_date'] ?? '',
          price: '₹${b['total_price'] ?? 0}',
          imageUrl: b['image_url'] ?? '',
          status: (b['is_confirmed'] ?? false) ? 'CONFIRMED' : 'UNCONFIRMED',
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
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }
    if (_bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            ..._bookings.map((b) => _BookingCard(booking: b, isUpcoming: widget.isUpcoming)),
            const SizedBox(height: 4),
            const NearbyTipCard(),
          ],
        ),
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
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
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
                    color: booking.status == 'CONFIRMED' ? Theme.of(context).colorScheme.primary : Colors.orange,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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
          child: Icon(Icons.navigation_outlined,
              color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 10),
        // View Details button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
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
        backgroundColor: Theme.of(context).colorScheme.primary,
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


