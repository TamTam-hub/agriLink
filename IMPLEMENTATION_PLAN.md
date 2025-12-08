# AgriLink Flutter App - Implementation Plan

## Project Overview
Building a farmer-to-market application that connects farmers with local buyers for fair trade and sustainable agriculture.

## Information Gathered from Figma Designs

### Screens Identified:
1. **Splash/Welcome Screen** - App branding with role selection
2. **Login Screen** - Authentication with features showcase
3. **Home Screen** - Dashboard with statistics and product categories
4. **Marketplace Screen** - Product browsing with filters
5. **Orders Screen** - Order tracking and history
6. **Profile Screen** - User settings and account management

### Design System:
- **Primary Color**: Green (#00A651)
- **Secondary Colors**: White, Light Gray (#F5F5F5)
- **Accent Colors**: Blue (Confirmed), Yellow (Pending), Red (Sign Out)
- **Typography**: Sans-serif (likely Poppins or Inter)
- **Border Radius**: 12-16px for cards
- **Spacing**: Consistent 16px padding

### Key Components:
1. Bottom Navigation Bar (Home, Market, Orders, Profile)
2. Product Cards with images, prices, locations, stock info
3. Status Badges (Organic, Confirmed, Delivered, Pending)
4. Search Bars with icons
5. Category Pills/Chips
6. Statistics Cards
7. Order Cards with product info
8. Profile Cards with user details
9. Settings Menu Items with icons

## Implementation Plan

### Phase 1: Project Setup & Structure
- [ ] Create folder structure (screens, widgets, models, services, utils, constants)
- [ ] Set up theme configuration with color scheme
- [ ] Add required dependencies (google_fonts, etc.)
- [ ] Create constants file for colors, text styles, spacing

### Phase 2: Core UI Components (Reusable Widgets)
- [ ] `custom_button.dart` - Reusable button widget
- [ ] `product_card.dart` - Product display card
- [ ] `order_card.dart` - Order history card
- [ ] `status_badge.dart` - Status indicator badges
- [ ] `category_chip.dart` - Category selection chips
- [ ] `stat_card.dart` - Statistics display card
- [ ] `custom_text_field.dart` - Input fields
- [ ] `bottom_nav_bar.dart` - Bottom navigation

### Phase 3: Screen Implementation

#### 3.1 Authentication Screens
- [ ] `splash_screen.dart` - Welcome screen with role toggle
- [ ] `login_screen.dart` - Login form with features section
- [ ] `signup_screen.dart` - Registration form (if needed)

#### 3.2 Main App Screens
- [ ] `home_screen.dart` - Dashboard with stats and categories
- [ ] `marketplace_screen.dart` - Product browsing with filters
- [ ] `orders_screen.dart` - Order tracking with tabs
- [ ] `profile_screen.dart` - User profile and settings

#### 3.3 Additional Screens
- [ ] `product_detail_screen.dart` - Individual product view
- [ ] `edit_profile_screen.dart` - Profile editing
- [ ] `notifications_screen.dart` - Notifications list
- [ ] `preferences_screen.dart` - App preferences
- [ ] `help_support_screen.dart` - Help and support

### Phase 4: Data Models
- [ ] `user_model.dart` - User data structure
- [ ] `product_model.dart` - Product data structure
- [ ] `order_model.dart` - Order data structure
- [ ] `category_model.dart` - Category data structure

### Phase 5: Navigation & State Management
- [ ] Set up navigation routes
- [ ] Implement bottom navigation logic
- [ ] Add state management (Provider/Riverpod/Bloc)

### Phase 6: Sample Data & Testing
- [ ] Create mock data for products
- [ ] Create mock data for orders
- [ ] Test all screens with sample data
- [ ] Verify responsive design

## File Structure
```
lib/
├── main.dart
├── constants/
│   ├── colors.dart
│   ├── text_styles.dart
│   └── spacing.dart
├── models/
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── order_model.dart
│   └── category_model.dart
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── marketplace/
│   │   ├── marketplace_screen.dart
│   │   └── product_detail_screen.dart
│   ├── orders/
│   │   └── orders_screen.dart
│   └── profile/
│       ├── profile_screen.dart
│       └── edit_profile_screen.dart
├── widgets/
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── bottom_nav_bar.dart
│   ├── product/
│   │   ├── product_card.dart
│   │   └── category_chip.dart
│   ├── order/
│   │   └── order_card.dart
│   └── profile/
│       └── stat_card.dart
└── utils/
    └── sample_data.dart
```

## Dependencies to Add
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  intl: ^0.19.0
```

## Next Steps
1. Confirm this plan with user
2. Create folder structure and constants
3. Implement reusable widgets
4. Build screens one by one
5. Add navigation and test
