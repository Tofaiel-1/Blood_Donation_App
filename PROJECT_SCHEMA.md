# Blood Donation App - Project Schema & Architecture

## 📊 Complete System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        BLOOD DONATION APP ECOSYSTEM                          │
│                    (Flutter + Firebase + Gemini AI)                          │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────┐
│   USER INTERFACE     │────▶│   BUSINESS LOGIC     │────▶│   DATA LAYER     │
│   (Screens/Widgets)  │     │   (Services)         │     │   (Firebase)     │
└──────────────────────┘     └──────────────────────┘     └──────────────────┘
```

---

## 🗄️ DATABASE SCHEMA (Firebase Firestore)

### **Collections & Documents Structure**

```
firebase_firestore/
│
├── users/                              # User Profiles Collection
│   └── {userId}/                       # Document per user
│       ├── id: String                  # User ID (UID from Firebase Auth)
│       ├── email: String               # Email address
│       ├── name: String                # Full name
│       ├── bloodType: String           # A+, A-, B+, B-, O+, O-, AB+, AB-
│       ├── phone: String?              # Contact number
│       ├── role: String                # 'user' | 'orgAdmin' | 'superAdmin'
│       ├── age: int?                   # Age in years
│       ├── gender: String?             # 'Male' | 'Female' | 'Other'
│       ├── address: String?            # Full address
│       ├── lastDonationDate: Timestamp?# Last donation date
│       ├── totalDonations: int         # Total donations count
│       ├── livesSaved: int             # Lives saved (1 per donation)
│       ├── availability: String        # 'available' | 'unavailable' | 'busy'
│       ├── badges: List<String>        # Achievement badges
│       ├── weight: double?             # Weight in kg
│       ├── medicalConditions: String?  # Any medical issues
│       ├── dateOfBirth: Timestamp?     # Birth date
│       ├── isEligibleToDonate: bool    # Donation eligibility
│       ├── nextEligibleDate: Timestamp?# Next donation date (120 days rule)
│       ├── profileImageUrl: String?    # Profile picture URL
│       ├── createdAt: Timestamp        # Account creation
│       └── updatedAt: Timestamp        # Last update
│
├── bloodRequests/                      # Blood Request Collection
│   └── {requestId}/                    # Document per request
│       ├── bloodType: String           # Required blood type
│       ├── hospitalName: String        # Hospital name
│       ├── location: String            # Location/Address
│       ├── contactPhone: String        # Contact number
│       ├── patientName: String         # Patient name
│       ├── unitsNeeded: int            # Blood units needed
│       ├── urgency: String             # 'normal' | 'urgent' | 'critical'
│       ├── status: String              # 'pending' | 'approved' | 'fulfilled' | 'cancelled'
│       ├── requestedBy: String         # User ID who created request
│       ├── requestedByName: String     # Requester's name
│       ├── requestDate: Timestamp      # Request creation date
│       ├── fulfilledDate: Timestamp?   # When fulfilled
│       ├── notes: String?              # Additional notes
│       └── assignedAdminId: String?    # Admin handling this
│
├── donations/                          # Donation History Collection
│   └── {donationId}/                   # Document per donation
│       ├── donorId: String             # Donor's user ID
│       ├── donorName: String           # Donor's name
│       ├── bloodType: String           # Blood type donated
│       ├── donationDate: String        # ISO 8601 date
│       ├── location: String            # Donation center
│       ├── status: String              # 'scheduled' | 'completed' | 'cancelled'
│       ├── notes: String?              # Additional notes
│       ├── recipientRequestId: String? # Linked blood request ID
│       ├── recipientPatientName: String?# Patient who received
│       ├── recipientHospital: String?  # Hospital name
│       ├── recipientBloodType: String? # Patient's blood type
│       └── recipientContactPhone: String?# Contact number
│
├── donationCenters/                    # Donation Centers Collection
│   └── {centerId}/                     # Document per center
│       ├── name: String                # Center name (Bengali/English)
│       ├── address: String             # Full address
│       ├── area: String                # Area/Region
│       ├── latitude: double            # GPS coordinate
│       ├── longitude: double           # GPS coordinate
│       ├── phone: String               # Contact number
│       ├── type: String                # 'hospital' | 'blood_bank' | 'mobile_unit'
│       ├── availableBloodTypes: List<String> # Blood types available
│       ├── isActive: bool              # Currently operating
│       ├── workingHours: Map<String, String> # Day: "9AM-5PM"
│       └── createdAt: Timestamp        # Center added date
│
├── messages/                           # Messaging Collection
│   └── {messageId}/                    # Document per message
│       ├── senderId: String            # Sender user ID
│       ├── senderName: String          # Sender name
│       ├── receiverId: String          # Receiver user ID
│       ├── content: String             # Message text
│       ├── timestamp: Timestamp        # Message time
│       ├── isRead: bool                # Read status
│       └── type: String                # 'personal' | 'emergency' | 'system' | 'broadcast'
│
├── chatRooms/                          # Chat Rooms Collection
│   └── {chatRoomId}/                   # Document per chat room
│       ├── participants: List<String>  # User IDs in chat
│       ├── lastMessage: String         # Last message preview
│       ├── lastMessageTime: Timestamp  # Last message time
│       ├── unreadCount: int            # Unread messages count
│       └── otherParticipantName: String# Other person's name
│
├── broadcastAlerts/                    # Admin Broadcast Alerts
│   └── {alertId}/                      # Document per alert
│       ├── title: String               # Alert title
│       ├── message: String             # Alert content
│       ├── createdBy: String           # Admin user ID
│       ├── createdAt: Timestamp        # Creation time
│       ├── bloodType: String?          # Target blood type (optional)
│       ├── urgency: String             # 'normal' | 'urgent' | 'critical'
│       └── sentToCount: int            # Recipients count
│
└── inventory/                          # Blood Inventory (Admin)
    └── {inventoryId}/                  # Document per blood unit
        ├── bloodType: String           # Blood type
        ├── unitsAvailable: int         # Available units
        ├── location: String            # Storage location
        ├── expiryDate: Timestamp       # Expiration date
        └── lastUpdated: Timestamp      # Last update time
