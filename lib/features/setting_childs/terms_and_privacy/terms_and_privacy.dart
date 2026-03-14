import 'package:flutter/material.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/layout/app_bar.dart';

class TermsAndPolicyScreen extends StatelessWidget {
  const TermsAndPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      appBar: CommonAppBar(
        title: 'Terms and Policy',
        showReturnIcon: true,
        onBack: () => Navigator.pop(context),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle('1. Welcome to Zenit'),
          _buildSectionContent(
            'Welcome to Zenit! We are delighted that you have chosen to use our application. '
            'To ensure you feel secure while using our services, Zenit has prepared these '
            'comprehensive Terms of Service and Privacy Policy. This document clearly outlines '
            'your rights and obligations, and explains how we manage your personal data.',
          ),
          _buildSectionContent(
            'By continuing to use the Zenit application, you confirm that you have read, '
            'understood, and agreed to all the terms outlined below.',
          ),
          const SizedBox(height: 10),
          _buildSectionTitle('2. General Terms of Service'),

          _buildSubSection(
            '1. Eligibility:',
            'You affirm that you are of legal age (typically 16 years old or older, depending on '
                'applicable law) to enter into these binding legal agreements. If you are under this age, '
                'please use the application under the supervision of a parent or guardian.',
          ),

          _buildSubSection(
            '2. Lawful Use:',
            'You agree to use Zenit for lawful purposes only, without violating any current laws, '
                'and without causing harm, annoyance, or disruption to the experience of other users.',
          ),

          _buildSubSection(
            '3. Intellectual Property:',
            'All content (design, text, graphics, etc.) within Zenit is the property of us '
                '(or our licensors). You are permitted to use this content through the application '
                'but are not allowed to copy, distribute, or modify it without permission.',
          ),
          const SizedBox(height: 10),
          _buildSectionTitle('3. User Accounts'),

          _buildSectionContent(
            'To access certain features of Zenit, users may be required to create an account. '
            'You are responsible for maintaining the confidentiality of your login credentials '
            'and for all activities that occur under your account. Zenit will not be liable for '
            'any loss or damage arising from your failure to comply with these obligations.',
          ),

          _buildSectionContent(
            'You agree to provide accurate, complete, and up-to-date information when creating '
            'your account. If we suspect that the information you provided is false or misleading, '
            'we reserve the right to suspend or terminate your account at any time.',
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('4. Privacy and Data Collection'),

          _buildSectionContent(
            'Zenit respects your privacy and is committed to protecting your personal data. '
            'We may collect certain information such as your email address, usage data, and '
            'device information in order to provide and improve our services.',
          ),

          _buildSectionContent(
            'This information may be used for authentication, security monitoring, analytics, '
            'and improving user experience. We do not sell your personal data to third parties.',
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('5. Data Security'),

          _buildSectionContent(
            'We implement reasonable security measures to protect your personal information '
            'from unauthorized access, alteration, disclosure, or destruction. However, no '
            'method of electronic storage or transmission over the internet is completely secure.',
          ),

          _buildSectionContent(
            'While we strive to use commercially acceptable means to protect your data, '
            'we cannot guarantee its absolute security.',
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('6. Third-Party Services'),

          _buildSectionContent(
            'Zenit may integrate or rely on third-party services such as analytics providers, '
            'cloud storage, or authentication systems. These services may collect information '
            'in accordance with their own privacy policies.',
          ),

          _buildSectionContent(
            'We encourage users to review the privacy policies of any third-party services '
            'that may interact with the Zenit application.',
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('7. Limitation of Liability'),

          _buildSectionContent(
            'Zenit is provided on an "as-is" and "as-available" basis. We do not guarantee that '
            'the application will be uninterrupted, secure, or error-free.',
          ),

          _buildSectionContent(
            'Under no circumstances shall Zenit or its developers be liable for any indirect, '
            'incidental, special, or consequential damages resulting from the use or inability '
            'to use the application.',
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('8. Termination'),

          _buildSectionContent(
            'We reserve the right to suspend or terminate your access to the application at '
            'any time without prior notice if you violate these terms or engage in behavior '
            'that may harm the application or other users.',
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('9. Changes to These Policies'),

          _buildSectionContent(
            'Zenit may update these Terms of Service and Privacy Policy from time to time. '
            'Any updates will be reflected within the application, and continued use of the '
            'application after such updates constitutes acceptance of the revised terms.',
          ),

          const SizedBox(height: 10),
          _buildSectionTitle('10. Contact Us'),

          _buildSectionContent(
            'If you have any questions regarding these Terms and Privacy Policy, please contact '
            'our support team through the contact information provided within the application.',
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
