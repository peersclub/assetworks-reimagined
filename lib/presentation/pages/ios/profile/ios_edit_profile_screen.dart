import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import '../../../../core/theme/ios18_theme.dart';
import '../../../../core/services/dynamic_island_service.dart';

class iOSEditProfileScreen extends StatefulWidget {
  const iOSEditProfileScreen({super.key});

  @override
  State<iOSEditProfileScreen> createState() => _iOSEditProfileScreenState();
}

class _iOSEditProfileScreenState extends State<iOSEditProfileScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _usernameController = TextEditingController(text: '@johndoe');
  final TextEditingController _emailController = TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '+1 234 567 8900');
  final TextEditingController _bioController = TextEditingController(text: 'Passionate investor and trader. Love analyzing market trends and building wealth through smart investments.');
  final TextEditingController _websiteController = TextEditingController(text: 'johndoe.com');
  final TextEditingController _locationController = TextEditingController(text: 'San Francisco, CA');
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isLoading = false;
  bool _hasChanges = false;
  File? _selectedImage;
  String _selectedPrivacy = 'public';
  bool _enableNotifications = true;
  bool _showActivityStatus = true;
  bool _allowMessages = true;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
    
    // Add listeners to detect changes
    _nameController.addListener(_onFieldChanged);
    _usernameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }
  
  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Change Profile Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Implement camera picker
              setState(() {
                _hasChanges = true;
              });
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Implement gallery picker
              setState(() {
                _hasChanges = true;
              });
            },
            child: const Text('Choose from Library'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
  
  Future<void> _saveProfile() async {
    if (!_hasChanges) return;
    
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });
    
    DynamicIslandService.showProgress('Updating profile...');
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _hasChanges = false;
    });
    
    DynamicIslandService.showSuccess('Profile updated!');
    Navigator.of(context).pop(true);
  }
  
  void _showDiscardDialog() {
    HapticFeedback.heavyImpact();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Editing'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: iOS18Theme.primaryBackground.resolveFrom(context).withOpacity(0.8),
        border: null,
        middle: const Text('Edit Profile'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            if (_hasChanges) {
              _showDiscardDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: iOS18Theme.systemBlue,
            ),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : Text(
                  'Save',
                  style: TextStyle(
                    color: _hasChanges
                        ? iOS18Theme.systemBlue
                        : iOS18Theme.tertiaryLabel.resolveFrom(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: CustomScrollView(
                  slivers: [
                    // Profile photo section
                    SliverToBoxAdapter(
                      child: _buildProfilePhotoSection(),
                    ),
                    
                    // Basic info section
                    SliverToBoxAdapter(
                      child: _buildSection(
                        'BASIC INFORMATION',
                        [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Name',
                            icon: CupertinoIcons.person,
                          ),
                          _buildTextField(
                            controller: _usernameController,
                            label: 'Username',
                            icon: CupertinoIcons.at,
                          ),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: CupertinoIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            icon: CupertinoIcons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    
                    // Bio section
                    SliverToBoxAdapter(
                      child: _buildSection(
                        'ABOUT',
                        [
                          _buildTextArea(
                            controller: _bioController,
                            label: 'Bio',
                            maxLines: 4,
                          ),
                          _buildTextField(
                            controller: _websiteController,
                            label: 'Website',
                            icon: CupertinoIcons.globe,
                            keyboardType: TextInputType.url,
                          ),
                          _buildTextField(
                            controller: _locationController,
                            label: 'Location',
                            icon: CupertinoIcons.location,
                          ),
                        ],
                      ),
                    ),
                    
                    // Privacy settings
                    SliverToBoxAdapter(
                      child: _buildSection(
                        'PRIVACY',
                        [
                          _buildPrivacySelector(),
                          _buildSwitch(
                            'Show Activity Status',
                            _showActivityStatus,
                            (value) {
                              setState(() {
                                _showActivityStatus = value;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildSwitch(
                            'Allow Messages',
                            _allowMessages,
                            (value) {
                              setState(() {
                                _allowMessages = value;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildSwitch(
                            'Enable Notifications',
                            _enableNotifications,
                            (value) {
                              setState(() {
                                _enableNotifications = value;
                                _hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Danger zone
                    SliverToBoxAdapter(
                      child: _buildDangerZone(),
                    ),
                    
                    const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildProfilePhotoSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iOS18Theme.systemBlue,
                        iOS18Theme.systemIndigo,
                      ],
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Text(
                            'JD',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iOS18Theme.systemBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: iOS18Theme.primaryBackground.resolveFrom(context),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change photo',
            style: TextStyle(
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, top: 24),
            child: Text(
              title,
              style: TextStyle(
                color: iOS18Theme.secondaryLabel.resolveFrom(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iOS18Theme.secondaryLabel.resolveFrom(context),
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Enter $label',
              placeholderStyle: TextStyle(
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 16,
              ),
              decoration: null,
              padding: EdgeInsets.zero,
              textAlign: TextAlign.right,
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iOS18Theme.tertiarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Tell us about yourself',
              placeholderStyle: TextStyle(
                color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              ),
              style: TextStyle(
                color: iOS18Theme.label.resolveFrom(context),
                fontSize: 15,
              ),
              decoration: null,
              padding: EdgeInsets.zero,
              maxLines: maxLines,
              minLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrivacySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Profile Visibility',
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          CupertinoSlidingSegmentedControl<String>(
            groupValue: _selectedPrivacy,
            onValueChanged: (value) {
              if (value != null) {
                HapticFeedback.selectionFeedback();
                setState(() {
                  _selectedPrivacy = value;
                  _hasChanges = true;
                });
              }
            },
            children: {
              'public': Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Public',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              'private': Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Private',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: iOS18Theme.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: iOS18Theme.label.resolveFrom(context),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          CupertinoSwitch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              onChanged(newValue);
            },
            activeColor: iOS18Theme.systemGreen,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDangerZone() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
            child: Text(
              'DANGER ZONE',
              style: TextStyle(
                color: iOS18Theme.systemRed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: iOS18Theme.secondarySystemGroupedBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iOS18Theme.systemRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildDangerButton(
                  'Deactivate Account',
                  'Temporarily disable your account',
                  CupertinoIcons.pause_circle,
                  () {
                    HapticFeedback.heavyImpact();
                    // Handle deactivation
                  },
                ),
                _buildDangerButton(
                  'Delete Account',
                  'Permanently delete your account and data',
                  CupertinoIcons.trash,
                  () {
                    HapticFeedback.heavyImpact();
                    // Handle deletion
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDangerButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: iOS18Theme.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iOS18Theme.systemRed,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: iOS18Theme.systemRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: iOS18Theme.secondaryLabel.resolveFrom(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: iOS18Theme.tertiaryLabel.resolveFrom(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}