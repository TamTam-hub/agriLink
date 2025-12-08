# Farmer UI Implementation Plan

## Overview
Create a distinct UI for Farmers that focuses on product management, order fulfillment, and sales analytics.

## Key Differences: Buyer vs Farmer

### Buyer UI (Current)
- Browse products from all farmers
- Search and filter marketplace
- Place orders
- Track purchases
- View all available products

### Farmer UI (New)
- Dashboard with sales analytics
- Manage own products (CRUD operations)
- View and fulfill incoming orders
- Inventory management
- Farm profile management

## Farmer Screens to Implement

### 1. Farmer Home Screen
**Purpose**: Dashboard overview
**Features**:
- Sales statistics cards (Today's Sales, Total Revenue, Active Orders)
- Recent orders list
- Quick actions (Add Product, View Orders)
- Inventory alerts (low stock items)
- Sales chart/graph
- Performance metrics

### 2. My Products Screen
**Purpose**: Product inventory management
**Features**:
- List/Grid of farmer's products
- Add new product button (FAB)
- Edit product details
- Delete product option
- Stock management
- Product status (Active/Inactive)
- Search own products
- Category filter

### 3. Orders Screen (Farmer View)
**Purpose**: Manage incoming orders
**Features**:
- Tabs: New, In Progress, Completed, Cancelled
- Order cards with buyer info
- Accept/Reject buttons for new orders
- Mark as fulfilled option
- Order details (buyer, quantity, price, delivery)
- Order timeline/status
- Contact buyer option

### 4. Profile Screen (Farmer View)
**Purpose**: Farm and farmer profile
**Features**:
- Farm information (name, location, description)
- Farmer details
- Farm photos/gallery
- Certifications (Organic, etc.)
- Business hours
- Contact preferences
- Demo mode toggle (switch to Buyer view)
- Settings and sign out

## Implementation Strategy

1. Create farmer-specific screens in `lib/screens/farmer/`
2. Update MainScreen to show different screens based on user role
3. Add role management in app state
4. Create farmer-specific widgets
5. Update sample data with farmer products
6. Implement role-based navigation

## Color Scheme
- Keep primary green (#00A651) for consistency
- Use different accent colors for farmer-specific actions:
  - Blue for analytics/stats
  - Orange for pending actions
  - Green for completed/success
