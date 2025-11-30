# Blood Donation App - Firebase Database Schema & ER Diagram

## 📊 Entity Relationship Diagram (ER Diagram)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                          BLOOD DONATION APP - DATABASE SCHEMA                                │
│                                   Firebase Firestore                                         │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────────┐
                                    │   SUPER ADMIN   │
                                    │    (User)       │
                                    │  role=superAdmin│
                                    └────────┬────────┘
                                             │ creates (1:N)
                                             ▼
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                              │
│  ┌─────────────────────┐         creates (1:N)        ┌─────────────────────┐               │
│  │      ORG ADMIN      │◄─────────────────────────────│      USERS          │               │
│  │  (User Collection)  │                              │   (Collection)      │               │
│  │   role = orgAdmin   │                              │   role = user       │               │
│  ├─────────────────────┤                              ├─────────────────────┤               │
│  │ • id (PK)           │                              │ • id (PK)           │               │
│  │ • email             │                              │ • email             │               │
│  │ • name              │                              │ • name              │               │
│  │ • phone             │         manages (1:N)        │ • bloodType         │               │
│  │ • organization      │──────────────────────────┐   │ • phone             │               │
│  │ • isActive          │                          │   │ • age               │               │
│  │ • createdAt         │                          │   │ • gender            │               │
│  │ • createdBy (FK)────│──► SuperAdmin            │   │ • address           │               │
│  │ • permissions[]     │                          │   │ • district          │               │
│  │ • role              │                          │   │ • lastDonationDate  │               │
│  └─────────────────────┘                          │   │ • role              │               │
│           │                                       │   │ • createdAt         │               │
│           │ assigned to (N:1)                     │   └─────────────────────┘               │
│           ▼                                       │             │                           │
│  ┌─────────────────────────────────────────────┐  │             │ creates (1:N)             │
│  │              BLOOD REQUESTS                 │  │             │                           │
│  │               (Collection)                  │◄─┘             │                           │
│  ├─────────────────────────────────────────────┤                ▼                           │
│  │ • id (PK)                                   │◄───────────────┤                           │
│  │ • bloodType                                 │   requests     │                           │
│  │ • hospitalName                              │                │                           │
│  │ • location                                  │                │                           │
│  │ • contactPhone                              │                │                           │
│  │ • patientName                               │                │                           │
│  │ • unitsNeeded                               │                │                           │
│  │ • urgency (normal/urgent/critical)          │                │                           │
│  │ • status (pending/approved/fulfilled/cancel)│                │                           │
│  │ • requestedBy (FK) ─────────────────────────│──► User.id     │                           │
│  │ • requestedByName                           │                │                           │
│  │ • requestDate                               │                │                           │
│  │ • fulfilledDate                             │                │                           │
│  │ • notes                                     │                │                           │
│  │ • assignedAdminId (FK) ─────────────────────│──► OrgAdmin.id │                           │
│  └─────────────────────────────────────────────┘                │                           │
│                    │                                            │                           │
│                    │ fulfilled by (N:1)                         │                           │
│                    ▼                                            │                           │
│  ┌─────────────────────────────────────────────┐                │                           │
│  │              DONATIONS                      │◄───────────────┘                           │
│  │              (Collection)                   │   donates (1:N)                            │
│  ├─────────────────────────────────────────────┤                                            │
│  │ • id (PK)                                   │                                            │
│  │ • donorId (FK) ─────────────────────────────│──► User.id                                 │
│  │ • donorName                                 │                                            │
│  │ • bloodType                                 │                                            │
│  │ • donationDate                              │                                            │
│  │ • location                                  │                                            │
│  │ • status (scheduled/completed/cancelled)    │                                            │
│  │ • notes                                     │                                            │
│  │ • recipientRequestId (FK) ──────────────────│──► BloodRequest.id                         │
│  │ • recipientPatientName                      │                                            │
│  │ • recipientHospital                         │                                            │
│  │ • recipientBloodType                        │                                            │
│  │ • recipientContactPhone                     │                                            │
│  └─────────────────────────────────────────────┘                                            │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SUPPORTING COLLECTIONS                                          │
└──────────────────────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────┐          ┌─────────────────────────────┐
  │      DONATION CENTERS       │          │         MESSAGES            │
  │        (Collection)         │          │        (Collection)         │
  ├─────────────────────────────┤          ├─────────────────────────────┤
  │ • id (PK)                   │          │ • id (PK)                   │
  │ • name                      │          │ • senderId (FK) ──► User.id │
  │ • address                   │          │ • senderName                │
  │ • area                      │          │ • receiverId (FK) ► User.id │
  │ • latitude                  │          │ • content                   │
  │ • longitude                 │          │ • timestamp                 │
  │ • phone                     │          │ • isRead                    │
  │ • type (hospital/blood_bank │          │ • type (personal/emergency/ │
  │         /mobile_unit)       │          │         system)             │
  │ • availableBloodTypes[]     │          └─────────────────────────────┘
  │ • isActive                  │
  │ • workingHours{}            │          ┌─────────────────────────────┐
  │ • createdAt                 │          │        CHAT ROOMS           │
  └─────────────────────────────┘          │        (Collection)         │
                                           ├─────────────────────────────┤
  ┌─────────────────────────────┐          │ • id (PK)                   │
  │        AUDIT LOGS           │          │ • participants[] (FK)►User  │
  │        (Collection)         │          │ • lastMessage               │
  ├─────────────────────────────┤          │ • lastMessageTime           │
  │ • id (PK)                   │          │ • unreadCount               │
  │ • action                    │          │ • otherParticipantName      │
  │ • email                     │          └─────────────────────────────┘
  │ • role                      │
  │ • status                    │          ┌─────────────────────────────┐
  │ • uid                       │          │         SETTINGS            │
  │ • timestamp                 │          │        (Collection)         │
  └─────────────────────────────┘          ├─────────────────────────────┤
                                           │ • id (PK)                   │
                                           │ • key                       │
                                           │ • value                     │
                                           │ • updatedAt                 │
                                           └─────────────────────────────┘
