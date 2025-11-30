import 'dart:async';

import 'package:flutter/material.dart';
import '../../models/search.dart';

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
  List<SearchResult> searchResults = [];
  Set<String> favoriteIds = {}; // store favorite donor ids
  String sortBy = 'relevance'; // relevance | distance | lastDonation
  List<String> recentQueries = [];

  // Enhanced filter options
  bool isEmergencyMode = false;
  String selectedUrgency = 'all'; // all, critical, urgent, normal
  bool showNearbyOnly = false;
  String donorType = 'all'; // all, regular, volunteer, verified

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
    _loadMockData();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      // perform search automatically for better UX
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch();
      }
    });
  }

  void _loadMockData() {
    // Enhanced mock search results
    searchResults = [
      SearchResult(
        id: '1',
        name: 'Arif Shahriar',
        bloodType: 'O+',
        location: 'Dhaka Medical College',
        distance: 2.5,
        lastDonation: DateTime.now().subtract(Duration(days: 90)),
        isAvailable: true,
        phone: '+880123456789',
        email: 'arif@example.com',
      ),
      SearchResult(
        id: '2',
        name: 'Sarah Ahmed',
        bloodType: 'A+',
        location: 'Chattogram Medical College',
        distance: 5.2,
        lastDonation: DateTime.now().subtract(Duration(days: 120)),
        isAvailable: true,
        phone: '+880918765432',
      ),
      SearchResult(
        id: '3',
        name: 'Rahman Khan',
        bloodType: 'B-',
        location: 'PSTU Health Center',
        distance: 1.8,
        lastDonation: DateTime.now().subtract(Duration(days: 90)),
        isAvailable: false,
        phone: '+880555666777',
      ),
      SearchResult(
        id: '4',
        name: 'Dr. Fatima Khatun',
        bloodType: 'AB+',
        location: 'BSMMU Hospital',
        distance: 3.1,
        lastDonation: DateTime.now().subtract(Duration(days: 45)),
        isAvailable: true,
        phone: '+880177889900',
        email: 'fatima.dr@example.com',
      ),
      SearchResult(
        id: '5',
        name: 'Karim Ahmed',
        bloodType: 'O-',
        location: 'Apollo Hospital',
        distance: 7.8,
        lastDonation: DateTime.now().subtract(Duration(days: 200)),
        isAvailable: true,
        phone: '+880134567890',
        email: 'karim.universal@example.com',
      ),
    ];
    // ensure favorites persist in mock session
    favoriteIds = {'1', '4'};
  }

  void _performSearch() {
    setState(() {
      isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        isLoading = false;
        // Filter mock data based on search criteria
        final query = _searchController.text.toLowerCase().trim();
        final locationQuery = _locationController.text.toLowerCase().trim();

        // save recent query
        if (query.isNotEmpty) {
          recentQueries.remove(query);
          recentQueries.insert(0, query);
          if (recentQueries.length > 6) recentQueries.removeLast();
        }

        searchResults = searchResults.where((result) {
          bool matchesBloodType =
              selectedBloodType == null ||
              result.bloodType == selectedBloodType;
          bool matchesDistance = result.distance <= maxDistance;
          bool matchesAvailability = !availableOnly || result.isAvailable;

          bool matchesText =
              query.isEmpty ||
              result.name.toLowerCase().contains(query) ||
              result.bloodType.toLowerCase().contains(query);

          bool matchesLocation =
              locationQuery.isEmpty ||
              result.location.toLowerCase().contains(locationQuery);

          return matchesBloodType &&
              matchesDistance &&
              matchesAvailability &&
              matchesText &&
              matchesLocation;
        }).toList();

        // Apply sorting
        if (sortBy == 'distance') {
          searchResults.sort((a, b) => a.distance.compareTo(b.distance));
        } else if (sortBy == 'lastDonation') {
          searchResults.sort(
            (a, b) => b.lastDonation.compareTo(a.lastDonation),
          );
        } else if (sortBy == 'favorites') {
          searchResults.sort((a, b) {
            final aFav = favoriteIds.contains(a.id) ? 0 : 1;
            final bFav = favoriteIds.contains(b.id) ? 0 : 1;
            return aFav.compareTo(bFav);
          });
        }
      });
    });
  }

  Future<void> _refreshResults() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(milliseconds: 800));
    _performSearch();
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

  void _showDetailSheet(SearchResult result) {
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
                  result.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    favoriteIds.contains(result.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red[700],
                  ),
                  onPressed: () {
                    _toggleFavorite(result.id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Blood Type: ${result.bloodType}'),
            Text('Location: ${result.location}'),
            Text('Distance: ${result.distance.toStringAsFixed(1)} km'),
            SizedBox(height: 8),
            Text('Phone: ${result.phone}'),
            SizedBox(height: 8),
            Text('Email: ${result.email ?? 'N/A'}'),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.phone),
                    label: Text('Call'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _callDonor(result.phone);
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
                    onPressed: result.isAvailable
                        ? () {
                            Navigator.of(context).pop();
                            _sendMessage(result);
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // placeholder for map integration
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Open map for ${result.location}'),
                        ),
                      );
                    },
                    icon: Icon(Icons.map),
                    label: Text('Map'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // share contact placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Share ${result.name}')),
                      );
                    },
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
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

              // Blood Type Filter
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

              // Distance Filter
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
                  setModalState(() {
                    maxDistance = value;
                  });
                },
                activeColor: Colors.red[700],
              ),

              SizedBox(height: 20),

              // Availability Filter
              SwitchListTile(
                title: Text('Available donors only'),
                value: availableOnly,
                onChanged: (value) {
                  setModalState(() {
                    availableOnly = value;
                  });
                },
                activeColor: Colors.red[700],
              ),

              // Donor Type Filter
              SizedBox(height: 15),
              Text(
                'Donor Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: Text('All'),
                    selected: donorType == 'all',
                    onSelected: (selected) {
                      setModalState(() {
                        donorType = 'all';
                      });
                    },
                    selectedColor: Colors.red[200],
                  ),
                  FilterChip(
                    label: Text('Verified'),
                    selected: donorType == 'verified',
                    onSelected: (selected) {
                      setModalState(() {
                        donorType = selected ? 'verified' : 'all';
                      });
                    },
                    selectedColor: Colors.blue[200],
                  ),
                  FilterChip(
                    label: Text('Regular'),
                    selected: donorType == 'regular',
                    onSelected: (selected) {
                      setModalState(() {
                        donorType = selected ? 'regular' : 'all';
                      });
                    },
                    selectedColor: Colors.green[200],
                  ),
                ],
              ),

              // Urgency Filter
              SizedBox(height: 20),
              Text(
                'Urgency Level',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedUrgency,
                items: [
                  DropdownMenuItem(value: 'all', child: Text('All Requests')),
                  DropdownMenuItem(
                    value: 'critical',
                    child: Text('Critical Only'),
                  ),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent Only')),
                  DropdownMenuItem(value: 'normal', child: Text('Normal Only')),
                ],
                onChanged: (value) {
                  setModalState(() {
                    selectedUrgency = value ?? 'all';
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Spacer(),

              // Reset and Apply Buttons
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
                          showNearbyOnly = false;
                          isEmergencyMode = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text('Reset'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performSearch();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(fontSize: 16),
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
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.red[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _searchFocus,
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, hospital or blood type...',
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      searchResults = [];
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (_searchController.text.trim().isNotEmpty) {
                          _performSearch();
                        }
                      },
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

                // Emergency Mode Toggle
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEmergencyMode ? Colors.red[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isEmergencyMode
                          ? Colors.red[200]!
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emergency,
                        color: isEmergencyMode
                            ? Colors.red[700]
                            : Colors.grey[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Emergency Mode - Find donors faster',
                          style: TextStyle(
                            color: isEmergencyMode
                                ? Colors.red[700]
                                : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: isEmergencyMode,
                        onChanged: (value) {
                          setState(() {
                            isEmergencyMode = value;
                            if (value) {
                              availableOnly = true;
                              maxDistance = 20;
                              sortBy = 'distance';
                            }
                          });
                          _performSearch();
                        },
                        activeColor: Colors.red[700],
                      ),
                    ],
                  ),
                ),

                // Quick Filters
                SizedBox(height: 12),
                Text(
                  'Quick Filters',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildQuickFilterChip(
                        'Nearby (10km)',
                        showNearbyOnly,
                        () {
                          setState(() {
                            showNearbyOnly = !showNearbyOnly;
                            if (showNearbyOnly) maxDistance = 10;
                          });
                          _performSearch();
                        },
                      ),
                      SizedBox(width: 8),
                      _buildQuickFilterChip(
                        'O+ Universal',
                        selectedBloodType == 'O+',
                        () {
                          setState(() {
                            selectedBloodType = selectedBloodType == 'O+'
                                ? null
                                : 'O+';
                          });
                          _performSearch();
                        },
                      ),
                      SizedBox(width: 8),
                      _buildQuickFilterChip(
                        'O- Universal',
                        selectedBloodType == 'O-',
                        () {
                          setState(() {
                            selectedBloodType = selectedBloodType == 'O-'
                                ? null
                                : 'O-';
                          });
                          _performSearch();
                        },
                      ),
                      SizedBox(width: 8),
                      _buildQuickFilterChip('Available Now', availableOnly, () {
                        setState(() {
                          availableOnly = !availableOnly;
                        });
                        _performSearch();
                      }),
                      SizedBox(width: 8),
                      _buildQuickFilterChip(
                        'Verified Donors',
                        donorType == 'verified',
                        () {
                          setState(() {
                            donorType = donorType == 'verified'
                                ? 'all'
                                : 'verified';
                          });
                          _performSearch();
                        },
                      ),
                    ],
                  ),
                ),

                if (recentQueries.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: recentQueries.map((q) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(q, style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              _searchController.text = q;
                              _performSearch();
                              _searchFocus.unfocus();
                            },
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: sortBy,
                        items: [
                          DropdownMenuItem(
                            value: 'relevance',
                            child: Text('Sort: Relevance'),
                          ),
                          DropdownMenuItem(
                            value: 'distance',
                            child: Text('Sort: Distance'),
                          ),
                          DropdownMenuItem(
                            value: 'lastDonation',
                            child: Text('Sort: Recent Donors'),
                          ),
                          DropdownMenuItem(
                            value: 'favorites',
                            child: Text('Sort: Favorites'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => sortBy = v ?? 'relevance'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.red[700]),
                      onPressed: _refreshResults,
                    ),
                    SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.red[700]),
                      onSelected: (v) {
                        if (v == 'clear') {
                          setState(() {
                            selectedBloodType = null;
                            maxDistance = 50;
                            availableOnly = true;
                            _searchController.clear();
                            _locationController.clear();
                            searchResults = [];
                          });
                        }
                      },
                      itemBuilder: (c) => [
                        PopupMenuItem(
                          value: 'clear',
                          child: Text('Clear filters'),
                        ),
                      ],
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
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Search Donors'),
                  ),
                ),
              ],
            ),
          ),

          // Search Results
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No donors found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your search filters',
                                style: TextStyle(color: Colors.grey),
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
                        final result = searchResults[index];
                        return _buildSearchResultCard(result);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    final daysSinceLastDonation = DateTime.now()
        .difference(result.lastDonation)
        .inDays;
    final isEligible = daysSinceLastDonation >= 120; // 120 days gap required

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: result.isAvailable
              ? LinearGradient(
                  colors: [Colors.white, Colors.green[25]!],
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
                  // Enhanced Blood Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[600]!, Colors.red[800]!],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red[200]!,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      result.bloodType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Verification Badge (if verified donor)
                  if (donorType == 'verified' || result.id == '4') ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue[800],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Spacer(),

                  // Favorite Button
                  GestureDetector(
                    onTap: () => _toggleFavorite(result.id),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: favoriteIds.contains(result.id)
                            ? Colors.red[50]
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        favoriteIds.contains(result.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favoriteIds.contains(result.id)
                            ? Colors.red[700]
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Donor Name & Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: result.isAvailable
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          result.isAvailable
                              ? Icons.check_circle
                              : Icons.schedule,
                          size: 14,
                          color: result.isAvailable
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                        SizedBox(width: 4),
                        Text(
                          result.isAvailable ? 'Available' : 'Busy',
                          style: TextStyle(
                            color: result.isAvailable
                                ? Colors.green[800]
                                : Colors.orange[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // Location & Distance
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      result.location,
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
                      '${result.distance.toStringAsFixed(1)} km',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              // Last Donation & Eligibility
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    'Last donation: ${_formatDate(result.lastDonation)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isEligible ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isEligible ? 'Eligible' : 'Not eligible yet',
                      style: TextStyle(
                        color: isEligible ? Colors.green[700] : Colors.red[700],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _callDonor(result.phone),
                      icon: Icon(Icons.phone, size: 16),
                      label: Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: result.isAvailable
                          ? () => _sendMessage(result)
                          : null,
                      icon: Icon(Icons.message, size: 16),
                      label: Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () => _showDetailSheet(result),
                      icon: Icon(Icons.info_outline, color: Colors.grey[600]),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
              // In a real app, use url_launcher to make the call
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

  void _sendMessage(SearchResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message'),
        content: Text('Send a message to ${result.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to ${result.name}')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  // Quick filter chip widget
  Widget _buildQuickFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[100] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.red[700]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red[700] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
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
