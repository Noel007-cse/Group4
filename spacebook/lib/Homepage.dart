import 'package:flutter/material.dart';
import 'package:spacebook/services/api_service.dart';
import 'package:spacebook/list_your_space_page.dart';
import 'package:spacebook/main.dart';
import 'package:spacebook/models/category_item_model.dart';
import 'package:spacebook/models/space_frame_model.dart';
import 'package:spacebook/search_page.dart';
import 'package:spacebook/widgets/favorites_card_widget.dart';
import 'services/api_service.dart';
import 'package:spacebook/widgets/spaces_card_widget.dart';
import 'package:spacebook/widgets/search_result_widget.dart';
import 'package:spacebook/widgets/space_frame_widget.dart';
import 'data/category_item_data.dart';
import 'package:spacebook/map_page.dart';
const Color _green = Color(0xFF3F6B00);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  List<dynamic> _favorites = [];
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _loadFavorites() async {
    try {
      final data = await ApiService.getFavorites();

      setState(() {
        _favorites = data.map((d) => SpaceFrameModel(
          id: d['id'] ?? 0,
          title: d['title'] ?? '',
          category: d['category'] ?? '',
          area: d['area'] ?? '',
          distance: d['distance'] ?? '0.0',
          distanceKm: d['distance_km'] ?? 0.0,
          rating: d['rating'] ?? 0.0,
          noOfRating: d['no_of_rating'] ?? 0.0,
          description: d['description'] ?? '',
          pricePerHr: d['price_per_hr'] ?? 0,
          hasSeats: d['has_seats'] ?? false,
          isFavorite: true,
          imageUrl: d['image_url'] ?? '',
        )).toList();

        _loading = false;
      });
    } catch (e) {
      print("Error loading favorites: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRecommended() async {
    try {
      final data = await ApiService.getRecommend();
      setState(() {
        _recommendations = data.map((d) => SpaceFrameModel(
          id: d['id'] ?? 0,
          title: d['title'] ?? '',
          category: d['category'] ?? '',
          area: d['area'] ?? '',
          distance: d['distance'] ?? '0.0',
          distanceKm: d['distance_km'] ?? 0.0,
          rating: d['rating'] ?? 0.0,
          noOfRating: d['no_of_rating'] ?? 0.0,
          description: d['description'] ?? '',
          pricePerHr: d['price_per_hr'] ?? 0,
          isFavorite: d['is_favorite'] ?? false,
          hasSeats: d['has_seats'] ?? false,
          imageUrl: d['image_url'] ?? '',
        )).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadFavorites(),
      _loadRecommended(),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                _Header(),
                const SizedBox(height: 16),
                _SearchBar(onRefresh: _refreshAll,),
                const SizedBox(height: 24),
                _CategoriesSection(onRefresh: _refreshAll,),
                const SizedBox(height: 20),
                _HostBanner(onRefresh: _refreshAll,),
                const SizedBox(height: 24),
                _FavoritesSection(favorites: _favorites, onRefresh: _refreshAll,),
                const SizedBox(height: 24),
                _RecommendedSection(recommendations: _recommendations, onRefresh: _refreshAll,),
                const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hello, ${ApiService.currentUser?['name'] ?? 'Guest'}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode_outlined,
              size: 20,
            ),
            onPressed: () {
              SpaceBookApp.of(context)?.toggleTheme();
            },
          ),
        ),
      ],
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final VoidCallback? onRefresh;
  const _SearchBar({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        ).then((_) => onRefresh?.call());
      },
      child: Container(
        height: 48,
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
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Search sports, study, or events...',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            // Container(
            //   margin: const EdgeInsets.only(right: 8),
            //   padding: const EdgeInsets.all(6),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: const Icon(Icons.tune, color: Colors.grey, size: 18),
            // ),
          ],
        ),
      ),
    );
  }
}

// ─── Categories ────────────────────────────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  final VoidCallback? onRefresh;
  const _CategoriesSection({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
            ),
            // Text(
            //   'See All',
            //   style: TextStyle(
            //       fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
            // ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories
              .map((category) => _CategoryItem(
                    category: category,
                    onTap: () => _onCategoryTap(context, category.label),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _onCategoryTap(BuildContext context, String label) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(categoryTitle: label),
      ),
    ).then((_) => onRefresh?.call());
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryItemModel category;
  final VoidCallback? onTap;

  const _CategoryItem({required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: category.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  Icon(category.icon, color: category.iconColor, size: 28),
            ),
            const SizedBox(height: 7),
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).textTheme.bodyLarge?.color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Host Banner ───────────────────────────────────────────────────────────────

class _HostBanner extends StatelessWidget {
  final VoidCallback? onRefresh;
  const _HostBanner({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.store_outlined,
              size: 100,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Host Your Space &\nEarn More!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Turn your empty seats or fields\ninto income. It\'s free to list.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  if (!ApiService.isOwner) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Create an Owner account to list your space.'),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListYourSpacePage()),
                  ).then((_) => onRefresh?.call());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  'List Your Space',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Favorites ─────────────────────────────────────────────────────────────────

class _FavoritesSection extends StatelessWidget {
  final List<dynamic> favorites;
  final VoidCallback? onRefresh;

  const _FavoritesSection({required this.favorites, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorites',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
        ),
        const SizedBox(height: 12),
        
        if(favorites.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Icon(Icons.favorite_border,
                    size: 36, color: Colors.grey.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap the heart icon on any space to\nsave it here for quick access',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final space = favorites[index];
                return FavoritesCardWidget(space: space, onRefresh: onRefresh,);
              },
            ),
          ),
      ],
    );
  }
}

// ─── Recommended Section ───────────────────────────────────────────────────────

class _RecommendedSection extends StatelessWidget {
  final List<dynamic> recommendations;
  final VoidCallback? onRefresh;

  const _RecommendedSection({required this.recommendations, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended for You',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
            ),
            GestureDetector(
  onTap: () async {
    // Load all spaces then show map
    try {
      final spaces = await ApiService.getSpaces();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapPage(
            locationName: 'All Spaces',
            allSpaces: List<Map<String, dynamic>>.from(spaces),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load spaces')));
    }
  },
  child: Text(
    'View map',
    style: TextStyle(
      fontSize: 13,
      color: _green,
      fontWeight: FontWeight.w600,
    ),
  ),
),
          ],
        ),
        const SizedBox(height: 14),
        ...recommendations.map((space) => SpacesCardWidget(space: space, onRefresh: onRefresh,)),
      ],
    );
  }
}