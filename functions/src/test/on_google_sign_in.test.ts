import { describe, it, expect, vi, beforeEach } from 'vitest';
import * as admin from 'firebase-admin';
import { onGoogleSignIn } from '../auth/on_google_sign_in';

// Mock Firebase Admin
vi.mock('firebase-admin', () => {
  const mockFirestoreInstance = {
    collection: vi.fn().mockReturnThis(),
    doc: vi.fn().mockReturnThis(),
    get: vi.fn(),
    set: vi.fn(),
  };

  return {
    firestore: vi.fn(() => mockFirestoreInstance),
    initializeApp: vi.fn(),
  };
});

// Mock Firebase Functions
vi.mock('firebase-functions', () => ({
  auth: {
    user: () => ({
      onCreate: vi.fn((handler) => handler),
    }),
  },
}));

describe('onGoogleSignIn', () => {
  let mockFirestore: any;
  const mockDate = new Date('2024-02-20T00:00:00.000Z');

  beforeEach(() => {
    // Reset semua mock
    vi.clearAllMocks();

    // Mock Date
    vi.setSystemTime(mockDate);

    // Dapatkan instance mock Firestore
    mockFirestore = admin.firestore();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('tidak melakukan apa-apa jika user tidak sign in dengan Google', async () => {
    const mockUser = {
      uid: 'test-uid',
      email: 'test@example.com',
      emailVerified: false,
      providerData: [{
        providerId: 'password',
        email: 'test@example.com'
      }]
    };

    await onGoogleSignIn(mockUser as any);

    expect(mockFirestore.collection).not.toHaveBeenCalled();
  });

  it('membuat dokumen baru untuk user Google yang pertama kali sign in', async () => {
    const mockUser = {
      uid: 'google-uid',
      email: 'google@example.com',
      emailVerified: true,
      providerData: [{
        providerId: 'google.com',
        displayName: 'Google User',
        email: 'google@example.com',
        photoURL: 'https://google.com/photo.jpg'
      }]
    };

    // Mock dokumen tidak ada
    mockFirestore.get.mockResolvedValue({
      exists: false,
      data: () => null
    });

    await onGoogleSignIn(mockUser as any);

    // Verifikasi panggilan Firestore
    expect(mockFirestore.collection).toHaveBeenCalledWith('users');
    expect(mockFirestore.doc).toHaveBeenCalledWith('google-uid');
    expect(mockFirestore.set).toHaveBeenCalledWith(
      expect.objectContaining({
        email: 'google@example.com',
        emailVerified: true,
        displayName: 'Google User',
        photoURL: 'https://google.com/photo.jpg',
        createdAt: mockDate,
        lastLoginAt: mockDate
      }),
      { merge: true }
    );
  });

  it('update dokumen yang sudah ada untuk user Google yang sign in lagi', async () => {
    const mockUser = {
      uid: 'existing-uid',
      email: 'existing@example.com',
      emailVerified: true,
      providerData: [{
        providerId: 'google.com',
        displayName: 'Existing User',
        email: 'existing@example.com',
        photoURL: 'https://example.com/updated.jpg'
      }]
    };

    const oldDate = new Date('2024-01-01T00:00:00.000Z');

    // Mock dokumen sudah ada dengan timestamp yang benar
    mockFirestore.get.mockResolvedValue({
      exists: true,
      data: () => ({
        email: 'old@example.com',
        createdAt: {
          toDate: () => oldDate
        },
        displayName: 'Old Name'
      })
    });

    await onGoogleSignIn(mockUser as any);

    // Verifikasi panggilan Firestore
    expect(mockFirestore.collection).toHaveBeenCalledWith('users');
    expect(mockFirestore.doc).toHaveBeenCalledWith('existing-uid');
    expect(mockFirestore.set).toHaveBeenCalledWith(
      expect.objectContaining({
        email: 'existing@example.com',
        emailVerified: true,
        displayName: 'Existing User',
        photoURL: 'https://example.com/updated.jpg',
        createdAt: oldDate,
        lastLoginAt: mockDate
      }),
      { merge: true }
    );
  });

  it('menangani error Firestore dengan baik', async () => {
    const mockUser = {
      uid: 'test-uid',
      email: 'test@example.com',
      emailVerified: true,
      providerData: [{
        providerId: 'google.com',
        email: 'test@example.com'
      }]
    };

    // Mock error Firestore
    mockFirestore.get.mockRejectedValue(new Error('Firestore error'));

    await expect(onGoogleSignIn(mockUser as any)).rejects.toThrow('Firestore error');
  });

  it('menangani kasus dimana providerData kosong', async () => {
    const mockUser = {
      uid: 'test-uid',
      email: 'test@example.com',
      emailVerified: true,
      providerData: []
    };

    await onGoogleSignIn(mockUser as any);

    expect(mockFirestore.collection).not.toHaveBeenCalled();
  });
}); 