```

---

## 🏗️ APPLICATION ARCHITECTURE

### **Layer Structure**

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
│                         (lib/screens/)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Welcome    │  │     Auth     │  │     Home     │             │
│  │   Screen     │──▶│   Screens    │──▶│   Screens    │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│         │               │    │              │   │   │               │
│         │          ┌────┘    └────┐         │   │   │               │
│         │          │              │         │   │   │               │
│    ┌────▼────┐  ┌─▼──┐      ┌───▼───┐  ┌──▼───▼───▼──┐            │
│    │  Theme  │  │Login│      │Sign Up│  │  Main Nav   │            │
│    │Showcase │  └─────┘      └───────┘  │   Screen    │            │
│    └─────────┘                           └──────┬──────┘            │
│                                                  │                   │
│                     ┌────────────────────────────┼──────────┐        │
│                     │            │               │          │        │
│                ┌────▼───┐   ┌───▼────┐   ┌─────▼────┐ ┌───▼───┐   │
│                │  Home  │   │ Search │   │ Donate   │ │Profile│   │
│                │ Screen │   │ Screen │   │ Screen   │ │Screen │   │
│                └────┬───┘   └───┬────┘   └─────┬────┘ └───┬───┘   │
│                     │           │              │          │        │
│         ┌───────────┼───────────┼──────────────┼──────────┤        │
│         │           │           │              │          │        │
│    ┌────▼────┐ ┌───▼────┐ ┌───▼─────┐   ┌────▼────┐ ┌──▼──────┐  │
│    │Messages │ │Request │ │Donation │   │  My QR  │ │  About  │  │
│    │ Screen  │ │Posting │ │ Centers │   │  Code   │ │ Screen  │  │
│    └─────────┘ └────────┘ └─────────┘   └─────────┘ └─────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────┐          │
│  │              ADMIN SCREENS (lib/screens/admin/)       │          │
│  ├──────────────────────────────────────────────────────┤          │
│  │  • Admin Dashboard      • User Management            │          │
│  │  • Blood Request Mgmt   • Inventory Management       │          │
│  │  • Broadcast Alerts     • Analytics & Reports        │          │
│  └──────────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BUSINESS LOGIC LAYER                         │
│                         (lib/services/)                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │    Auth      │  │  Firestore   │  │   Messaging  │             │
│  │   Service    │  │   Service    │  │   Service    │             │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │
│         │                  │                  │                      │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐             │
│  │   Location   │  │  Inventory   │  │   Analytics  │             │
│  │   Service    │  │   Service    │  │   Service    │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │    Admin     │  │    Gemini    │  │  Broadcast   │             │
│  │   Service    │  │ Chat Service │  │Alert Service │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Storage    │  │Notification  │  │ Demo Data    │             │
│  │   Service    │  │   Service    │  │   Service    │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                │
│                         (lib/models/)                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │     User     │  │    Blood     │  │   Donation   │             │
│  │    Model     │  │   Request    │  │    Model     │             │
│  │              │  │    Model     │  │              │             │
│  │ • UserRole   │  │              │  │ • id         │             │
│  │ • Donor      │  │ • Status     │  │ • donorId    │             │
│  │   Availability│  │ • Urgency    │  │ • bloodType  │             │
│  │ • DonorBadge │  │   Level      │  │ • location   │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Donation   │  │    Message   │  │     Admin    │             │
│  │    Center    │  │    Model     │  │    Model     │             │
│  │              │  │              │  │              │             │
│  │ • location   │  │ • MessageType│  │ • adminId    │             │
│  │ • workingHrs │  │ • ChatRoom   │  │ • permissions│             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       EXTERNAL SERVICES                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              Firebase Services                                │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  • Firebase Auth        (Authentication)                      │  │
│  │  • Cloud Firestore      (Database)                            │  │
│  │  • Firebase Storage     (File Storage - Profile Images)       │  │
│  │  • Cloud Messaging      (Push Notifications - FCM)            │  │
│  │  • Firebase Analytics   (Usage Analytics)                     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              Third-Party Services                             │  │
│  ├──────────────────────────────────────────────────────────────┤  │
│  │  • Google Gemini AI     (Chatbot Service)                     │  │
│  │  • Google Maps API      (Location Services)                   │  │
│  │  • QR Flutter           (QR Code Generation)                  │  │
│  │  • Share Plus           (Social Sharing)                      │  │
│  │  • URL Launcher         (External Links)                      │  │
│  │  • Package Info Plus    (App Version Info)                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 👥 USER ROLES & PERMISSIONS

```
┌────────────────────────────────────────────────────────────────┐
│                         USER HIERARCHY                          │
└────────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │   Super Admin    │
                    │   (superAdmin)   │
                    └────────┬─────────┘
                             │
                    Full System Access
                             │
            ┌────────────────┼────────────────┐
            │                │                │
     ┌──────▼──────┐  ┌─────▼─────┐  ┌──────▼──────┐
     │   Manage    │  │  Manage   │  │  Broadcast  │
     │    Users    │  │ Requests  │  │   Alerts    │
     └─────────────┘  └───────────┘  └─────────────┘

                    ┌──────────────────┐
                    │  Organization    │
                    │  Admin (orgAdmin)│
                    └────────┬─────────┘
                             │
                  Limited Admin Access
                             │
            ┌────────────────┼────────────────┐
            │                │                │
     ┌──────▼──────┐  ┌─────▼─────┐  ┌──────▼──────┐
     │   View      │  │  Approve  │  │   Manage    │
     │  Analytics  │  │  Requests │  │  Inventory  │
     └─────────────┘  └───────────┘  └─────────────┘

                    ┌──────────────────┐
                    │   Regular User   │
                    │     (user)       │
                    └────────┬─────────┘
                             │
                    Standard Features
                             │
            ┌────────────────┼────────────────────┐
            │                │                    │
     ┌──────▼──────┐  ┌─────▼─────┐  ┌──────────▼──────┐
     │   Search    │  │  Donate   │  │  Create Request │
     │   Donors    │  │   Blood   │  │  (for patient)  │
     └─────────────┘  └───────────┘  └─────────────────┘
