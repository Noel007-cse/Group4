import 'package:flutter/material.dart';

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

  final TextEditingController priceController =
        TextEditingController(text: "500");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "List Your Space",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [

          /// SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Space Name",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildTextField("e.g. Downtown Sports Arena"),

                  const SizedBox(height: 20),

                  const Text("Space Type",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildDropdown(),

                  const SizedBox(height: 20),

                  const Text("Enter the number of seats(optional)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildTextField("e.g. 100"),

                  const SizedBox(height: 20),

                  /// Time Slots
                  const Text("Available Slots",
                      style:
                          TextStyle(fontWeight: FontWeight.w600)),

                  const SizedBox(height: 8),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: timeSlots.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      final isSelected = selectedSlots.contains(slot.time);

                      Color bgColor;
                      Color textColor;
                      Border? border;

                      if (isSelected) {
                        bgColor = _green;
                        textColor = Colors.white;
                        border = null;
                      } else {
                        bgColor = Colors.white;
                        textColor = Colors.black;
                        border = Border.all(color: _green, width: 2);
                      }

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
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: border,
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
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              decoration: slot.status == "booked"
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text("Location/Address",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildTextField("Enter full address"),

                  const SizedBox(height: 20),

                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _green, width: 2),
                      color: Colors.grey.shade200,
                    ),
                    child: const Center(
                      child: Icon(Icons.map, size: 50, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text("Pricing per Hour (INR)",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
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
                        borderSide: BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text("Facilities",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),

                  ...facilities.keys.map((facility) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(facility),
                      value: facilities[facility],
                      activeColor: _green,
                      onChanged: (value) {
                        setState(() {
                          facilities[facility] = value!;
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  /// Upload Photos
                  const Text("Upload Photos",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _photoBox(isAdd: true),
                      const SizedBox(width: 12),
                      _photoBox(),
                      const SizedBox(width: 12),
                      _photoBox(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Description
                  const Text("Description",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          "Tell guests what makes your space unique...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // space for bottom buttons
                ],
              ),
            ),
          ),

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
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: _green, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Draft"
                      , style: TextStyle(fontWeight: FontWeight.w600, color: _green)
                    )
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                     onPressed: () async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Space listed successfully!')));
    Navigator.pop(context);
  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      padding:
                          const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
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

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _green, width: 2),
          borderRadius: BorderRadius.circular(12),
        )
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
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
              value: "Select Space Type",
              items: const [
                DropdownMenuItem(
                  value: "Select Space Type",
                  child: Text("Select Space Type"),
                ),
                DropdownMenuItem(value: "Turf", child: Text("Turf")),
                DropdownMenuItem(value: "Library", child: Text("Library")),
                DropdownMenuItem(value: "Study Halls", child: Text("Study Halls")),
                DropdownMenuItem(value: "Event Halls", child: Text("Event Halls")),
              ],
              onChanged: (value) {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoBox({bool isAdd = false}) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: _green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            isAdd ? Icons.add : Icons.image,
            size: 30,
          ),
        ),
      ),
    );
  }
}