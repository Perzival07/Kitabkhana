import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_config.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// Version, licences, privacy link and a small sign-off.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(KSpacing.screen),
              children: <Widget>[
                const SizedBox(height: KSpacing.xl),
                const Center(child: KWordmark(size: 32)),
                const SizedBox(height: KSpacing.sm),
                Center(
                  child: Text(
                    l10n.aboutVersion(kAppVersion),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: KSpacing.lg),
                Text(
                  l10n.aboutTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: KSpacing.xl),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.aboutLicenses),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appName,
                    applicationVersion: kAppVersion,
                  ),
                ),
                if (kPrivacyPolicyUrl.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l10n.aboutPrivacyPolicy),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => launchUrl(
                      Uri.parse(kPrivacyPolicyUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                const SizedBox(height: KSpacing.huge),
                Center(
                  child: Text(
                    l10n.aboutMadeWithCare,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: KSpacing.sm),
                const Center(child: KWordmark(size: 18, showGlyph: false)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
