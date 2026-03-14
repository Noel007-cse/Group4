import 'package:flutter/material.dart';
import 'package:spacebook/services/api_service.dart';

const Color _green = Color(0xFF3F6B00);

class Slot {
  final String time;
  final String status;
  Slot(this.time, this.status);
}

class ListYourSpacePage extends StatefulWidget {
  const ListYourSpacePage({super.key});

  @override
  State<ListYourSpacePage> createState() => _ListYourSpacePageState();
}

class _ListYourSpacePageState extends State<ListYourSpacePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: "500");
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedSpaceType = "Select Space Type";
  bool _isLoading = false;

  final Map<String, bool> facilities = {
    "Wi-Fi": false,
    "Parking": false,
    "Lighting": false,
    "Showers": false,
    "Air Conditioning": false,
  };

  final List<Slot> timeSlots = [
    Slot("08:00 AM", "free"),
    Slot("09:00 AM", "free"),
    Slot("10:00 AM", "free"),
    Slot("11:00 AM", "free"),
    Slot("12:00 PM", "free"),
    Slot("01:00 PM", "free"),
    Slot("02:00 PM", "free"),
    Slot("03:00 PM", "free"),
    Slot("04:00 PM", "free"),
  ];

  Set<String> selectedSlots = {};

  // Map dropdown value to database category
  String _getCategoryValue(String type) {
    switch (type) {
      case "Turf": return "Sports Turfs";
      case "Library": return "Libraries";
      case "Study Halls": return "Study Halls";
      case "Event Halls": return "Event Halls";
      default: return type;
    }
  }

  Future<void> _handleDone() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a space name');
      return;
    }
    if (_selectedSpaceType == "Select Space Type") {
      _showError('Please select a space type');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showError('Please enter a location/address');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('Please enter a price');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.createSpace(
        title: _nameController.text.trim(),
        category: _getCategoryValue(_selectedSpaceType),
        area: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        pricePerHr: int.tryParse(_priceController.text.trim()) ?? 500,
        hasSeats: _seatsController.text.trim().isNotEmpty,
      );

      if (result['id'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Space listed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        _showError(result['error'] ?? 'Failed to list space. Try again.');
      }
    } catch (e) {
      _showError('Connection error. Is the backend running?');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "List Your Space",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Space Name
                  const Text("Space Name",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildTextField("e.g. Downtown Sports Arena",
                      controller: _nameController),

                  const SizedBox(height: 20),

                  // Space Type
                  const Text("Space Type",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildDropdown(),

                  const SizedBox(height: 20),

                  // Seats
                  const Text("Enter the number of seats (optional)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildTextField("e.g. 100",
                      controller: _seatsController,
                      keyboardType: TextInputType.number),

                  const SizedBox(height: 20),

                  // Time Slots
                  const Text("Available Slots",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: timeSlots.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      final isSelected = selectedSlots.contains(slot.time);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedSlots.contains(slot.time)) {
                              selectedSlots.remove(slot.time);
                            } else {
                              selectedSlots.add(slot.time);
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? _green : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _green, width: 2),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _green.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            slot.time,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Location
                  const Text("Location/Address",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildTextField("e.g. MG Road, Bangalore",
                      controller: _locationController),

                  const SizedBox(height: 20),

                  // Map placeholder
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _green, width: 2),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Map view",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Price
                  const Text("Pricing per Hour (INR)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Facilities
                  const Text("Facilities",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...facilities.keys.map((facility) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(facility),
                      value: facilities[facility],
                      activeColor: _green,
                      onChanged: (value) {
                        setState(() => facilities[facility] = value!);
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // Image URL input (replaces file upload for web)
                  const Text("Space Image URL",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text(
                    "Paste an image URL from unsplash.com or any image link",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    "https://images.unsplash.com/...",
                    controller: _imageUrlController,
                  ),
                  const SizedBox(height: 8),

                  // Image preview
                  if (_imageUrlController.text.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _imageUrlController.text,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          color: Colors.grey[200],
                          child: const Center(
                              child: Text("Invalid image URL",
                                  style: TextStyle(color: Colors.grey))),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Description
                  const Text("Description",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tell guests what makes your space unique...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: _green, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Save Draft",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: _green)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Done",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}), // for image preview refresh
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: _green, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedSpaceType,
            items: const [
              DropdownMenuItem(
                  value: "Select Space Type",
                  child: Text("Select Space Type")),
              DropdownMenuItem(value: "Turf", child: Text("Turf")),
              DropdownMenuItem(
                  value: "Library", child: Text("Library")),
              DropdownMenuItem(
                  value: "Study Halls", child: Text("Study Halls")),
              DropdownMenuItem(
                  value: "Event Halls", child: Text("Event Halls")),
            ],
            onChanged: (value) {
              setState(() => _selectedSpaceType = value!);
            },
          ),
        ),
      ),
    );
  }
}