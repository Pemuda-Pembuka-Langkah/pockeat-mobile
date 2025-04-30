import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Firebase function that triggers on any write to the food_analysis collection
 * and updates the timestamp field to use Firebase Timestamp.now() instead of ISO string
 */
export const updateFoodAnalysisTimestamp = functions.firestore
  .document('food_analysis/{docId}')
  .onWrite(async (change, context) => {
    // If document was deleted, do nothing
    if (!change.after.exists) {
      return null;
    }

    const docData = change.after.data();
    
    // If document data is undefined, do nothing
    if (!docData) {
      console.log(`No data found for document: ${context.params.docId}`);
      return null;
    }
    
    // If there's already a timestamp field in Firebase Timestamp format, don't update
    if (docData.timestamp && docData.timestamp instanceof admin.firestore.Timestamp) {
      return null;
    }

    // Update the timestamp field with current Firebase timestamp
    const updatedData = {
      timestamp: admin.firestore.Timestamp.now()
    };

    try {
      // Get reference to the document and update it
      const docRef = change.after.ref;
      await docRef.update(updatedData);
      
      console.log(`Successfully updated timestamp for document: ${context.params.docId}`);
      return null;
    } catch (error) {
      console.error(`Error updating timestamp for document ${context.params.docId}:`, error);
      return null;
    }
  });
