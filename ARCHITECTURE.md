# AgriLink Application Architecture

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     AGRILINK MOBILE APP                         │
│                    (Flutter - Cross Platform)                   │
└─────────────────────────────────────────────────────────────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
        │ USER INPUT   │ │   USER AUTH  │ │ INTERACTION │
        │  (UI/UX)     │ │  & ROUTING   │ │   (GESTURE) │
        └──────────────┘ └──────────────┘ └──────────────┘
                │              │              │
                └──────────────┼──────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  SPLASH SCREEN      │
                    │  Session Check      │
                    │  Role Detection     │
                    └──────────┬──────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
         No Session     Session Found    Login Screen
                │              │              │
                ▼              ▼              ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
        │ ROLE SELECT  │ │BUYER/FARMER  │ │ SUPABASE     │
        │ (Buyer/Frmr) │ │ AUTO-LOGIN   │ │ SIGN-IN/UP   │
        └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
               │                │                │
               └────────────────┼────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │ AUTHENTICATION LAYER  │
                    │                       │
                    │ ┌─────────────────┐   │
                    │ │ Supabase Auth   │   │
                    │ ├─────────────────┤   │
                    │ │ Firebase Auth   │   │
                    │ └─────────────────┘   │
                    └───────────┬───────────┘
                                │
                    ┌───────────▼───────────┐
                    │   DATA PERSISTENCE    │
                    │                       │
                    │ ┌─────────────────┐   │
                    │ │   Firestore     │   │
                    │ │ (Products,      │   │
                    │ │  Orders, Users) │   │
                    │ ├─────────────────┤   │
                    │ │ Supabase Storage│   │
                    │ │ (Product Images)│   │
                    │ └─────────────────┘   │
                    └───────────┬───────────┘
                                │
                ┌───────────────┼───────────────┐
                │               │               │
                ▼               ▼               ▼
         ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
         │ BUYER SCREEN │ │ FARMER SCREEN│ │  SERVICES   │
         │   (Main)     │ │   (Main)     │ │  LAYER      │
         └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
                │                │                │
         ┌──────▼──────┐  ┌──────▼──────┐ ┌──────▼───────┐
         │ • Home       │  │ • Home      │ │ • Firestore │
         │ • Marketplace│  │ • My Prod.  │ │   Service   │
         │ • Orders     │  │ • Add Prod. │ ├─────────────┤
         │ • Profile    │  │ • Orders    │ │ • Auth      │
         └──────────────┘  │ • Profile   │ │   Services  │
                           └─────────────┘ ├─────────────┤
                                          │ • Storage   │
                                          │   Services  │
                                          └─────────────┘
                                                │
                                    ┌───────────▼────────────┐
                                    │   UI COMPONENT LAYER   │
                                    │                        │
                                    │ ┌────────────────────┐ │
                                    │ │ Bottom Navigation  │ │
                                    │ ├────────────────────┤ │
                                    │ │ Product Cards      │ │
                                    │ ├────────────────────┤ │
                                    │ │ Status Badges      │ │
                                    │ ├────────────────────┤ │
                                    │ │ Custom Buttons     │ │
                                    │ ├────────────────────┤ │
                                    │ │ Dialogs/Modals     │ │
                                    │ └────────────────────┘ │
                                    └────────────────────────┘
                                                │
                                    ┌───────────▼────────────┐
                                    │  RESPONSIVE UTILITIES  │
                                    │                        │
                                    │ • Screen Adaptation    │
                                    │ • Text Scaling (Clamp) │
                                    │ • Layout Flexibility   │
                                    └────────────────────────┘
```

---

## Detailed Component Breakdown

### 1. **Entry Point (main.dart)**
   - Initializes Firebase & Supabase
   - Sets up app-wide responsive text scaling
   - Routes to SplashScreen
   - Defines named routes for buyer/farmer home screens

### 2. **Authentication Flow (Splash Screen)**
```
Splash Screen
    │
    ├─► Check Supabase Session
    │   ├─► User Found → Fetch Firestore Profile
    │   │   ├─► isBuyer = true → Route to MainScreen (Buyer)
    │   │   └─► isBuyer = false → Route to FarmerMainScreen
    │   │
    │   └─► No User → Check Firebase Auth
    │       └─► Same logic as Supabase
    │
    └─► No Session → Show Role Selection
        ├─► Select Buyer → Go to Login
        └─► Select Farmer → Go to Login
