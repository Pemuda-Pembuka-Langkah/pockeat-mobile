import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Inisialisasi Firebase Admin
admin.initializeApp();

interface GoogleUserData {
  email: string | null;
  displayName: string | null;
  photoURL: string | null;
  providerId: string;
}

interface UserData {
  email: string | null;
  emailVerified: boolean;
  displayName: string | null;
  photoURL: string | null;
  createdAt: Date;
  lastLoginAt: Date;
}

export const onGoogleSignIn = functions.auth.user().onCreate(async (user) => {
  // Cek apakah user sign in dengan Google
  if (user.providerData[0]?.providerId === 'google.com') {
    try {
      // Ambil data dari Google Sign In
      const googleUserData = user.providerData[0] as GoogleUserData;
      const now = new Date();

      // Cek apakah user sudah ada di Firestore
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(user.uid)
        .get();

      // Data yang akan disimpan ke Firestore sesuai dengan UserModel
      const userData: UserData = {
        // Required fields
        email: user.email || null,
        emailVerified: user.emailVerified || false,
        createdAt: userDoc.exists && userDoc.data()?.createdAt ? userDoc.data()?.createdAt.toDate() : now,
        
        // Data dari Google
        displayName: googleUserData.displayName,
        photoURL: googleUserData.photoURL,
        lastLoginAt: now,
      };

      // Simpan ke Firestore
      await admin.firestore()
        .collection('users')
        .doc(user.uid)
        .set(userData, { merge: true });

      console.log(`Successfully ${userDoc.exists ? 'updated' : 'created'} user profile for ${user.email}`);
    } catch (error) {
      console.error('Error creating/updating user profile:', error);
      throw error;
    }
  }
}); 