```

### **Permission Matrix**

| Feature                 | Super Admin | Org Admin | Regular User |
|------------------------|-------------|-----------|--------------|
| 🔍 Search Donors       | ✅          | ✅        | ✅           |
| 🩸 Donate Blood        | ✅          | ✅        | ✅           |
| 📋 Create Request      | ✅          | ✅        | ✅           |
| 💬 Chat/Message        | ✅          | ✅        | ✅           |
| 📱 QR Code             | ✅          | ✅        | ✅           |
| 👤 Edit Own Profile    | ✅          | ✅        | ✅           |
| ✅ Approve Requests    | ✅          | ✅        | ❌           |
| 📊 View Analytics      | ✅          | ✅        | ❌           |
| 📦 Manage Inventory    | ✅          | ✅        | ❌           |
| 📢 Broadcast Alerts    | ✅          | ❌        | ❌           |
| 👥 Manage All Users    | ✅          | ❌        | ❌           |
| ⚙️ System Settings     | ✅          | ❌        | ❌           |

---

## 🔄 DATA FLOW DIAGRAM

### **Blood Donation Flow**

```
┌─────────────┐
│    USER     │
│ (Wants to   │
│   Donate)   │
└──────┬──────┘
       │
       │ 1. Opens Donate Screen
       ▼
