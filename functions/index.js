// Cloud Functions (Node 18) for FCM push notifications
// Triggers on Firestore order create/update and sends push notifications.

const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');

// Set default region and concurrency
setGlobalOptions({ region: 'us-central1', maxInstances: 10 });

initializeApp();
const db = getFirestore();

async function getUserTokens(uid) {
  const snap = await db.collection('deviceTokens').doc(uid).get();
  if (!snap.exists) return [];
  const data = snap.data() || {};
  let tokens = [];
  if (Array.isArray(data.tokens)) tokens = tokens.concat(data.tokens.filter(Boolean));
  if (typeof data.token === 'string' && data.token) tokens.push(data.token);
  // Unique, truthy
  return [...new Set(tokens.filter(Boolean))];
}

async function sendMulticast(tokens, payload) {
  if (!tokens || tokens.length === 0) return { successCount: 0, failureCount: 0 };
  const message = {
    notification: payload.notification,
    data: payload.data || {},
    tokens,
    android: {
      priority: 'high',
      notification: { channelId: 'default_channel' },
    },
    apns: { payload: { aps: { sound: 'default' } } },
  };
  const resp = await getMessaging().sendEachForMulticast(message);
  // Optional: prune invalid tokens
  const invalidTokens = [];
  resp.responses.forEach((r, idx) => {
    if (!r.success) {
      const code = r.error && r.error.code ? r.error.code : '';
      if (code.includes('registration-token-not-registered') || code.includes('invalid-argument')) {
        invalidTokens.push(tokens[idx]);
      }
    }
  });
  if (invalidTokens.length) {
    // If you want to prune, store arrays in Firestore; this sample only supports single token doc
    // and won't mutate Firestore automatically.
    console.log('Invalid tokens detected:', invalidTokens.length);
  }
  return { successCount: resp.successCount, failureCount: resp.failureCount };
}

exports.onOrderCreatedSendFarmerPush = onDocumentCreated('orders/{orderId}', async (event) => {
  const data = event.data && event.data.data ? event.data.data() : null;
  if (!data) return;
  const farmerId = data.farmerId;
  if (!farmerId) return;

  const tokens = await getUserTokens(farmerId);
  if (tokens.length === 0) {
    console.log(`No tokens for farmerId=${farmerId}`);
    return;
  }

  const productName = data.productName || 'New order';
  const qty = data.quantity || '';

  await sendMulticast(tokens, {
    notification: {
      title: `New Order: ${productName}`,
      body: qty ? `${qty} x ${productName}` : productName,
    },
    data: {
      type: 'order_created',
      orderId: data.id || event.params.orderId,
      farmerId: farmerId,
      buyerId: data.buyerId || '',
      productId: data.productId || '',
      status: data.status || 'pending',
    },
  });
});

exports.onOrderUpdatedSendBuyerPush = onDocumentUpdated('orders/{orderId}', async (event) => {
  const before = event.data && event.data.before ? event.data.before.data() : null;
  const after = event.data && event.data.after ? event.data.after.data() : null;
  if (!before || !after) return;

  const beforeStatus = before.status;
  const afterStatus = after.status;
  if (beforeStatus === afterStatus) return; // Only notify on status change

  const buyerId = after.buyerId;
  if (!buyerId) return;

  const tokens = await getUserTokens(buyerId);
  if (tokens.length === 0) {
    console.log(`No tokens for buyerId=${buyerId}`);
    return;
  }

  const productName = after.productName || 'Order';
  await sendMulticast(tokens, {
    notification: {
      title: 'Order Updated',
      body: `${productName}: ${afterStatus}`,
    },
    data: {
      type: 'order_updated',
      orderId: after.id || event.params.orderId,
      buyerId: buyerId,
      farmerId: after.farmerId || '',
      productId: after.productId || '',
      status: afterStatus || '',
    },
  });
});
