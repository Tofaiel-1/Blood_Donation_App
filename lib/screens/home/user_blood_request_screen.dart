import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/app_colors.dart';
import '../../models/donation_center.dart';

class UserBloodRequestScreen extends StatefulWidget {
  const UserBloodRequestScreen({super.key});

  @override
  State<UserBloodRequestScreen> createState() => _UserBloodRequestScreenState();
}

class _UserBloodRequestScreenState extends State<UserBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedBloodType = 'A+';
  int _unitsNeeded = 1;
  String _urgencyLevel = 'urgent';
  String? _selectedCenter;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  List<DonationCenter> _nearbyCenters = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
      });

      await _loadNearbyCenters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location error: $e')));
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _loadNearbyCenters() async {
    if (_currentPosition == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('donationCenters')
          .where('isActive', isEqualTo: true)
          .get();

      final centers = snapshot.docs.map((doc) {
        return DonationCenter.fromFirestore(doc);
      }).toList();

      // Calculate distances and sort
      for (var center in centers) {
        center.distanceFrom(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      centers.sort((a, b) {
        final distA = a.distanceFrom(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        final distB = b.distanceFrom(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        return distA.compareTo(distB);
      });

      // Only show centers within 10 km
      final nearbyCenters = centers.where((center) {
        final distance = center.distanceFrom(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        return distance <= 10.0;
      }).toList();

      setState(() {
        _nearbyCenters = nearbyCenters;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading centers: $e')));
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit request')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc.data()?['name'] ?? 'Unknown User';

      // Get selected center details
      String location = 'Dhaka';
      if (_selectedCenter != null && _nearbyCenters.isNotEmpty) {
        final center = _nearbyCenters.firstWhere(
          (c) => c.id == _selectedCenter,
          orElse: () => _nearbyCenters.first,
        );
        location = center.area;
      }

      // Create blood request
      await FirebaseFirestore.instance.collection('bloodRequests').add({
        'patientName': _patientNameController.text.trim(),
        'bloodType': _selectedBloodType,
        'unitsNeeded': _unitsNeeded,
        'hospitalName': _hospitalController.text.trim(),
        'location': location,
        'contactPhone': _phoneController.text.trim(),
        'urgency': _urgencyLevel,
        'status': 'pending',
        'requestDate': FieldValue.serverTimestamp(),
        'requestedBy': user.uid,
        'requestedByName': userName,
        'notes': _notesController.text.trim(),
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Blood request submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Card
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_currentPosition != null) ...[
                              Text(
                                'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Long: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Found ${_nearbyCenters.length} nearby centers (within 10 km)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ] else
                              const Text(
                                'Location not available',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Patient Name
                    TextFormField(
                      controller: _patientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Patient Name *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Blood Type
                    DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      decoration: const InputDecoration(
                        labelText: 'Blood Type *',
                        prefixIcon: Icon(Icons.bloodtype),
                        border: OutlineInputBorder(),
                      ),
                      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedBloodType = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Units Needed
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Units Needed:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_unitsNeeded > 1) {
                              setState(() => _unitsNeeded--);
                            }
                          },
                          icon: const Icon(Icons.remove_circle),
                          color: AppColors.bloodRed,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _unitsNeeded.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_unitsNeeded < 10) {
                              setState(() => _unitsNeeded++);
                            }
                          },
                          icon: const Icon(Icons.add_circle),
                          color: AppColors.bloodRed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Hospital Name
                    TextFormField(
                      controller: _hospitalController,
                      decoration: const InputDecoration(
                        labelText: 'Hospital Name *',
                        prefixIcon: Icon(Icons.local_hospital),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter hospital name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nearby Centers
                    if (_nearbyCenters.isNotEmpty) ...[
                      const Text(
                        'Select Nearby Center (Optional):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCenter,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                          hintText: 'Choose a center',
                        ),
                        items: _nearbyCenters.map((center) {
                          final distance = center.distanceFrom(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          );
                          return DropdownMenuItem(
                            value: center.id,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  center.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${distance.toStringAsFixed(1)} km away',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCenter = value);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Contact Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Urgency Level
                    const Text(
                      'Urgency Level:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'normal',
                          label: Text('Normal'),
                          icon: Icon(Icons.info),
                        ),
                        ButtonSegment(
                          value: 'urgent',
                          label: Text('Urgent'),
                          icon: Icon(Icons.warning),
                        ),
                        ButtonSegment(
                          value: 'critical',
                          label: Text('Critical'),
                          icon: Icon(Icons.error),
                        ),
                      ],
                      selected: {_urgencyLevel},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _urgencyLevel = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        hintText: 'Any additional information...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitRequest,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isSubmitting ? 'Submitting...' : 'Submit Request',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bloodRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Card
                    Card(
                      color: Colors.amber[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your request will be visible to donors nearby. '
                                'You will be notified when someone responds.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
