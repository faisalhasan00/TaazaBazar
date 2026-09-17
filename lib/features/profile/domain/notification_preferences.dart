/// User-controlled notification settings for TaazaBazar customer app
class NotificationPreferences {
  /// Transactional: Order confirmed, rider on the way, delivered, refunds (default: true)
  final bool orderUpdates;

  /// Optional: Fresh farm harvest arrivals at 6:00 AM (default: true)
  final bool morningHarvestAlerts;

  /// Optional: Weekly coupons and organic flash sales (default: true)
  final bool offersAndPromotions;

  const NotificationPreferences({
    this.orderUpdates = true,
    this.morningHarvestAlerts = true,
    this.offersAndPromotions = true,
  });

  NotificationPreferences copyWith({
    bool? orderUpdates,
    bool? morningHarvestAlerts,
    bool? offersAndPromotions,
  }) {
    return NotificationPreferences(
      orderUpdates: orderUpdates ?? this.orderUpdates,
      morningHarvestAlerts: morningHarvestAlerts ?? this.morningHarvestAlerts,
      offersAndPromotions: offersAndPromotions ?? this.offersAndPromotions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderUpdates': orderUpdates,
      'morningHarvestAlerts': morningHarvestAlerts,
      'offersAndPromotions': offersAndPromotions,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationPreferences();
    return NotificationPreferences(
      orderUpdates: map['orderUpdates'] != false,
      morningHarvestAlerts: map['morningHarvestAlerts'] != false,
      offersAndPromotions: map['offersAndPromotions'] != false,
    );
  }
}