```

### 3. **User Authentication (Login/Signup)**
   - **Supabase Auth Service**: Email/password sign-in and sign-up
   - **Firebase Firestore**: User profile storage (name, email, role)
   - **Auto-provisioning**: New users get auto-created Firestore profile
   - **Session Persistence**: Tokens stored in Supabase local cache

### 4. **Buyer Flow (MainScreen with 4 Tabs)**
```
MainScreen (Tabbed Navigation)
├─► Tab 1: Home (BuyerHomeScreen)
│   ├─ Welcome message with user name
│   ├─ Product listing by category
│   └─ Search functionality
│
├─► Tab 2: Marketplace (MarketplaceScreen)
│   ├─ Browse all products
│   └─ Filter & sort options
│
├─► Tab 3: Orders (OrdersScreen)
│   ├─ View placed orders
│   ├─ Track order status (pending, confirmed, delivered, cancelled)
│   └─ Order history
│
└─► Tab 4: Profile (ProfileScreen)
    ├─ User info (name, email, phone, location)
    ├─ Edit profile
    ├─ Preferences
    ├─ Help & Support
    └─ Sign Out (clears Supabase & Firebase sessions)
```

### 5. **Farmer Flow (FarmerMainScreen with 5 Tabs)**
```
FarmerMainScreen (Tabbed Navigation + Center FAB)
├─► Tab 1: Home (FarmerHomeScreen)
│   ├─ Today's Sales Stats
│   ├─ New Orders Count
│   ├─ Monthly Sales
│   ├─ Product Count
│   ├─ Recent Orders Preview
│   └─ My Products Preview (3 latest)
│
├─► Tab 2: Marketplace (MarketplaceScreen)
│   └─ Browse buyer marketplace
│
├─► Tab 3: FAB (Center Add Button)
│   └─► AddProductScreen
│       ├─ Product name, price, stock
│       ├─ Category selection
│       ├─ Unit selection (kg, g, lb, piece, dozen, L)
│       ├─ Image upload (camera/gallery)
│       ├─ Certified Organic toggle
│       └─ Submit to Firestore
│
├─► Tab 4: Orders (FarmerOrdersScreen)
│   ├─ Tab Filtering: New | In Progress | Completed | Cancelled
│   ├─ Order cards with buyer info
│   ├─ Status management (accept/reject orders)
│   └─ Auto-accept orders option
│
└─► Tab 5: Profile (FarmerProfileScreen)
    ├─ User info
    ├─ Stats (active products, total orders, revenue)
    ├─ Edit profile
    ├─ Preferences
    ├─ Help & Support
    └─ Sign Out
