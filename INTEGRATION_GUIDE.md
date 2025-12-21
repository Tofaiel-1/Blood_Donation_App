# 🚀 Quick Integration Guide - How to Use New Services

## 📋 Table of Contents
1. [Smart Donation Scheduler](#1-smart-donation-scheduler)
2. [Donor Health Tracker](#2-donor-health-tracker)
3. [Blood Buddy System](#3-blood-buddy-system)
4. [Smart Matching (AI)](#4-smart-matching-ai)
5. [Emergency Contact Network](#5-emergency-contact-network)
6. [Inventory Management](#6-inventory-management)
7. [Campaign Manager](#7-campaign-manager)
8. [Advanced Analytics](#8-advanced-analytics)
9. [Bangla Localization](#9-bangla-localization)
10. [System Health Monitoring](#10-system-health-monitoring)

---

## 1. Smart Donation Scheduler

### Initialize Service
```dart
import 'package:blood_bank/services/donation_scheduler_service.dart';

final scheduler = DonationSchedulerService();

// Initialize notifications
await scheduler.initialize();
```

### Schedule Reminders After Donation
```dart
// When user donates blood
final lastDonation = DateTime.now();
final nextEligible = scheduler.calculateNextEligibleDate(lastDonation);

// Schedule 4 reminders (7, 3, 1 days before + eligible day)
await scheduler.scheduleReminders(userId, nextEligible!);
```

### Check Eligibility in Profile Screen
```dart
// In profile_screen.dart
final lastDonation = userData['lastDonationDate']?.toDate();
final daysUntil = scheduler.getDaysUntilNextDonation(lastDonation);
final isEligible = scheduler.isEligibleNow(lastDonation);

Text(isEligible 
  ? '✅ Eligible to donate now!' 
  : '⏳ Next donation in $daysUntil days'
);
```

### Export to Calendar
```dart
// Generate iCal file for Google Calendar/Apple Calendar
final icalData = scheduler.generateCalendarEvent(userId, nextEligible);

// Share or save the file
await Share.share(icalData, subject: 'Blood Donation Reminder');
```

---

## 2. Donor Health Tracker

### Save Health Record Before Donation
```dart
import 'package:blood_bank/services/donor_health_tracker_service.dart';

final healthService = DonorHealthTrackerService();

// User fills health form
await healthService.saveHealthRecord(
  userId: currentUserId,
  hemoglobinLevel: 14.5,        // g/dL
  bloodPressure: '120/80',      // systolic/diastolic
  weight: 65.0,                  // kg
  temperature: 36.8,             // °C
  pulse: 72,                     // bpm
  sleepHours: 8,
  hydrationLevel: 'good',        // good/moderate/low
  lastMealTime: DateTime.now().subtract(Duration(hours: 3)),
  medications: [],
  notes: 'Feeling healthy',
);
```

### Show Health Dashboard
```dart
// Get latest health record
final healthRecord = await healthService.getLatestHealthRecord(userId);

if (healthRecord != null) {
  final score = healthRecord['eligibilityScore'];
  final isEligible = healthRecord['isEligible'];
  
  // Show score
  Text('Health Score: $score/100');
  
  // Get recommendations
  final recommendations = healthService.getHealthRecommendations(healthRecord);
  
  // Display recommendations list
  for (var rec in recommendations) {
    ListTile(title: Text(rec));
  }
}
```

### Pre-Donation Checklist Screen
```dart
// Show checklist before donation
final checklist = DonorHealthTrackerService.preDonationChecklist;

ListView.builder(
  itemCount: checklist.length,
  itemBuilder: (context, index) {
    final item = checklist[index];
    return CheckboxListTile(
      title: Text('${item['icon']} ${item['item']}'),
      subtitle: Text('Importance: ${item['importance']}'),
      value: userChecked[index],
      onChanged: (value) => setState(() => userChecked[index] = value!),
    );
  },
);
```

---

## 3. Blood Buddy System

### Register as a Buddy (Experienced Donors)
```dart
import 'package:blood_bank/services/blood_buddy_service.dart';

final buddyService = BloodBuddyService();

// Experienced donor becomes buddy
await buddyService.registerAsBuddy(
  userId: currentUserId,
  bloodType: 'O-',
  location: 'Dhaka',
  languages: ['Bangla', 'English'],
  specialization: 'first_timer',
);
```

### Find Buddy for First-Timer
```dart
// First-time donor needs buddy
final buddy = await buddyService.findBuddy(
  bloodType: 'O-',
  location: 'Dhaka',
  preferredLanguage: 'Bangla',
);

if (buddy != null) {
  // Send buddy request
  final relationshipId = await buddyService.createBuddyRelationship(
    newDonorId: currentUserId,
    buddyId: buddy['userId'],
    message: 'This is my first donation. Please help!',
  );
}
```

### Accept Buddy Request (Buddy Side)
```dart
// Buddy accepts request
await buddyService.acceptBuddyRequest(relationshipId);

// After successful donation
await buddyService.completeBuddyRelationship(
  relationshipId: relationshipId,
  wasSuccessful: true,
  rating: 5.0,
  feedback: 'Excellent mentor!',
);
// Buddy automatically gets ৳50 bonus!
```

### Show Buddy Leaderboard
```dart
final leaderboard = await buddyService.getBuddyLeaderboard(limit: 10);

ListView.builder(
  itemCount: leaderboard.length,
  itemBuilder: (context, index) {
    final buddy = leaderboard[index];
    return ListTile(
      leading: Text('#${index + 1}'),
      title: Text(buddy['name']),
      subtitle: Text('${buddy['successfulReferrals']} successful mentorships'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Text('${buddy['rating']}'),
        ],
      ),
    );
  },
);
```

---

## 4. Smart Matching (AI)

### Auto-Match Donors to Blood Request
```dart
import 'package:blood_bank/services/smart_matching_service.dart';

final matchingService = SmartMatchingService();

// When admin approves blood request
final matches = await matchingService.matchDonorsToRequest(
  requestId: requestId,
  bloodType: 'O-',
  latitude: 23.8103,  // Hospital coordinates
  longitude: 90.4125,
  urgency: 'critical', // critical/urgent/normal
  maxResults: 20,
);

// Display matched donors sorted by score
for (var match in matches) {
  print('${match['name']} - Score: ${match['score']}');
  print('Distance: ${match['distance'].toStringAsFixed(1)} km');
  print('Reliability: ${(match['reliability'] * 100).round()}%');
}
```

### Send Bulk Invitations to Top Matches
```dart
// Send notifications to top 20 matches
final topDonorIds = matches.take(20).map((m) => m['donorId'] as String).toList();

await matchingService.sendBulkInvitations(
  requestId: requestId,
  donorIds: topDonorIds,
  bloodType: 'O-',
  hospitalName: 'PSTU Medical Center',
  urgency: 'critical',
);
// All 20 donors get push notifications instantly!
```

### Show Matching Statistics
```dart
final stats = await matchingService.getMatchingStats();

Card(
  child: Column(
    children: [
      Text('Success Rate: ${stats['successRate']}%'),
      Text('Avg Response Time: ${stats['avgResponseTimeFormatted']}'),
      Text('Total Requests: ${stats['totalRequests']}'),
      Text('Fulfilled: ${stats['fulfilledRequests']}'),
    ],
  ),
);
```

---

## 5. Emergency Contact Network

### Create Emergency Network
```dart
import 'package:blood_bank/services/emergency_contact_network_service.dart';

final networkService = EmergencyContactNetworkService();

// User creates family network
final networkId = await networkService.createNetwork(
  creatorId: currentUserId,
  networkName: 'Rahman Family Network',
  networkType: 'family',
  bloodType: 'O+',
  description: 'Immediate family members',
  tags: ['Dhaka', 'Emergency'],
);
```

### Join Existing Network
```dart
// Search networks
final networks = await networkService.searchNetworks(
  bloodType: 'O+',
  networkType: 'family',
  location: 'Dhaka',
);

// Join a network
await networkService.joinNetwork(networks.first['id'], currentUserId);
```

### Send Emergency Alert (SOS Button)
```dart
// CRITICAL EMERGENCY - broadcast to network
await networkService.sendEmergencyAlert(
  networkId: networkId,
  senderId: currentUserId,
  bloodType: 'O+',
  hospitalName: 'PSTU Medical Center',
  hospitalAddress: 'Dumki, Patuakhali',
  latitude: 22.0968,
  longitude: 90.0379,
  urgency: 'critical',
  patientName: 'Ahmed Rahman',
  contactNumber: '+8801712345678',
  additionalNotes: 'Accident case, urgent need',
);
// All network members get INSTANT notification!
```

### Respond to Alert
```dart
// Member responds
await networkService.respondToAlert(
  alertId: alertId,
  responderId: currentUserId,
  response: 'on_my_way', // can_help/cannot_help/on_my_way
  message: 'Coming in 15 minutes',
);
```

### Mark Alert Fulfilled
```dart
// After successful help
await networkService.fulfillAlert(alertId, helperId);
// Helper gets ৳100 emergency bonus!
```

---

## 6. Inventory Management

### Add Blood Stock (Hospital/Blood Bank)
```dart
import 'package:blood_bank/services/inventory_management_service.dart';

final inventoryService = InventoryManagementService();

// Add new blood stock
await inventoryService.addStock(
  organizationId: hospitalId,
  bloodType: 'O-',
  units: 3,  // 3 bags
  collectionDate: DateTime.now(),
  expiryDate: DateTime.now().add(Duration(days: 42)), // 42 days shelf life
  donorId: donorId,
  location: 'Main Storage',
  batchNumber: 'BATCH2024001',
);
```

### Reserve Blood for Request
```dart
// Try to reserve blood units
final success = await inventoryService.reserveBlood(
  organizationId: hospitalId,
  bloodType: 'O-',
  units: 2,
  requestId: requestId,
);

if (success) {
  print('✅ Blood reserved successfully');
} else {
  print('❌ Not enough stock');
}
```

### Get Stock Levels Dashboard
```dart
final stockLevels = await inventoryService.getStockLevels(hospitalId);

// Display stock for all blood types
for (var entry in stockLevels.entries) {
  print('${entry.key}: ${entry.value} units');
}
```

### Show Expiring Stock Alerts
```dart
final expiringStock = await inventoryService.getExpiringStock(hospitalId);

ListView.builder(
  itemCount: expiringStock.length,
  itemBuilder: (context, index) {
    final stock = expiringStock[index];
    final daysLeft = (stock['expiryDate'] as Timestamp)
        .toDate()
        .difference(DateTime.now())
        .inDays;
    
    return ListTile(
      leading: Icon(Icons.warning, color: Colors.orange),
      title: Text('${stock['bloodType']} - ${stock['availableUnits']} units'),
      subtitle: Text('Expires in $daysLeft days'),
    );
  },
);
```

### Demand Forecasting
```dart
final forecast = await inventoryService.forecastDemand(hospitalId);

print('Last 30 days demand: ${forecast['last30Days']}');
print('Weekly forecast: ${forecast['weeklyForecast']}');
print('Total demand: ${forecast['totalDemand']}');
```

---

## 7. Campaign Manager

### Create Blood Donation Campaign
```dart
import 'package:blood_bank/services/donor_campaign_manager_service.dart';

final campaignService = DonorCampaignManagerService();

// Create new campaign
final campaignId = await campaignService.createCampaign(
  organizerId: currentUserId,
  title: 'PSTU Blood Donation Camp 2024',
  description: 'Annual blood donation drive at PSTU campus',
  startDate: DateTime(2024, 12, 16, 9, 0),
  endDate: DateTime(2024, 12, 16, 17, 0),
  location: 'Patuakhali',
  latitude: 22.0968,
  longitude: 90.0379,
  targetBloodTypes: ['O+', 'A+', 'B+', 'AB+'],
  targetDonations: 100,
  venue: 'PSTU Auditorium',
  contactNumber: '+8801712345678',
  incentives: ['Free health checkup', 'Refreshments', 'Certificate'],
);
// Relevant donors automatically notified!
```

### Register for Campaign
```dart
// User registers
await campaignService.registerForCampaign(campaignId, currentUserId);
// Confirmation notification sent
```

### Record Donation at Campaign
```dart
// Admin records donation at camp
await campaignService.recordCampaignDonation(
  campaignId: campaignId,
  donorId: donorId,
  bloodType: 'O+',
);
// Donor gets ৳75 campaign bonus!
```

### Show Active Campaigns
```dart
final campaigns = await campaignService.getActiveCampaigns(
  bloodType: userBloodType,
  location: userLocation,
);

ListView.builder(
  itemCount: campaigns.length,
  itemBuilder: (context, index) {
    final campaign = campaigns[index];
    final progress = ((campaign['currentDonations'] / campaign['targetDonations']) * 100).toInt();
    
    return Card(
      child: Column(
        children: [
          Text(campaign['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(campaign['location']),
          LinearProgressIndicator(value: progress / 100),
          Text('$progress% complete'),
          ElevatedButton(
            onPressed: () => campaignService.registerForCampaign(campaign['id'], userId),
            child: Text('Register Now'),
          ),
        ],
      ),
    );
  },
);
```

---

## 8. Advanced Analytics

### Get Complete Dashboard Data
```dart
import 'package:blood_bank/services/advanced_analytics_service.dart';

final analyticsService = AdvancedAnalyticsService();

// Get comprehensive dashboard
final dashboard = await analyticsService.getComprehensiveDashboard();

final retention = dashboard['retention'];
final revenue = dashboard['revenue'];
final engagement = dashboard['engagement'];
final bloodDemand = dashboard['bloodDemand'];
```

### Show Donor Retention Stats
```dart
final retention = await analyticsService.getDonorRetentionRate();

Card(
  child: Column(
    children: [
      Text('Retention Rate: ${retention['retentionRate']}%'),
      Text('Active Donors: ${retention['activeDonors']}'),
      Text('Inactive Donors: ${retention['inactiveDonors']}'),
      Text('New Donors (6mo): ${retention['newDonors']}'),
      Text('Churn Rate: ${retention['churnRate']}%'),
    ],
  ),
);
```

### Revenue Analytics (SuperAdmin)
```dart
final revenue = await analyticsService.getRevenueAnalytics(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);

print('Total Revenue: ৳${revenue['totalRevenue']}');
print('Breakdown:');
for (var entry in (revenue['revenueByType'] as Map).entries) {
  print('  ${entry.key}: ৳${entry.value}');
}
print('Top Source: ${revenue['topRevenueSource']}');
```

### Blood Type Demand Analysis
```dart
final demand = await analyticsService.getBloodTypeDemand();

print('Most Demanded: ${demand['mostDemanded']}');
print('Least Fulfilled: ${demand['leastFulfilled']}');

// Show chart
final demandByType = demand['demandByType'] as Map<String, int>;
final fulfillmentRate = demand['fulfillmentRateByType'] as Map<String, int>;
```

### User Growth Trend (12 Months)
```dart
final growthTrend = await analyticsService.getUserGrowthTrend();

LineChart(
  data: growthTrend.map((data) => 
    DataPoint(x: data['month'], y: data['newUsers'])
  ).toList(),
);
```

---

## 9. Bangla Localization

### Initialize & Set Language
```dart
import 'package:blood_bank/services/bangla_localization_service.dart';

final localization = BanglaLocalizationService();

// Set language (saved in SharedPreferences)
localization.setLanguage('bn'); // Bangla
// or
localization.setLanguage('en'); // English
```

### Use Translations in UI
```dart
// Instead of hardcoded text
Text('Donate Blood');

// Use translation
Text(localization.translate('donate_blood'));
// Returns: "রক্তদান করুন" (if Bangla)
// Returns: "Donate Blood" (if English)
```

### Common Translations
```dart
// Blood types
localization.translate('O+');  // "ও পজিটিভ"
localization.translate('A-');  // "এ নেগেটিভ"

// Actions
localization.translate('save');     // "সংরক্ষণ করুন"
localization.translate('cancel');   // "বাতিল"
localization.translate('submit');   // "জমা দিন"

// Divisions
localization.translate('dhaka');      // "ঢাকা"
localization.translate('chittagong'); // "চট্টগ্রাম"
```

### Format Numbers & Currency in Bangla
```dart
// Numbers
localization.formatNumberBangla(123);  // "১২৩"
localization.formatNumberBangla(2024); // "২০২৪"

// Currency
localization.formatCurrency(100.0);  // "৳১০০"
localization.formatCurrency(500.0);  // "৳৫০০"
```

### Language Toggle Button
```dart
IconButton(
  icon: Icon(Icons.language),
  onPressed: () {
    final newLang = localization.currentLanguage == 'bn' ? 'en' : 'bn';
    localization.setLanguage(newLang);
    setState(() {}); // Rebuild UI
  },
);
```

---

## 10. System Health Monitoring

### Log Errors (Auto-Catch)
```dart
import 'package:blood_bank/services/system_health_monitoring_service.dart';

final healthService = SystemHealthMonitoringService();

// Wrap risky code in try-catch
try {
  await someRiskyOperation();
} catch (e, stackTrace) {
  await healthService.logError(
    errorType: 'API_ERROR',
    errorMessage: e.toString(),
    stackTrace: stackTrace.toString(),
    userId: currentUserId,
    context: {'operation': 'blood_request_creation'},
  );
}
```

### Record API Calls (Middleware)
```dart
// After every API call
await healthService.recordApiCall(
  endpoint: '/api/blood-requests',
  method: 'POST',
  statusCode: 200,
  responseTime: 350, // milliseconds
  userId: currentUserId,
);
```

### Show System Health Dashboard (SuperAdmin)
```dart
final health = await healthService.getSystemHealth();

Card(
  child: Column(
    children: [
      Text('Status: ${health['status']}'), // healthy/warning/critical
      Text('Uptime: ${health['uptime']}%'),
      Text('Total Errors (24h): ${health['totalErrors']}'),
      Text('API Calls (24h): ${health['totalApiCalls']}'),
      Text('Failed Calls: ${health['failedApiCalls']}'),
      Text('Avg Response Time: ${health['avgResponseTime']}ms'),
      Text('Active Users (24h): ${health['activeUsers24h']}'),
    ],
  ),
);
```

### Show Alerts
```dart
final alerts = await healthService.checkAlerts();

if (alerts.isNotEmpty) {
  ListView.builder(
    itemCount: alerts.length,
    itemBuilder: (context, index) {
      final alert = alerts[index];
      final color = alert['severity'] == 'critical' ? Colors.red : Colors.orange;
      
      return ListTile(
        leading: Icon(Icons.warning, color: color),
        title: Text(alert['message']!),
        subtitle: Text(alert['type']!),
      );
    },
  );
}
```

### Complete Monitoring Dashboard
```dart
final dashboard = await healthService.getMonitoringDashboard();

// Contains:
// - health: System health metrics
// - errorBreakdown: Errors by type
// - performance: Performance metrics
// - databaseStats: Database collection sizes
// - alerts: Active alerts
```

---

## 🎯 Integration Priority

### Phase 1 (Immediate - User Features):
1. ✅ Bangla Localization (everywhere)
2. ✅ Health Tracker (before every donation)
3. ✅ Smart Scheduler (after every donation)
4. ✅ Emergency Network (SOS button on home)

### Phase 2 (This Week - Admin Features):
1. ✅ Smart Matching (for all blood requests)
2. ✅ Campaign Manager (create camps)
3. ✅ Inventory Management (hospital partners)

### Phase 3 (Next Week - Backend):
1. ✅ Advanced Analytics (dashboard)
2. ✅ Buddy System (for first-timers)
3. ✅ System Monitoring (background)

---

## 🔧 Common Integration Points

### In Home Screen:
```dart
// Add Emergency Network button
FloatingActionButton(
  onPressed: () => Navigator.push(...EmergencyNetworkScreen()),
  child: Icon(Icons.sos),
);
```

### In Profile Screen:
```dart
// Show next donation date
final scheduler = DonationSchedulerService();
final daysUntil = scheduler.getDaysUntilNextDonation(lastDonation);
Text('Next donation in: $daysUntil days');

// Show health score
final healthService = DonorHealthTrackerService();
final health = await healthService.getLatestHealthRecord(userId);
Text('Health Score: ${health['eligibilityScore']}/100');
```

### In Blood Request Screen (Admin):
```dart
// Auto-match donors
final matchingService = SmartMatchingService();
final matches = await matchingService.matchDonorsToRequest(...);

// Send invitations
await matchingService.sendBulkInvitations(...);
```

### In Settings Screen:
```dart
// Language toggle
final localization = BanglaLocalizationService();
SwitchListTile(
  title: Text('বাংলা ভাষা / Bangla Language'),
  value: localization.currentLanguage == 'bn',
  onChanged: (value) {
    localization.setLanguage(value ? 'bn' : 'en');
    setState(() {});
  },
);
```

---

## 📚 Full Example: Complete Donation Flow

```dart
// 1. Check health before donation
final healthService = DonorHealthTrackerService();
await healthService.saveHealthRecord(...);
final health = await healthService.getLatestHealthRecord(userId);

if (health['isEligible']) {
  // 2. Record donation
  await recordDonation(userId);
  
  // 3. Schedule next donation reminders
  final scheduler = DonationSchedulerService();
  final nextEligible = scheduler.calculateNextEligibleDate(DateTime.now());
  await scheduler.scheduleReminders(userId, nextEligible!);
  
  // 4. Award incentives (if rare blood or universal donor)
  if (bloodType == 'O-') {
    final universalService = UniversalDonorRewardsService();
    await universalService.awardUniversalDonorRewards(userId);
  }
  
  // 5. Show success message
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(localization.translate('thank_you')),
      content: Text(localization.translate('you_saved_life')),
    ),
  );
} else {
  // Show health recommendations
  final recommendations = healthService.getHealthRecommendations(health);
  showDialog(...);
}
```

---

**🎊 All services are production-ready! Start integrating today!** 🚀
