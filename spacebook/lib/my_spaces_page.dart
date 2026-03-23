import 'package:flutter/material.dart';
import 'package:spacebook/list_your_space_page.dart';
import 'package:spacebook/services/api_service.dart';

class MySpacesPage extends StatefulWidget {
  const MySpacesPage({super.key});

  @override
  State<MySpacesPage> createState() => _MySpacesPageState();
}

class _MySpacesPageState extends State<MySpacesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          'My Spaces',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListYourSpacePage()),
            ),
          ),
        ],
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
                  fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'My Listings'),
                Tab(text: 'Bookings Received'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
              controller: _tabController,
              children: [
                _MyListingsTab(),
                _BookingsReceivedTab(),
              ],
            )
    );
  }
}

// ── My Listings Tab ────────────────────────────────────────────────────────────

class _MyListingsTab extends StatefulWidget {
  @override
  State<_MyListingsTab> createState() => _MyListingsTabState();
}

class _MyListingsTabState extends State<_MyListingsTab> {
  List<dynamic> _spaces = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    try {
      final spaces = await ApiService.getMySpaces();

      setState(() {
        _spaces = spaces;
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
    if (_spaces.isEmpty) {
      return const Center(child: Text('No spaces listed yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadSpaces,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _spaces.length,
        itemBuilder: (_, i) =>
            _SpaceCard(space: _spaces[i], onRefresh: _loadSpaces),
      ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Remove Listing'),
                          content: const Text(
                              'Are you sure you want to remove this space?'),
                          actions: [
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ApiService.deleteSpace(space['id']);
                        onRefresh();
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white,),
                    label: const Text('Remove Listing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,      
                      foregroundColor: Colors.white,    
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

class _BookingsReceivedTab extends StatefulWidget {
  @override
  State<_BookingsReceivedTab> createState() => _BookingsReceivedTabState();
}

class _BookingsReceivedTabState extends State<_BookingsReceivedTab> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await ApiService.getBookingsForMySpaces();
      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
          child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary));
    }
    if (_bookings.isEmpty) {
      return const Center(child: Text('No bookings yet'));
    }
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (_, i) => _BookingReceivedCard(
          booking: _bookings[i],
          onRefresh: () => _loadBookings(),
        ),
      ),
    );
  }
}

class _BookingReceivedCard extends StatefulWidget {
  final dynamic booking;
  final VoidCallback onRefresh;

  const _BookingReceivedCard({required this.booking, required this.onRefresh});

  @override
  State<_BookingReceivedCard> createState() => _BookingReceivedCardState();
}

class _BookingReceivedCardState extends State<_BookingReceivedCard> {
  bool _toggling = false;

  Future<void> _handleToggle() async {
    setState(() => _toggling = true);
    try {
      await ApiService.toggleBookingConfirmation(widget.booking['id']);
      widget.onRefresh();
    } catch (e) {
      print('Toggle error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update confirmation.')),
      );
    } finally {
      setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmed = widget.booking['is_confirmed'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + confirmation badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.booking['title'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isConfirmed ? Theme.of(context).colorScheme.primary : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isConfirmed ? 'CONFIRMED' : 'PENDING',
                  style: TextStyle(
                    color: isConfirmed ? Theme.of(context).colorScheme.primary : Colors.orange,
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
                'Booked by: ${widget.booking['booker_name'] ?? 'User'}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Email
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.booking['booker_email'] ?? '',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Date + time slot
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${widget.booking['booking_date'] ?? ''} | ${widget.booking['time_slot'] ?? ''}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${widget.booking['total_price'] ?? 0}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Confirm toggle button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggling ? null : _handleToggle,
              icon: _toggling
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isConfirmed ? Icons.cancel_outlined : Icons.check_circle_outline,
                      size: 18,
                      color: Colors.white,
                    ),
              label: Text(
                isConfirmed ? 'Unconfirm Booking' : 'Confirm Booking',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isConfirmed ? Colors.orange : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}