```

---

## 🔗 Relationships Summary (সম্পর্ক সারসংক্ষেপ)

### 1. ONE-TO-MANY (1:N) Relationships

| Parent Entity | Child Entity | Relationship | Description (বাংলা) |
|---------------|--------------|--------------|---------------------|
| **SuperAdmin** | **OrgAdmin** | 1:N | একজন Super Admin অনেক Org Admin তৈরি করতে পারে |
| **User** | **BloodRequest** | 1:N | একজন User অনেকগুলো Blood Request করতে পারে |
| **User** | **Donation** | 1:N | একজন User (Donor) অনেকবার রক্তদান করতে পারে |
| **OrgAdmin** | **BloodRequest** | 1:N | একজন OrgAdmin অনেক Request manage করতে পারে |
| **User** | **Message** (sender) | 1:N | একজন User অনেক Message পাঠাতে পারে |
| **User** | **Message** (receiver) | 1:N | একজন User অনেক Message পেতে পারে |

### 2. MANY-TO-ONE (N:1) Relationships

| Child Entity | Parent Entity | Foreign Key | Description (বাংলা) |
|--------------|---------------|-------------|---------------------|
| **BloodRequest** | **User** | requestedBy | প্রতিটি Request একজন User এর |
| **BloodRequest** | **OrgAdmin** | assignedAdminId | প্রতিটি Request একজন Admin এ assign |
| **Donation** | **User** | donorId | প্রতিটি Donation একজন Donor এর |
| **Donation** | **BloodRequest** | recipientRequestId | Donation কোন Request পূরণ করল |
| **OrgAdmin** | **SuperAdmin** | createdBy | প্রতিটি Admin কোন SuperAdmin তৈরি করেছে |

### 3. MANY-TO-MANY (N:M) Relationships

| Entity 1 | Entity 2 | Junction | Description (বাংলা) |
|----------|----------|----------|---------------------|
| **User** | **User** | ChatRoom.participants[] | দুইজন User একটি ChatRoom এ থাকে |

---

## 📋 Collection Details (বিস্তারিত)

### 1. USERS Collection
```
Collection: users
Document ID: Firebase Auth UID
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | ✅ | User's email address |
| name | string | ✅ | Full name |
| bloodType | string | ✅ | A+, A-, B+, B-, O+, O-, AB+, AB- |
| phone | string | ❌ | Contact number |
| role | string | ✅ | 'superAdmin', 'orgAdmin', 'user' |
| age | number | ❌ | User's age |
| gender | string | ❌ | 'male', 'female', 'other' |
| address | string | ❌ | Full address |
| district | string | ❌ | District/Division |
| lastDonationDate | timestamp | ❌ | Last blood donation date |
| createdAt | timestamp | ✅ | Account creation date |
| isActive | boolean | ❌ | For admins only |
| organization | string | ❌ | For orgAdmin only |
| createdBy | string | ❌ | SuperAdmin ID who created |
| permissions | array | ❌ | Admin permissions list |

