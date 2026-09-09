const admin = require('firebase-admin');
const serviceAccount = require('./o2-clinic-a5631-firebase-adminsdk-fbsvc-ff6c5bef4f.json');
const data = require('./o2_clinic_firestore_seed.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'o2-clinic-a5631'
});

const db = admin.firestore();

function transformData(val) {
  if (val && typeof val === 'object') {
    if (val._type === 'timestamp') {
      return new admin.firestore.Timestamp(val.seconds, val.nanoseconds);
    }
    const res = Array.isArray(val) ? [] : {};
    for (const k in val) {
      if (k === 'bookings' || k === 'notifications' || k === 'messages') {
          // These will be handled as subcollections, so we skip them in the main document fields
          // if we want to follow typical subcollection patterns.
          // However, for simplicity and to match the JSON structure if intended as fields,
          // we could keep them. But usually they are subcollections.
          continue;
      }
      res[k] = transformData(val[k]);
    }
    return res;
  }
  return val;
}

async function seedCollection(collectionName, collectionData) {
  console.log(`Seeding collection: ${collectionName}...`);
  for (const [id, docData] of Object.entries(collectionData)) {
    const transformedDoc = transformData(docData);

    const docId = transformedDoc.id || id;

    await db.collection(collectionName).doc(docId).set(transformedDoc);

    // Handle subcollections
    if (collectionName === 'users') {
        if (docData.bookings) {
            for (const [bId, bData] of Object.entries(docData.bookings)) {
                await db.collection('users').doc(docId).collection('bookings').doc(bId).set(transformData(bData));
            }
        }
        if (docData.notifications) {
            for (const [nId, nData] of Object.entries(docData.notifications)) {
                await db.collection('users').doc(docId).collection('notifications').doc(nId).set(transformData(nData));
            }
        }
    }

    if (collectionName === 'chat_rooms' && docData.messages) {
        for (const [mId, mData] of Object.entries(docData.messages)) {
            await db.collection('chat_rooms').doc(docId).collection('messages').doc(mId).set(transformData(mData));
        }
    }

    console.log(`  Added document: ${docId} to ${collectionName}`);
  }
  console.log(`Finished seeding collection: ${collectionName}`);
}

async function seedDatabase() {
  try {
    console.log('Starting full database seeding...');
    
    for (const [collectionName, collectionData] of Object.entries(data)) {
        await seedCollection(collectionName, collectionData);
    }
    
    console.log('Database seeding completed successfully!');
  } catch (error) {
    console.error('Error seeding database:', error);
  } finally {
    admin.app().delete();
  }
}

seedDatabase();
