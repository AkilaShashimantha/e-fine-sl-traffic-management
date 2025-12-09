import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../services/auth_service.dart'; 
import 'driver_home_screen.dart';

class LicenseVerificationScreen extends StatefulWidget {
  final String registeredLicenseNumber;

  const LicenseVerificationScreen({super.key, required this.registeredLicenseNumber});

  @override
  State<LicenseVerificationScreen> createState() => _LicenseVerificationScreenState();
}

class _LicenseVerificationScreenState extends State<LicenseVerificationScreen> {
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;
  bool _isSubmitting = false; 
  int _currentStep = 0;

  // Controllers for Front Side
  final _licenseNoController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();

  // Data for Back Side
  // Structure: [{ "category": "A", "issueDate": "...", "expiryDate": "..." }]
  List<Map<String, String>> extractedClasses = [];

  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          if (isFront) { _frontImage = File(image.path); } 
          else { _backImage = File(image.path); }
          _isScanning = true;
        });
        await _processImage(image.path, isFront);
      }
    } catch (e) {
      _showError("Camera Error: $e");
    }
  }

  Future<void> _processImage(String path, bool isFront) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      if (isFront) {
        _extractFrontData(recognizedText.text);
      } else {
        
        _extractBackData(recognizedText);
      }
    } catch (e) {
      _showError("Scanning Failed: $e");
    } finally {
      setState(() => _isScanning = false);
      textRecognizer.close();
    }
  }

  // --- FRONT SIDE 
  void _extractFrontData(String text) {
    // 1. License Number
    RegExp licenseNoRegExp = RegExp(r'5\.\s*([A-Z0-9\s\.\-]+)');
    RegExpMatch? licenseMatch = licenseNoRegExp.firstMatch(text);
    
    String rawLicense = "";
    if (licenseMatch != null) {
      rawLicense = licenseMatch.group(1) ?? "";
    } else {
      RegExp fallback = RegExp(r'[A-Z]\d{7}|\d{12}');
      RegExpMatch? fallbackMatch = fallback.firstMatch(text.replaceAll(' ', ''));
      if (fallbackMatch != null) rawLicense = fallbackMatch.group(0) ?? "";
    }
    
    String cleanLicense = rawLicense.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleanLicense.length > 8 && RegExp(r'^[A-Z]').hasMatch(cleanLicense)) {
        cleanLicense = cleanLicense.substring(0, 8);
    }
    _licenseNoController.text = cleanLicense;

    // 2. Dates
    RegExp dateRegExp = RegExp(r'\d{2}[./-]\d{2}[./-]\d{4}|\d{4}[./-]\d{2}[./-]\d{2}');
    List<String> foundDates = dateRegExp.allMatches(text).map((m) => m.group(0)!).toList();

    if (foundDates.length >= 2) {
      _issueDateController.text = foundDates[foundDates.length - 2]; 
      _expiryDateController.text = foundDates.last; 
    } else if (foundDates.isNotEmpty) {
      _expiryDateController.text = foundDates.last;
    }
  }

  // --- BACK SIDE (ADVANCED LOGIC) ---
  void _extractBackData(RecognizedText recognizedText) {
    List<Map<String, String>> tempClasses = [];
    // Regex pattern: (Category) (Date) (Date)
    // Example: A 12.02.2010 12.02.2018
    // 3 parts: 
    // 1. Letters (A, B1...)
    // 2. A date
    // 3. Another date
    RegExp rowPattern = RegExp(r'([A-Z][0-9]?)\s+(\d{2}[./-]\d{2}[./-]\d{4})\s+(\d{2}[./-]\d{2}[./-]\d{4})');

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text;
        
        // Check if the line matches our pattern
        RegExpMatch? match = rowPattern.firstMatch(lineText);
        
        if (match != null) {
            // If matched, extract the data
          String category = match.group(1) ?? "";
          String issue = match.group(2) ?? "";
          String expiry = match.group(3) ?? "";

            // Remove incorrect OCR readings (Noise). We check if the category is valid.
          if (['A1', 'A', 'B1', 'B', 'C1', 'C', 'CE', 'D1', 'D', 'G1', 'J'].contains(category)) {
             tempClasses.add({
               "category": category,
               "issueDate": issue,
               "expiryDate": expiry
             });
          }
        }
      }
    }

    if (tempClasses.isNotEmpty) {
      setState(() {
        extractedClasses = tempClasses;
      });
    }
  }

  // --- SUBMIT TO DATABASE ---
  Future<void> _submitData() async {
    String scannedNo = _licenseNoController.text.toUpperCase();
    String registeredNo = widget.registeredLicenseNumber.toUpperCase();

    // 1. Validation: License Number Check
    if (scannedNo.isEmpty || scannedNo != registeredNo) {
      _showDialog("Verification Failed", "License number ($scannedNo) does not match your registered number ($registeredNo).");
      return;
    }

    // 2. Validation: Data Check
    if (_issueDateController.text.isEmpty || _expiryDateController.text.isEmpty) {
      _showDialog("Incomplete Data", "Could not scan dates properly. Please try again.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 3. Backend Call
      await AuthService().verifyDriverLicense(
        issueDate: _issueDateController.text,
        expiryDate: _expiryDateController.text,
        vehicleClasses: extractedClasses,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green)
        );
        // Navigate to Home Screen (clears the navigation stack)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          (route) => false,
        );
      }

    } catch (e) {
      _showError("Save Failed: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify License"), backgroundColor: Colors.green[700], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // STEP INDICATOR
            Row(children: [_buildStepCircle(0, "Front"), _buildStepLine(0), _buildStepCircle(1, "Back"), _buildStepLine(1), _buildStepCircle(2, "Review")]),
            const SizedBox(height: 30),

            // --- STEP 0: FRONT ---
            if (_currentStep == 0) ...[
              const Text("Scan Front Side (Dates)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImagePreview(_frontImage),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: () => _pickImage(true), icon: const Icon(Icons.camera_alt), label: const Text("Scan Front")),
              if (_frontImage != null && !_isScanning) 
                Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton(onPressed: () => setState(() => _currentStep = 1), child: const Text("Next: Scan Back"))),
            ],

            // --- STEP 1: BACK ---
            if (_currentStep == 1) ...[
              const Text("Scan Back Side (Classes table)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImagePreview(_backImage),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: () => _pickImage(false), icon: const Icon(Icons.flip), label: const Text("Scan Back")),
              if (_backImage != null && !_isScanning) 
                Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton(onPressed: () => setState(() => _currentStep = 2), child: const Text("Next: Review"))),
            ],

            // --- STEP 2: REVIEW (IMPROVED UI) ---
            if (_currentStep == 2) ...[
              const Text("Verify & Save", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              _buildTextField("License No (Auto-matched)", _licenseNoController, readOnly: true),
              _buildTextField("Issue Date", _issueDateController, readOnly: true),
              _buildTextField("Expiry Date", _expiryDateController, readOnly: true),

              const SizedBox(height: 15),
              const Align(alignment: Alignment.centerLeft, child: Text("Vehicle Classes:", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 5),

              // Classes List 
              extractedClasses.isEmpty 
                ? const Text("No classes detected.", style: TextStyle(color: Colors.red))
                : Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: extractedClasses.map((item) {
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.green[100], child: Text(item['category']!)),
                          title: Text("Issued: ${item['issueDate']}"),
                          subtitle: Text("Expires: ${item['expiryDate']}"),
                          dense: true,
                        );
                      }).toList(),
                    ),
                  ),

              const SizedBox(height: 30),
              _isSubmitting 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                    child: const Text("Confirm & Save Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
              
              TextButton(onPressed: (){ setState(() => _currentStep = 0); }, child: const Text("Re-scan"))
            ],

            if (_isScanning) const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS (Same as before) ---
  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File? image) {
    return Container(
      height: 180, width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
      child: image != null ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(image, fit: BoxFit.cover)) : const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  Widget _buildStepCircle(int index, String label) {
    bool isActive = _currentStep >= index;
    return Column(children: [CircleAvatar(radius: 15, backgroundColor: isActive ? Colors.green : Colors.grey[300], child: Text("${index + 1}", style: TextStyle(color: isActive ? Colors.white : Colors.black))), Text(label, style: const TextStyle(fontSize: 10))]);
  }

  Widget _buildStepLine(int index) {
    return Expanded(child: Container(height: 2, color: _currentStep > index ? Colors.green : Colors.grey[300]));
  }
}