┌─────────────────┐
│  Donate Screen  │──────┐
│  - Select Center│      │
│  - Choose Date  │      │ 2. Fetch Available Centers
└────────┬────────┘      │
         │               ▼
         │        ┌──────────────┐
         │        │  Firestore   │
         │        │  Service     │
         │        └──────┬───────┘
         │               │
         │ 3. Submit     │ 4. Query donationCenters/
         │    Donation   │
         ▼               ▼
┌──────────────────────────┐
│   Firestore Database     │
│   donations/             │
│   └── {newDonationId}    │
│       ├── donorId        │
│       ├── bloodType      │
│       ├── date           │
│       └── status         │
└────────┬─────────────────┘
         │
         │ 5. Update User Stats
         ▼
┌──────────────────────────┐
│   users/{userId}         │
│   ├── totalDonations++   │
│   ├── livesSaved++       │
│   ├── lastDonationDate   │
│   └── badges (update)    │
└────────┬─────────────────┘
         │
         │ 6. Send Confirmation
         ▼
┌─────────────┐
│    USER     │
│ (Receives   │
│Confirmation)│
└─────────────┘
```

### **Blood Request Flow**

```
┌─────────────┐
│    USER     │
│  (Needs     │
│   Blood)    │
└──────┬──────┘
       │
       │ 1. Create Blood Request
       ▼
┌─────────────────────┐
│ Request Posting     │
│ Screen              │
│ - Blood Type        │
│ - Hospital          │
│ - Contact           │
│ - Urgency Level     │
└────────┬────────────┘
         │
         │ 2. Submit Request
         ▼
┌──────────────────────────┐
│   Firestore Database     │
│   bloodRequests/         │
│   └── {requestId}        │
│       ├── status: pending│
│       ├── urgency        │
│       └── requestedBy    │
└────────┬─────────────────┘
         │
         │ 3. Notification
         ▼
┌─────────────────┐
│  Broadcast      │
│  Alert Service  │───────────────┐
└────────┬────────┘               │
         │                        │ 4. Notify Matching Donors
         │                        ▼
         │                 ┌──────────────┐
         │                 │  Users with  │
         │                 │  Matching    │
         │                 │  Blood Type  │
         │                 └──────┬───────┘
         │                        │
         │                        │ 5. Push Notification
         │                        ▼
         │                 ┌──────────────┐
         │                 │   Donors     │
         │                 │  (Receive    │
         │                 │   Alert)     │
         │                 └──────┬───────┘
         │                        │
         │                        │ 6. Donor Responds
         ▼                        ▼
