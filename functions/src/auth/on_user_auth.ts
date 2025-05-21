import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

// Handle new user registration
export const onUserAuth = functions.auth.user().onCreate(async (user) => {
  try {
    const now = new Date();
    // Calculate free trial end date (7 days from now)
    const freeTrialEndsAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

    // Add free trial end date to user document
    await admin.firestore()
      .collection('users')
      .doc(user.uid)
      .set({ freeTrialEndsAt }, { merge: true });

    console.log(`Added free trial for user ${user.email}`);
  } catch (error) {
    console.error('Error adding free trial:', error);
    throw error;
  }
}); 