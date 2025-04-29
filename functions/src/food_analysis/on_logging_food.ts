import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

export const setCurrentTimestamp = functions.firestore
  .document('food_analysis/{docId}')
  .onCreate(async (snapshot, context) => {
    try {
      // Get the current server timestamp
      const now = admin.firestore.Timestamp.now();
      
      // Update the document with the current timestamp
      await snapshot.ref.update({
        timestamp: now
      });
      
      console.log(`Successfully set current timestamp for document ID: ${context.params.docId}`);
      return null;
    } catch (error) {
      console.error('Error setting current timestamp:', error);
      throw error;
    }
  });