┌─────────────────────────────────────┐
│         Admin Dashboard              │
│         - Approve Request            │
│         - Assign Donors              │
└─────────────┬───────────────────────┘
              │
              │ 7. Approve & Match
              ▼
┌──────────────────────────┐
│  bloodRequests/          │
│  └── {requestId}         │
│      ├── status: approved│
│      └── assignedAdminId │
└────────┬─────────────────┘
         │
         │ 8. Status Update
         ▼
┌─────────────┐
│  Requester  │
│ (Receives   │
│  Update)    │
└─────────────┘
```

### **Search & Matching Flow**

```
┌─────────────┐
│    USER     │
│ (Searches   │
│  for Donor) │
└──────┬──────┘
       │
       │ 1. Open Search Screen
       ▼
┌─────────────────────┐
│   Search Screen     │
│   - Blood Type      │
│   - Location        │
│   - Availability    │
└────────┬────────────┘
         │
         │ 2. Apply Filters
         ▼
┌──────────────────────────┐
│   Firestore Service      │
│   - Query users/         │
│   - Where conditions:    │
│     • bloodType ==       │
│     • availability ==    │
│     • isEligible == true │
└────────┬─────────────────┘
         │
         │ 3. Return Results
         ▼
┌─────────────────────┐
│  Donor List         │
│  ┌────────────────┐ │
│  │ Donor 1        │ │
│  │ - Name         │ │
│  │ - Blood Type   │ │
│  │ - Availability │ │
│  │ - Last Donation│ │
│  └────────────────┘ │
│  ┌────────────────┐ │
│  │ Donor 2        │ │
│  └────────────────┘ │
└────────┬────────────┘
         │
         │ 4. Select Donor
         ▼
┌─────────────────────┐
│  Donor Profile      │
│  - Contact Info     │
│  - View QR Code     │
│  - Send Message     │
└────────┬────────────┘
         │
         │ 5. Contact/Message
         ▼
