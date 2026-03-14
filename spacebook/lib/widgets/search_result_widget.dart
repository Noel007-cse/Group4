import 'package:flutter/material.dart';
import 'package:spacebook/models/space_frame_model.dart';
import 'package:spacebook/data/category_result_data.dart';
import 'package:spacebook/widgets/spaces_card_widget.dart';
import 'package:spacebook/services/api_service.dart';

enum SortType { nearest, priceLow, ratingHigh }

const Color _green = Color(0xFF3F6B00);

class SearchResultPage extends StatefulWidget {
  final String categoryTitle;

  const SearchResultPage({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late List<SpaceFrameModel> _spaces;
  SortType _sortType = SortType.nearest;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
    // _spaces = List.from(getSpacesForCategory(widget.categoryTitle));
  }
  Future<void> _loadSpaces() async {
  try {
    final data = await ApiService.getSpaces(category: widget.categoryTitle);
    setState(() {
      _spaces = data.map((json) => SpaceFrameModel(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
        area: json['area'] ?? '',
        description: json['description'] ?? '',
        distance: (json['distance'] ?? 0).toString(),
        distanceKm: (json['distance'] ?? 0).toDouble(),
        pricePerHr: json['price_per_hr'] ?? 0,
        rating: double.tryParse(json['rating'].toString()) ?? 0.0,
        noOfRating: 0,
        imageUrl: json['image_url'] ?? '',
        isFavorite: false,
        hasSeats: json['has_seats'] ?? false,
      )).toList();
    });
  } catch (e) {
    debugPrint('Error: $e');
  }
}

  void _applySort(SortType type) {
    setState(() {
      _sortType = type;
      final sorted = List<SpaceFrameModel>.from(
          getSpacesForCategory(widget.categoryTitle));
      switch (type) {
        case SortType.nearest:
          sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
          break;
        case SortType.priceLow:
          sorted.sort((a, b) => a.pricePerHr.compareTo(b.pricePerHr));
          break;
        case SortType.ratingHigh:
          sorted.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
      _spaces = sorted;
    });
  }

  String get _sortLabel {
    switch (_sortType) {
      case SortType.nearest:
        return 'Sort by: Nearest';
      case SortType.priceLow:
        return 'Sort by: Price ↑';
      case SortType.ratingHigh:
        return 'Sort by: Rating ↓';
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortBottomSheet(
        current: _sortType,
        onSelected: (t) {
          Navigator.pop(context);
          _applySort(t);
        },
      ),
    );
  }

  void _showPriceFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PriceFilterSheet(
        onApply: () {
          Navigator.pop(context);
          _applySort(SortType.priceLow);
        },
      ),
    );
  }

  void _showRatingFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RatingFilterSheet(
        onApply: () {
          Navigator.pop(context);
          _applySort(SortType.ratingHigh);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: widget.categoryTitle),
            const SizedBox(height: 12),

            // ── Filter chips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showSortSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune,
                                color: Colors.white, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              _sortLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: 'Price',
                      isActive: _sortType == SortType.priceLow,
                      onTap: _showPriceFilter,
                    ),
                    const SizedBox(width: 10),
                    _FilterChip(
                      label: 'Rating',
                      isActive: _sortType == SortType.ratingHigh,
                      onTap: _showRatingFilter,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Listings ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _spaces.length,
                itemBuilder: (_, i) => SpacesCardWidget(space: _spaces[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({this.title = 'Sports Turf'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.black87, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.grey, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.dark_mode_outlined,
                color: Colors.black54, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _green : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? _green : Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? _green : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sort Bottom Sheet ────────────────────────────────────────────────────────

class _SortBottomSheet extends StatelessWidget {
  final SortType current;
  final ValueChanged<SortType> onSelected;

  const _SortBottomSheet({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (SortType.nearest, Icons.near_me_outlined, 'Nearest First'),
      (SortType.priceLow, Icons.currency_rupee, 'Price: Low to High'),
      (SortType.ratingHigh, Icons.star_outline, 'Rating: High to Low'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Sort By',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final isSelected = current == opt.$1;
            return GestureDetector(
              onTap: () => onSelected(opt.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _green : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(opt.$2,
                        color: isSelected ? _green : Colors.black54,
                        size: 20),
                    const SizedBox(width: 12),
                    Text(opt.$3,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? _green : Colors.black87,
                        )),
                    const Spacer(),
                    if (isSelected)
                      Icon(Icons.check_circle, color: _green, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Price Filter Sheet ───────────────────────────────────────────────────────

class _PriceFilterSheet extends StatefulWidget {
  final VoidCallback onApply;

  const _PriceFilterSheet({required this.onApply});

  @override
  State<_PriceFilterSheet> createState() => _PriceFilterSheetState();
}

class _PriceFilterSheetState extends State<_PriceFilterSheet> {
  RangeValues _range = const RangeValues(50, 500);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Filter by Price',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${_range.start.toInt()}',
                  style: const TextStyle(
                      color: _green, fontWeight: FontWeight.bold)),
              Text('₹${_range.end.toInt()}',
                  style: const TextStyle(
                      color: _green, fontWeight: FontWeight.bold)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _green,
              thumbColor: _green,
              overlayColor: _green.withOpacity(0.15),
              inactiveTrackColor: Colors.grey[300],
            ),
            child: RangeSlider(
              values: _range,
              min: 0,
              max: 1000,
              divisions: 20,
              onChanged: (v) => setState(() => _range = v),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Apply — Sort Price Low to High',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rating Filter Sheet ──────────────────────────────────────────────────────

class _RatingFilterSheet extends StatefulWidget {
  final VoidCallback onApply;

  const _RatingFilterSheet({required this.onApply});

  @override
  State<_RatingFilterSheet> createState() => _RatingFilterSheetState();
}

class _RatingFilterSheetState extends State<_RatingFilterSheet> {
  double _minRating = 4.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Filter by Rating',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [4.0, 4.2, 4.5, 4.7, 4.9].map((r) {
                final selected = _minRating == r;
                return GestureDetector(
                  onTap: () => setState(() => _minRating = r),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _green : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? _green : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star,
                            color: selected
                                ? Colors.white
                                : const Color(0xFFFFC107),
                            size: 14),
                        const SizedBox(width: 4),
                        Text(r.toString(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  selected ? Colors.white : Colors.black87,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Show venues rated $_minRating and above',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Apply — Sort by Highest Rating',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
