import 'package:flutter/material.dart';
import '../../objects/singletons/crash_reporter.dart';

Future<void> showCrashlyticsConsentDialog(BuildContext context, ) async {

  // Si l'utlisateur a choisi, alors on n'affiche rien, sinon on le fait choisir
  if (CrashReporter().consent == null) {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Autoriser l\'envoi des rapports de plantage ?',
          ),
          content: const Text(
            'Ces rapports servent à analyser les problèmes rencontrés afin d\'améliorer l\'application.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Non'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );

    // On applique le choix
    if (accepted != null) {
      CrashReporter().setConsent(accepted);
    }
    CrashReporter().refreshConsent();
  }
}