┌─────────────────────┐
│  Messaging Service  │
│  - Create Chat      │
│  - Send Message     │
└─────────────────────┘
```

---

## 🎯 FEATURE MODULES

### **1. Authentication Module**
```
┌─────────────────────────────────────────────┐
│           Authentication Flow                │
├─────────────────────────────────────────────┤
│                                              │
│  Welcome Screen                              │
│       ↓                                      │
│  ┌────────┐        ┌──────────┐            │
│  │ Login  │───OR───│ Sign Up  │            │
│  └───┬────┘        └────┬─────┘            │
│      │                  │                   │
│      └─────────┬────────┘                   │
│                │                             │
│        Firebase Auth                         │
│    (Email/Password/Phone)                    │
│                │                             │
│                ▼                             │
│    ┌─────────────────────┐                  │
│    │  Create/Update User │                  │
│    │  Profile in         │                  │
│    │  Firestore          │                  │
│    └──────────┬──────────┘                  │
│               │                              │
│               ▼                              │
│    ┌─────────────────────┐                  │
│    │  Main Navigation    │                  │
│    │  Screen             │                  │
│    └─────────────────────┘                  │
└─────────────────────────────────────────────┘
```

### **2. Donor Management**
- **User Profile**: View/Edit personal info, donation history, badges
- **Availability Status**: Set availability (Available/Unavailable/Busy)
- **Eligibility Tracking**: Auto-calculate next donation date (120-day rule)
- **Badge System**: Earn badges based on donations (Bronze → Silver → Gold → Platinum → Legendary)

### **3. Blood Request Management**
- **Create Request**: Users can request blood for patients
- **Urgency Levels**: Normal, Urgent, Critical
- **Admin Approval**: Admins review and approve requests
- **Status Tracking**: Pending → Approved → Fulfilled → Cancelled

### **4. Search & Discovery**
- **Advanced Filters**: Blood type, location, availability
- **Real-time Results**: Live Firestore queries
- **Donor Profiles**: View detailed donor information
- **Direct Contact**: Chat with matched donors

### **5. Messaging System**
- **One-on-One Chat**: Direct messaging between users
- **Chat Rooms**: Persistent conversation threads
- **Message Types**: Personal, Emergency, System, Broadcast
- **Read Receipts**: Track message read status

### **6. Admin Dashboard**
- **User Management**: View, edit, delete users
- **Request Approval**: Approve/reject blood requests
- **Broadcast Alerts**: Send urgent notifications to all donors
- **Analytics**: View donation statistics, active users
- **Inventory Management**: Track blood unit availability

### **7. Location Services**
- **Donation Centers**: Map of nearby centers with directions
- **GPS Integration**: Find centers based on current location
- **Center Details**: Working hours, contact info, available blood types
- **Bangladesh Focused**: Pre-loaded with Dhaka hospital data

### **8. AI Chatbot (Gemini)**
- **24/7 Support**: Answer donation-related questions
- **Health Guidelines**: Provide donation eligibility info
- **Smart Responses**: Context-aware conversation
- **Multi-language**: Support for Bengali and English

---

## 📱 SCREEN NAVIGATION MAP

```
Welcome Screen
│
├── Login Screen ────────────┐
│                             │
├── Sign Up Screen ──────────┤
                             │
                             ▼
                   Main Navigation Screen
                   │
                   ├── 🏠 Home Tab
                   │   │
                   │   ├── Home Screen
                   │   │   ├── Blood Request Stats
                   │   │   ├── Recent Donations
                   │   │   ├── Urgent Requests
                   │   │   └── Quick Actions
                   │   │
                   │   └── User Blood Requests Screen
                   │       └── View Own Requests
                   │
                   ├── 🔍 Search Tab
                   │   │
                   │   └── Search Screen
                   │       ├── Filter by Blood Type
                   │       ├── Filter by Location
                   │       └── Donor List Results
                   │
                   ├── 🩸 Donate Tab
                   │   │
                   │   └── Donate Screen
                   │       ├── Donation Centers Map
                   │       ├── Schedule Donation
                   │       └── Donation History
                   │
                   └── 👤 Profile Tab
                       │
                       └── Profile Screen
                           ├── User Info
                           ├── Donation Stats
                           ├── Badges
                           ├── Quick Actions
                           │   ├── My QR Code Screen
                           │   ├── Invite Friends Screen
                           │   ├── Help & Support Screen
                           │   └── About Screen
                           └── Settings

Admin Navigation
│
└── Admin Dashboard
    ├── User Management Screen
    ├── Blood Request Management
    ├── Inventory Management
    ├── Broadcast Alerts
    └── Analytics Screen
