# Farmer UI Update Plan - Revised

## Overview
Update the Farmer UI based on Figma design with focus on:
1. Adding 5-item bottom navigation (Home, Market, Add, Orders, Profile)
2. Updating product cards and layouts to match Figma
3. Creating Add Product screen
4. Keeping existing headers intact

## Changes Summary

### 1. Bottom Navigation Update
**Current:** 4 items (Home, Products, Orders, Profile)
**New:** 5 items (Home, Market, Add, Orders, Profile)

**Changes:**
- Add "Market" tab (index 1) - for browsing/marketplace view
- Add "Add" tab (index 2) - for adding new products (center button with special styling)
- Rename "Products" to show in Market or keep as separate
- Update farmer_main_screen.dart to handle 5 screens
- Update bottom_nav_bar.dart to show 5 items with center "Add" button

### 2. My Products Screen Layout
**Changes based on Figma Screenshot 2:**
- Add stats cards at top (Active Listings: 3, Growth: +12%)
- Update product card layout:
  - Square image on left (80x80 or 100x100)
  - Product info on right (name, price, stock, sales, category)
  - Organic badge (green pill)
  - Edit and Delete buttons below in horizontal row
- Remove search bar from main view
- Remove category filter chips
- Keep "My Products" heading with item count

### 3. Add Product Screen (New)
**Create new full-screen form based on Figma Screenshot 1:**
- Back button in app bar
- Title: "Add New Product"
- Image upload area with dashed border and upload icon
- Form fields:
  - Product Name (text field with hint "e.g., Fresh Tomatoes")
  - Category (dropdown)
  - Price ($) and Unit (kg) side by side
  - Available Stock (number field)
  - Description (multiline text field)
  - Certified Organic (toggle switch)
- Green "List Product" button at bottom
- Show bottom navigation

### 4. Dashboard/Home Screen
**Changes based on Figma Screenshot 3:**
- Keep existing header (as per your request)
- Update stat cards to simpler design
- Add "My Products" section showing product list
- Show 2-3 products with Edit/Delete buttons
- Remove quick actions section
- Remove low stock alert

## Implementation Steps

### Step 1: Create Add Product Screen
**File:** `lib/screens/farmer/add_product_screen.dart`

Components needed:
- Image upload widget with dashed border
- Form fields with validation
- Certified Organic toggle
- Submit button

### Step 2: Update Bottom Navigation
**Files to modify:**
- `lib/widgets/common/bottom_nav_bar.dart`
- `lib/screens/farmer/farmer_main_screen.dart`

Changes:
- Add 5th item (Add button in center)
- Style center button differently (circular, elevated)
- Update navigation logic for 5 screens
- Add Market screen or reuse existing marketplace

### Step 3: Update My Products Screen
**File:** `lib/screens/farmer/my_products_screen.dart`

Changes:
- Add stats cards at top
- Redesign product cards
- Move Edit/Delete buttons below
- Update layout and spacing

### Step 4: Update Home Screen
**File:** `lib/screens/farmer/farmer_home_screen.dart`

Changes:
- Keep header as is
- Update stat cards design
- Add "My Products" section
- Remove quick actions
- Remove low stock alert

### Step 5: Create/Update Market Screen
**File:** `lib/screens/farmer/farmer_market_screen.dart` (new or reuse existing)

Options:
- Create new marketplace view for farmers
- Or reuse existing marketplace screen
- Show all products from all farmers

## File Structure
```
lib/
├── screens/
│   └── farmer/
│       ├── farmer_main_screen.dart (UPDATE - 5 screens)
│       ├── farmer_home_screen.dart (UPDATE - simplified)
│       ├── farmer_market_screen.dart (NEW or reuse)
│       ├── add_product_screen.dart (NEW)
│       ├── my_products_screen.dart (UPDATE - new layout)
│       ├── farmer_orders_screen.dart (keep as is)
│       └── farmer_profile_screen.dart (keep as is)
├── widgets/
│   ├── common/
│   │   └── bottom_nav_bar.dart (UPDATE - 5 items)
│   └── farmer/
│       └── image_upload_widget.dart (NEW - optional)
```

## Design Specifications

### Bottom Navigation:
- 5 items: Home, Market, Add, Orders, Profile
- Center "Add" button: Circular, elevated, green background
- Icons: outlined when inactive, filled when active
- Labels below icons

### Product Cards (My Products):
- White background with shadow
- Square image (100x100)
- Product name (bold)
- Price with unit
- Stock and Sales info
- Category badge (gray background)
- Organic badge (green pill)
- Edit button (outlined, with icon)
- Delete button (outlined, red, with icon)

### Add Product Form:
- White background
- Dashed border for image upload
- Standard text fields
- Dropdown for category
- Toggle switch for organic
- Full-width green button

### Stats Cards:
- White background with shadow
- Icon at top
- Large number
- Label below
- Rounded corners

## Testing Checklist
- [ ] Bottom navigation shows 5 items
- [ ] Center Add button is styled correctly
- [ ] Navigation between all 5 screens works
- [ ] Add Product screen opens from center button
- [ ] Image upload works
- [ ] Form validation works
- [ ] Product cards display correctly
- [ ] Edit/Delete buttons work
- [ ] Stats cards show on My Products screen
- [ ] Home screen shows products section
- [ ] All existing functionality still works
