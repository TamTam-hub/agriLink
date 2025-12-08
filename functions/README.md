# Cloud Functions for AgriLink (FCM Push)

This folder contains Firebase Cloud Functions (Node.js 18) that send FCM push notifications when:
- An order is created: notifies the farmer (uses `farmerId` on the order).
- An order is updated: notifies the buyer if `status` changes.

Tokens are read from Firestore at `deviceTokens/{userId}`. The Flutter app already writes a single `token` string to this doc. If you later store multiple tokens, add a `tokens: string[]` array; the function supports both.

## Prerequisites
- Node.js 18
- Firebase CLI

```powershell
npm install -g firebase-tools
firebase login
```

## Project setup
The project ID is set to `agrilink-app-c137b` via `.firebaserc`.
If you need to switch:

```powershell
firebase use agrilink-app-c137b
```

## Install dependencies

If this is the first install (no `package-lock.json` yet), run:

```powershell
cd functions
npm install
```

After a lockfile exists, you can use the faster clean install:

```powershell
npm ci
```

## Deploy

```powershell
firebase deploy --only functions
```

Note: Deploying Cloud Functions requires upgrading your Firebase project to the Blaze plan because Google Cloud Build and Artifact Registry are used during deployment. If you prefer to avoid Blaze, consider using Supabase Edge Functions or another server to call the FCM HTTP API.

## Triggers
- `onOrderCreatedSendFarmerPush`: Firestore `orders/{orderId}` on create → sends push to `farmerId`.
- `onOrderUpdatedSendBuyerPush`: Firestore `orders/{orderId}` on update (status changed) → sends push to `buyerId`.

## Customization
- Notification texts in `index.js` can be adjusted.
- To prune invalid tokens automatically, migrate `deviceTokens/{uid}` to store `tokens[]` arrays and add a write-back after `sendEachForMulticast`.
