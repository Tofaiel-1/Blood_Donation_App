# 🩸 Blood Donation App - Entity Relationship Diagram

## Project Information
| Property | Value |
|----------|-------|
| **Project Name** | Blood Donation Management System |
| **Database** | Firebase Cloud Firestore (NoSQL) |
| **Platform** | Flutter (Android, iOS, Web) |
| **Version** | 1.0.0 |
| **Date** | November 29, 2025 |

---

## 📊 Complete ER Diagram

```
╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                                   ║
║                         🩸 BLOOD DONATION MANAGEMENT SYSTEM                                       ║
║                              Entity Relationship Diagram                                          ║
║                                                                                                   ║
╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝


                                         ┌─────────────────────────┐
                                         │      👑 SUPER_ADMIN     │
                                         │    ═══════════════════  │
                                         │    (Singleton Entity)   │
                                         │                         │
                                         │  • Full System Control  │
                                         │  • Creates Org Admins   │
                                         │  • Manages Settings     │
                                         └────────────┬────────────┘
                                                      │
                                                      │ creates
                                                      │ (1:N)
                                                      ▼
╔═════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                                     ║
║   ┌──────────────────────────────────────┐              ┌──────────────────────────────────────┐   ║
║   │          🏢 ORG_ADMIN                │              │           👤 USER (DONOR)            │   ║
║   │      ════════════════════            │              │        ═══════════════════           │   ║
║   │                                      │              │                                      │   ║
║   │  PK │ id           : string          │              │  PK │ id              : string      │   ║
║   │  ───┼────────────────────────────    │              │  ───┼────────────────────────────   │   ║
║   │     │ email        : string          │              │     │ email           : string      │   ║
║   │     │ name         : string          │              │     │ name            : string      │   ║
║   │     │ phone        : string?         │              │     │ bloodType       : enum        │   ║
║   │     │ organization : string          │              │     │ phone           : string?     │   ║
║   │     │ isActive     : boolean         │              │     │ age             : number?     │   ║
║   │     │ permissions  : array<string>   │              │     │ gender          : string?     │   ║
║   │     │ role         : 'orgAdmin'      │              │     │ address         : string?     │   ║
║   │     │ createdAt    : timestamp       │              │     │ district        : string?     │   ║
║   │  FK │ createdBy    : string ─────────│──────────────│──►  │ lastDonationDate: timestamp?  │   ║
║   │     │              (→ SuperAdmin)    │              │     │ role            : 'user'      │   ║
║   │     │                                │              │     │ createdAt       : timestamp   │   ║
║   └──────────────────┬───────────────────┘              └──────────────────┬───────────────────┘   ║
║                      │                                                     │                       ║
║                      │ manages/assigns                                     │ creates               ║
║                      │ (1:N)                                               │ (1:N)                 ║
║                      │                                                     │                       ║
║                      └─────────────────────┬───────────────────────────────┘                       ║
║                                            │                                                       ║
║                                            ▼                                                       ║
║   ┌────────────────────────────────────────────────────────────────────────────────────────────┐   ║
║   │                              🆘 BLOOD_REQUEST                                              │   ║
║   │                          ═══════════════════════                                           │   ║
║   │                                                                                            │   ║
║   │   PK │ id              : string (auto-generated)                                           │   ║
║   │   ───┼──────────────────────────────────────────────────────────────────────               │   ║
║   │      │ bloodType       : enum (A+, A-, B+, B-, O+, O-, AB+, AB-)                           │   ║
║   │      │ patientName     : string                                                            │   ║
║   │      │ hospitalName    : string                                                            │   ║
║   │      │ location        : string                                                            │   ║
║   │      │ contactPhone    : string                                                            │   ║
║   │      │ unitsNeeded     : number                                                            │   ║
║   │      │ urgency         : enum (normal, urgent, critical)                                   │   ║
║   │      │ status          : enum (pending, approved, fulfilled, cancelled)                    │   ║
║   │      │ requestDate     : timestamp                                                         │   ║
║   │      │ fulfilledDate   : timestamp?                                                        │   ║
║   │      │ notes           : string?                                                           │   ║
║   │   FK │ requestedBy     : string ──────────────────────────────────────► USER.id            │   ║
║   │   FK │ assignedAdminId : string? ─────────────────────────────────────► ORG_ADMIN.id       │   ║
║   │      │ requestedByName : string (denormalized)                                             │   ║
║   │                                                                                            │   ║
║   └────────────────────────────────────────┬───────────────────────────────────────────────────┘   ║
║                                            │                                                       ║
║                                            │ fulfilled by                                          ║
║                                            │ (N:1)                                                 ║
║                                            ▼                                                       ║
║   ┌────────────────────────────────────────────────────────────────────────────────────────────┐   ║
║   │                               💉 DONATION                                                  │   ║
║   │                           ════════════════════                                             │   ║
║   │                                                                                            │   ║
║   │   PK │ id                     : string (auto-generated)                                    │   ║
║   │   ───┼──────────────────────────────────────────────────────────────────────               │   ║
║   │      │ bloodType              : enum (A+, A-, B+, B-, O+, O-, AB+, AB-)                    │   ║
║   │      │ donationDate           : timestamp                                                  │   ║
║   │      │ location               : string                                                     │   ║
║   │      │ status                 : enum (scheduled, completed, cancelled)                     │   ║
║   │      │ notes                  : string?                                                    │   ║
║   │   FK │ donorId                : string ───────────────────────────────► USER.id            │   ║
║   │      │ donorName              : string (denormalized)                                      │   ║
║   │   ───┼────────────────────────────────────────────────────────────────────────             │   ║
║   │      │ 📋 RECIPIENT INFO (Optional - links to fulfilled request)                          │   ║
║   │   FK │ recipientRequestId     : string? ──────────────────────────────► BLOOD_REQUEST.id   │   ║
║   │      │ recipientPatientName   : string? (denormalized)                                     │   ║
║   │      │ recipientHospital      : string? (denormalized)                                     │   ║
║   │      │ recipientBloodType     : string? (denormalized)                                     │   ║
║   │      │ recipientContactPhone  : string? (denormalized)                                     │   ║
║   │                                                                                            │   ║
║   └────────────────────────────────────────────────────────────────────────────────────────────┘   ║
║                                                                                                     ║
╚═════════════════════════════════════════════════════════════════════════════════════════════════════╝


╔═════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                    SUPPORTING ENTITIES                                              ║
╚═════════════════════════════════════════════════════════════════════════════════════════════════════╝

┌────────────────────────────────────────┐      ┌────────────────────────────────────────┐
│         🏥 DONATION_CENTER             │      │            💬 MESSAGE                  │
│      ════════════════════════          │      │         ═══════════════                │
│                                        │      │                                        │
│  PK │ id                  : string     │      │  PK │ id          : string             │
│  ───┼────────────────────────────────  │      │  ───┼────────────────────────────────  │
│     │ name                : string     │      │     │ content     : string             │
│     │ address             : string     │      │     │ timestamp   : timestamp          │
│     │ area                : string     │      │     │ isRead      : boolean            │
│     │ latitude            : number     │      │     │ type        : enum               │
│     │ longitude           : number     │      │     │   (personal, emergency, system)  │
│     │ phone               : string     │      │  FK │ senderId    : string ──► USER.id │
│     │ type                : enum       │      │     │ senderName  : string             │
│     │   (hospital,blood_bank,mobile)   │      │  FK │ receiverId  : string ──► USER.id │
│     │ availableBloodTypes : array      │      │                                        │
│     │ isActive            : boolean    │      └────────────────────────────────────────┘
│     │ workingHours        : map        │
│     │ createdAt           : timestamp  │      ┌────────────────────────────────────────┐
│                                        │      │           🗨️ CHAT_ROOM                 │
└────────────────────────────────────────┘      │        ══════════════════              │
                                                │                                        │
┌────────────────────────────────────────┐      │  PK │ id                   : string    │
│          📝 AUDIT_LOG                  │      │  ───┼────────────────────────────────  │
│       ═══════════════════              │      │  FK │ participants[]       : array     │
│                                        │      │     │   (→ USER.id, USER.id)           │
│  PK │ id          : string             │      │     │ lastMessage          : string    │
│  ───┼────────────────────────────────  │      │     │ lastMessageTime      : timestamp │
│     │ action      : string             │      │     │ unreadCount          : number    │
│     │ email       : string             │      │     │ otherParticipantName : string    │
│     │ role        : string             │      │                                        │
│     │ status      : string             │      └────────────────────────────────────────┘
│  FK │ uid         : string ──► USER.id │
│     │ timestamp   : timestamp          │      ┌────────────────────────────────────────┐
│                                        │      │           ⚙️ SETTINGS                  │
└────────────────────────────────────────┘      │        ══════════════════              │
                                                │                                        │
                                                │  PK │ id        : string               │
                                                │  ───┼────────────────────────────────  │
                                                │     │ key       : string               │
                                                │     │ value     : dynamic              │
                                                │     │ updatedAt : timestamp            │
                                                │                                        │
                                                └────────────────────────────────────────┘
```

