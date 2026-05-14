const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

exports.syncUserEmails = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated', 'Debes iniciar sesión para ejecutar esta función'
    );
  }

  const adminEmail = context.auth.token.email;
  const adminEmails = [
    'hsoundpasto@gmail.com',
    'esneyderj.ibarra221@gmail.com',
    'esneydribarra1970@gmail.com',
    'sofia.burbanoba221@umariana.edu.co',
    'admin@hsound.com',
    'admin@musical.com',
  ];

  if (!adminEmails.includes(adminEmail)) {
    throw new functions.https.HttpsError(
      'permission-denied', 'Solo administradores pueden ejecutar esta función'
    );
  }

  const usersSnapshot = await db.collection('users').get();
  let updated = 0;
  let skipped = 0;

  const promises = usersSnapshot.docs.map(async (doc) => {
    const data = doc.data();
    if (data.email) {
      skipped++;
      return;
    }

    try {
      const userRecord = await auth.getUser(doc.id);
      if (userRecord.email) {
        await doc.ref.update({ email: userRecord.email });
        updated++;
      }
    } catch (err) {
      console.error(`Error obteniendo usuario ${doc.id}:`, err.message);
    }
  });

  await Promise.all(promises);

  return {
    success: true,
    updated,
    skipped,
    total: usersSnapshot.docs.length,
  };
});