```

### 6. **Data Layer (Firestore Collections)**
```
Firestore
├─► users/
│   ├─ uid (Supabase auth ID)
│   ├─ name
│   ├─ email
│   ├─ isBuyer (boolean: true=Buyer, false=Farmer)
│   ├─ phone
│   ├─ location
│   └─ createdAt, lastLoginAt
│
├─► products/
│   ├─ id (auto-generated)
│   ├─ farmerId (owner's Supabase UID)
│   ├─ name
│   ├─ price
│   ├─ priceUnit (/kg, /g, /piece, etc.)
│   ├─ stockAmount
│   ├─ category
│   ├─ description
│   ├─ imageUrl (Supabase storage URL)
│   ├─ imagePath (Supabase storage path)
│   ├─ isOrganic
│   └─ createdAt
│
└─► orders/
    ├─ id (auto-generated)
    ├─ buyerId (Supabase UID)
    ├─ farmerId (Supabase UID)
    ├─ productId
    ├─ productName
    ├─ quantity
    ├─ price
    ├─ imageUrl
    ├─ status (pending, confirmed, delivered, cancelled)
    ├─ orderDate
    └─ notes
```

### 7. **Storage Layer (Supabase Storage)**
```
Supabase Storage
├─► /product-images/
│   ├─ {farmerId}/{productId}/{filename}
│   └─ Images stored securely with signed URLs
│
└─► Fallback: Firebase Storage URLs
    └─ For legacy/migrated images
```

### 8. **Services Layer**
```
Services
├─► FirebaseFirestoreService
│   ├─ getUserProfile(uid)
│   ├─ saveUserData(userModel)
│   ├─ productsByFarmerStream(farmerId)
│   ├─ ordersByFarmerStream(farmerId)
│   ├─ ordersByBuyerStream(buyerId)
│   ├─ updateOrderStatus()
│   └─ saveOrder()
│
├─► SupabaseAuthService
│   ├─ signInWithEmailAndPassword()
│   ├─ signUpWithEmailAndPassword()
│   ├─ signOut()
│   └─ currentUser
│
└─► SupabaseStorageService
    ├─ uploadProductImage()
    ├─ deleteProductImageByPath()
    └─ deleteProductImageByPublicUrl()
```

### 9. **UI/UX Layer**
```
Responsive Design
├─► Responsive Utility (responsive.dart)
│   ├─ Responsive.init(context) - init screen metrics
│   ├─ Responsive.sp() - scaled font size (clamped)
│   └─ LayoutBuilder for adaptive layouts
│
├─► Widgets
│   ├─ CustomBottomNavBar (buyer: 4 items | farmer: 4 items + center FAB)
│   ├─ ProductCard (responsive image/text sizing)
│   ├─ StatusBadge (order status display)
│   ├─ Custom buttons, text fields, dialogs
│   └─ Dynamic stat cards (scales on small screens)
│
└─► Text Scaling
    ├─ Global MediaQuery text scale clamp (0.9-1.2x)
    ├─ Per-component font size adjustments
    └─ MaxLines + Ellipsis for overflow prevention
```

### 10. **Session & Navigation Flow**
```
Login/Auto-Login
    │
    ├─► Supabase Auth Token Stored Locally
    │   └─ Persists across app restarts
    │
    ├─► Firestore Profile Cached
    │   └─ Used to determine role (buyer vs farmer)
    │
    ├─► Route to MainScreen (buyer)
    │   └─ BottomNavBar with 4 tabs
    │
    └─► Route to FarmerMainScreen (farmer)
        └─ BottomNavBar with 4 tabs + center FAB
        
Sign Out
    │
    ├─► Clear Supabase Auth Session
    ├─► Clear Firebase Auth Session
    └─► Redirect to SplashScreen → Role Selection
```

---

## Key Features by Component

### **Buyer Features**
- Browse products by category
- Search products
- Place orders (creates order in Firestore)
- Track order status in real-time (streams)
- View order history
- Manage profile & preferences

### **Farmer Features**
- Add/edit/delete products
- Manage product images (upload, delete)
- View all incoming orders
- Filter orders by status (New, In Progress, Completed, Cancelled)
- Accept/reject orders with auto-accept option
- Track sales & revenue
- Manage profile & preferences

### **Cross-User Features**
- Persistent session (auto-login on app restart)
- Responsive UI (all screen sizes)
- Real-time data updates (Firestore streams)
- Image management (upload/delete)
- Proper error handling & user feedback

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Dart) |
| **Authentication** | Supabase Auth + Firebase Auth |
| **Database** | Firestore (NoSQL) |
| **Storage** | Supabase Storage + Firebase Storage |
| **State Management** | StatefulWidget + StreamBuilder |
| **Navigation** | MaterialPageRoute + Named Routes |
| **Image Handling** | image_picker, Image.network |
| **Notifications** | flutter_local_notifications |

---

## Data Flow Example: Order Placement

```
User taps "Buy" on ProductCard
    │
    ▼
Place Order Dialog Confirmation
    │
    ▼
_firestoreService.saveOrder(orderModel)
    │
    ▼
Firestore: orders/ collection
    ├─► Document created with orderData
    │
    ▼
Real-time Streams Updated
    ├─► Buyer: OrdersScreen refreshes
    ├─► Farmer: FarmerOrdersScreen refreshes
    │
    ▼
Notifications (optional)
    ├─► Buyer: "Order placed successfully"
    └─► Farmer: "New order received"
```

---

## Data Flow Example: Persistent Login

```
App Launched
    │
    ▼
SplashScreen._checkExistingSession()
    │
    ├─► Supabase.instance.client.auth.currentUser
    │   │
    │   ├─► User found?
    │   │   ├─► YES: Fetch Firestore profile
    │   │   │    ├─► isBuyer=true → Route to MainScreen
    │   │   │    └─► isBuyer=false → Route to FarmerMainScreen
    │   │   │
    │   │   └─► NO: Check Firebase Auth
    │   │       └─► Same logic
    │   │
    │   └─► No user? Show role selection UI
    │
    └─► After 5 seconds, navigate to home or role screen
```

---

## Error Handling & Edge Cases

1. **Auth Errors**: Session expired → Auto sign-out, show login screen
2. **Network Errors**: Firestore query fails → Show cached data or error message
3. **Image Upload Errors**: Image too large → Show user feedback
4. **Overflow Prevention**: Responsive text scaling + ellipsis + wrapping
5. **Hot Reload**: Const constructors prevent widget state loss

---

This architecture ensures:
- ✅ Scalability (separation of concerns)
- ✅ Maintainability (clear layer structure)
- ✅ Performance (efficient streams & caching)
- ✅ Security (Supabase + Firebase authentication)
- ✅ User Experience (responsive, persistent sessions)
