import 'package:flutter/material.dart';
import '../services/bangladesh_locations_service.dart';
import '../services/location_service.dart';
import '../utils/app_colors.dart';
import 'package:geolocator/geolocator.dart';

/// Comprehensive Bangladesh location selector with current location support
class BangladeshLocationSelector extends StatefulWidget {
  final String? initialDivision;
  final String? initialDistrict;
  final String? initialUpazila;
  final String? initialVillage;
  final Function(
    String? division,
    String? district,
    String? upazila,
    String? village,
  )?
  onLocationChanged;
  final Function(double? latitude, double? longitude)? onCurrentLocationChanged;
  final bool showCurrentLocation;
  final String? divisionLabel;
  final String? districtLabel;
  final String? upazilaLabel;
  final String? villageLabel;

  const BangladeshLocationSelector({
    super.key,
    this.initialDivision,
    this.initialDistrict,
    this.initialUpazila,
    this.initialVillage,
    this.onLocationChanged,
    this.onCurrentLocationChanged,
    this.showCurrentLocation = true,
    this.divisionLabel = 'Division',
    this.districtLabel = 'District',
    this.upazilaLabel = 'Upazila/Thana',
    this.villageLabel = 'Village/Union (Optional)',
  });

  @override
  State<BangladeshLocationSelector> createState() =>
      _BangladeshLocationSelectorState();
}

