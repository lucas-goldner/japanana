import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/settings/application/progress_controller.dart';
import 'package:japanana/features/settings/presentation/widgets/sheet_parts.dart';

typedef _Status = ({String text, SheetMessageTone tone});

TextStyle _buttonText(BuildContext context) => TextStyle(
      fontFamily: context.textTheme.notoSansJPFont,
      fontSize: 16,
    );

class ResetProgressSheet extends HookConsumerWidget {
  const ResetProgressSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final neo = context.neo;
    final l10n = context.l10n;
    final confirming = useState(false);
    final done = useState(false);

    Future<void> reset() async {
      await ref.read(progressControllerProvider).reset();
      confirming.value = false;
      done.value = true;
    }

    return SheetColumn(
      children: [
        SheetDescription(l10n.resetDescription),
        if (done.value)
          SheetMessage(l10n.resetDone, tone: SheetMessageTone.success)
        else if (confirming.value) ...[
          NeoButton(
            onPressed: reset,
            minHeight: 56,
            color: neo.wrongFill,
            foregroundColor: neo.onFeedback,
            shadowColor: neo.accentShadow,
            child: Text(l10n.resetConfirm, style: _buttonText(context)),
          ),
          NeoButton(
            onPressed: () => confirming.value = false,
            minHeight: 56,
            child: Text(l10n.close, style: _buttonText(context)),
          ),
        ] else
          NeoButton(
            onPressed: () => confirming.value = true,
            minHeight: 56,
            color: neo.wrongFill,
            foregroundColor: neo.onFeedback,
            shadowColor: neo.accentShadow,
            child: Text(l10n.resetButton, style: _buttonText(context)),
          ),
      ],
    );
  }
}

class ExportSyncSheet extends HookConsumerWidget {
  const ExportSyncSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.watch(progressControllerProvider);
    final status = useState<_Status?>(null);
    final busy = useState(false);

    /// Runs [action] and reports the result. [action] returns false when the
    /// user cancelled or there was nothing to restore.
    Future<void> run(
      Future<bool> Function() action, {
      required String success,
    }) async {
      if (busy.value) return;
      busy.value = true;
      status.value = null;
      try {
        if (await action()) {
          status.value = (text: success, tone: SheetMessageTone.success);
        }
      } on Object {
        status.value = (text: l10n.backupFailed, tone: SheetMessageTone.error);
      } finally {
        busy.value = false;
      }
    }

    Rect? shareOrigin() {
      final box = context.findRenderObject() as RenderBox?;
      return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    }

    Widget button(String label, IconData icon, VoidCallback onPressed) =>
        NeoButton(
          onPressed: onPressed,
          minHeight: 56,
          child: Row(
            children: [
              Icon(icon, color: context.neo.onCard),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: _buttonText(context))),
            ],
          ),
        );

    return SheetColumn(
      children: [
        SheetDescription(l10n.exportDescription),
        button(
          l10n.exportFile,
          Icons.ios_share,
          () => run(
            () async {
              await controller.exportFile(shareOrigin: shareOrigin());
              return false;
            },
            success: l10n.backupSaved,
          ),
        ),
        button(
          l10n.importFile,
          Icons.file_open_outlined,
          () => run(controller.importFile, success: l10n.backupRestored),
        ),
        if (controller.supportsICloud) ...[
          button(
            l10n.iCloudBackup,
            Icons.cloud_upload_outlined,
            () => run(
              () async {
                await controller.backupToICloud();
                return true;
              },
              success: l10n.backupSaved,
            ),
          ),
          button(
            l10n.iCloudRestore,
            Icons.cloud_download_outlined,
            () => run(
              () async {
                final restored = await controller.restoreFromICloud();
                if (!restored) {
                  status.value =
                      (text: l10n.iCloudEmpty, tone: SheetMessageTone.error);
                }
                return restored;
              },
              success: l10n.backupRestored,
            ),
          ),
        ],
        if (status.value case final status?)
          SheetMessage(status.text, tone: status.tone),
      ],
    );
  }
}
