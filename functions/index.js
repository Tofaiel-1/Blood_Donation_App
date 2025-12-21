/**
 * Firebase Cloud Functions for Email Service
 * Sends emails from custom domain using SendGrid or Gmail SMTP
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();
const db = admin.firestore();

// Configure your SMTP settings
// Option 1: Gmail SMTP (for testing)
const gmailTransporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: functions.config().email?.gmail_user || 'your-email@gmail.com',
    pass: functions.config().email?.gmail_password || 'your-app-password'
  }
});

// Option 2: SendGrid (recommended for production)
// npm install @sendgrid/mail
// const sgMail = require('@sendgrid/mail');
// sgMail.setApiKey(functions.config().sendgrid?.api_key);

/**
 * Process email queue and send emails
 * Triggered when new document added to emailQueue collection
 */
exports.sendEmail = functions.firestore
  .document('emailQueue/{emailId}')
  .onCreate(async (snap, context) => {
    const emailData = snap.data();
    
    try {
      // Email configuration
      const mailOptions = {
        from: {
          name: emailData.from.name || 'Blood Donation App',
          address: emailData.from.email || 'admin@blooddonation.com'
        },
        to: emailData.to,
        subject: emailData.subject,
        html: getEmailTemplate(emailData.templateType, emailData.templateData)
      };

      // Send email using Gmail SMTP
      await gmailTransporter.sendMail(mailOptions);

      // Update email status
      await snap.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`Email sent successfully to ${emailData.to}`);
      return null;

    } catch (error) {
      console.error('Error sending email:', error);
      
      // Update error status
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      return null;
    }
  });

/**
 * Get email template HTML
 */
function getEmailTemplate(templateType, data) {
  switch (templateType) {
    case 'verification':
      return getVerificationTemplate(data);
    case 'blood_request':
      return getBloodRequestTemplate(data);
    case 'donation_confirmation':
      return getDonationConfirmationTemplate(data);
    default:
      return getDefaultTemplate(data);
  }
}

function getVerificationTemplate(data) {
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; margin: 0 auto; background-color: white;">
    <tr>
      <td style="background: linear-gradient(135deg, #D32F2F 0%, #B71C1C 100%); padding: 40px 20px; text-align: center;">
        <h1 style="color: white; margin: 0; font-size: 28px;">🩸 ${data.appName}</h1>
        <p style="color: white; margin: 10px 0 0;">Verify Your Email Address</p>
      </td>
    </tr>
    <tr>
      <td style="padding: 40px 30px;">
        <h2 style="color: #333;">Hello ${data.userName}!</h2>
        <p style="color: #666; font-size: 16px; line-height: 1.6;">
          Welcome to ${data.appName}! Please verify your email to activate your account.
        </p>
        <div style="text-align: center; margin: 30px 0;">
          <a href="${data.verificationLink}" style="background-color: #D32F2F; color: white; padding: 15px 40px; text-decoration: none; border-radius: 5px; font-weight: bold;">
            Verify Email
          </a>
        </div>
      </td>
    </tr>
    <tr>
      <td style="background-color: #f9f9f9; padding: 20px 30px; text-align: center;">
        <p style="color: #999; font-size: 12px;">
          © ${data.year} ${data.appName}<br>
          <a href="mailto:${data.supportEmail}">${data.supportEmail}</a>
        </p>
      </td>
    </tr>
  </table>
</body>
</html>
  `;
}

function getBloodRequestTemplate(data) {
  return `
<!DOCTYPE html>
<html>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; margin: 0 auto; background-color: white;">
    <tr>
      <td style="background: linear-gradient(135deg, #D32F2F 0%, #B71C1C 100%); padding: 40px 20px; text-align: center;">
        <h1 style="color: white; margin: 0;">🚨 Urgent Blood Request</h1>
      </td>
    </tr>
    <tr>
      <td style="padding: 40px 30px;">
        <h2>Dear ${data.donorName},</h2>
        <p style="color: #666; font-size: 16px;">
          A patient urgently needs <strong style="color: #D32F2F;">${data.bloodType}</strong> blood.
        </p>
        <div style="background-color: #fff3f3; border-left: 4px solid #D32F2F; padding: 20px; margin: 20px 0;">
          <p><strong>Patient:</strong> ${data.patientName}</p>
          <p><strong>Hospital:</strong> ${data.hospital}</p>
          <p><strong>Urgency:</strong> <span style="color: #D32F2F;">${data.urgency.toUpperCase()}</span></p>
        </div>
        <p>Please open the app to respond.</p>
      </td>
    </tr>
  </table>
</body>
</html>
  `;
}

function getDonationConfirmationTemplate(data) {
  return `
<!DOCTYPE html>
<html>
<body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; margin: 0 auto; background-color: white;">
    <tr>
      <td style="background: linear-gradient(135deg, #4CAF50 0%, #388E3C 100%); padding: 40px 20px; text-align: center;">
        <h1 style="color: white; margin: 0;">🎉 Thank You!</h1>
      </td>
    </tr>
    <tr>
      <td style="padding: 40px 30px; text-align: center;">
        <h2>You're a Hero, ${data.userName}!</h2>
        <p style="font-size: 18px; color: #666;">
          Thank you for your donation on ${data.donationDate} at ${data.location}.
        </p>
        <p style="font-size: 20px; color: #4CAF50; font-weight: bold;">
          You just saved a life! ❤️
        </p>
      </td>
    </tr>
  </table>
</body>
</html>
  `;
}

function getDefaultTemplate(data) {
  return `
<!DOCTYPE html>
<html>
<body>
  <h2>Blood Donation App</h2>
  <p>${data.message || 'No message'}</p>
</body>
</html>
  `;
}

/**
 * Cleanup old email logs (runs daily)
 */
exports.cleanupOldEmails = functions.pubsub
  .schedule('0 2 * * *') // Run at 2 AM daily
  .onRun(async (context) => {
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
    );

    const oldEmails = await db.collection('emailQueue')
      .where('createdAt', '<', thirtyDaysAgo)
      .where('status', 'in', ['sent', 'failed'])
      .get();

    const batch = db.batch();
    oldEmails.forEach(doc => batch.delete(doc.ref));
    
    await batch.commit();
    console.log(`Cleaned up ${oldEmails.size} old emails`);
    return null;
  });
