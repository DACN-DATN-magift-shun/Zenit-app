import 'package:flutter/material.dart';
import 'package:zenit/core/l10n/l10n.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/layout/app_bar.dart';

class TermsAndPolicyScreen extends StatelessWidget {
  const TermsAndPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BaseLayout(
      appBar: CommonAppBar(
        title: l10n.termsAndPolicy,
        showReturnIcon: true,
        onBack: () => Navigator.pop(context),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle(l10n.termsWelcomeTitle),
          _buildSectionContent(
            l10n.termsWelcomeBody1,
          ),
          _buildSectionContent(
            l10n.termsWelcomeBody2,
          ),
          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsGeneralTitle),

          _buildSubSection(
            l10n.termsEligibilityTitle,
            l10n.termsEligibilityBody,
          ),

          _buildSubSection(
            l10n.termsLawfulUseTitle,
            l10n.termsLawfulUseBody,
          ),

          _buildSubSection(
            l10n.termsIntellectualPropertyTitle,
            l10n.termsIntellectualPropertyBody,
          ),
          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsUserAccountsTitle),

          _buildSectionContent(
            l10n.termsUserAccountsBody1,
          ),

          _buildSectionContent(
            l10n.termsUserAccountsBody2,
          ),

          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsPrivacyTitle),

          _buildSectionContent(
            l10n.termsPrivacyBody1,
          ),

          _buildSectionContent(
            l10n.termsPrivacyBody2,
          ),

          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsDataSecurityTitle),

          _buildSectionContent(
            l10n.termsDataSecurityBody1,
          ),

          _buildSectionContent(
            l10n.termsDataSecurityBody2,
          ),

          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsThirdPartyTitle),

          _buildSectionContent(
            l10n.termsThirdPartyBody1,
          ),

          _buildSectionContent(
            l10n.termsThirdPartyBody2,
          ),

          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsLiabilityTitle),

          _buildSectionContent(
            l10n.termsLiabilityBody1,
          ),

          _buildSectionContent(
            l10n.termsLiabilityBody2,
          ),

          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsTerminationTitle),

          _buildSectionContent(
            l10n.termsTerminationBody,
          ),

          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsChangesTitle),

          _buildSectionContent(
            l10n.termsChangesBody,
          ),

          const SizedBox(height: 10),
          _buildSectionTitle(l10n.termsContactTitle),

          _buildSectionContent(
            l10n.termsContactBody,
          ),
          const SizedBox(height: 30), // Cho nó thoáng cái chân trang
        ],
      ),
    );
  }

  // Hàm phụ để build mấy cái title cho gọn code
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // Hàm phụ để build content
  Widget _buildSectionContent(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[800]),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // Hàm phụ build mấy cái mục nhỏ (Eligibility, Lawful Use...)
  Widget _buildSubSection(String subTitle, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
          children: [
            TextSpan(
              text: '$subTitle ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
