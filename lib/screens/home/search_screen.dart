import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import '../../models/user.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;

  String? selectedBloodType;
  double maxDistance = 50.0;
  bool availableOnly = true;
  bool isLoading = false;
  List<User> searchResults = [];
  Set<String> favoriteIds = {};
  String sortBy = 'relevance';
  List<String> recentQueries = [];
  String? currentUserLocation;

  bool isEmergencyMode = false;
  String selectedUrgency = 'all';
  bool showNearbyOnly = false;
  String donorType = 'all';

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadDonorsFromFirebase();
    _searchController.addListener(_onSearchChanged);
    _ensureDemoData();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch();
      }
    });
  }

  Future<void> _ensureDemoData() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .limit(1)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        await _addDemoUsers();
      }
    } catch (e) {
      debugPrint('Error checking demo data: $e');
    }
  }

  Future<void> _addDemoUsers() async {
    final demoUsers = [
      {
        'email': 'arif.shahriar@example.com',
        'name': 'Arif Shahriar',
        'bloodType': 'O+',
        'phone': '+880123456789',
        'role': 'user',
        'age': 28,
        'gender': 'Male',
        'address': 'Dhaka Medical College, Dhaka',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 90)),
        ),
        'totalDonations': 8,
        'livesSaved': 8,
        'availability': 'available',
        'weight': 68.5,
        'isEligibleToDonate': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'sarah.ahmed@example.com',
        'name': 'Sarah Ahmed',
        'bloodType': 'A+',
        'phone': '+880918765432',
        'role': 'user',
        'age': 25,
        'gender': 'Female',
        'address': 'Chattogram Medical College, Chattogram',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 130)),
        ),
        'totalDonations': 5,
        'livesSaved': 5,
        'availability': 'available',
        'weight': 55.0,
        'isEligibleToDonate': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'rahman.khan@example.com',
        'name': 'Rahman Khan',
        'bloodType': 'B-',
        'phone': '+880555666777',
        'role': 'user',
        'age': 32,
        'gender': 'Male',
        'address': 'PSTU Health Center, Dumki',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 90)),
        ),
        'totalDonations': 12,
        'livesSaved': 12,
        'availability': 'busy',
        'weight': 75.0,
        'isEligibleToDonate': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'fatima.khatun@example.com',
        'name': 'Dr. Fatima Khatun',
        'bloodType': 'AB+',
        'phone': '+880177889900',
        'role': 'user',
        'age': 35,
        'gender': 'Female',
        'address': 'BSMMU Hospital, Dhaka',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 45)),
        ),
        'totalDonations': 15,
        'livesSaved': 15,
        'availability': 'available',
        'weight': 58.0,
        'isEligibleToDonate': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'karim.ahmed@example.com',
        'name': 'Karim Ahmed',
        'bloodType': 'O-',
        'phone': '+880134567890',
        'role': 'user',
        'age': 30,
        'gender': 'Male',
        'address': 'Apollo Hospital, Dhaka',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 200)),
        ),
        'totalDonations': 25,
        'livesSaved': 25,
        'availability': 'available',
        'weight': 72.0,
        'isEligibleToDonate': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'nabila.islam@example.com',
        'name': 'Nabila Islam',
        'bloodType': 'A-',
        'phone': '+880166778899',
        'role': 'user',
        'age': 27,
        'gender': 'Female',
        'address': 'Square Hospital, Dhaka',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 150)),
        ),
        'totalDonations': 6,
        'livesSaved': 6,
        'availability': 'available',
        'weight': 52.0,
        'isEligibleToDonate': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'tanvir.hasan@example.com',
        'name': 'Tanvir Hasan',
        'bloodType': 'B+',
        'phone': '+880199887766',
        'role': 'user',
        'age': 29,
        'gender': 'Male',
        'address': 'Rajshahi Medical College, Rajshahi',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 180)),
        ),
        'totalDonations': 10,
        'livesSaved': 10,
        'availability': 'available',
        'weight': 80.0,
        'isEligibleToDonate': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'email': 'maliha.tabassum@example.com',
        'name': 'Maliha Tabassum',
        'bloodType': 'AB-',
        'phone': '+880155443322',
        'role': 'user',
        'age': 26,
        'gender': 'Female',
        'address': 'Sylhet MAG Osmani Medical College',
        'lastDonationDate': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: 100)),
        ),
        'totalDonations': 4,
        'livesSaved': 4,
        'availability': 'available',
        'weight': 54.0,
        'isEligibleToDonate': true,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (var userData in demoUsers) {
      final docRef = FirebaseFirestore.instance.collection('users').doc();
      userData['id'] = docRef.id;
      batch.set(docRef, userData);
    }
    await batch.commit();
    debugPrint('✅ Demo users added successfully');
  }

  Future<void> _loadDonorsFromFirebase() async {
    setState(() => isLoading = true);

    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          currentUserLocation = userDoc.data()?['address'] ?? 'Dhaka';
        }
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      setState(() {
        searchResults = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return User.fromMap(data);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading donors: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading donors: $e')));
      }
    }
  }

  Future<void> _performSearch() async {
    setState(() => isLoading = true);

    try {
      final query = _searchController.text.toLowerCase().trim();
      final locationQuery = _locationController.text.toLowerCase().trim();

      if (query.isNotEmpty) {
        recentQueries.remove(query);
        recentQueries.insert(0, query);
        if (recentQueries.length > 6) recentQueries.removeLast();
      }

      Query<Map<String, dynamic>> firestoreQuery = FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user');

      if (selectedBloodType != null) {
        firestoreQuery = firestoreQuery.where(
          'bloodType',
          isEqualTo: selectedBloodType,
        );
      }

      if (availableOnly) {
        firestoreQuery = firestoreQuery.where(
          'availability',
          isEqualTo: 'available',
        );
      }

      final querySnapshot = await firestoreQuery.get();

      List<User> results = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromMap(data);
      }).toList();

      results = results.where((user) {
        bool matchesText =
            query.isEmpty ||
            user.name.toLowerCase().contains(query) ||
            user.bloodType.toLowerCase().contains(query) ||
            (user.phone?.toLowerCase().contains(query) ?? false);

        bool matchesLocation =
            locationQuery.isEmpty ||
            (user.address?.toLowerCase().contains(locationQuery) ?? false);

        return matchesText && matchesLocation;
      }).toList();

      if (sortBy == 'lastDonation') {
        results.sort((a, b) {
          if (a.lastDonationDate == null && b.lastDonationDate == null)
            return 0;
          if (a.lastDonationDate == null) return 1;
          if (b.lastDonationDate == null) return -1;
          return b.lastDonationDate!.compareTo(a.lastDonationDate!);
        });
      } else if (sortBy == 'favorites') {
        results.sort((a, b) {
          final aFav = favoriteIds.contains(a.id) ? 0 : 1;
          final bFav = favoriteIds.contains(b.id) ? 0 : 1;
          return aFav.compareTo(bFav);
        });
      } else if (sortBy == 'donations') {
        results.sort((a, b) => b.totalDonations.compareTo(a.totalDonations));
      }

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    }
  }

  Future<void> _refreshResults() async {
    await _loadDonorsFromFirebase();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
  }

  void _showDetailSheet(User donor) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  donor.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    favoriteIds.contains(donor.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red[700],
                  ),
                  onPressed: () {
                    _toggleFavorite(donor.id ?? '');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Blood Type: ${donor.bloodType}'),
            Text('Location: ${donor.address ?? 'N/A'}'),
            Text('Total Donations: ${donor.totalDonations}'),
            SizedBox(height: 8),
            Text('Phone: ${donor.phone ?? 'N/A'}'),
            Text('Email: ${donor.email}'),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.phone),
                    label: Text('Call'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _callDonor(donor.phone ?? '');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.message),
                    label: Text('Message'),
                    onPressed: donor.availability == DonorAvailability.available
                        ? () {
                            Navigator.of(context).pop();
                            _sendMessage(donor);
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Filters',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Blood Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: bloodTypes
                    .map(
                      (type) => FilterChip(
                        label: Text(type),
                        selected: selectedBloodType == type,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedBloodType = selected ? type : null;
                          });
                        },
                        selectedColor: Colors.red[200],
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20),
              Text(
                'Maximum Distance: ${maxDistance.round()} km',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: maxDistance,
                min: 1,
                max: 100,
                divisions: 99,
                onChanged: (value) {
                  setModalState(() => maxDistance = value);
                },
                activeColor: Colors.red[700],
              ),
              SizedBox(height: 20),
              SwitchListTile(
                title: Text('Available donors only'),
                value: availableOnly,
                onChanged: (value) {
                  setModalState(() => availableOnly = value);
                },
                activeColor: Colors.red[700],
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          selectedBloodType = null;
                          maxDistance = 50.0;
                          availableOnly = true;
                          donorType = 'all';
                          selectedUrgency = 'all';
                        });
                      },
                      child: Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                        _performSearch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Search Donors', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.red[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        decoration: InputDecoration(
                          hintText: 'Search by name, hospital or blood type...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: _performSearch,
                      icon: Icon(Icons.search, color: Colors.red[700]),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'Enter location...',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sortBy,
                        items: [
                          DropdownMenuItem(
                            value: 'relevance',
                            child: Text('Relevance'),
                          ),
                          DropdownMenuItem(
                            value: 'lastDonation',
                            child: Text('Last Donation'),
                          ),
                          DropdownMenuItem(
                            value: 'donations',
                            child: Text('Most Donations'),
                          ),
                          DropdownMenuItem(
                            value: 'favorites',
                            child: Text('Favorites'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => sortBy = value ?? 'relevance');
                          _performSearch();
                        },
                        decoration: InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.red[700]),
                      onPressed: _refreshResults,
                    ),
                  ],
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Search Donors'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshResults,
              color: Colors.white,
              backgroundColor: Colors.red[700],
              child: isLoading
                  ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 200),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : searchResults.isEmpty
                  ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No donors found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your search filters',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final donor = searchResults[index];
                        return _buildSearchResultCard(donor);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(User donor) {
    final isEligible = donor.canDonateNow;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: donor.availability == DonorAvailability.available
              ? LinearGradient(
                  colors: [Colors.white, Colors.green[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[700]!, Colors.red[900]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(76),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      donor.bloodType,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (donor.totalDonations >= 5) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[700]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Spacer(),
                  GestureDetector(
                    onTap: () => _toggleFavorite(donor.id ?? ''),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: favoriteIds.contains(donor.id)
                            ? Colors.red[50]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        favoriteIds.contains(donor.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favoriteIds.contains(donor.id)
                            ? Colors.red[700]
                            : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      donor.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: donor.availability == DonorAvailability.available
                          ? Colors.green[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color:
                              donor.availability == DonorAvailability.available
                              ? Colors.green[700]
                              : Colors.grey[500],
                        ),
                        SizedBox(width: 4),
                        Text(
                          donor.availability == DonorAvailability.available
                              ? 'Available'
                              : donor.availability == DonorAvailability.busy
                              ? 'Busy'
                              : 'Unavailable',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                donor.availability ==
                                    DonorAvailability.available
                                ? Colors.green[700]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      donor.address ?? 'Location not specified',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${donor.totalDonations} donations',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    donor.lastDonationDate != null
                        ? 'Last donation: ${_formatDate(donor.lastDonationDate!)}'
                        : 'No donations yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isEligible
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEligible ? 'Eligible' : 'Not Eligible',
                      style: TextStyle(
                        fontSize: 10,
                        color: isEligible
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.phone, size: 16),
                      label: Text('Call'),
                      onPressed: () => _callDonor(donor.phone ?? ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.message, size: 16),
                      label: Text('Message'),
                      onPressed:
                          donor.availability == DonorAvailability.available
                          ? () => _sendMessage(donor)
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.info_outline),
                      color: Colors.blue[700],
                      onPressed: () => _showDetailSheet(donor),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 30) {
      return '$difference days ago';
    } else if (difference < 365) {
      return '${(difference / 30).round()} months ago';
    } else {
      return '${(difference / 365).round()} years ago';
    }
  }

  void _callDonor(String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Donor'),
        content: Text('Would you like to call $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Calling $phone...')));
            },
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(User donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message'),
        content: Text('Send a message to ${donor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to ${donor.name}')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