---

## 🔗 Relationship Diagram (Chen Notation)

```
                                    ┌─────────────┐
                                    │ SUPER_ADMIN │
                                    └──────┬──────┘
                                           │
                                           │ 1
                                    ╔══════╧══════╗
                                    ║   CREATES   ║
                                    ╚══════╤══════╝
                                           │ N
                                           ▼
                    ┌──────────────────────────────────────┐
                    │                                      │
                    ▼                                      ▼
             ┌─────────────┐                        ┌─────────────┐
             │  ORG_ADMIN  │                        │    USER     │
             └──────┬──────┘                        └──────┬──────┘
                    │                                      │
                    │ 1                                    │ 1
             ╔══════╧══════╗                        ╔══════╧══════╗
             ║  MANAGES    ║                        ║   CREATES   ║
             ╚══════╤══════╝                        ╚══════╤══════╝
                    │ N                                    │ N
                    │                                      │
                    └──────────────┬───────────────────────┘
                                   │
                                   ▼
                           ┌──────────────┐
                           │ BLOOD_REQUEST│
                           └──────┬───────┘
                                  │
                                  │ N
                           ╔══════╧══════╗
                           ║ FULFILLED BY║
                           ╚══════╤══════╝
                                  │ 1
                                  ▼
                    ┌──────────────────────────┐
                    │         DONATION         │
                    └──────────────────────────┘
                                  ▲
                                  │ N
                           ╔══════╧══════╗
                           ║   DONATES   ║
                           ╚══════╤══════╝
                                  │ 1
                                  │
                           ┌──────┴──────┐
                           │    USER     │
                           └─────────────┘


      ┌─────────────┐              ┌─────────────┐
      │    USER     │──────────────│    USER     │
      └──────┬──────┘      N   N   └──────┬──────┘
             │      ╔═════════════╗       │
             └──────╢  MESSAGES   ╟───────┘
                    ╚═════════════╝
```

