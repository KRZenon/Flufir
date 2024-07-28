
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNewOrderNotification = functions.firestore
    .document('orders/{orderId}')
    .onCreate((snapshot, context) => {
        // Get the newly added order data
        const newOrderData = snapshot.data();

        // Check if the order is new and should be notified
        if (newOrderData && newOrderData.isNew) {
            // Logic to send notification to admin
            // Implement your notification logic here
            const adminDeviceToken = 'ADMIN_DEVICE_TOKEN'; // Replace with the admin's device token
            sendNotificationToAdmin(adminDeviceToken);
        }

        return null;
    });

function sendNotificationToAdmin(deviceToken) {
    // Send push notification to admin using deviceToken
    // Implement FCM or any other push notification service here
    console.log("Sending notification to admin with device token:", deviceToken);
}
