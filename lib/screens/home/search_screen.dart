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

  String? selectedBloodType;
  double maxDistance = 50.0;
  bool availableOnly = true;
  bool isLoading = false;
  List<SearchResult> searchResults = [];
  Set<String> favoriteIds = {}; // store favorite donor ids
  String sortBy = 'relevance'; // relevance | distance | lastDonation

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
  }

  void _loadMockData() {
    // Mock search results
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
    ];
    // ensure favorites persist in mock session
    favoriteIds = {'1'};
  }

  void _performSearch() {
    setState(() {
      isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
        // Filter mock data based on search criteria
        final query = _searchController.text.toLowerCase().trim();
        final locationQuery = _locationController.text.toLowerCase().trim();

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
              CheckboxListTile(
                title: Text('Available donors only'),
                value: availableOnly,
                onChanged: (value) {
                  setModalState(() {
                    availableOnly = value ?? true;
                  });
                },
                activeColor: Colors.red[700],
              ),

              Spacer(),

              // Apply Filters Button
              SizedBox(
                width: double.infinity,
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
                  child: Text('Apply Filters', style: TextStyle(fontSize: 16)),
                ),
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
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or blood type...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
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
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Blood Type Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.bloodType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _toggleFavorite(result.id),
                  child: Icon(
                    favoriteIds.contains(result.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favoriteIds.contains(result.id)
                        ? Colors.red[700]
                        : Colors.grey,
                  ),
                ),
                // Availability Status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: result.isAvailable
                        ? Colors.green[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.isAvailable ? 'Available' : 'Not Available',
                    style: TextStyle(
                      color: result.isAvailable
                          ? Colors.green[800]
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    result.location,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                Text(
                  '${result.distance.toStringAsFixed(1)} km away',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Last donation: ${_formatDate(result.lastDonation)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callDonor(result.phone),
                    icon: Icon(Icons.phone, size: 16),
                    label: Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: result.isAvailable
                        ? () => _showDetailSheet(result)
                        : null,
                    icon: Icon(Icons.message, size: 16),
                    label: Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
