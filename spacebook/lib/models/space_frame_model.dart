class SpaceFrameModel {
  final int id;
  final String title;
  final String category;
  final String area;
  final String description;
  final String distance; // e.g. "0.5"
  final double distanceKm;
  final int pricePerHr;
  final double rating;
  final double noOfRating;
  final String imageUrl;
  final bool isFavorite;
  final bool hasSeats;

  const SpaceFrameModel({
    required this.id,
    required this.title,
    required this.category,
    required this.area,
    required this.description,
    required this.distance,
    required this.distanceKm,
    required this.pricePerHr,
    required this.rating,
    required this.noOfRating,
    required this.imageUrl,
    required this.isFavorite,
    required this.hasSeats,
  });
}