```

---

## 🔐 SECURITY & AUTHENTICATION

```
┌──────────────────────────────────────────────┐
│        Security Implementation               │
├──────────────────────────────────────────────┤
│                                              │
│  1. Firebase Authentication                  │
│     ✓ Email/Password Auth                    │
│     ✓ Phone Authentication (OTP)             │
│     ✓ Secure Token Management                │
│                                              │
│  2. Firestore Security Rules                 │
│     ✓ User can only edit own profile         │
│     ✓ Admin role-based access                │
│     ✓ Read permissions for public data       │
│     ✓ Write permissions for authorized users │
│                                              │
│  3. Data Validation                          │
│     ✓ Input sanitization                     │
│     ✓ Type checking                          │
│     ✓ Required field validation              │
│                                              │
│  4. Privacy                                  │
│     ✓ Phone number optional                  │
│     ✓ Address optional                       │
│     ✓ Profile visibility controls            │
│                                              │
└──────────────────────────────────────────────┘
```

---

## 📊 KEY METRICS & ANALYTICS

### **Tracked Metrics**

1. **User Metrics**
   - Total registered users
   - Active donors (available)
   - Donation frequency
   - Badge distribution

2. **Donation Metrics**
   - Total donations
   - Lives saved
   - Donations by blood type
   - Donations by location

3. **Request Metrics**
   - Total requests (pending/approved/fulfilled)
   - Average response time
   - Urgency level distribution
   - Fulfillment rate

4. **Engagement Metrics**
   - Daily active users
   - Message count
   - Search queries
   - App session duration

---

## 🔧 TECHNICAL STACK

```
┌─────────────────────────────────────────────┐
│           Technology Stack                   │
├─────────────────────────────────────────────┤
│                                              │
│  Frontend Framework                          │
│    • Flutter 3.32.6                          │
│    • Dart 3.8.1                              │
│                                              │
│  State Management                            │
│    • Provider Pattern                        │
│                                              │
│  Backend (BaaS)                              │
│    • Firebase Auth                           │
│    • Cloud Firestore                         │
│    • Firebase Storage                        │
│    • Firebase Cloud Messaging (FCM)          │
│    • Firebase Analytics                      │
│                                              │
│  AI Integration                              │
│    • Google Gemini AI API                    │
│                                              │
│  Key Packages                                │
│    • firebase_core                           │
│    • firebase_auth                           │
│    • cloud_firestore                         │
│    • firebase_storage                        │
│    • firebase_messaging                      │
│    • google_generative_ai (Gemini)           │
│    • provider (State Management)             │
│    • geolocator (Location)                   │
│    • qr_flutter (QR Code Generation)         │
│    • share_plus (Social Sharing)             │
│    • url_launcher (External Links)           │
│    • package_info_plus (App Info)            │
│                                              │
│  Platform Support                            │
│    • Android ✅                              │
│    • iOS ✅                                  │
│    • Web ✅                                  │
│                                              │
└─────────────────────────────────────────────┘
```

---

## 🌐 API INTEGRATIONS

### **1. Firebase APIs**
```
• Authentication API
  - signInWithEmailAndPassword()
  - createUserWithEmailAndPassword()
  - signInWithPhoneNumber()
  - signOut()

• Firestore API
  - collection()
  - doc()
  - get(), set(), update(), delete()
  - where(), orderBy(), limit()
  - onSnapshot() (Real-time listeners)

• Storage API
  - uploadBytes()
  - getDownloadURL()
  - deleteObject()
```

### **2. Google Gemini AI API**
```
• Chat API
  - generateContent()
  - startChat()
  - sendMessage()
  - getResponse()
```

### **3. Location Services**
```
• Geolocator
  - getCurrentPosition()
  - requestPermission()
  - getDistanceBetween()
```

---

## 🎨 UI/UX COMPONENTS

### **Reusable Widgets** (lib/widgets/)

```
themed_widgets.dart
├── ThemedButton
├── ThemedTextField
├── ThemedCard
├── ThemedAppBar
└── LoadingIndicator