### 2. BLOOD_REQUESTS Collection
```
Collection: bloodRequests
Document ID: Auto-generated
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| bloodType | string | ✅ | Required blood type |
| hospitalName | string | ✅ | Hospital name |
| location | string | ✅ | Hospital location |
| contactPhone | string | ✅ | Contact phone |
| patientName | string | ✅ | Patient name |
| unitsNeeded | number | ✅ | Blood units needed |
| urgency | string | ✅ | 'normal', 'urgent', 'critical' |
| status | string | ✅ | 'pending', 'approved', 'fulfilled', 'cancelled' |
| requestedBy | string | ✅ | User ID (FK → users) |
| requestedByName | string | ✅ | User's name |
| requestDate | timestamp | ✅ | Request creation date |
| fulfilledDate | timestamp | ❌ | When request was fulfilled |
| notes | string | ❌ | Additional notes |
| assignedAdminId | string | ❌ | OrgAdmin ID (FK → users) |

### 3. DONATIONS Collection
```
Collection: donations
Document ID: Auto-generated
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| donorId | string | ✅ | Donor User ID (FK → users) |
| donorName | string | ✅ | Donor's name |
| bloodType | string | ✅ | Donated blood type |
| donationDate | timestamp | ✅ | Date of donation |
| location | string | ✅ | Donation location |
| status | string | ✅ | 'scheduled', 'completed', 'cancelled' |
| notes | string | ❌ | Additional notes |
| recipientRequestId | string | ❌ | BloodRequest ID (FK) |
| recipientPatientName | string | ❌ | Patient who received |
| recipientHospital | string | ❌ | Hospital name |
| recipientBloodType | string | ❌ | Patient's blood type |
| recipientContactPhone | string | ❌ | Contact phone |

### 4. DONATION_CENTERS Collection
```
Collection: donationCenters
Document ID: Auto-generated
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | ✅ | Center name |
| address | string | ✅ | Full address |
| area | string | ✅ | Area/Zone |
| latitude | number | ✅ | GPS latitude |
| longitude | number | ✅ | GPS longitude |
| phone | string | ✅ | Contact phone |
| type | string | ✅ | 'hospital', 'blood_bank', 'mobile_unit' |
| availableBloodTypes | array | ✅ | List of blood types |
| isActive | boolean | ✅ | Is center active |
| workingHours | map | ✅ | Day → Hours mapping |
| createdAt | timestamp | ✅ | Creation date |

### 5. MESSAGES Collection
```
Collection: messages
Document ID: Auto-generated
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| senderId | string | ✅ | Sender User ID (FK → users) |
| senderName | string | ✅ | Sender's name |
| receiverId | string | ✅ | Receiver User ID (FK → users) |
| content | string | ✅ | Message content |
| timestamp | timestamp | ✅ | Send time |
| isRead | boolean | ✅ | Read status |
| type | string | ✅ | 'personal', 'emergency', 'system' |