class _BangladeshLocationSelectorState
    extends State<BangladeshLocationSelector> {
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  String? _selectedVillage;
  List<String> _districts = [];
  List<String> _upazilas = [];
  List<String> _villages = [];
  bool _isLoadingLocation = false;
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    _selectedDivision = widget.initialDivision;
    _selectedDistrict = widget.initialDistrict;
    _selectedUpazila = widget.initialUpazila;
    _selectedVillage = widget.initialVillage;

    if (_selectedDivision != null) {
      _districts = BangladeshLocationsService.getDistricts(_selectedDivision!);
    }
    if (_selectedDivision != null && _selectedDistrict != null) {
      _upazilas = BangladeshLocationsService.getUpazilas(
        _selectedDivision!,
        _selectedDistrict!,
      );
    }
    if (_selectedDivision != null &&
        _selectedDistrict != null &&
        _selectedUpazila != null) {
      _villages = BangladeshLocationsService.getVillages(
        _selectedDivision!,
        _selectedDistrict!,
        _selectedUpazila!,
      );
    }
  }

  void _onDivisionChanged(String? division) {
    setState(() {
      _selectedDivision = division;
      _selectedDistrict = null;
      _selectedUpazila = null;
      _selectedVillage = null;
      _districts = division != null
          ? BangladeshLocationsService.getDistricts(division)
          : [];
      _upazilas = [];
      _villages = [];
    });
    _notifyLocationChanged();
  }

  void _onDistrictChanged(String? district) {
    setState(() {
      _selectedDistrict = district;
      _selectedUpazila = null;
      _selectedVillage = null;
      _upazilas = (district != null && _selectedDivision != null)
          ? BangladeshLocationsService.getUpazilas(_selectedDivision!, district)
          : [];
      _villages = [];
    });
    _notifyLocationChanged();
  }

  void _onUpazilaChanged(String? upazila) {
    setState(() {
      _selectedUpazila = upazila;
      _selectedVillage = null;
      _villages =
          (upazila != null &&
              _selectedDivision != null &&
              _selectedDistrict != null)
          ? BangladeshLocationsService.getVillages(
              _selectedDivision!,
              _selectedDistrict!,
              upazila,
            )
          : [];
    });
    _notifyLocationChanged();
  }

  void _onVillageChanged(String? village) {
    setState(() {
      _selectedVillage = village;
    });
    _notifyLocationChanged();
  }

  void _notifyLocationChanged() {
    widget.onLocationChanged?.call(
      _selectedDivision,
      _selectedDistrict,
      _selectedUpazila,
      _selectedVillage,
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check and request permissions
      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location services are disabled. Please enable them.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await LocationService.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await LocationService.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showLocationPermissionDialog();
        }
        return;
      }

      // Get current position
      Position? position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
        });

        widget.onCurrentLocationChanged?.call(
          _currentLatitude,
          _currentLongitude,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Location captured: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in app settings to use current location feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Location Button (if enabled)
        if (widget.showCurrentLocation) ...[
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_currentLatitude != null && _currentLongitude != null)
                    Text(
                      'Lat: ${_currentLatitude!.toStringAsFixed(6)}, Long: ${_currentLongitude!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.gps_fixed, size: 18),
                      label: Text(
                        _isLoadingLocation
                            ? 'Getting Location...'
                            : _currentLatitude != null
                            ? 'Update Current Location'
                            : 'Get Current Location',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This helps others find donors near you',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
        ],

        // Division Dropdown
        Text(
          widget.divisionLabel!,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDivision,
          decoration: InputDecoration(
            hintText: 'Select ${widget.divisionLabel}',
            prefixIcon: Icon(Icons.location_city, color: AppColors.bloodRed),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: BangladeshLocationsService.getDivisions()
              .map((div) => DropdownMenuItem(value: div, child: Text(div)))
              .toList(),
          onChanged: _onDivisionChanged,
          validator: (v) => v == null ? 'Please select a division' : null,
        ),
        const SizedBox(height: 16),

        // District Dropdown
        Text(
          widget.districtLabel!,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          decoration: InputDecoration(
            hintText: _selectedDivision == null
                ? 'Select division first'
                : 'Select ${widget.districtLabel}',
            prefixIcon: Icon(Icons.location_on, color: AppColors.bloodRed),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: _districts
              .map((dist) => DropdownMenuItem(value: dist, child: Text(dist)))
              .toList(),
          onChanged: _selectedDivision == null ? null : _onDistrictChanged,
          validator: (v) => v == null ? 'Please select a district' : null,
        ),
        const SizedBox(height: 16),

        // Upazila Dropdown
        Text(
          widget.upazilaLabel!,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedUpazila,
          decoration: InputDecoration(
            hintText: _selectedDistrict == null
                ? 'Select district first'
                : 'Select ${widget.upazilaLabel}',
            prefixIcon: Icon(Icons.place, color: AppColors.bloodRed),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: _upazilas
              .map(
                (upazila) =>
                    DropdownMenuItem(value: upazila, child: Text(upazila)),
              )
              .toList(),
          onChanged: _selectedDistrict == null ? null : _onUpazilaChanged,
          validator: (v) => v == null ? 'Please select an upazila' : null,
        ),
        const SizedBox(height: 16),

        // Village/Union Dropdown (Optional - only shown if data available)
        if (_villages.isNotEmpty) ...[
          Text(
            widget.villageLabel!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedVillage,
            decoration: InputDecoration(
              hintText: 'Select ${widget.villageLabel}',
              prefixIcon: Icon(Icons.home_work, color: AppColors.bloodRed),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: _villages
                .map(
                  (village) =>
                      DropdownMenuItem(value: village, child: Text(village)),
                )
                .toList(),
            onChanged: _onVillageChanged,
          ),
          const SizedBox(height: 16),
        ],

        // Location preview
        if (_selectedDivision != null || _selectedDistrict != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selected: ${_buildLocationText()}',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _buildLocationText() {
    List<String> parts = [];
    if (_selectedVillage != null && _selectedVillage!.isNotEmpty) {
      parts.add(_selectedVillage!);
    }
    if (_selectedUpazila != null && _selectedUpazila!.isNotEmpty) {
      parts.add(_selectedUpazila!);
    }
    if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
      parts.add(_selectedDistrict!);
    }
    if (_selectedDivision != null && _selectedDivision!.isNotEmpty) {
      parts.add(_selectedDivision!);
    }
    return parts.join(', ');
  }
}
