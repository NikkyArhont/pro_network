const { onRequest } = require("firebase-functions/v2/https");
const admin = require('firebase-admin');
const { getFirestore } = require('firebase-admin/firestore');
const axios = require('axios');

admin.initializeApp();
const db = getFirestore(admin.app(), 'pronetwork');

// === НАСТРОЙКИ SMS AERO (СОХРАНЕНО) ===
const SMSAERO_EMAIL = 'Svya3i@yandex.ru';
const SMSAERO_API_KEY = 'qd__Mvk-ZkyYkkhkUB-3eBm4-U5jBf2U';
const SMSAERO_SIGN = 'SMSAero';
// ======================================

function normalizePhone(phone) {
  return phone.replace(/\s+/g, '').replace('+', '');
}

function generateCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

exports.sendcode = onRequest({ cors: true }, async (req, res) => {
  console.log('DEBUG [sendcode]: GCLOUD_PROJECT:', process.env.GCLOUD_PROJECT);
  console.log('DEBUG [sendcode]: GOOGLE_CLOUD_PROJECT:', process.env.GOOGLE_CLOUD_PROJECT);
  console.log('DEBUG [sendcode]: admin.app().options.projectId:', admin.app().options.projectId);

  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  const { phone: phoneInput } = req.body;
  if (!phoneInput) {
    return res.status(400).json({ success: false, message: 'Phone is required' });
  }

  const phone = normalizePhone(phoneInput);
  const code = generateCode();
  const expiresAt = admin.firestore.Timestamp.fromDate(new Date(Date.now() + 5 * 60000));

  try {
    // DIAGNOSTIC FIRESTORE READ
    try {
      const snap = await db.collection('users').limit(1).get();
      console.log('DEBUG [sendcode]: Successfully connected to Firestore. Found users:', snap.size);
    } catch (e) {
      console.error('DEBUG [sendcode]: Firestore connection error:', e);
    }

    await db.collection('sms_verifications').doc(phone).set({
      phone,
      code,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
      attemptsCount: 0,
      used: false
    });

    const url = `https://gate.smsaero.ru/v2/telegram/send`;
    const aeroRes = await axios.get(url, {
      params: {
        number: phone,
        code: code,
        text: `Ваш код: ${code}`,
        sign: SMSAERO_SIGN
      },
      auth: { username: SMSAERO_EMAIL, password: SMSAERO_API_KEY },
      headers: { 'Accept': 'application/json' }
    });

    if (aeroRes.data.success) {
      res.json({ success: true, message: 'Code sent' });
    } else {
      res.json({ success: false, message: aeroRes.data.message || 'Failed to send' });
    }
  } catch (error) {
    console.error('sendCode Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

/**
 * 2) verifyCode - 2nd Gen Function with CORS
 */
exports.verifycode = onRequest({ cors: true }, async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  const { phone: phoneInput, code: inputCode } = req.body;
  if (!phoneInput || !inputCode) {
    return res.status(400).json({ success: false, message: 'Phone and code are required' });
  }

  const phone = normalizePhone(phoneInput);
  const verificationRef = db.collection('sms_verifications').doc(phone);
  const doc = await verificationRef.get();

  if (!doc.exists) {
    return res.json({ success: false, message: 'Code not requested' });
  }

  const verData = doc.data();
  if (verData.used) return res.json({ success: false, message: 'Code already used' });
  if (verData.expiresAt.toDate() < new Date()) return res.json({ success: false, message: 'Code expired' });
  if (verData.attemptsCount >= 5) return res.json({ success: false, message: 'Too many attempts' });

  if (verData.code !== inputCode) {
    await verificationRef.update({ attemptsCount: admin.firestore.FieldValue.increment(1) });
    return res.json({ success: false, message: 'Invalid code' });
  }

  try {
    await verificationRef.update({ used: true });

    let userRecord;
    try {
      userRecord = await admin.auth().getUser(phone);
    } catch (e) {
      userRecord = await admin.auth().createUser({ uid: phone, phoneNumber: `+${phone}` });
    }

    const customToken = await admin.auth().createCustomToken(userRecord.uid);
    res.json({ success: true, customToken: customToken });

  } catch (error) {
    console.error('verifyCode Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});