### 6. AUDIT_LOGS Collection
```
Collection: auditLogs
Document ID: Auto-generated
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| action | string | ✅ | Action performed |
| email | string | ✅ | User email |
| role | string | ✅ | User role |
| status | string | ✅ | Action status |
| uid | string | ✅ | User ID |
| timestamp | timestamp | ✅ | Action time |

---

## 📊 Visual ER Diagram (Simplified)

```
                                    ┌──────────────┐
                                    │  SUPER ADMIN │
                                    └──────┬───────┘
                                           │ 1
                                           │
                                           │ creates
                                           ▼ N
                          ┌────────────────────────────────┐
                          │           ORG ADMIN            │
                          └────────────────┬───────────────┘
                                           │ 1
                                           │ manages
                                           ▼ N
    ┌─────────┐  1         N  ┌─────────────────────────┐
    │  USER   │───────────────│     BLOOD REQUEST       │
    │ (Donor) │  creates      └────────────┬────────────┘
    └────┬────┘                            │
         │ 1                               │ N
         │                                 │ fulfilled by
         │ donates                         ▼ 1
         ▼ N                    ┌─────────────────────────┐
    ┌─────────────────────────┐ │       DONATION          │
    │       DONATION          │◄┘                         │
    │   (with recipient)      │                           │
    └─────────────────────────┘                           │
                                                          │
    ┌─────────────────────────┐       ┌──────────────────┐
    │    DONATION CENTER      │       │   AUDIT LOGS     │
    │  (Independent Entity)   │       │  (System Logs)   │
    └─────────────────────────┘       └──────────────────┘

    ┌─────────────────────────┐       ┌──────────────────┐
    │       MESSAGES          │       │   CHAT ROOMS     │
    │  (User ↔ User)         │       │ (N:M via array)  │
    └─────────────────────────┘       └──────────────────┘
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BLOOD DONATION WORKFLOW                            │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌──────────┐                                              ┌──────────┐
  │   USER   │                                              │   USER   │
  │ (Patient)│                                              │ (Donor)  │
  └────┬─────┘                                              └────┬─────┘
       │                                                         │
       │ 1. Creates Blood Request                                │
       ▼                                                         │
  ┌─────────────────┐                                            │
  │  BLOOD REQUEST  │ status = 'pending'                         │
  │   (pending)     │                                            │
  └────────┬────────┘                                            │
           │                                                     │
           │ 2. Admin Reviews                                    │
           ▼                                                     │
  ┌─────────────────┐                                            │
  │   ORG ADMIN     │ assigns to self                            │
  │                 │ status = 'approved'                        │
  └────────┬────────┘                                            │
           │                                                     │
           │ 3. Notifies Donors                                  │
           ├─────────────────────────────────────────────────────┤
           │                                                     │
           │                                    4. Donor Responds│
           │                                                     ▼
           │                                            ┌─────────────────┐
           │                                            │    DONATION     │
           │                                            │  (scheduled)    │
           │                                            └────────┬────────┘
           │                                                     │
           │ 5. Links Donation to Request                        │
           ◄─────────────────────────────────────────────────────┤
           │                                                     │
           ▼                                                     │
  ┌─────────────────┐                              ┌─────────────┴─────────┐
  │  BLOOD REQUEST  │                              │      DONATION         │
  │   (fulfilled)   │◄─────────────────────────────│     (completed)       │
  │                 │  recipientRequestId links    │  with recipient info  │
  └─────────────────┘                              └───────────────────────┘
```

---

## 📱 Role-Based Access

| Collection | SuperAdmin | OrgAdmin | User |
|------------|------------|----------|------|
| users | Full CRUD | Read Only | Own Profile Only |
| bloodRequests | Full CRUD | Assigned Only | Own Requests |
| donations | Full CRUD | View All | Own Donations |
| donationCenters | Full CRUD | Read Only | Read Only |
| auditLogs | Full Access | No Access | No Access |
| messages | View All | Own Messages | Own Messages |
| settings | Full CRUD | No Access | No Access |

---

## 🔑 Key Constraints

### Business Rules (ব্যবসায়িক নিয়ম):

1. **Donation Interval**: একজন Donor ১২০ দিনে একবার রক্তদান করতে পারবে
2. **Blood Type Match**: Donation এর bloodType এবং Donor এর bloodType same হতে হবে
3. **Request Assignment**: একটি BloodRequest শুধুমাত্র একজন OrgAdmin এ assign হতে পারে
4. **Status Flow**: 
   - BloodRequest: pending → approved → fulfilled/cancelled
   - Donation: scheduled → completed/cancelled

### Referential Integrity:

```
donations.donorId           → users.id (REQUIRED)
donations.recipientRequestId → bloodRequests.id (OPTIONAL)
bloodRequests.requestedBy    → users.id (REQUIRED)
bloodRequests.assignedAdminId → users.id (OPTIONAL)
messages.senderId           → users.id (REQUIRED)
messages.receiverId         → users.id (REQUIRED)
users.createdBy             → users.id (for orgAdmins only)
```

---

## 📈 Statistics Query Examples

```javascript
// Total Users by Role
users.where('role', '==', 'user').count()
users.where('role', '==', 'orgAdmin').count()
users.where('role', '==', 'superAdmin').count()

// Blood Type Distribution
users.where('bloodType', '==', 'A+').count()
users.where('bloodType', '==', 'B+').count()
// ... etc

// Request Status
bloodRequests.where('status', '==', 'pending').count()
bloodRequests.where('status', '==', 'fulfilled').count()

// Donations This Month
donations.where('donationDate', '>=', startOfMonth)
         .where('donationDate', '<=', endOfMonth)
         .count()
```

---

**Document Created**: November 29, 2025  
**App Name**: Blood Donation App  
**Database**: Firebase Firestore  
**Author**: Auto-generated from codebase analysis
