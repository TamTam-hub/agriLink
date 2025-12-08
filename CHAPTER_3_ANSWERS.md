# Chapter 3 Methodology Answers

## 1. Tools and Technologies Used in AgriLink

### ✅ Frontend / App Framework
- **Flutter (Dart)** ✓
  - Cross-platform mobile framework for UI and business logic
  
- **Android Studio** ✓
  - IDE for Android build configuration and APK generation
  
- **Figma (UI prototyping)** - Optional
  - (Mark if used for design mockups)

### ✅ Backend Services
- **Supabase Auth** ✓
  - Primary authentication service
  - Email/password sign-in/sign-up with session persistence
  
- **Firebase Auth** ✓
  - Secondary authentication service (dual auth system)
  
- **Firestore Database** ✓
  - NoSQL database for users, products, and orders
  - Real-time data synchronization
  
- **Supabase Storage** ✓
  - Cloud storage for product images
  - Organized folder structure with signed URLs

### ✅ Other Tools
- **Visual Studio Code** ✓
  - Primary code editor
  
- **GitHub / GitLab** ✓
  - Version control system
  
- **Flutter Packages:**
  - `image_picker` - Image selection from camera/gallery
  - `flutter_local_notifications` - Push notifications
  - `cloud_firestore` - Firestore integration
  - `firebase_auth` - Firebase authentication
  - `supabase_flutter` - Supabase integration

---

## 2. Data Gathering

**Status:** No formal data gathering conducted

**Justification:**
- AgriLink is a prototype-based system developed to demonstrate a functional agricultural marketplace concept
- Requirements were derived from:
  * Literature review of existing agricultural e-commerce platforms
  * General understanding of farmer-buyer transaction flows
  * Standard e-commerce application patterns
  * Market research on agricultural marketplace needs
- The system is designed as a proof-of-concept for thesis purposes
- Future work will include pilot testing with actual farmers and buyers for validation

**Alternative (if you conducted data gathering):**
```
Type: Interviews/Surveys

Participants:
- X farmers from [location]
- Y potential buyers

Sample Size: [Total number]

Data Gathered:
- Farmers: Pain points in selling products, pricing needs, order management
- Buyers: Shopping preferences, trust factors, product information needs

Method: Semi-structured interviews + online surveys
```

---

## 3. Application Requirements

### Hardware Requirements
- **Smartphone with Android OS** (API level 21+, Android 5.0 Lollipop or higher)
- **Minimum 2GB RAM** (recommended: 4GB)
- **100MB+ free storage space**
- **Camera** (for product image uploads)
- **Internet connection** (Wi-Fi or mobile data)

### Software Requirements
- **Android OS version 5.0+** (Lollipop or higher)

### Backend Requirements
- **Supabase Account** with:
  - Authentication API enabled
  - Storage bucket configured (`product-images`)
  - Project URL and anon key
  
- **Firebase Project** with:
  - Firestore Database enabled
  - Firebase Authentication enabled
  - `google-services.json` file configured

### User Requirements
- **Valid email address** for registration
- **User account** (Farmer or Buyer role)
- **Phone number** (optional, for profile)
- **Location/address** (for order fulfillment)

### Developer Requirements (for deployment)
- **Flutter SDK** (version 3.x)
- **Android Studio** or **VS Code** with Flutter extensions
- **Supabase API keys** (URL and Anon Key)
- **Firebase configuration files** (`google-services.json`)

---

## 4. Version of App Completed

**Status:** ✅ **Fully Functional Prototype**

### What's Complete:
- ✓ Full authentication system (sign-up, login, auto-login, sign-out)
- ✓ Role-based navigation (Buyer vs Farmer)
- ✓ Product management (create, read, update, delete)
- ✓ Order placement and tracking system
- ✓ Real-time data synchronization via Firestore streams
- ✓ Image upload and storage functionality
- ✓ Responsive UI for various screen sizes
- ✓ APK build for Android deployment

### Limitations:
- ⚠ No payment integration (orders tracked but not processed)
- ⚠ No live push notifications (infrastructure exists)
- ⚠ Limited to Android platform (no iOS/Web deployment)
- ⚠ Not deployed to Google Play Store

### Testing Status:
- ✓ Development testing completed
- ✓ APK successfully built and tested
- ⚠ Not pilot-tested with real users
- ⚠ Not deployed in production environment

**Conclusion:** The application is a complete, working prototype with all core features implemented and tested in development environment. It is ready for pilot testing phase.

---

## 5. SDLC Model Used

