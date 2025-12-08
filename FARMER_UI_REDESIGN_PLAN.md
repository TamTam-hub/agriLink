# Farmer UI Redesign Plan

## Overview
Redesign the Farmer UI based on Figma design screenshots to create a cleaner, more modern interface with improved user experience.

## Key Design Changes from Figma Screenshots

### 1. **Dashboard/Home Screen Changes**
Based on Screenshot 3 (Dashboard):

**Current Implementation:**
- Gradient header with "Welcome Back!" and farm name
- 4 stat cards in 2x2 grid layout
- Quick action cards
- Recent orders list with images
- Low stock alert banner

**New Figma Design:**
- Green rounded header card with "Dashboard" title and subtitle
- Cleaner stat cards with icons (dollar, shopping bag, box, trending up)
- Simplified layout with better spacing
- Product list integrated directly on home screen
- Removed quick action cards
- Removed low stock alert banner

**Changes Needed:**
- Replace gradient header with rounded green card
- Redesign stat cards to match Figma (simpler, cleaner)
- Add "My Products" section directly on home screen
- Show product cards with Edit/Delete buttons
- Remove quick actions section
- Remove low stock alert

### 2. **My Products Screen Changes**
Based on Screenshot 2 (My Products):

**Current Implementation:**
- Gradient header with search bar
- Category filter chips (horizontal scroll)
- Product count and sort/filter buttons
- List view with large product cards
- Edit/Delete buttons in column on right side
- Dialogs for add/edit/delete

**New Figma Design:**
- Simpler white background
- Stats cards at top (Active Listings, Growth)
- "My Products" heading with item count
- Cleaner product cards with:
  - Square product image on left
  - Product name, price, stock, sales info
  - Category badge
  - Organic badge (green pill)
  - Edit and Delete buttons below each card (not on side)
- No search bar visible
- No category filters visible

**Changes Needed:**
- Remove gradient header
- Add stats section at top (Active Listings, Growth)
- Redesign product cards to match Figma layout
- Move Edit/Delete buttons below product info (horizontal layout)
- Simplify overall design
- Remove search bar from main view
- Remove category filter chips

### 3. **Add Product Screen Changes**
Based on Screenshot 1 (Add New Product):

**Current Implementation:**
- Dialog-based add product form

**New Figma Design:**
- Full-screen form with back button
- Clean white background
- Image upload area with dashed border and upload icon
- Form fields:
  - Product Name (with placeholder "e.g., Fresh Tomatoes")
  - Category dropdown
  - Price and Unit (side by side)
  - Available Stock
  - Description (multiline)
  - Certified Organic toggle switch
- Green "List Product" button at bottom
- Bottom navigation bar visible

**Changes Needed:**
- Create new full-screen Add Product page
- Replace dialog with dedicated screen
- Add image upload component with dashed border
- Implement all form fields as shown
- Add Certified Organic toggle
- Add bottom navigation

### 4. **Bottom Navigation**
All screenshots show consistent bottom navigation:
- Home (house icon)
- Market (shopping bag icon)
- Add (plus icon in circle)
- Orders (receipt icon)
- Profile (person icon)

**Changes Needed:**
- Ensure bottom nav is consistent across all farmer screens
- Update icons to match Figma design
- Add proper navigation handling

## Implementation Plan

### Phase 1: Update Farmer Home Screen
**Files to modify:**
- `lib/screens/farmer/farmer_home_screen.dart`

**Changes:**
1. Replace gradient header with rounded green card
2. Update stat cards design (simpler, cleaner)
3. Add "My Products" section with product list
4. Remove quick actions section
5. Remove low stock alert
6. Integrate product cards with Edit/Delete buttons

### Phase 2: Update My Products Screen
**Files to modify:**
- `lib/screens/farmer/my_products_screen.dart`

**Changes:**
1. Remove gradient header
2. Add stats cards at top (Active Listings, Growth)
3. Redesign product cards layout
4. Move Edit/Delete buttons to horizontal layout below product
5. Remove search bar from main view
6. Remove category filter chips
7. Update FAB to navigate to new Add Product screen

### Phase 3: Create Add Product Screen
**Files to create:**
- `lib/screens/farmer/add_product_screen.dart`
- `lib/widgets/farmer/image_upload_widget.dart` (optional)

**Changes:**
1. Create full-screen Add Product form
2. Add back button in app bar
3. Implement image upload area with dashed border
4. Add all form fields as per Figma
5. Add Certified Organic toggle
6. Add "List Product" button
7. Implement form validation

### Phase 4: Update Bottom Navigation
**Files to modify:**
- `lib/widgets/common/bottom_nav_bar.dart`
- `lib/screens/farmer/farmer_main_screen.dart`

**Changes:**
1. Update icons to match Figma
2. Ensure consistent navigation across farmer screens
3. Add proper routing for Add button

### Phase 5: Update Colors and Styling
**Files to modify:**
- `lib/constants/colors.dart` (if needed)
- `lib/constants/text_styles.dart` (if needed)

**Changes:**
1. Ensure colors match Figma design
2. Update text styles if needed
3. Ensure consistent spacing

## Design Specifications from Figma

### Colors:
- Primary Green: #00A651 (existing)
- Background: White (#FFFFFF)
- Card Background: White with shadow
- Text Primary: Dark gray/black
- Text Secondary: Gray
- Organic Badge: Green (#00A651)
- Category Badge: Light gray background

### Typography:
- Headers: Bold, larger size
- Body text: Regular weight
- Captions: Smaller, gray color

### Spacing:
- Card padding: 16px
- Section spacing: 16-24px
- Button height: 48px

### Components:
- Rounded corners: 12-16px
- Shadows: Subtle, soft shadows
- Buttons: Full width or side-by-side
- Icons: Outlined style

## Testing Checklist
- [ ] Home screen displays correctly
- [ ] Stats cards show proper data
- [ ] Product list displays on home screen
- [ ] My Products screen shows stats
- [ ] Product cards layout matches Figma
- [ ] Edit/Delete buttons work properly
- [ ] Add Product screen opens correctly
- [ ] Image upload works
- [ ] Form validation works
- [ ] Certified Organic toggle works
- [ ] Bottom navigation works on all screens
- [ ] Navigation between screens works
- [ ] All buttons and interactions work

## Notes
- Keep existing functionality intact
- Maintain data models and sample data
- Focus on UI/UX improvements
- Ensure responsive design
- Test on different screen sizes
