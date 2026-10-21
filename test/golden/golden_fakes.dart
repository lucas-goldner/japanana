import 'package:flutter/material.dart';
import 'package:japanana/features/settings/data/backup_storage.dart';
import 'package:japanana/features/settings/data/external_actions.dart';
import 'package:japanana/features/settings/data/purchases_service.dart';
import 'package:japanana/features/settings/data/reminder_service.dart';
import 'package:japanana/features/settings/domain/store_catalog.dart';

const goldenSubscriptions = [
  StoreItem(
    id: 'monthly',
    kind: StoreItemKind.monthly,
    title: 'Japanana Supporter',
    price: r'$2.99',
  ),
  StoreItem(
    id: 'yearly',
    kind: StoreItemKind.yearly,
    title: 'Japanana Supporter',
    price: r'$24.99',
  ),
];

const goldenTips = [
  StoreItem(
    id: 'tip_small',
    kind: StoreItemKind.tip,
    title: 'Small tip',
    price: r'$0.99',
  ),
  StoreItem(
    id: 'tip_medium',
    kind: StoreItemKind.tip,
    title: 'Medium tip',
    price: r'$4.99',
  ),
  StoreItem(
    id: 'tip_large',
    kind: StoreItemKind.tip,
    title: 'Large tip',
    price: r'$9.99',
  ),
];

class FakePurchasesService implements PurchasesService {
  FakePurchasesService({this.isSupporter = false, this.isAvailable = true});

  bool isSupporter;
  final List<StoreItem> purchased = [];

  @override
  final bool isAvailable;

  @override
  Future<StoreCatalog> loadCatalog() async => StoreCatalog(
        subscriptions: goldenSubscriptions,
        tips: goldenTips,
        isSupporter: isSupporter,
      );

  @override
  Future<bool?> purchase(StoreItem item) async {
    purchased.add(item);
    if (item.kind != StoreItemKind.tip) isSupporter = true;
    return isSupporter;
  }

  @override
  Future<bool> restore() async => isSupporter;
}

class FakeReminderService implements ReminderService {
  FakeReminderService({this.grantPermission = true});

  final bool grantPermission;
  TimeOfDay? scheduled;

  @override
  Future<bool> requestPermission() async => grantPermission;

  @override
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async =>
      scheduled = time;

  @override
  Future<void> cancelDaily() async => scheduled = null;
}

class FakeBackupStorage implements BackupStorage {
  FakeBackupStorage({this.supportsICloud = true, this.importContents});

  @override
  final bool supportsICloud;
  String? importContents;
  String? exported;
  String? iCloudContents;

  @override
  Future<void> exportFile(String contents, {Rect? shareOrigin}) async =>
      exported = contents;

  @override
  Future<String?> importFile() async => importContents;

  @override
  Future<void> uploadToICloud(String contents) async =>
      iCloudContents = contents;

  @override
  Future<String?> downloadFromICloud() async => iCloudContents;
}

class FakeExternalActions implements ExternalActions {
  final List<String> opened = [];

  @override
  Future<bool> openUrl(String url, {bool inApp = false}) async {
    opened.add(url);
    return true;
  }

  @override
  Future<bool> sendFeedback({
    required String subject,
    required String body,
  }) async {
    opened.add('mailto:$subject');
    return true;
  }

  @override
  Future<void> rateApp() async => opened.add('review');

  @override
  Future<void> requestReview() async => opened.add('review prompt');

  @override
  Future<void> shareText(String text, {Rect? shareOrigin}) async =>
      opened.add('share:$text');
}
