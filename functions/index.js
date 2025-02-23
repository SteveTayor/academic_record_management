/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

// Ensure Firebase is initialized
admin.initializeApp();

// Import specific functions correctly
// const { onRequest, onCall } = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

/**
 * Simple HTTP function
 */
// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", { structuredData: true });
//   response.send("Hello from Firebase!");
// });

/**
 * Cloud Function to send OTP
 */
exports.sendOtp = onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { email, otp } = data;
  if (!email || !otp) {
    throw new functions.https.HttpsError("invalid-argument", "Email and OTP are required.");
  }

  const apiKey = process.env.ZEPTOMAIL_KEY;
  if (!apiKey) {
    throw new functions.https.HttpsError("internal", "ZeptoMail API key is not set.");
  }

  const fromEmail = "noreply@joseph-jahazil.name.ng";
  const url = "https://api.zeptomail.com/v1.1/email";
  const headers = {
    Accept: "application/json",
    "Content-Type": "application/json",
    Authorization: `Zoho-enczapikey ${apiKey}`,
  };
  const body = {
    from: { address: fromEmail },
    to: [{ email_address: { address: email } }],
    subject: "Your OTP Code",
    htmlbody: `<div><b>Your OTP code is ${otp}. It will expire in 5 minutes.</b></div>`,
  };

  try {
    logger.info(`Sending OTP to ${email}`, { structuredData: true });
    await axios.post(url, body, { headers });
    logger.info(`OTP sent successfully to ${email}`, { structuredData: true });
    return { success: true };
  } catch (error) {
    logger.error("Error sending OTP:", error);
    throw new functions.https.HttpsError("internal", "Failed to send OTP");
  }
});
