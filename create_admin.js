// This script creates an admin user in Firebase
// Run with: node create_admin.js

const admin = require('firebase-admin');

// You need to download your service account key from Firebase Console
// Go to Project Settings > Service Accounts > Generate New Private Key
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function createAdmin() {
  try {
    // Create auth user
    const userRecord = await admin.auth().createUser({
      email: 'admin@biryanibyflame.com',
      password: 'Admin@123456',
      displayName: 'Admin User',
    });

    console.log('✅ Admin user created successfully!');
    console.log('UID:', userRecord.uid);
    console.log('Email:', userRecord.email);
    console.log('\n📋 Now update Firestore document:');
    console.log('1. Go to Firestore Console');
    console.log('2. Find employees collection');
    console.log('3. Update document ID to:', userRecord.uid);
    console.log('4. Update the id field to:', userRecord.uid);
    
  } catch (error) {
    console.error('❌ Error creating admin:', error);
  }
}

createAdmin();
