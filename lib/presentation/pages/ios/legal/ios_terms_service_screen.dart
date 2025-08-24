import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSTermsServiceScreen extends StatefulWidget {
  const iOSTermsServiceScreen({super.key});

  @override
  State<iOSTermsServiceScreen> createState() => _iOSTermsServiceScreenState();
}

class _iOSTermsServiceScreenState extends State<iOSTermsServiceScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkAnimation;
  
  double _scrollProgress = 0.0;
  bool _hasScrolledToBottom = false;
  bool _acceptedTerms = false;
  
  final String _version = '2.0';
  final String _lastUpdated = 'December 15, 2024';
  final String _effectiveDate = 'January 1, 2025';
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.easeOutBack,
    ));
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }
  
  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
        
        if (!_hasScrolledToBottom && _scrollProgress > 0.95) {
          _hasScrolledToBottom = true;
          HapticFeedback.lightImpact();
        }
      });
    }
  }
  
  void _toggleAcceptance() {
    if (!_hasScrolledToBottom) {
      HapticFeedback.heavyImpact();
      _showScrollAlert();
      return;
    }
    
    HapticFeedback.mediumImpact();
    setState(() {
      _acceptedTerms = !_acceptedTerms;
    });
    
    if (_acceptedTerms) {
      _checkmarkController.forward();
    } else {
      _checkmarkController.reverse();
    }
  }
  
  void _showScrollAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Please Read Terms'),
        content: const Text('You must read through the entire Terms of Service before accepting.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _confirmAcceptance() {
    if (!_acceptedTerms) {
      HapticFeedback.heavyImpact();
      return;
    }
    
    HapticFeedback.notificationFeedback(HapticFeedbackType.success);
    DynamicIslandService.showSuccess('Terms accepted!');
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
            const Text('Terms of Service'),
            if (_scrollProgress > 0)
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 150,
                  height: 2,
                  child: LinearProgressIndicator(
                    value: _scrollProgress,
                    backgroundColor: iOS18Theme.separator.resolveFrom(context),
                    valueColor: AlwaysStoppedAnimation(
                      _hasScrolledToBottom ? iOS18Theme.systemGreen : iOS18Theme.systemBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
        previousPageTitle: 'Back',
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
                  
                  // Important notice
                  SliverToBoxAdapter(
                    child: _buildImportantNotice(),
                  ),
                  
                  // Sections
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '1. Acceptance of Terms',
                      '''By accessing or using AssetWorks ("Service"), you agree to be bound by these Terms of Service ("Terms"). If you disagree with any part of these terms, you may not access the Service.

These Terms apply to all visitors, users, and others who access or use the Service. By accessing or using the Service, you agree to be bound by these Terms and our Privacy Policy.

We reserve the right to update and change these Terms at any time without notice. Continued use of the Service after any such changes constitutes your acceptance of the new Terms.''',
                      CupertinoIcons.doc_checkmark,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '2. Description of Service',
                      '''AssetWorks provides a financial portfolio management and tracking platform that includes:

• Real-time market data and analytics
• Portfolio tracking and management tools
• Home screen widgets and notifications
• Investment insights and recommendations
• Social features and community discussions

The Service is provided "as is" and "as available" without any warranties, express or implied. We do not guarantee that the Service will be uninterrupted, secure, or error-free.''',
                      CupertinoIcons.app_badge,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '3. User Accounts',
                      '''Account Creation:
• You must provide accurate and complete information
• You are responsible for maintaining account security
• You must be at least 18 years old to use the Service
• One person or legal entity may maintain only one account

Account Security:
• Keep your password confidential
• Notify us immediately of any unauthorized access
• You are responsible for all activities under your account

Account Termination:
• You may delete your account at any time
• We may suspend or terminate accounts that violate these Terms
• Upon termination, your right to use the Service will cease''',
                      CupertinoIcons.person_crop_circle,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '4. User Conduct',
                      '''You agree not to:

• Violate any laws or regulations
• Infringe on intellectual property rights
• Transmit malicious code or viruses
• Attempt to gain unauthorized access
• Harass, abuse, or harm other users
• Spam or send unsolicited communications
• Manipulate or interfere with the Service
• Create multiple accounts or false identities
• Use the Service for illegal activities
• Scrape or copy content without permission

We reserve the right to investigate and take action against violations of these rules, including account termination and legal action.''',
                      CupertinoIcons.hand_raised,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '5. Financial Information Disclaimer',
                      '''IMPORTANT: The Service provides financial information for informational purposes only and should not be construed as investment advice.

• We are not a registered investment advisor
• Content is not personalized financial advice
• Past performance does not guarantee future results
• You should consult with qualified professionals
• We are not responsible for investment decisions
• Market data may be delayed or inaccurate

You acknowledge that all investment decisions are made at your own risk, and we are not liable for any losses or damages resulting from your use of the Service.''',
                      CupertinoIcons.exclamationmark_triangle,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '6. Intellectual Property',
                      '''Ownership:
• The Service and its content are owned by AssetWorks
• This includes design, features, and functionality
• Protected by copyright, trademark, and other laws

License to Use:
• We grant you a limited, non-exclusive license
• For personal, non-commercial use only
• You may not copy, modify, or distribute our content
• You retain ownership of content you create

User Content:
• You grant us a license to use your content
• We may display, distribute, and modify it
• You are responsible for your content
• We may remove content that violates these Terms''',
                      CupertinoIcons.lock_shield,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '7. Privacy and Data Protection',
                      '''Your privacy is important to us. Our Privacy Policy explains:

• What information we collect
• How we use and protect your data
• Your rights regarding your information
• How to contact us about privacy concerns

By using the Service, you consent to our collection and use of information as described in the Privacy Policy.''',
                      CupertinoIcons.shield,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '8. Subscription and Payments',
                      '''Premium Features:
• Some features require a paid subscription
• Prices are subject to change with notice
• Subscriptions auto-renew unless cancelled

Billing:
• Payment processed through app stores
• You agree to pay all applicable fees
• No refunds for partial subscription periods

Cancellation:
• You may cancel anytime through your account
• Access continues until the end of billing period
• No refunds for unused time''',
                      CupertinoIcons.creditcard,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '9. Third-Party Services',
                      '''The Service may contain links to third-party services:

• We are not responsible for third-party content
• Third-party terms and policies apply
• Use third-party services at your own risk
• We don't endorse third-party services

Market data is provided by third-party providers and may be subject to additional terms and conditions.''',
                      CupertinoIcons.link,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '10. Limitation of Liability',
                      '''TO THE MAXIMUM EXTENT PERMITTED BY LAW:

• THE SERVICE IS PROVIDED "AS IS"
• WE DISCLAIM ALL WARRANTIES
• WE ARE NOT LIABLE FOR ANY DAMAGES
• INCLUDING LOST PROFITS OR DATA
• OUR LIABILITY IS LIMITED TO FEES PAID
• SOME JURISDICTIONS DON'T ALLOW LIMITATIONS

You agree to indemnify and hold us harmless from any claims arising from your use of the Service.''',
                      CupertinoIcons.exclamationmark_octagon,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '11. Dispute Resolution',
                      '''Any disputes will be resolved through:

• Good faith negotiations
• Binding arbitration if negotiations fail
• Arbitration under AAA rules
• Individual claims only (no class actions)
• Venue in San Francisco, California

You may opt out of arbitration within 30 days of accepting these Terms by sending written notice.''',
                      CupertinoIcons.scales,
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildSection(
                      '12. General Provisions',
                      '''Governing Law:
• These Terms are governed by California law
• Excluding conflict of law provisions

Severability:
• Invalid provisions will be modified or removed
• Remaining Terms continue in full effect

Entire Agreement:
• These Terms constitute the entire agreement
• Supersede all prior agreements

Contact:
• AssetWorks, Inc.
• legal@assetworks.com
• 1-800-LEGAL''',
                      CupertinoIcons.doc_text,
                    ),
                  ),
                  
                  // Footer
                  SliverToBoxAdapter(
                    child: _buildFooter(),
                  ),
                  
                  const SliverPadding(padding: EdgeInsets.only(bottom: 150)),
                ],
              ),
            ),
            
            // Accept section
            _buildAcceptSection(),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iOS18Theme.systemIndigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Version $_version',
                  style: TextStyle(
                    color: iOS18Theme.systemIndigo,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iOS18Theme.systemBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Updated: $_lastUpdated',
                  style: TextStyle(
                    color: iOS18Theme.systemBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Terms of Service',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please read these terms carefully before using AssetWorks',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImportantNotice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iOS18Theme.systemRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iOS18Theme.systemRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            color: iOS18Theme.systemRed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Legal Agreement',
                  style: TextStyle(
                    color: iOS18Theme.systemRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This is a binding legal agreement. By using our service, you agree to these terms.',
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iOS18Theme.systemBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iOS18Theme.systemBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: iOS18Theme.label.resolveFrom(context),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 15,
                height: 1.5,
              ),
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
        gradient: LinearGradient(
          colors: [
            iOS18Theme.systemIndigo.withOpacity(0.1),
            iOS18Theme.systemBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iOS18Theme.systemBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.doc_text_fill,
            color: iOS18Theme.systemBlue,
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
            'These terms constitute a legal agreement between you and AssetWorks, Inc.',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_hasScrolledToBottom)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: iOS18Theme.systemGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'You have read all terms',
                  style: TextStyle(
                    color: iOS18Theme.systemGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildAcceptSection() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
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
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleAcceptance,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _acceptedTerms
                            ? iOS18Theme.systemGreen
                            : iOS18Theme.separator.resolveFrom(context),
                        width: _acceptedTerms ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _checkmarkAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _acceptedTerms
                                    ? iOS18Theme.systemGreen
                                    : iOS18Theme.tertiarySystemGroupedBackground.resolveFrom(context),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _acceptedTerms
                                      ? iOS18Theme.systemGreen
                                      : iOS18Theme.separator.resolveFrom(context),
                                  width: 2,
                                ),
                              ),
                              child: _acceptedTerms
                                  ? Transform.scale(
                                      scale: _checkmarkAnimation.value,
                                      child: const Icon(
                                        CupertinoIcons.checkmark,
                                        color: CupertinoColors.white,
                                        size: 16,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I have read and agree to the Terms of Service',
                            style: TextStyle(
                              color: iOS18Theme.label.resolveFrom(context),
                              fontSize: 16,
                              fontWeight: _acceptedTerms ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: _acceptedTerms ? iOS18Theme.systemBlue : iOS18Theme.tertiarySystemGroupedBackground.resolveFrom(context),
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _acceptedTerms ? _confirmAcceptance : null,
                    child: Text(
                      'Accept & Continue',
                      style: TextStyle(
                        color: _acceptedTerms
                            ? CupertinoColors.white
                            : iOS18Theme.tertiaryLabel.resolveFrom(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}