### **Waterfall Model** ✓

The AgriLink development followed the traditional **Waterfall Model** with sequential phases:

#### **Phase 1: Requirements Analysis**
- Identified stakeholder needs (farmers and buyers)
- Defined functional requirements (authentication, product management, orders)
- Defined non-functional requirements (responsive UI, security, performance)
- Selected technology stack (Flutter, Firebase, Supabase)

#### **Phase 2: System Design**
- **Architectural Design:**
  - Designed system architecture (see ARCHITECTURE.md)
  - Defined three-tier architecture (UI, Services, Data layers)
  - Planned dual authentication system (Supabase + Firebase)
  
- **Database Design:**
  - Designed Firestore collections (users, products, orders)
  - Defined data schemas and relationships
  - Planned storage structure for product images
  
- **UI/UX Design:**
  - Created wireframes for buyer and farmer interfaces
  - Designed navigation flows (bottom nav bars, routing)
  - Planned responsive layout system

#### **Phase 3: Implementation (Development)**
- **Week 1-2:** Authentication system development
  - Implemented Supabase and Firebase Auth integration
  - Created login, signup, and splash screens
  - Built session persistence mechanism

- **Week 3-4:** Core features development
  - Developed product management screens (add, edit, delete)
  - Implemented marketplace and product browsing
  - Created order placement and tracking system

- **Week 5-6:** User interface refinement
  - Built buyer and farmer main screens with navigation
  - Implemented responsive design utilities
  - Added image upload functionality

- **Week 7:** Integration and polish
  - Connected all services (Auth, Firestore, Storage)
  - Implemented real-time data streams
  - Fixed responsive layout issues

#### **Phase 4: Testing**
- **Unit Testing:** Tested individual components and services
- **Integration Testing:** Verified data flow between UI, services, and database
- **System Testing:** End-to-end testing of user flows
- **APK Testing:** Built and tested Android release APK
- **Bug Fixes:** Resolved navigation issues, overflow problems, session persistence bugs

#### **Phase 5: Deployment**
- Generated release APK for Android
- Documented installation requirements
- Prepared for pilot testing phase
- Created architecture documentation

### **Justification for Waterfall Model:**

1. **Clear Requirements:** All features were defined upfront based on marketplace needs
2. **Sequential Development:** Each phase completed before moving to next
3. **Academic Context:** Waterfall suits thesis timeline with defined milestones
4. **Documentation:** Each phase produced deliverables (design docs, code, test reports)
5. **Single Delivery:** Prototype delivered as complete system at end of development

### **Waterfall Advantages in This Project:**
- ✓ Clear project milestones for thesis documentation
- ✓ Comprehensive design before implementation
- ✓ Structured approach suitable for academic research
- ✓ Well-documented phases for thesis Chapter 3

### **Waterfall Limitations Encountered:**
- ⚠ Limited flexibility for requirement changes mid-development
- ⚠ Late discovery of UI responsiveness issues (fixed in testing phase)
- ⚠ Navigation bug found post-deployment (required rebuild)

---

## Chapter 3 Structure Using Waterfall Model

### 3.1 Requirements Analysis Phase
- Project objectives and scope
- Stakeholder identification (farmers, buyers)
- Functional requirements (features list)
- Non-functional requirements (performance, security, usability)
- Technology selection and justification

### 3.2 System Design Phase
- System architecture design (3-tier architecture)
- Database schema design (Firestore collections)
- UI/UX design (screen wireframes, navigation flows)
- Component design (services, widgets, utilities)
- Security design (authentication, authorization)

### 3.3 Implementation Phase
- Development environment setup
- Authentication system implementation
- Product management features development
- Order system implementation
- UI/UX implementation with responsive design
- Service layer integration

### 3.4 Testing Phase
- Test plan and test cases
- Unit testing results
- Integration testing results
- System testing and bug tracking
- APK build and deployment testing
- Bug fixes and optimization

### 3.5 Deployment Phase
- APK generation and configuration
- Installation requirements documentation
- User manual creation
- System documentation
- Preparation for pilot testing

---

## Summary

- **Tools:** Flutter, Android Studio, Supabase, Firebase, Firestore, VS Code
- **Data Gathering:** Prototype-based (no formal user research)
- **Requirements:** Android smartphone, internet, Firebase/Supabase setup, user account
- **Version:** Fully functional prototype (not pilot-tested)
- **SDLC:** **Waterfall Model** with 5 sequential phases

This methodology ensures systematic development with clear documentation at each phase, suitable for academic thesis requirements.
