import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/widget_response_model.dart';
import '../../controllers/widget_controller.dart';

class WidgetShareScreen extends StatefulWidget {
  const WidgetShareScreen({Key? key}) : super(key: key);
  
  @override
  State<WidgetShareScreen> createState() => _WidgetShareScreenState();
}

class _WidgetShareScreenState extends State<WidgetShareScreen> {
  late WidgetController _controller;
  late WidgetResponseModel widgetData;
  
  String _selectedShareType = 'link'; // link, embed, export
  String _selectedEmbedSize = 'responsive'; // responsive, fixed
  String _embedWidth = '100%';
  String _embedHeight = '600';
  
  @override
  void initState() {
    super.initState();
    _controller = Get.find<WidgetController>();
    widgetData = Get.arguments as WidgetResponseModel;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Widget'),
        actions: [
          IconButton(
            onPressed: _showShareHelp,
            icon: const Icon(LucideIcons.helpCircle, size: 22),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Widget Preview Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.layout,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widgetData.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widgetData.tagline,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Share Type Selection
          Text(
            'Share Type',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          
          // Share Options
          _buildShareOption(
            type: 'link',
            icon: LucideIcons.link,
            title: 'Share Link',
            description: 'Get a shareable link to your widget',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildShareOption(
            type: 'embed',
            icon: LucideIcons.code2,
            title: 'Embed Code',
            description: 'Embed widget in your website or app',
            isDark: isDark,
          ),
          // Export option removed - no backend support
          const SizedBox(height: 24),
          
          // Content Based on Selection
          if (_selectedShareType == 'link') _buildLinkSection(isDark),
          if (_selectedShareType == 'embed') _buildEmbedSection(isDark),
          // Export section removed - no backend support
          
          const SizedBox(height: 24),
          
          // Social Share Buttons
          Text(
            'Quick Share',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(
                icon: LucideIcons.twitter,
                label: 'Twitter',
                color: const Color(0xFF1DA1F2),
                onTap: () => _shareToSocial('twitter'),
              ),
              _buildSocialButton(
                icon: LucideIcons.linkedin,
                label: 'LinkedIn',
                color: const Color(0xFF0077B5),
                onTap: () => _shareToSocial('linkedin'),
              ),
              _buildSocialButton(
                icon: LucideIcons.mail,
                label: 'Email',
                color: AppColors.primary,
                onTap: () => _shareToSocial('email'),
              ),
              _buildSocialButton(
                icon: LucideIcons.messageCircle,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _shareToSocial('whatsapp'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildShareOption({
    required String type,
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    final isSelected = _selectedShareType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedShareType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                    ? AppColors.neutral800
                    : AppColors.neutral200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.checkCircle,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLinkSection(bool isDark) {
    final shareUrl = 'https://app.assetworks.ai/widget/${widgetData.id}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral900 : AppColors.neutral100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.neutral800 : AppColors.neutral200,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  shareUrl,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _copyToClipboard(shareUrl),
                icon: const Icon(LucideIcons.copy, size: 18),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // QR Code
        AppCard(
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.qrCode,
                    size: 100,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scan to view widget',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Privacy Settings
        CheckboxListTile(
          value: true,
          onChanged: (value) {},
          title: const Text('Public Access', style: TextStyle(fontSize: 14)),
          subtitle: Text(
            'Anyone with the link can view',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
  
  Widget _buildEmbedSection(bool isDark) {
    final embedCode = _generateEmbedCode();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Size Options
        Text(
          'Embed Size',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'responsive',
                groupValue: _selectedEmbedSize,
                onChanged: (value) {
                  setState(() {
                    _selectedEmbedSize = value!;
                    _embedWidth = '100%';
                    _embedHeight = '600';
                  });
                },
                title: const Text('Responsive', style: TextStyle(fontSize: 13)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: 'fixed',
                groupValue: _selectedEmbedSize,
                onChanged: (value) {
                  setState(() {
                    _selectedEmbedSize = value!;
                    _embedWidth = '800';
                    _embedHeight = '600';
                  });
                },
                title: const Text('Fixed', style: TextStyle(fontSize: 13)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
        
        if (_selectedEmbedSize == 'fixed') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Width (px)',
                    labelStyle: const TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _embedWidth = value,
                  controller: TextEditingController(text: _embedWidth),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Height (px)',
                    labelStyle: const TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _embedHeight = value,
                  controller: TextEditingController(text: _embedHeight),
                ),
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Embed Code
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral900 : AppColors.neutral100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.neutral800 : AppColors.neutral200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Embed Code',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(embedCode),
                    icon: const Icon(LucideIcons.copy, size: 16),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ),
              SelectableText(
                embedCode,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Export section removed - no backend support
  
  // Export option removed - no backend support
  
  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _generateEmbedCode() {
    final width = _selectedEmbedSize == 'responsive' ? '100%' : '${_embedWidth}px';
    final height = '${_embedHeight}px';
    
    return '''<iframe 
  src="https://app.assetworks.ai/embed/${widgetData.id}"
  width="$width"
  height="$height"
  frameborder="0"
  style="border: 1px solid #e5e7eb; border-radius: 8px;"
  allowfullscreen>
</iframe>''';
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  void _shareToSocial(String platform) {
    final shareUrl = 'https://app.assetworks.ai/widget/${widgetData.id}';
    final shareText = 'Check out this widget: ${widgetData.title}';
    
    // TODO: Implement actual social sharing
    Get.snackbar(
      'Share to ${platform.capitalize}',
      'Opening $platform...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // Export functionality removed - no backend support
  
  void _showShareHelp() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sharing Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: LucideIcons.link,
                title: 'Share Link',
                description: 'Share a direct link to view your widget',
              ),
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: LucideIcons.code2,
                title: 'Embed Code',
                description: 'Embed the widget in websites or applications',
              ),
              // Export help removed - no backend support
              const SizedBox(height: 12),
              _buildHelpItem(
                icon: LucideIcons.shield,
                title: 'Privacy',
                description: 'Control who can access your shared widgets',
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}