---

## 📋 Entity Details

### 1️⃣ USERS Collection (Unified User Table)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USERS                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  Collection Path: /users/{userId}                                           │
│  Document ID: Firebase Auth UID                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┬───────────────┬──────────┬──────────────────────────┐ │
│  │    Field        │     Type      │ Required │      Description         │ │
│  ├─────────────────┼───────────────┼──────────┼──────────────────────────┤ │
│  │ 🔑 id           │ string        │    ✅    │ Primary Key (Auth UID)   │ │
│  │ email           │ string        │    ✅    │ Unique email address     │ │
│  │ name            │ string        │    ✅    │ Full name                │ │
│  │ bloodType       │ string (enum) │    ✅    │ A+,A-,B+,B-,O+,O-,AB+,AB-│ │
│  │ phone           │ string        │    ❌    │ Contact number           │ │
│  │ role            │ string (enum) │    ✅    │ superAdmin/orgAdmin/user │ │
│  │ age             │ number        │    ❌    │ Age in years             │ │
│  │ gender          │ string        │    ❌    │ male/female/other        │ │
│  │ address         │ string        │    ❌    │ Full address             │ │
│  │ district        │ string        │    ❌    │ District/Division        │ │
│  │ lastDonationDate│ timestamp     │    ❌    │ Last donation date       │ │
│  │ createdAt       │ timestamp     │    ✅    │ Account creation time    │ │
│  │ isActive        │ boolean       │    ❌    │ For admins only          │ │
│  │ organization    │ string        │    ❌    │ For orgAdmin only        │ │
│  │ 🔗 createdBy    │ string (FK)   │    ❌    │ → SuperAdmin (orgAdmin)  │ │
│  │ permissions     │ array<string> │    ❌    │ Admin permissions        │ │
│  └─────────────────┴───────────────┴──────────┴──────────────────────────┘ │
│                                                                             │
│  📌 Indexes: email (unique), role, bloodType, district                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2️⃣ BLOOD_REQUESTS Collection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           BLOOD_REQUESTS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  Collection Path: /bloodRequests/{requestId}                                │
│  Document ID: Auto-generated                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┬───────────────┬──────────┬─────────────────────────┐ │
│  │    Field         │     Type      │ Required │     Description         │ │
│  ├──────────────────┼───────────────┼──────────┼─────────────────────────┤ │
│  │ 🔑 id            │ string        │    ✅    │ Primary Key             │ │
│  │ bloodType        │ string (enum) │    ✅    │ Required blood type     │ │
│  │ patientName      │ string        │    ✅    │ Patient's name          │ │
│  │ hospitalName     │ string        │    ✅    │ Hospital name           │ │
│  │ location         │ string        │    ✅    │ Hospital location       │ │
│  │ contactPhone     │ string        │    ✅    │ Emergency contact       │ │
│  │ unitsNeeded      │ number        │    ✅    │ Blood units required    │ │
│  │ urgency          │ string (enum) │    ✅    │ normal/urgent/critical  │ │
│  │ status           │ string (enum) │    ✅    │ pending/approved/...    │ │
│  │ requestDate      │ timestamp     │    ✅    │ Request creation time   │ │
│  │ fulfilledDate    │ timestamp     │    ❌    │ When fulfilled          │ │
│  │ notes            │ string        │    ❌    │ Additional notes        │ │
│  │ 🔗 requestedBy   │ string (FK)   │    ✅    │ → USER.id               │ │
│  │ requestedByName  │ string        │    ✅    │ Denormalized name       │ │
│  │ 🔗 assignedAdminId│ string (FK)  │    ❌    │ → ORG_ADMIN.id          │ │
│  └──────────────────┴───────────────┴──────────┴─────────────────────────┘ │
│                                                                             │
│  📌 Indexes: status, bloodType, requestDate, assignedAdminId                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3️⃣ DONATIONS Collection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              DONATIONS                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  Collection Path: /donations/{donationId}                                   │
│  Document ID: Auto-generated                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌────────────────────────┬───────────────┬──────────┬───────────────────┐ │
│  │    Field               │     Type      │ Required │   Description     │ │
│  ├────────────────────────┼───────────────┼──────────┼───────────────────┤ │
│  │ 🔑 id                  │ string        │    ✅    │ Primary Key       │ │
│  │ 🔗 donorId             │ string (FK)   │    ✅    │ → USER.id         │ │
│  │ donorName              │ string        │    ✅    │ Denormalized      │ │
│  │ bloodType              │ string (enum) │    ✅    │ Donated type      │ │
│  │ donationDate           │ timestamp     │    ✅    │ Donation date     │ │
│  │ location               │ string        │    ✅    │ Donation place    │ │
│  │ status                 │ string (enum) │    ✅    │ scheduled/done/.. │ │
│  │ notes                  │ string        │    ❌    │ Additional notes  │ │
│  ├────────────────────────┴───────────────┴──────────┴───────────────────┤ │
│  │                    RECIPIENT INFO (Optional)                          │ │
│  ├────────────────────────┬───────────────┬──────────┬───────────────────┤ │
│  │ 🔗 recipientRequestId  │ string (FK)   │    ❌    │ → BLOOD_REQUEST.id│ │
│  │ recipientPatientName   │ string        │    ❌    │ Denormalized      │ │
│  │ recipientHospital      │ string        │    ❌    │ Denormalized      │ │
│  │ recipientBloodType     │ string        │    ❌    │ Denormalized      │ │
│  │ recipientContactPhone  │ string        │    ❌    │ Denormalized      │ │
│  └────────────────────────┴───────────────┴──────────┴───────────────────┘ │
│                                                                             │
│  📌 Indexes: donorId, donationDate, status                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4️⃣ DONATION_CENTERS Collection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DONATION_CENTERS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  Collection Path: /donationCenters/{centerId}                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────┬───────────────┬──────────┬───────────────────────┐│
│  │    Field            │     Type      │ Required │    Description        ││
│  ├─────────────────────┼───────────────┼──────────┼───────────────────────┤│
│  │ 🔑 id               │ string        │    ✅    │ Primary Key           ││
│  │ name                │ string        │    ✅    │ Center name           ││
│  │ address             │ string        │    ✅    │ Full address          ││
│  │ area                │ string        │    ✅    │ Area/Zone             ││
│  │ latitude            │ number        │    ✅    │ GPS latitude          ││
│  │ longitude           │ number        │    ✅    │ GPS longitude         ││
│  │ phone               │ string        │    ✅    │ Contact phone         ││
│  │ type                │ string (enum) │    ✅    │ hospital/blood_bank/..││
│  │ availableBloodTypes │ array<string> │    ✅    │ Available types       ││
│  │ isActive            │ boolean       │    ✅    │ Is active             ││
│  │ workingHours        │ map           │    ✅    │ Day → Hours           ││
│  │ createdAt           │ timestamp     │    ✅    │ Creation time         ││
│  └─────────────────────┴───────────────┴──────────┴───────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Relationship Summary Table

