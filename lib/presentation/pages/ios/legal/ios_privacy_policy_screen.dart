import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/ios18_theme.dart';

class iOSPrivacyPolicyScreen extends StatefulWidget {
  const iOSPrivacyPolicyScreen({super.key});

  @override
  State<iOSPrivacyPolicyScreen> createState() => _iOSPrivacyPolicyScreenState();
}

class _iOSPrivacyPolicyScreenState extends State<iOSPrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  
  final String _lastUpdated = 'December 15, 2024';
  final String _effectiveDate = 'January 1, 2025';
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
      });
    }
  }
  
  void _acceptPolicy() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(true);
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        middle: Column(
          children: [
            const Text('Privacy Policy'),
            if (_scrollProgress > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 150,
                  height: 2,
                  child: LinearProgressIndicator(
                    value: _scrollProgress,
                    backgroundColor: iOS18Theme.separator.resolveFrom(context),
                    valueColor: AlwaysStoppedAnimation(iOS18Theme.systemBlue),
                  ),
                ),
              ),
          ],
        ),
        previousPageTitle: 'Settings',
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),
                  
                  // Table of Contents
                  SliverToBoxAdapter(
                    child: _buildTableOfContents(),
                  ),
                  
                  // Sections
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '1. Information We Collect',
                      '''We collect information you provide directly to us, such as when you create an account, use our services, or contact us for support.

Personal Information:
• Name and email address
• Phone number (optional)
• Profile information
• Payment information (processed securely by our payment providers)

Financial Data:
• Portfolio holdings and transactions
• Watchlist preferences
• Alert settings
• Investment goals and risk preferences

Usage Information:
• Device information (device type, operating system, unique identifiers)
• Log data (IP address, browser type, pages visited, time spent)
• Location data (with your permission)
• Widget configuration and usage patterns''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '2. How We Use Your Information',
                      '''We use the information we collect to:

• Provide, maintain, and improve our services
• Process transactions and send related information
• Send technical notices, updates, and support messages
• Respond to your comments and questions
• Monitor and analyze trends, usage, and activities
• Detect, investigate, and prevent fraudulent transactions
• Personalize and improve your experience
• Deliver relevant content and advertisements
• Comply with legal obligations''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '3. Information Sharing',
                      '''We do not sell, trade, or rent your personal information to third parties. We may share your information in the following situations:

Service Providers:
• With vendors and service providers who perform services on our behalf
• Payment processors for secure transaction handling
• Analytics providers to improve our services

Legal Requirements:
• When required by law or to respond to legal process
• To protect our rights, privacy, safety, or property
• To enforce our terms of service

Business Transfers:
• In connection with a merger, acquisition, or sale of assets

With Your Consent:
• With your explicit consent for any other purpose''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '4. Data Security',
                      '''We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

Security Measures:
• 256-bit SSL encryption for data transmission
• Encrypted storage of sensitive information
• Regular security audits and penetration testing
• Limited access to personal information by employees
• Two-factor authentication available
• Automatic session timeout for inactive users

While we strive to protect your personal information, no method of transmission over the Internet or electronic storage is 100% secure.''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '5. Your Rights and Choices',
                      '''You have certain rights regarding your personal information:

Access and Update:
• Access your personal information through your account settings
• Update or correct inaccurate information
• Request a copy of your data

Delete:
• Request deletion of your account and associated data
• Note: Some information may be retained for legal purposes

Opt-Out:
• Unsubscribe from marketing emails
• Disable push notifications
• Limit ad tracking in your device settings

Data Portability:
• Request your data in a structured, machine-readable format

Object to Processing:
• Object to certain types of processing of your personal information''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '6. Children\'s Privacy',
                      '''Our services are not directed to individuals under 18. We do not knowingly collect personal information from children under 18. If you become aware that a child has provided us with personal information, please contact us.''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '7. International Data Transfers',
                      '''Your information may be transferred to and maintained on servers located outside of your state, province, or country. By using our services, you consent to the transfer of your information to the United States and other countries.''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '8. Third-Party Services',
                      '''Our services may contain links to third-party websites and services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies.

Third-party services include:
• Market data providers
• Payment processors
• Analytics services
• Social media platforms''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '9. Cookies and Tracking',
                      '''We use cookies and similar tracking technologies to:

• Remember your preferences
• Understand how you use our services
• Provide personalized content
• Measure advertising effectiveness

You can manage cookie preferences through your browser settings.''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '10. Changes to This Policy',
                      '''We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.

Your continued use of our services after any changes indicates your acceptance of the updated Privacy Policy.''',
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '11. Contact Us',
                      '''If you have questions about this Privacy Policy, please contact us:

AssetWorks, Inc.
Privacy Team
1 Market Street, Suite 3600
San Francisco, CA 94105

Email: privacy@assetworks.com
Phone: 1-800-PRIVACY
Website: www.assetworks.com/privacy''',
                    ),
                  ),
                  
                  // Footer
                  SliverToBoxAdapter(
                    child: _buildFooter(),
                  ),
                  
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            ),
            
            // Accept button
            _buildAcceptButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: iOS18Theme.systemBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Last Updated: $_lastUpdated',
              style: TextStyle(
                color: iOS18Theme.systemBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Privacy Matters',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This Privacy Policy explains how AssetWorks collects, uses, and protects your information when you use our services.',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iOS18Theme.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iOS18Theme.systemGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.shield_fill,
                  color: iOS18Theme.systemGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We are committed to protecting your privacy and securing your data.',
                    style: TextStyle(
                      color: iOS18Theme.label.resolveFrom(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTableOfContents() {
    final sections = [
      'Information We Collect',
      'How We Use Your Information',
      'Information Sharing',
      'Data Security',
      'Your Rights and Choices',
      'Children\'s Privacy',
      'International Data Transfers',
      'Third-Party Services',
      'Cookies and Tracking',
      'Changes to This Policy',
      'Contact Us',
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table of Contents',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sections.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Scroll to section
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        color: iOS18Theme.systemBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: iOS18Theme.systemBlue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.checkmark_seal_fill,
            color: iOS18Theme.systemGreen,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Effective Date: $_effectiveDate',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By using AssetWorks, you agree to this Privacy Policy',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAcceptButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: CupertinoButton(
          color: iOS18Theme.systemBlue,
          borderRadius: BorderRadius.circular(12),
          onPressed: _acceptPolicy,
          child: const Text(
            'I Understand',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}