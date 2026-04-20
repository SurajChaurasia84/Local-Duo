import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/issue.dart';
import '../providers/issue_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class PreviewScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final bool isMock;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    this.isMock = false,
  });

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  late String _currentImagePath;
  Position? _currentPosition;
  String _currentAddress = 'Fetching location...';
  bool _isFetchingLocation = true;
  String _reportId = 'FETCHING...';

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _fetchLocation();
  }

  String _getCityCode(String? city) {
    if (city == null) return 'IND';
    final name = city.trim().toUpperCase();
    
    final Map<String, String> stationCodes = {
      'DELHI': 'NDLS', 'NEW DELHI': 'NDLS', 'MUMBAI': 'CSTM', 'BOMBAY': 'CSTM',
      'KOLKATA': 'HWH', 'CALCUTTA': 'HWH', 'CHENNAI': 'MAS', 'MADRAS': 'MAS',
      'BANGALORE': 'SBC', 'BENGALURU': 'SBC', 'HYDERABAD': 'SC', 'SECUNDERABAD': 'SC',
      'AHMEDABAD': 'ADI', 'PUNE': 'PUNE', 'JAIPUR': 'JP', 'LUCKNOW': 'LKO',
      'GORAKHPUR': 'GKP', 'KANPUR': 'CNB', 'VARANASI': 'BSB', 'BANARAS': 'BSB',
      'PATNA': 'PNBE', 'BHOPAL': 'BPL', 'INDORE': 'INDB', 'RAIPUR': 'R',
      'RANCHI': 'RNC', 'BHUBANESWAR': 'BBS', 'GUWAHATI': 'GHY', 'CHANDIGARH': 'CDG',
      'LUDHIANA': 'LDH', 'AMRITSAR': 'ASR', 'JALANDHAR': 'JUC', 'MEERUT': 'MTC',
      'AGRA': 'AGC', 'GWALIOR': 'GWL', 'JABALPUR': 'JBP', 'NAGPUR': 'NGP',
      'SURAT': 'ST', 'VADODARA': 'BRC', 'NASHIK': 'NK', 'AURANGABAD': 'AWB',
      'GOA': 'MAO', 'KOCHI': 'ERS', 'TRIVANDRUM': 'TVC', 'COIMBATORE': 'CBE',
      'MADURAI': 'MDU', 'VIJAYAWADA': 'BZA', 'VISAKHAPATNAM': 'VSKP', 'MYSORE': 'MYS',
      'SHIMLA': 'SML', 'JAMMU': 'JAT', 'DEHRADUN': 'DDN', 'PRAYAGRAJ': 'PRYJ',
      'ALLAHABAD': 'PRYJ', 'GAYA': 'GAYA', 'DHANBAD': 'DHN', 'JHANSI': 'VGLJ',
    };

    for (var entry in stationCodes.entries) {
      if (name.contains(entry.key)) return entry.value;
    }

    String code = name.replaceAll(RegExp(r'[AEIOU\s]'), '');
    if (code.length >= 3) return code.substring(0, 3);
    
    return name.length >= 3 ? name.substring(0, 3) : 'IND';
  }

  String _generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    String result = '';
    for (int i = 0; i < length; i++) {
        result += chars[(random + i * 7) % chars.length];
    }
    return result;
  }

  String _generateUniqueId(String cityCode) {
    final randomPart = _generateSecureRandomString(10);
    final timeSuffix = DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase();
    return '${cityCode}RP$randomPart$timeSuffix';
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _currentAddress = 'Location Unavailable';
            _isFetchingLocation = false;
            _reportId = _generateUniqueId('IND');
          });
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentAddress = 'Location Permission Denied';
              _isFetchingLocation = false;
              _reportId = _generateUniqueId('IND');
            });
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (mounted) {
        final p = placemarks.isNotEmpty ? placemarks.first : null;
        final cityCode = _getCityCode(p?.locality);
        
        setState(() {
          _currentPosition = position;
          if (p != null) {
            _currentAddress = '${p.street}, ${p.subLocality}, ${p.locality}';
          }
          _reportId = _generateUniqueId(cityCode);
          _isFetchingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Location error';
          _isFetchingLocation = false;
          _reportId = _generateUniqueId('IND');
        });
      }
    }
  }
  
  Future<void> _openEditor() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.file(
          File(_currentImagePath),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {
              final tempDir = await getTemporaryDirectory();
              final editedFile = File('${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg');
              await editedFile.writeAsBytes(bytes);
              
              if (mounted) {
                setState(() {
                  _currentImagePath = editedFile.path;
                });
                if (context.mounted) Navigator.pop(context); // Go back to PreviewScreen
              }
            },
          ),
          configs: const ProImageEditorConfigs(
            designMode: ImageEditorDesignMode.material,
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage() {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: widget.isMock 
                  ? Image.network(_currentImagePath, fit: BoxFit.contain)
                  : Image.file(File(_currentImagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final String description = _captionController.text.trim().isEmpty 
        ? 'No description' 
        : _captionController.text.trim();

    final issue = Issue(
      id: _reportId, 
      caption: description,
      imagePath: _currentImagePath, 
      location: _currentAddress,
      latitude: _currentPosition?.latitude ?? 0.0,
      longitude: _currentPosition?.longitude ?? 0.0,
    );

    final success = await ref.read(submitIssueProvider.notifier).submit(issue);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Issue reported successfully!'),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = ref.watch(submitIssueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Report?'),
            content: const Text('If you go back now, your report will be lost. Are you sure you want to discard it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'DISCARD', 
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Report ID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                _reportId,
                style: TextStyle(
                  fontSize: 13, 
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showFullScreenImage,
                            child: Hero(
                              tag: 'preview_image',
                              child: widget.isMock 
                                ? Image.network(_currentImagePath, width: 180, fit: BoxFit.contain)
                                : Image.file(File(_currentImagePath), width: 180, fit: BoxFit.contain),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                onPressed: _openEditor,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _isFetchingLocation ? null : _fetchLocation,
                      borderRadius: BorderRadius.circular(12),
                      child: _infoChip(
                        Icons.location_on, 
                        _currentAddress,
                        isLoading: _isFetchingLocation,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _captionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue...',
                        filled: true,
                        fillColor: Theme.of(context).cardTheme.color,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ElevatedButton(
            onPressed: submissionState.isLoading ? null : _submit,
            child: submissionState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('SUBMIT REPORT'),
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, {bool isLoading = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label, 
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget choiceChip(dynamic category, bool isSelected) {
    return Container(); 
  }
}