| Relationship | Type | From Entity | To Entity | Cardinality | Description |
|:------------:|:----:|:-----------:|:---------:|:-----------:|:------------|
| Creates Admin | 1:N | SuperAdmin | OrgAdmin | One-to-Many | Super Admin creates multiple Org Admins |
| Creates Request | 1:N | User | BloodRequest | One-to-Many | User can create multiple blood requests |
| Manages Request | 1:N | OrgAdmin | BloodRequest | One-to-Many | Admin manages assigned requests |
| Donates Blood | 1:N | User | Donation | One-to-Many | Donor can donate multiple times |
| Fulfills Request | N:1 | Donation | BloodRequest | Many-to-One | Donation can fulfill a request |
| Sends Message | 1:N | User | Message | One-to-Many | User sends multiple messages |
| Receives Message | 1:N | User | Message | One-to-Many | User receives multiple messages |
| Chat Participants | N:M | User | User | Many-to-Many | Users participate in chat rooms |

---

## 📊 Cardinality Notation

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        CARDINALITY LEGEND                                │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│    ──────│           One (mandatory)                                     │
│    ──────○           Zero or One (optional)                              │
│    ──────<           Many (mandatory)                                    │
│    ──────◇           Zero or Many (optional)                             │
│                                                                          │
│    ┌─────┐    1        N    ┌─────┐                                      │
│    │  A  │────────◆────────│  B  │   A has many B                        │
│    └─────┘                  └─────┘                                      │
│                                                                          │
│    ┌─────┐    N        M    ┌─────┐                                      │
│    │  A  │────◆────◆────────│  B  │   A and B have many-to-many          │
│    └─────┘                  └─────┘                                      │
│                                                                          │
│    PK = Primary Key                                                      │
│    FK = Foreign Key                                                      │
│    🔑 = Primary Key indicator                                            │
│    🔗 = Foreign Key indicator                                            │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Data Integrity Rules

