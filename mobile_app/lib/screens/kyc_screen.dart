// ─────────────────────────────────────────────────────────────────────────────
// lib/screens/kyc_screen.dart
// e-Fine SL — KYC Face Verification Screen
//
// Multi-step flow:
//   Step 1 → Upload or capture driving license photo (front side)
//   Step 2 → Take a live selfie using the FRONT camera
//   Step 3 → Preview both images
//   Step 4 → Submit to POST /api/kyc/verify
//   Result → Success (green) or Failure (red) with retry option
//
// Usage:
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => KycScreen(
//         onVerified: () { /* proceed with registration */ },
//       ),
//     ),
//   );
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../config/app_constants.dart';

// ─── KycScreen ───────────────────────────────────────────────────────────────

class KycScreen extends StatefulWidget {
  /// Called when the KYC verification succeeds. The caller should use this
  /// callback to proceed with the next step (e.g. final registration submit).
  final VoidCallback onVerified;

  const KycScreen({super.key, required this.onVerified});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

// ─── Step enum ───────────────────────────────────────────────────────────────

enum _KycStep { license, selfie, preview, loading, success, failure }

// ─── State ───────────────────────────────────────────────────────────────────

class _KycScreenState extends State<KycScreen> with TickerProviderStateMixin {
  // Current UI step
  _KycStep _step = _KycStep.license;

  // Captured images
  File? _licenseFile;
  File? _selfieFile;

  // Result from backend
  bool   _verified  = false;
  double _distance  = 0;
  int    _score     = 0;
  String _errorMsg  = '';

  // Animation controller for result icon
  late AnimationController _iconAnimController;
  late Animation<double>   _iconScaleAnim;

  final ImagePicker _picker = ImagePicker();

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScaleAnim = CurvedAnimation(
      parent: _iconAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    super.dispose();
  }

  // ── Image picking helpers ───────────────────────────────────────────────────

  /// Pick license from gallery or camera (rear camera preferred for documents)
  Future<void> _pickLicense(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source:       source,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (picked == null) return;
    setState(() {
      _licenseFile = File(picked.path);
      _step        = _KycStep.selfie; // Auto-advance
    });
  }

  /// Capture selfie using FRONT camera only
  Future<void> _captureSelfie() async {
    final XFile? picked = await _picker.pickImage(
      source:       ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked == null) return;
    setState(() {
      _selfieFile = File(picked.path);
      _step       = _KycStep.preview; // Auto-advance to preview
    });
  }

  // ── MIME type helper ─────────────────────────────────────────────────────────

  MediaType _getMediaType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Fallback to JPEG
    }
  }

  // ── Submission ──────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_licenseFile == null || _selfieFile == null) return;

    setState(() => _step = _KycStep.loading);

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/kyc/verify');

      // Build multipart request
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'license',
          _licenseFile!.path,
          contentType: _getMediaType(_licenseFile!.path),
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'selfie',
          _selfieFile!.path,
          contentType: _getMediaType(_selfieFile!.path),
        ),
      );

      print('🚀 [KYC] POST ${uri.toString()}');
      print('📦 Files: license=${_licenseFile?.lengthSync()}B, selfie=${_selfieFile?.lengthSync()}B');

      // Send with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timed out. Please check your connection.'),
      );

      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 [KYC] Response Status: ${response.statusCode}');
      print('📥 [KYC] Content-Type: ${response.headers['content-type']}');
      
      // Prevent parsing HTML error pages
      if (!(response.headers['content-type']?.contains('application/json') ?? false)) {
        final sample = response.body.length > 50 ? '${response.body.substring(0, 50)}...' : response.body;
        print('❌ [KYC] Non-JSON Response: $sample');
        
        setState(() {
          _step = _KycStep.failure;
          _errorMsg = 'Server Error (${response.statusCode}): Try again later.';
        });
        return;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        setState(() {
          _verified = body['verified'] == true;
          _score    = (body['score']    as num?)?.toInt()    ?? 0;
          _distance = (body['distance'] as num?)?.toDouble() ?? 1.0;
          _step     = _verified ? _KycStep.success : _KycStep.failure;
          _errorMsg = _verified ? '' : 'Face does not match the license photo.';
        });
      } else {
        // 422 = no face detected, 500 = server error
        setState(() {
          _step     = _KycStep.failure;
          _errorMsg = body['message'] as String? ?? 'Verification failed. Please try again.';
        });
      }
    } on SocketException {
      setState(() {
        _step     = _KycStep.failure;
        _errorMsg = 'No internet connection. Please check your network and retry.';
      });
    } on FormatException catch (e) {
      print('❌ [KYC] FormatException Parse Error: $e');
      setState(() {
        _step     = _KycStep.failure;
        _errorMsg = 'Bad response from server. Please try again.';
      });
    } catch (e) {
      print('❌ [KYC] Unexpected Error: $e');
      setState(() {
        _step     = _KycStep.failure;
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
    }

    // Trigger icon animation for result screens
    _iconAnimController.forward(from: 0);
  }

  // ── Reset for retry ─────────────────────────────────────────────────────────

  void _retry() {
    setState(() {
      _licenseFile = null;
      _selfieFile  = null;
      _errorMsg    = '';
      _step        = _KycStep.license;
    });
    _iconAnimController.reset();
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Identity Verification'),
        backgroundColor: AppColors.primaryGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        // Hide back arrow during loading / final result
        automaticallyImplyLeading:
            _step != _KycStep.loading && _step != _KycStep.success,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _KycStep.license:
        return _buildLicenseStep();
      case _KycStep.selfie:
        return _buildSelfieStep();
      case _KycStep.preview:
        return _buildPreviewStep();
      case _KycStep.loading:
        return _buildLoadingStep();
      case _KycStep.success:
        return _buildSuccessStep();
      case _KycStep.failure:
        return _buildFailureStep();
    }
  }

  // ── Step 1: License Photo ───────────────────────────────────────────────────

  Widget _buildLicenseStep() {
    return SingleChildScrollView(
      key: const ValueKey('license'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepIndicator(currentStep: 1, totalSteps: 3),
          const SizedBox(height: 28),

          // Illustration area
          _illustrationCard(
            icon:  Icons.credit_card,
            color: AppColors.primaryGreen,
            title: 'Driving License Photo',
            subtitle:
                'Upload a clear, well-lit photo of your driving license (front side). '
                'Make sure your face on the license is visible.',
          ),

          const SizedBox(height: 32),

          // Preview if already selected
          if (_licenseFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Image.file(_licenseFile!, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          _primaryButton(
            label:   'Take Photo',
            icon:    Icons.camera_alt,
            onTap:   () => _pickLicense(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          _secondaryButton(
            label: 'Upload from Gallery',
            icon:  Icons.photo_library,
            onTap: () => _pickLicense(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  // ── Step 2: Selfie ──────────────────────────────────────────────────────────

  Widget _buildSelfieStep() {
    return SingleChildScrollView(
      key: const ValueKey('selfie'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepIndicator(currentStep: 2, totalSteps: 3),
          const SizedBox(height: 28),

          _illustrationCard(
            icon:  Icons.face,
            color: AppColors.primaryBlue,
            title: 'Take a Live Selfie',
            subtitle:
                'Look straight at the front camera in a well-lit environment. '
                'Remove glasses or mask if possible.',
          ),

          const SizedBox(height: 32),

          if (_selfieFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Image.file(_selfieFile!, height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
          ],

          _primaryButton(
            label:   'Open Front Camera',
            icon:    Icons.camera_front,
            onTap:   _captureSelfie,
          ),
          const SizedBox(height: 12),
          _secondaryButton(
            label: 'Back',
            icon:  Icons.arrow_back,
            onTap: () => setState(() => _step = _KycStep.license),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Preview ─────────────────────────────────────────────────────────

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      key: const ValueKey('preview'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepIndicator(currentStep: 3, totalSteps: 3),
          const SizedBox(height: 24),

          const Text(
            'Review Your Photos',
            style: TextStyle(
              fontSize: AppTextSize.heading2,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Make sure both images are clear and your face is fully visible.',
            style: TextStyle(fontSize: AppTextSize.bodyMedium, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Preview cards row
          Row(
            children: [
              Expanded(child: _previewCard(label: 'License', file: _licenseFile)),
              const SizedBox(width: 12),
              Expanded(child: _previewCard(label: 'Selfie',  file: _selfieFile)),
            ],
          ),
          const SizedBox(height: 32),

          _primaryButton(
            label:   'Verify Identity',
            icon:    Icons.verified_user,
            onTap:   _submit,
          ),
          const SizedBox(height: 12),
          _secondaryButton(
            label: 'Retake Photos',
            icon:  Icons.refresh,
            onTap: _retry,
          ),
        ],
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────────

  Widget _buildLoadingStep() {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryGreen,
            strokeWidth: 3.5,
          ),
          const SizedBox(height: 28),
          Text(
            'Verifying your identity…',
            style: TextStyle(
              fontSize: AppTextSize.bodyLarge,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take up to 30 seconds.',
            style: TextStyle(
              fontSize: AppTextSize.bodySmall,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Success ─────────────────────────────────────────────────────────────────

  Widget _buildSuccessStep() {
    return Center(
      key: const ValueKey('success'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _iconScaleAnim,
              child: Container(
                width:  120,
                height: 120,
                decoration: BoxDecoration(
                  color:  AppColors.successBg,
                  shape:  BoxShape.circle,
                  border: Border.all(color: AppColors.successGreen, width: 3),
                ),
                child: const Icon(
                  Icons.verified_user,
                  size:  60,
                  color: AppColors.successGreen,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Identity Verified!',
              style: TextStyle(
                fontSize:   AppTextSize.heading1,
                fontWeight: FontWeight.bold,
                color:      AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your face matches the license photo.\nMatch score: $_score / 100',
              style: const TextStyle(
                fontSize: AppTextSize.bodyMedium,
                color:    AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon:    const Icon(Icons.arrow_forward),
                label:   const Text('Continue Registration'),
                style:   ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreenDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                onPressed: () {
                  widget.onVerified(); // Notify caller
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Failure ─────────────────────────────────────────────────────────────────

  Widget _buildFailureStep() {
    return Center(
      key: const ValueKey('failure'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _iconScaleAnim,
              child: Container(
                width:  120,
                height: 120,
                decoration: BoxDecoration(
                  color:  AppColors.errorBg,
                  shape:  BoxShape.circle,
                  border: Border.all(color: AppColors.errorRed, width: 3),
                ),
                child: const Icon(
                  Icons.cancel,
                  size:  60,
                  color: AppColors.errorRed,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Verification Failed',
              style: TextStyle(
                fontSize:   AppTextSize.heading1,
                fontWeight: FontWeight.bold,
                color:      AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMsg.isNotEmpty ? _errorMsg : 'Please try again with clearer photos.',
              style: const TextStyle(
                fontSize: AppTextSize.bodyMedium,
                color:    AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon:    const Icon(Icons.refresh),
                label:   const Text('Try Again'),
                style:   ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreenDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                onPressed: _retry,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable sub-widgets ────────────────────────────────────────────────────

  Widget _stepIndicator({required int currentStep, required int totalSteps}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isActive = i + 1 == currentStep;
        final isDone   = i + 1 < currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width:  isActive ? 32 : 24,
              height: isActive ? 32 : 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.successGreen
                    : isActive
                        ? AppColors.primaryGreen
                        : Colors.grey.shade300,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color:      isActive ? Colors.white : Colors.grey.shade600,
                          fontSize:   12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (i < totalSteps - 1)
              Container(
                width:  28,
                height: 2,
                color:  isDone ? AppColors.successGreen : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }

  Widget _illustrationCard({
    required IconData icon,
    required Color    color,
    required String   title,
    required String   subtitle,
  }) {
    return Container(
      padding:      const EdgeInsets.all(20),
      decoration:   BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color:  Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize:   AppTextSize.heading3,
              fontWeight: FontWeight.bold,
              color:      AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: AppTextSize.bodyMedium,
              color:    AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _previewCard({required String label, required File? file}) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color:      Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.medium)),
            child: file != null
                ? Image.file(file, height: 150, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 150,
                    color:  Colors.grey.shade100,
                    child:  const Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize:   AppTextSize.bodySmall,
                color:      AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String   label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        icon:  Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: AppTextSize.bodyLarge)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreenDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _secondaryButton({
    required String   label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        icon:  Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: AppTextSize.bodyMedium)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreenDark,
          side:            const BorderSide(color: AppColors.primaryGreenDark),
          shape:           RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
