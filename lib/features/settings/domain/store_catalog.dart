import 'package:flutter/foundation.dart';

enum StoreItemKind { monthly, yearly, tip }

/// Something the user can buy: a supporter subscription or a tip.
@immutable
class StoreItem {
  const StoreItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.price,
    this.handle,
  });

  final String id;
  final StoreItemKind kind;
  final String title;

  /// Localized price, e.g. "¥300".
  final String price;

  /// Store specific object needed to buy this item.
  final Object? handle;
}

@immutable
class StoreCatalog {
  const StoreCatalog({
    required this.subscriptions,
    required this.tips,
    required this.isSupporter,
  });

  final List<StoreItem> subscriptions;
  final List<StoreItem> tips;
  final bool isSupporter;

  StoreCatalog copyWith({bool? isSupporter}) => StoreCatalog(
        subscriptions: subscriptions,
        tips: tips,
        isSupporter: isSupporter ?? this.isSupporter,
      );
}
