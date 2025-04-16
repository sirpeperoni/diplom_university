const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "your-email@gmail.com", // Ваш email
    pass: "your-email-password", // Ваш пароль
  },
});

exports.sendVerificationCode = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const code = Math.floor(100000 + Math.random() * 900000).toString(); // Генерация 6-значного кода

  // Сохраняем код в Firestore (или Realtime Database)
  await admin.firestore().collection("verificationCodes").doc(email).set({
    code: code,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  const mailOptions = {
    from: "your-email@gmail.com",
    to: email,
    subject: "Ваш код подтверждения",
    text: `Ваш код подтверждения: ${code}`,
  };

  await transporter.sendMail(mailOptions);

  return {success: true};
});