### Business Rules

| Rule # | Entity | Rule Description | Enforcement |
|:------:|:------:|:-----------------|:-----------:|
| BR-01 | Donation | Donor must wait 120 days between donations | Application |
| BR-02 | Donation | Blood type must match donor's registered type | Application |
| BR-03 | BloodRequest | Status flow: pending → approved → fulfilled/cancelled | Application |
| BR-04 | Donation | Status flow: scheduled → completed/cancelled | Application |
| BR-05 | User | Email must be unique across all users | Firebase Auth |
| BR-06 | OrgAdmin | Can only manage assigned requests | Security Rules |

### Referential Integrity

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    FOREIGN KEY CONSTRAINTS                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  donations.donorId            ───────►  users.id          (REQUIRED)    │
│  donations.recipientRequestId ───────►  bloodRequests.id  (OPTIONAL)    │
│  bloodRequests.requestedBy    ───────►  users.id          (REQUIRED)    │
│  bloodRequests.assignedAdminId───────►  users.id          (OPTIONAL)    │
│  messages.senderId            ───────►  users.id          (REQUIRED)    │
│  messages.receiverId          ───────►  users.id          (REQUIRED)    │
│  auditLogs.uid                ───────►  users.id          (REQUIRED)    │
│  users.createdBy (orgAdmin)   ───────►  users.id          (OPTIONAL)    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🎨 Color Legend for Entities

