import 'package:flutter/material.dart';
import 'package:spacebook/models/space_frame_model.dart';
import 'package:spacebook/services/api_service.dart';
import 'package:spacebook/map_page.dart';
const Color _green = Color(0xFF3F6B00);

class Slot {
  final String time;
  final String status;
  Slot(this.time, this.status);
}

class Seat {
  final String name;
  final String status;
  Seat(this.name, this.status);
}

class SpaceFrameWidget extends StatefulWidget {
  final SpaceFrameModel space;

  const SpaceFrameWidget({super.key, required this.space});

  @override
  State<SpaceFrameWidget> createState() => _SpaceFrameWidgetState();
}

class _SpaceFrameWidgetState extends State<SpaceFrameWidget> {
  int selectedDateIndex = 0;
  String selectedTime = "09:00 AM";
  int selectedSeat = 0;
  bool _isFav = false;
  bool _isBooking = false;

  final List<String> dates = [
    "THU\n24", "FRI\n25", "SAT\n26", "SUN\n27", "MON\n28"
  ];

  final List<Slot> timeSlots = [
    Slot("08:00 AM", "booked"),
    Slot("09:00 AM", "free"),
    Slot("10:00 AM", "free"),
    Slot("11:00 AM", "free"),
    Slot("12:00 PM", "free"),
    Slot("01:00 PM", "free"),
    Slot("02:00 PM", "free"),
    Slot("03:00 PM", "booked"),
    Slot("04:00 PM", "free"),
  ];

  final List<Seat> seats = [
    Seat("A1", "free"), Seat("A2", "free"),
    Seat("B1", "free"), Seat("B2", "booked"),
    Seat("C1", "free"), Seat("C2", "free"),
    Seat("D1", "free"), Seat("D2", "booked"),
  ];

  Future<void> _handleBooking() async {
    if (ApiService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first to book')));
      return;
    }

    setState(() => _isBooking = true);
    try {
      final result = await ApiService.createBooking(
        spaceId: widget.space.id,
        bookingDate: DateTime.now().toIso8601String().split('T')[0],
        timeSlot: selectedTime,
        totalPrice: widget.space.pricePerHr,
      );

      if (result['id'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking confirmed! Check My Bookings.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Booking failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isBooking = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _addRecommendation();
    _isFav = widget.space.isFavorite;
  }

  Future<void> _addRecommendation() async {
    await ApiService.addRecommend(widget.space.id);
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  space.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 60, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: _circleButton(
                    icon: Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 16,
                  child: Row(
                    children: [
                      _circleButton(
                          icon: Icons.share,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          onTap: () {}
                        ),
                      const SizedBox(width: 10),
                      _circleButton(
                        icon: _isFav
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _isFav ? Colors.red : Theme.of(context).colorScheme.onPrimaryContainer,
                        onTap: () async {
                          final newState = await ApiService.toggleFavorite(space.id, _isFav);
                          setState(() => _isFav = newState);
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, -2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(space.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => MapPage(locationName: space.area),
    ),
  ),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _green.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_on_outlined, color: _green, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            space.area,
            style: const TextStyle(
              color: _green,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.map_outlined, color: _green, size: 13),
      ],
    ),
  ),
),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text("${space.rating} (${space.noOfRating.toInt()} reviews)"),
                        ],
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Starting from\n",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                          children: [
                            TextSpan(
                              text: "₹${space.pricePerHr}/hr",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          ],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text("About",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(space.description,
                      style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 20),
                  const Text("Select Date",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedDateIndex = index),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.fromLTRB(0,2,12,2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor.withOpacity(0.08),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                )
                              ]   
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              dates[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text("Available Slots",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: timeSlots.map((slot) {
                      final isSelected = selectedTime == slot.time;
                      Color bgColor;
                      Color textColor;
                      Border? border;

                      if (slot.status == "booked") {
                        bgColor = Theme.of(context).colorScheme.primaryContainer;
                        textColor = Colors.grey;
                        border = null;
                      } else if (isSelected) {
                        bgColor = Theme.of(context).colorScheme.primary;
                        textColor = Colors.white;
                        border = null;
                      } else {
                        bgColor = Theme.of(context).colorScheme.primaryContainer;
                        textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
                        border = Border.all(color: Theme.of(context).colorScheme.primary, width: 2);
                      }

                      return GestureDetector(
                        onTap: slot.status == "booked"
                            ? null
                            : () =>
                                setState(() => selectedTime = slot.time),
                        child: Container(
                          width: 100,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: border,
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).shadowColor.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                            ]
                          ),
                          child: Text(
                            slot.time,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              decoration: slot.status == "booked"
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  if (space.hasSeats) ...[
                    const Text("Available Seats",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: seats.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemBuilder: (context, index) {
                        final seat = seats[index];
                        final isSelected = selectedSeat == index;
                        Color bgColor;
                        Color iconColor;
                        Border? border;

                        if (seat.status == "booked") {
                          bgColor = Theme.of(context).colorScheme.primaryContainer;
                          iconColor = Colors.grey;
                          border = null;
                        } else if (isSelected) {
                          bgColor = Theme.of(context).colorScheme.primary;
                          iconColor = Colors.white;
                          border = null;
                        } else {
                          bgColor = Theme.of(context).colorScheme.primaryContainer;
                          iconColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
                          border = Border.all(color: Theme.of(context).colorScheme.primary, width: 2);
                        }

                        return GestureDetector(
                          onTap: seat.status == "booked"
                              ? null
                              : () =>
                                  setState(() => selectedSeat = index),
                          child: Column(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: border,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                ),
                                child: Icon(Icons.event_seat,
                                    color: iconColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "SEAT ${seat.name}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: seat.status == "booked"
                                      ? Colors.grey
                                      : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                  _facilitiesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _facilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Facilities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            FacilityItem(icon: Icons.wifi, label: "WI-FI"),
            FacilityItem(icon: Icons.power, label: "OUTLETS"),
            FacilityItem(icon: Icons.local_cafe, label: "CAFETERIA"),
            FacilityItem(icon: Icons.print, label: "PRINTING"),
            FacilityItem(icon: Icons.ac_unit, label: "AC"),
          ],
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle
          ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, -2))
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${widget.space.pricePerHr}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 60),
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 6,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isBooking ? null : _handleBooking,
              child: _isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Book Now",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward,
                            size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacilityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const FacilityItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer, 
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                )
              ]
            ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5),
        )
      ],
    );
  }
}