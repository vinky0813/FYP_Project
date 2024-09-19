class Review {
  final String review_id;
  final String user_id;
  final String listing_id;
  final String comment;
  final double rating;

  Review({
    required this.review_id,
    required this.user_id,
    required this.listing_id,
    required this.comment,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      review_id: json["review_id"],
      user_id: json["user_id"],
      listing_id: json["listing_id"],
      comment: json["comment"],
      rating: (json["rating"] as num).toDouble(),
    );
  }
}