Custom Components
├── BloodTypeSelector
├── DonorCard
├── RequestCard
├── BadgeDisplay
├── ChatBubble
└── CenterCard
```

### **Theme System**
- **Light Theme**: Default theme with red accent
- **Dark Theme**: Dark mode support
- **Custom Colors**: Blood donation theme (Red #E53935)
- **Dynamic Theming**: User can switch themes

---

## 📦 PROJECT FILE STRUCTURE

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
│
├── config/
│   └── routes.dart              # App routing configuration
│
├── models/                      # Data models
│   ├── user.dart                # User model with badges & roles
│   ├── blood_request.dart       # Blood request model
│   ├── donation.dart            # Donation model
│   ├── donation_center.dart     # Center model with locations
│   ├── message.dart             # Chat message model
│   ├── admin.dart               # Admin model
│   └── search.dart              # Search filters
│
├── screens/                     # UI screens
│   ├── welcome_screen.dart
│   ├── theme_showcase_screen.dart
│   ├── notifications_screen.dart
│   │
│   ├── auth/                    # Authentication
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── phone_auth_screen.dart
│   │
│   ├── home/                    # Main app screens
│   │   ├── main_navigation_screen.dart
│   │   ├── home_screen.dart
│   │   ├── search_screen.dart
│   │   ├── donate_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── messages_screen.dart
│   │   ├── user_blood_request_screen.dart
│   │   ├── request_posting_screen.dart
│   │   ├── my_qr_code_screen.dart
│   │   ├── invite_friends_screen.dart
│   │   ├── help_support_screen.dart
│   │   └── about_screen.dart
│   │
│   ├── admin/                   # Admin screens
│   │   ├── admin_dashboard_screen.dart
│   │   ├── user_management_screen.dart
│   │   ├── blood_request_management_screen.dart
│   │   ├── inventory_management_screen.dart
│   │   └── broadcast_alert_screen.dart
│   │
│   └── chat/                    # Chat features
│       └── chatbot_screen.dart  # Gemini AI chatbot
│
├── services/                    # Business logic
│   ├── auth_service.dart        # Authentication
│   ├── firestore_service.dart   # Database operations
│   ├── messaging_service.dart   # Chat functionality
│   ├── location_service.dart    # GPS & location
│   ├── admin_service.dart       # Admin operations
│   ├── inventory_service.dart   # Blood inventory
│   ├── analytics_service.dart   # Analytics tracking
│   ├── gemini_chat_service.dart # AI chatbot
│   ├── storage_service.dart     # File storage
│   ├── notification_service.dart# Push notifications
│   ├── broadcast_alert_service.dart # Mass alerts
│   ├── demo_data_service.dart   # Demo data
│   ├── bangladesh_demo_data_service.dart # BD data
│   └── donation_stats_service.dart # Statistics
│
├── utils/                       # Utilities
│   ├── app_colors.dart          # Color constants
│   ├── theme_manager.dart       # Theme management
│   └── validators.dart          # Input validation
│
└── widgets/                     # Reusable widgets
    ├── themed_widgets.dart      # Custom themed widgets
    ├── donor_card.dart          # Donor display card
    ├── request_card.dart        # Request display card
    └── badge_display.dart       # Achievement badges
```

---

## 🚀 DEPLOYMENT & BUILD

### **Build Variants**
```
Development
├── Debug Mode
├── Demo Data Enabled
└── Firebase Test Project

Production
├── Release Mode
├── Real Data
└── Firebase Production Project
```

### **Platform-Specific Configurations**
```
android/
├── app/
│   ├── build.gradle.kts         # Android build config
│   └── google-services.json     # Firebase Android config

ios/
└── Runner/
    └── GoogleService-Info.plist # Firebase iOS config

web/
└── index.html                   # Firebase Web config
```

---

## 📈 FUTURE ENHANCEMENTS

1. **Advanced Features**
   - Blood bank inventory tracking
   - Appointment scheduling system
   - Donor rewards program
   - Telemedicine integration

2. **Social Features**
   - Donor leaderboards
   - Social media sharing
   - Referral program
   - Community forums

3. **Analytics**
   - Advanced reporting
   - Predictive analytics
   - Donor behavior analysis
   - Demand forecasting

4. **Notifications**
   - SMS notifications
   - Email notifications
   - WhatsApp integration
   - Push notification preferences

---

## 📝 SUMMARY

This Blood Donation App is a comprehensive platform built with **Flutter** and **Firebase** that connects blood donors with recipients efficiently. The system features:

✅ **User Management**: Role-based access (Super Admin, Org Admin, User)
✅ **Donation Tracking**: Complete donation history with 120-day rule enforcement
✅ **Blood Requests**: Create, approve, and fulfill blood requests
✅ **Search & Match**: Advanced donor search with filters
✅ **Real-time Chat**: Direct messaging between users
✅ **Admin Dashboard**: Complete control over users, requests, and inventory
✅ **AI Chatbot**: 24/7 support powered by Google Gemini
✅ **Location Services**: Find nearby donation centers
✅ **Badge System**: Gamification with achievement badges
✅ **QR Codes**: Digital donor identification
✅ **Broadcast Alerts**: Mass notifications for urgent needs

The app follows a clean **3-layer architecture** (Presentation → Business Logic → Data) with Firebase as the backend, ensuring scalability, security, and real-time data synchronization.

---

**Created for**: Blood Donation App
**Version**: 1.0.0
**Last Updated**: December 2025
**Platform**: Flutter (Android, iOS, Web)
**Backend**: Firebase (Firestore, Auth, Storage, FCM)
**AI**: Google Gemini AI