| Color | Entity Type | Description |
|:-----:|:-----------:|:------------|
| 👑 Gold | Super Admin | System administrator |
| 🏢 Blue | Org Admin | Organization administrator |
| 👤 Green | User/Donor | Regular blood donors |
| 🆘 Red | Blood Request | Emergency blood requests |
| 💉 Purple | Donation | Blood donation records |
| 🏥 Teal | Donation Center | Blood banks & hospitals |
| 💬 Orange | Message | User communications |
| 📝 Gray | Audit Log | System logs |

---

## 📱 Firebase Collection Structure

```
firestore-root
│
├── 📁 users/
│   ├── 📄 {userId_1}
│   ├── 📄 {userId_2}
│   └── ...
│
├── 📁 bloodRequests/
│   ├── 📄 {requestId_1}
│   ├── 📄 {requestId_2}
│   └── ...
│
├── 📁 donations/
│   ├── 📄 {donationId_1}
│   ├── 📄 {donationId_2}
│   └── ...
│
├── 📁 donationCenters/
│   ├── 📄 {centerId_1}
│   └── ...
│
├── 📁 messages/
│   ├── 📄 {messageId_1}
│   └── ...
│
├── 📁 chatRooms/
│   ├── 📄 {roomId_1}
│   └── ...
│
├── 📁 auditLogs/
│   ├── 📄 {logId_1}
│   └── ...
│
└── 📁 settings/
    ├── 📄 {settingId_1}
    └── ...
```

---

## ✅ Summary

| Metric | Count |
|:------:|:-----:|
| **Total Entities** | 8 |
| **Core Entities** | 4 (Users, BloodRequests, Donations, DonationCenters) |
| **Supporting Entities** | 4 (Messages, ChatRooms, AuditLogs, Settings) |
| **1:N Relationships** | 6 |
| **N:1 Relationships** | 5 |
| **N:M Relationships** | 1 |
| **Foreign Keys** | 8 |

---

**Document Version**: 1.0  
**Created**: November 29, 2025  
**Database**: Firebase Cloud Firestore  
**Project**: Blood Donation Management System  
