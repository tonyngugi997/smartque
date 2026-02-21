require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { Sequelize, DataTypes, Op } = require('sequelize');

//NODEMAILER SETUP
const nodemailer = require('nodemailer');

const app = express();

// CORS 
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true,
}));

app.use(express.json());

const PORT = process.env.PORT || 5000;

//EMAIL CONFIG
let emailEnabled = false;
let mailTransporter = null;
let currentEmailMode = 'unknown';



async function initializeEmailTransporter() {
  console.log('\n📧 ============ INITIALIZING EMAIL SYSTEM ============');
  
  if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS) {
    console.log('🔧 Detected SMTP configuration');
    console.log(`   Host: ${process.env.SMTP_HOST}:${process.env.SMTP_PORT || 587}`);
    console.log(`   User: ${process.env.SMTP_USER}`);
    
    try {
      mailTransporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT || 587,
        secure: process.env.SMTP_SECURE === 'true',
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASS,
        },
        tls: {
          rejectUnauthorized: false, 
        },
        
        pool: true,
        maxConnections: 5,
        maxMessages: 100,
      });
      
      
      await mailTransporter.verify();
      emailEnabled = true;
      currentEmailMode = 'smtp';
      
      console.log('✅ SMTP connection verified successfully');
      console.log(`📧 Email system: REAL SMTP (${process.env.SMTP_HOST})`);
      
    } catch (smtpError) {
      console.error('❌ SMTP configuration failed:', smtpError.message);
      console.log('🔄 Falling back to alternative email methods...');
    }
  }
  
  if (!emailEnabled && process.env.NODE_ENV === 'development') {
    console.log('🔧 Attempting Ethereal smtp....');
    
    try {
      
      const testAccount = await nodemailer.createTestAccount();
      
      mailTransporter = nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        secure: false,
        auth: {
          user: testAccount.user,
          pass: testAccount.pass,
        },
      });
      
      await mailTransporter.verify();
      emailEnabled = true;
      currentEmailMode = 'ethereal';
      
      console.log('✅ Ethereal configured successfully');
      console.log(`📧 Email system: ETHEREAL (fake SMTP for testing)`);
      console.log(`   Test account: ${testAccount.user}`);
      console.log(`   Test password: ${testAccount.pass}`);
      console.log('💡 Note: Emails won\'t be delivered to real addresses');
      console.log('       Check Ethereal inbox for sent emails');
      
    } catch (etherealError) {
      console.error('❌ Ethereal setup failed:', etherealError.message);
      console.log('🔄 Falling back to console-only mode...');
    }
  }
  
  if (!emailEnabled) {
    emailEnabled = true; 
    currentEmailMode = 'console';
    console.log('✅ Email system: CONSOLE-ONLY MODE');
    console.log('💡 All emails will be logged to console only');
    console.log('   OTP codes will be displayed on the console');
  }
  
  console.log('📧 ============ EMAIL SYSTEM READY ============\n');
}

//DATABASE SETUP
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: process.env.DB_STORAGE || './database.sqlite',
  logging: false, 
});

// OTP Model
const OTP = sequelize.define('OTP', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  otp: {
    type: DataTypes.STRING(6),
    allowNull: false,
  },
  verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  attempts: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  expiresAt: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
});

// User Model 
const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  role: {
    type: DataTypes.STRING,
    defaultValue: 'user',
  },
  isEmailVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
});

// Appointment Model
const Appointment = sequelize.define('Appointment', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  doctorName: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  departmentName: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  dateTime: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  queueNumber: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected', 'upcoming', 'in_progress', 'completed', 'cancelled'),
    defaultValue: 'pending',
  },
  consultationFee: {
    type: DataTypes.FLOAT,
    defaultValue: 0,
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
});

// Department/Service Model
const Department = sequelize.define('Department', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false, unique: true },
  description: { type: DataTypes.TEXT, allowNull: true },
  createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
});

// Counter Model (service counters)
const Counter = sequelize.define('Counter', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING, allowNull: false },
  departmentId: { type: DataTypes.INTEGER, allowNull: true },
  isActive: { type: DataTypes.BOOLEAN, defaultValue: true },
  createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
});

Department.hasMany(Counter, { foreignKey: 'departmentId' });
Counter.belongsTo(Department, { foreignKey: 'departmentId' });

// Hashed password
User.beforeCreate(async (user) => {
  if (user.password) {
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(user.password, salt);
  }
});

//M-PESA DARAJA CONFIG 
const MPESA_BASE_URL = process.env.MPESA_BASE_URL || 'https://sandbox.safaricom.co.ke';
const MPESA_CONSUMER_KEY = process.env.MPESA_CONSUMER_KEY || '';
const MPESA_CONSUMER_SECRET = process.env.MPESA_CONSUMER_SECRET || '';
const MPESA_SHORTCODE = process.env.MPESA_SHORTCODE || '';
const MPESA_PASSKEY = process.env.MPESA_PASSKEY || '';
const MPESA_CALLBACK_URL =
  process.env.MPESA_CALLBACK_URL;

// timestamp as YYYYMMDDHHMMSS
const formatMpesaTimestamp = () => {
  const now = new Date();
  const pad = (n) => n.toString().padStart(2, '0');
  return (
    now.getFullYear().toString() +
    pad(now.getMonth() + 1) +
    pad(now.getDate()) +
    pad(now.getHours()) +
    pad(now.getMinutes()) +
    pad(now.getSeconds())
  );
};

// Get OAuth token from Daraja
async function getMpesaAccessToken() {
  if (!MPESA_CONSUMER_KEY || !MPESA_CONSUMER_SECRET) {
    throw new Error('MPESA_CONSUMER_KEY/SECRET are not configured');
  }

  const credentials = Buffer.from(
    `${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`
  ).toString('base64');

  const url = `${MPESA_BASE_URL}/oauth/v1/generate?grant_type=client_credentials`;
  const res = await fetch(url, {
    headers: {
      Authorization: `Basic ${credentials}`,
    },
  });

  const data = await res.json();
  if (!res.ok || !data.access_token) {
    console.error('❌ Failed to get M-Pesa access token:', data);
    throw new Error('Failed to get M-Pesa access token');
  }

  return data.access_token;
}

// Initiate STK Push
async function initiateStkPush({
  amount,
  phoneNumber,
  accountReference,
  transactionDesc,
}) {
  if (!MPESA_SHORTCODE || !MPESA_PASSKEY) {
    throw new Error('MPESA_SHORTCODE/PASSKEY are not configured');
  }

  const token = await getMpesaAccessToken();
  const timestamp = formatMpesaTimestamp();
  const password = Buffer.from(
    `${MPESA_SHORTCODE}${MPESA_PASSKEY}${timestamp}`
  ).toString('base64');

  const body = {
    BusinessShortCode: MPESA_SHORTCODE,
    Password: password,
    Timestamp: timestamp,
    TransactionType: 'CustomerPayBillOnline',
    Amount: amount,
    PartyA: phoneNumber,
    PartyB: MPESA_SHORTCODE,
    PhoneNumber: phoneNumber,
    CallBackURL: MPESA_CALLBACK_URL,
    AccountReference: accountReference || 'SmarTQue',
    TransactionDesc: transactionDesc || 'Appointment Payment',
  };

  console.log('📲 Initiating M-Pesa STK Push:', {
    PhoneNumber: phoneNumber,
    Amount: amount,
    AccountReference: body.AccountReference,
  });

  const res = await fetch(
    `${MPESA_BASE_URL}/mpesa/stkpush/v1/processrequest`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(body),
    }
  );

  const data = await res.json();
  console.log('📲 M-Pesa STK response:', data);

  if (!res.ok || data.ResponseCode !== '0') {
    throw new Error(
      data.errorMessage || data.errorCode || 'M-Pesa STK push failed'
    );
  }

  return data;
}

//UTILITY FUNCS

// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET || 'smartque_dev_secret_2024', {
    expiresIn: process.env.JWT_EXPIRE || '24h'
  });
};


const sendEmail = async (to, subject, html) => {
  const emailId = `email_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  
  console.log(`\n📧 [${emailId}] ============ EMAIL SENDING ATTEMPT ============`);
  console.log(`   To: ${to}`);
  console.log(`   Subject: ${subject}`);
  console.log(`   Mode: ${currentEmailMode.toUpperCase()}`);
  console.log(`   Time: ${new Date().toISOString()}`);
  
  
  const otpMatch = html.match(/<h1[^>]*>(\d{6})<\/h1>/i) || html.match(/>(\d{6})</);
  if (otpMatch) {
    console.log(`   📱 OTP in email: ${otpMatch[1]}`);
  }
  
  
  if (currentEmailMode === 'console') {
    console.log(`   📝 [CONSOLE MODE] Email would be sent in production`);
    console.log(`   📝 [CONSOLE MODE] HTML length: ${html.length} characters`);
    console.log(`📧 [${emailId}] ============ EMAIL LOGGED TO CONSOLE ============\n`);
    return { success: true, mode: 'console', emailId };
  }
  
  
  try {
    const fromEmail = ProcessingInstruction.env.EMAIL_FROM || process.env.SMTP-USER || "tonyngugi997@gmail.com";
    const fronName = process.env.EMAIL_FROM_NAME || "smarTQue Team";
    
    
    const mailOptions = {
      from: `"${fromName}" <${fromEmail}>`,
      to: to,
      subject: subject,
      html: html,
    
      headers: {
        'X-Email-ID': emailId,
        'X-Application': 'SmarTQue',
        'X-Environment': process.env.NODE_ENV || 'development',
      },
    };
    
    console.log(`   📤 Attempting to send via ${currentEmailMode}...`);
    const startTime = Date.now();
    
    const info = await mailTransporter.sendMail(mailOptions);
    const elapsedTime = Date.now() - startTime;
    
    console.log(`   ✅ Email sent successfully in ${elapsedTime}ms`);
    console.log(`   📨 Message ID: ${info.messageId}`);
    console.log(`   📊 Response: ${info.response || 'No response data'}`);
    
    
    if (currentEmailMode === 'ethereal') {
      const previewUrl = nodemailer.getTestMessageUrl(info);
      if (previewUrl) {
        console.log(`   🔗 Preview URL: ${previewUrl}`);
        console.log('   👀 Check this URL in browser to see the email');
      }
    }
    
    console.log(`📧 [${emailId}] ============ EMAIL SENT SUCCESSFULLY ============\n`);
    return { success: true, mode: currentEmailMode, emailId, info };
    
  } catch (emailError) {
    console.error(`   ❌ Email sending failed:`, emailError.message);
    console.error(`   🔧 Error details:`, {
      code: emailError.code,
      command: emailError.command,
      responseCode: emailError.responseCode,
      response: emailError.response,
    });
    
    console.log(`   ⚠️  Continuing without email (OTP will still work)`);
    console.log(`📧 [${emailId}] ============ EMAIL FAILED - CONTINUING ============\n`);
    
    return { 
      success: false, 
      mode: currentEmailMode, 
      emailId, 
      error: emailError.message,
      operationSuccess: true 
    };
  }
};

const sendOtpEmail = async (email, otp) => {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Verify Your Email - SmarTQue</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          line-height: 1.6;
          color: #333;
          margin: 0;
          padding: 0;
          background-color: #f8f9fa;
        }
        .container {
          max-width: 600px;
          margin: 0 auto;
          background-color: white;
        }
        .header {
          background: linear-gradient(135deg, #6C63FF 0%, #4A44C6 100%);
          padding: 40px;
          text-align: center;
          border-radius: 10px 10px 0 0;
        }
        .header h1 {
          color: white;
          margin: 0;
          font-size: 28px;
          font-weight: 600;
        }
        .header p {
          color: rgba(255, 255, 255, 0.9);
          margin: 10px 0 0 0;
          font-size: 16px;
        }
        .content {
          padding: 40px;
          border-radius: 0 0 10px 10px;
          border: 1px solid #e9ecef;
          border-top: none;
        }
        .otp-container {
          text-align: center;
          margin: 40px 0;
          padding: 30px;
          background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
          border-radius: 12px;
          border: 3px solid #6C63FF;
        }
        .otp-code {
          font-size: 48px;
          font-weight: bold;
          letter-spacing: 10px;
          color: #6C63FF;
          font-family: 'Courier New', monospace;
          margin: 0;
        }
        .instruction {
          font-size: 16px;
          color: #666;
          margin: 20px 0;
        }
        .security-note {
          background-color: #fff8e1;
          border-left: 4px solid #ffb300;
          padding: 15px;
          margin: 30px 0;
          border-radius: 0 8px 8px 0;
        }
        .footer {
          text-align: center;
          margin-top: 40px;
          padding-top: 20px;
          border-top: 1px solid #eee;
          color: #999;
          font-size: 12px;
        }
        .button {
          display: inline-block;
          background: linear-gradient(135deg, #6C63FF 0%, #4A44C6 100%);
          color: white;
          padding: 14px 28px;
          text-decoration: none;
          border-radius: 8px;
          font-weight: 600;
          margin: 20px 0;
        }
        @media only screen and (max-width: 600px) {
          .content, .header {
            padding: 20px;
          }
          .otp-code {
            font-size: 36px;
            letter-spacing: 8px;
          }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>SmarTQue</h1>
          <p>Email Verification</p>
        </div>
        
        <div class="content">
          <h2>Verify Your Email Address</h2>
          <p class="instruction">Hello,</p>
          <p class="instruction">Thank you for registering with SmarTQue. To complete your registration, please use the verification code below:</p>
          
          <div class="otp-container">
            <h3>Your Verification Code</h3>
            <p class="otp-code">${otp}</p>
            <p>Enter this 6-digit code in the app to verify your email address.</p>
          </div>
          
          <p class="instruction"><strong>⚠️ This code expires in 10 minutes.</strong></p>
          
          <div class="security-note">
            <p><strong>Security Notice:</strong></p>
            <p>• Never share this code with anyone</p>
            <p>• SmarTQue will never ask for your verification code</p>
            <p>• If you didn't request this code, please ignore this email</p>
          </div>
          
          <div class="footer">
            <p>© ${new Date().getFullYear()} SmarTQue Inc. All rights reserved.</p>
            <p>This is an automated message, please do not reply to this email.</p>
          </div>
        </div>
      </div>
    </body>
    </html>
  `;
  
  const subject = 'Your SmarTQue Verification Code';
  const result = await sendEmail(email, subject, html);
  
// log the otp....to replace laterr
  if (currentEmailMode === 'console') {
    console.log(`\n🔢 IMPORTANT: OTP for ${email} is: ${otp}`);
    console.log(`   Use this code in your app to verify your email\n`);
  }
  
  return result;
};

// init server
async function startServer() {
  try {
    console.log('\n' + '='.repeat(70));
    console.log('🚀 SmarTQue Backend Server v2.0 (NodeMailer Enhanced)');
    console.log('='.repeat(70));
    console.log('📊 Configuration:');
    console.log(`   PORT: ${PORT}`);
    console.log(`   NODE_ENV: ${process.env.NODE_ENV || 'development'}`);
    console.log(`   DB Storage: ${process.env.DB_STORAGE || './database.sqlite'}`);
    console.log(`   JWT Expire: ${process.env.JWT_EXPIRE || '24h'}`);
    
    // Initialize email system
    await initializeEmailTransporter();
    
    // Test database connection
    console.log('\n🔌 Testing database connection...');
    await sequelize.authenticate();
    console.log('✅ SQLite database connected');
    
    // Sync databas
    console.log('🔄 Syncing database tables...');
    try {
      await sequelize.sync({ alter: true });
      console.log('✅ Database tables created/synced');
      
      // Count tables to verify
      const [results] = await sequelize.query("SELECT name FROM sqlite_master WHERE type='table'");
      const tableNames = results.map(r => r.name).join(', ');
      console.log(`📊 Tables in database: ${tableNames || 'None found'}`);
    } catch (syncError) {
      console.error('❌ Database sync failed:', syncError.message);
      console.log('⚠️  Continuing with existing tables...');
    }

      // Seed a default admin if none exists (development convenience)
      try {
        const adminExists = await User.findOne({ where: { role: 'admin' } });
        if (!adminExists) {
          const adminEmail = process.env.ADMIN_EMAIL || 'admin@local';
          const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';
          const adminName = process.env.ADMIN_NAME || 'Administrator';
          const adminUser = await User.create({ email: adminEmail, password: adminPassword, name: adminName, role: 'admin', isEmailVerified: true });
          console.log('🔐 Default admin created:');
          console.log(`   email: ${adminEmail}`);
          console.log(`   password: ${adminPassword}`);
          console.log('   Please change this account in production');
        } else {
          console.log('🔒 Admin account(s) already present');
        }
      } catch (seedErr) {
        console.error('❌ Admin seeding failed:', seedErr.message);
      }
    
    //API ENDPOINT
     
    // Health check endpoint
    app.get('/', (req, res) => {
      res.json({
        success: true,
        message: 'SmarTQue Backend API v2.0 (NodeMailer)',
        status: 'running',
        email: currentEmailMode,
        timestamp: new Date().toISOString(),
        version: '2.0.0'
      });
    });
    
    app.get('/api/health', (req, res) => {
      res.json({
        success: true,
        status: 'healthy',
        timestamp: new Date().toISOString(),
        email: {
          enabled: emailEnabled,
          mode: currentEmailMode,
          status: currentEmailMode === 'console' ? 'console_only' : 'operational'
        },
        database: 'connected',
        version: '2.0.0'
      });
    });
    
    // Generate OTP endpoint
    app.post('/api/auth/generate-otp', async (req, res) => {
      try {
        const { email } = req.body;
        
        console.log('\n' + '='.repeat(60));
        console.log('📱 OTP REQUEST RECEIVED');
        console.log('='.repeat(60));
        console.log(`   Email: ${email}`);
        console.log(`   Time: ${new Date().toISOString()}`);
        console.log(`   Email Mode: ${currentEmailMode}`);
        
        if (!email) {
          console.log('❌ Validation failed: Email is required');
          return res.status(400).json({
            success: false,
            error: 'Email is required'
          });
        }
        
        // email validation
        if (!email.includes('@') || !email.includes('.')) {
          console.log('❌ Validation failed: Invalid email format');
          return res.status(400).json({
            success: false,
            error: 'Invalid email format'
          });
        }
        
        // Check if user already exists
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
          console.log('❌ User already exists with this email');
          return res.status(400).json({
            success: false,
            error: 'Email already registered. Please login instead.'
          });
        }
        
        // Clean old OTPs 
        const deletedCount = await OTP.destroy({ where: { email } });
        if (deletedCount > 0) {
          console.log(`   ♻️  Cleaned up ${deletedCount} old OTP(s) for this email`);
        }
        
        // Generate new OTP
        const otp = crypto.randomInt(100000, 999999).toString();
        const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
        
        await OTP.create({
          email,
          otp,
          expiresAt,
        });
        
        console.log(`   ✅ OTP Generated: ${otp}`);
        console.log(`   ⏰ Expires at: ${expiresAt.toLocaleTimeString()}`);
        console.log(`   📧 Email mode: ${currentEmailMode.toUpperCase()}`);
        
        // Send email
        const emailResult = await sendOtpEmail(email, otp);
        
        // Prepare response based on email mode
        let responseMessage = '';
        let additionalData = {};
        
        if (currentEmailMode === 'console') {
          responseMessage = `OTP generated successfully. Check server console for code: ${otp}`;
          additionalData = { otp, mode: 'console', note: 'Check server console for OTP code' };
        } else if (currentEmailMode === 'ethereal') {
          responseMessage = 'OTP sent to test email. Check Ethereal inbox for verification code.';
          if (emailResult.info && emailResult.info.messageId) {
            additionalData = { 
              mode: 'ethereal',
              note: 'Check Ethereal email preview URL in server console'
            };
          }
        } else {
          responseMessage = emailResult.success 
            ? 'Verification code sent to your email' 
            : 'OTP generated but email delivery failed. Check server logs.';
          additionalData = { mode: 'smtp', emailSuccess: emailResult.success };
        }
        
        console.log(`   📨 Email result: ${emailResult.success ? 'SUCCESS' : 'FAILED'}`);
        console.log('='.repeat(60));
        
        res.json({
          success: true,
          message: responseMessage,
          expiresIn: 600, 
          ...additionalData
        });
        
      } catch (error) {
        console.error('❌ OTP generation error:', error);
        console.error('   Stack:', error.stack);
        res.status(500).json({
          success: false,
          error: 'Server error during OTP generation'
        });
      }
    });
    
    // Verify OTP endpoint
    app.post('/api/auth/verify-otp', async (req, res) => {
      try {
        const { email, otp } = req.body;
        
        console.log('\n' + '='.repeat(60));
        console.log('🔍 OTP VERIFICATION REQUEST');
        console.log('='.repeat(60));
        console.log(`   Email: ${email}`);
        console.log(`   OTP: ${otp}`);
        console.log(`   Time: ${new Date().toISOString()}`);
        
        if (!email || !otp) {
          console.log('❌ Validation failed: Email and OTP are required');
          return res.status(400).json({
            success: false,
            error: 'Email and OTP are required'
          });
        }
        
        if (otp.length !== 6 || !/^\d+$/.test(otp)) {
          console.log('❌ Validation failed: Invalid OTP format');
          return res.status(400).json({
            success: false,
            error: 'Invalid OTP format. Must be 6 digits.'
          });
        }
        
        const otpRecord = await OTP.findOne({
          where: { email },
          order: [['createdAt', 'DESC']]
        });
        
        if (!otpRecord) {
          console.log('❌ No OTP record found for this email');
          return res.status(400).json({
            success: false,
            error: 'No verification request found for this email'
          });
        }
        
        if (new Date() > otpRecord.expiresAt) {
          console.log('❌ OTP has expired');
          await otpRecord.destroy();
          return res.status(400).json({
            success: false,
            error: 'Verification code has expired. Please request a new one.'
          });
        }
        
        if (otpRecord.otp !== otp) {
          otpRecord.attempts += 1;
          await otpRecord.save();
          
          console.log(`❌ Invalid OTP. Attempt ${otpRecord.attempts}/3`);
          
          return res.status(400).json({
            success: false,
            error: 'Invalid verification code',
            attemptsRemaining: 3 - otpRecord.attempts
          });
        }
        
        otpRecord.verified = true;
        await otpRecord.save();
        
        console.log('✅ OTP verified successfully');
        console.log('='.repeat(60));
        
        res.json({
          success: true,
          message: 'Email verified successfully!',
          verified: true,
        });
        
      } catch (error) {
        console.error('❌ OTP verification error:', error);
        res.status(500).json({
          success: false,
          error: 'Server error during OTP verification'
        });
      }
    });
    
    // Register endpoint 
    app.post('/api/auth/register', async (req, res) => {
      try {
        const { email, password, name } = req.body;
        
        console.log('\n📝 Registration attempt for:', email);
        
        if (!email || !password || !name) {
          return res.status(400).json({
            success: false,
            error: 'All fields are required'
          });
        }
        
        if (password.length < 6) {
          return res.status(400).json({
            success: false,
            error: 'Password must be at least 6 characters'
          });
        }
        
        // Check OTP verification
        const verifiedOtp = await OTP.findOne({
          where: {
            email,
            verified: true,
          }
        });
        
        if (!verifiedOtp) {
          return res.status(400).json({
            success: false,
            error: 'Email verification required. Please verify your email first.'
          });
        }
        
        // Check existing user
        const existingUser = await User.findOne({ where: { email } });
        if (existingUser) {
          await OTP.destroy({ where: { email } });
          return res.status(400).json({
            success: false,
            error: 'User already exists. Please login instead.'
          });
        }
        
        // Create user
        const user = await User.create({
          email,
          password,
          name,
          isEmailVerified: true,
        });
        
        // Clean OTP
        await OTP.destroy({ where: { email } });
        
        const token = generateToken(user.id);
        
        console.log('✅ Registration successful for:', email);
        
        res.status(201).json({
          success: true,
          message: 'Registration successful!',
          token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            isEmailVerified: user.isEmailVerified,
          }
        });
        
      } catch (error) {
        console.error('❌ Registration error:', error);
        res.status(500).json({
          success: false,
          error: 'Server error'
        });
      }
    });
    
    // Login endpoint 
    app.post('/api/auth/login', async (req, res) => {
      try {
        const { email, password } = req.body;
        
        console.log('\n🔐 Login attempt for:', email);
        
        if (!email || !password) {
          return res.status(400).json({
            success: false,
            error: 'Email and password are required'
          });
        }
        
        const user = await User.findOne({ where: { email } });
        
        if (!user) {
          console.log('❌ User not found:', email);
          return res.status(401).json({
            success: false,
            error: 'Invalid email or password'
          });
        }
        
        const isMatch = await bcrypt.compare(password, user.password);
        
        if (!isMatch) {
          return res.status(401).json({
            success: false,
            error: 'Invalid email or password'
          });
        }
        
        const token = generateToken(user.id);
        
        console.log('✅ Login successful for:', email);
        
        res.json({
          success: true,
          message: 'Login successful!',
          token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            isEmailVerified: user.isEmailVerified,
          }
        });
        
      } catch (error) {
        console.error('❌ Login error:', error);
        res.status(500).json({
          success: false,
          error: 'Server error'
        });
      }
    });
    
    // Forgot password endpoint 
    app.post('/api/auth/forgot-password', async (req, res) => {
      try {
        const { email } = req.body;
        
        console.log('\n🔑 Forgot password request for:', email);
        
        if (!email) {
          return res.status(400).json({
            success: false,
            error: 'Email is required'
          });
        }
        
        const user = await User.findOne({ where: { email } });
        
        if (!user) {
          console.log('📧 Reset request for non-existent email:', email);
          return res.json({
            success: true,
            message: 'If an account exists, password reset instructions have been sent to your email.'
          });
        }
        
        // Generate reset token
        const resetToken = crypto.randomBytes(32).toString('hex');
        
        console.log(`🔑 Reset token for ${email}: ${resetToken}`);
        console.log(`⏰ Token expires in 1 hour`);
        
        // Send reset email
        const resetUrl = `http://localhost:3000/reset-password?token=${resetToken}`;
        
        const html = `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #6C63FF, #00BFA6); padding: 30px; border-radius: 15px 15px 0 0; text-align: center;">
              <h1 style="color: white; margin: 0;">Password Reset</h1>
            </div>
            
            <div style="padding: 40px; background: white; border-radius: 0 0 15px 15px; border: 1px solid #e0e0e0; border-top: none;">
              <p>Hello ${user.name},</p>
              <p>You requested to reset your password for SmarTQue.</p>
              
              <div style="text-align: center; margin: 30px 0;">
                <a href="${resetUrl}" style="background: #6C63FF; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; display: inline-block; font-weight: bold;">
                  Reset Password
                </a>
              </div>
              
              <p style="color: #666;">This link will expire in 1 hour.</p>
            </div>
          </div>
        `;
        
        await sendEmail(email, 'Reset Your SmarTQue Password', html);
        
        res.json({
          success: true,
          message: 'Password reset instructions have been sent to your email.'
        });
        
      } catch (error) {
        console.error('❌ Forgot password error:', error);
        res.status(500).json({
          success: false,
          error: 'Server error'
        });
      }
    });
    
    // Get current user profile
    app.get('/api/auth/me', async (req, res) => {
      try {
        const token = req.headers.authorization?.split(' ')[1];
        
        if (!token) {
          return res.status(401).json({
            success: false,
            error: 'No authentication token provided'
          });
        }
        
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'smartque_dev_secret_2024');
        const user = await User.findByPk(decoded.id);
        
        if (!user) {
          return res.status(404).json({
            success: false,
            error: 'User not found'
          });
        }
        
        res.json({
          success: true,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            isEmailVerified: user.isEmailVerified,
          }
        });
        
      } catch (error) {
        console.error('❌ Profile error:', error);
        res.status(401).json({
          success: false,
          error: 'Invalid or expired token'
        });
      }
    });

    // APPOINTMENT ENDPOINTS
    
    // Book appointment
    app.post('/api/appointments/book', async (req, res) => {
      try {
        const token = req.headers.authorization?.split(' ')[1];
        
        if (!token) {
          return res.status(401).json({
            success: false,
            error: 'No authentication token provided'
          });
        }
        
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'smartque_dev_secret_2024');
        const { userId, doctorName, departmentName, dateTime, queueNumber, consultationFee } = req.body;
        
        if (!userId || !doctorName || !departmentName || !dateTime || !queueNumber) {
          return res.status(400).json({
            success: false,
            error: 'Missing required fields'
          });
        }
        
        const appointment = await Appointment.create({
          userId,
          doctorName,
          departmentName,
          dateTime,
          queueNumber,
          status: 'pending',
          consultationFee: consultationFee || 0,
        });
        
        res.status(201).json({
          success: true,
          appointment: appointment.toJSON(),
          message: 'Appointment booked successfully'
        });
        
      } catch (error) {
        console.error('❌ Book appointment error:', error);
        res.status(500).json({
          success: false,
          error: 'Failed to book appointment'
        });
      }
    });
    
    // Get user appointments
    app.get('/api/appointments/user/:userId', async (req, res) => {
      try {
        const token = req.headers.authorization?.split(' ')[1];
        
        if (!token) {
          return res.status(401).json({
            success: false,
            error: 'No authentication token provided'
          });
        }
        
        const { userId } = req.params;
        const appointments = await Appointment.findAll({
          where: { userId },
          order: [['dateTime', 'DESC']]
        });
        
        res.json({
          success: true,
          appointments: appointments.map(apt => apt.toJSON())
        });
        
      } catch (error) {
        console.error('❌ Get appointments error:', error);
        res.status(500).json({
          success: false,
          error: 'Failed to fetch appointments'
        });
      }
    });
    
    // Cancel appointment
    app.post('/api/appointments/cancel/:appointmentId', async (req, res) => {
      try {
        const token = req.headers.authorization?.split(' ')[1];
        
        if (!token) {
          return res.status(401).json({
            success: false,
            error: 'No authentication token provided'
          });
        }
        
        const { appointmentId } = req.params;
        const appointment = await Appointment.findByPk(appointmentId);
        
        if (!appointment) {
          return res.status(404).json({
            success: false,
            error: 'Appointment not found'
          });
        }
        
        await appointment.update({ status: 'cancelled' });
        
        res.json({
          success: true,
          message: 'Appointment cancelled successfully'
        });
        
      } catch (error) {
        console.error('❌ Cancel appointment error:', error);
        res.status(500).json({
          success: false,
          error: 'Failed to cancel appointment'
        });
      }
    });
    
    // Reschedule appointment
    app.post('/api/appointments/reschedule/:appointmentId', async (req, res) => {
      try {
        const token = req.headers.authorization?.split(' ')[1];
        
        if (!token) {
          return res.status(401).json({
            success: false,
            error: 'No authentication token provided'
          });
        }
        
        const { appointmentId } = req.params;
        const { dateTime } = req.body;
        
        if (!dateTime) {
          return res.status(400).json({
            success: false,
            error: 'New date/time is required'
          });
        }
        
        const appointment = await Appointment.findByPk(appointmentId);
        
        if (!appointment) {
          return res.status(404).json({
            success: false,
            error: 'Appointment not found'
          });
        }
        
        await appointment.update({ dateTime });
        
        res.json({
          success: true,
          appointment: appointment.toJSON(),
          message: 'Appointment rescheduled successfully'
        });
        
      } catch (error) {
        console.error('❌ Reschedule appointment error:', error);
        res.status(500).json({
          success: false,
          error: 'Failed to reschedule appointment'
        });
      }
    });
    
    // Get next queue number
    app.get('/api/appointments/next-queue', async (req, res) => {
      try {
        const { department, date } = req.query;
        
        const appointmentDate = new Date(date);
        const dayStart = new Date(appointmentDate);
        dayStart.setHours(0, 0, 0, 0);
        const dayEnd = new Date(appointmentDate);
        dayEnd.setHours(23, 59, 59, 999);
        
        const count = await Appointment.count({
          where: {
            departmentName: department,
            dateTime: {
              [Op.between]: [dayStart, dayEnd]
            },
            status: 'upcoming'
          }
        });
        
        const nextNumber = count + 1;
        
        res.json({
          success: true,
          queueNumber: nextNumber.toString()
        });
        
      } catch (error) {
        console.error('❌ Get next queue number error:', error);
        res.status(500).json({
          success: false,
          queueNumber: '1'
        });
      }
    });

    // Get current queue position for a specific appointment
    app.get('/api/appointments/queue-position/:appointmentId', async (req, res) => {
      try {
        const { appointmentId } = req.params;
        console.log(`   GET /api/appointments/queue-position/${appointmentId} requested`);
        console.log('   Authorization header:', req.headers.authorization || '<none>');
        
        const appointment = await Appointment.findByPk(appointmentId);
        if (!appointment) {
          return res.status(404).json({
            success: false,
            error: 'Appointment not found'
          });
        }

        // Count pending appointments scheduled BEFORE this appointment
        const queuePosition = await Appointment.count({
          where: {
            departmentName: appointment.departmentName,
            dateTime: {
              [Op.lte]: appointment.dateTime // Less than or equal to this appointment's time
            },
            status: 'upcoming',
            id: {
              [Op.lte]: appointment.id // If same time, count by appointment ID order
            }
          }
        });

        res.json({
          success: true,
          appointmentId,
          currentQueuePosition: queuePosition,
          status: appointment.status,
          department: appointment.departmentName
        });
        
      } catch (error) {
        console.error('❌ Get queue position error:', error);
        res.status(500).json({
          success: false,
          error: 'Failed to fetch queue position'
        });
      }
    });

    // -------------------- ADMIN MIDDLEWARE & ENDPOINTS --------------------
    // Auth middleware to verify token and attach user
    const authMiddleware = async (req, res, next) => {
      try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) return res.status(401).json({ success: false, error: 'No authentication token provided' });

        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'smartque_dev_secret_2024');
        const user = await User.findByPk(decoded.id);
        if (!user) return res.status(401).json({ success: false, error: 'Invalid token' });

        req.user = user;
        next();
      } catch (err) {
        console.error('❌ Auth middleware error:', err.message);
        return res.status(401).json({ success: false, error: 'Invalid or expired token' });
      }
    };

    // Admin guard
    const adminOnly = (req, res, next) => {
      const user = req.user;
      if (!user || user.role !== 'admin') {
        return res.status(403).json({ success: false, error: 'Admin access required' });
      }
      next();
    };

    // Get all users (admin)
    app.get('/api/admin/users', authMiddleware, adminOnly, async (req, res) => {
      try {
        const users = await User.findAll({ order: [['id', 'ASC']] });
        res.json({ success: true, users: users.map(u => ({ id: u.id, email: u.email, name: u.name, role: u.role, isEmailVerified: u.isEmailVerified })) });
      } catch (error) {
        console.error('❌ Admin get users error:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch users' });
      }
    });

    // Update user role (admin)
    app.patch('/api/admin/users/:id/role', authMiddleware, adminOnly, async (req, res) => {
      try {
        const { id } = req.params;
        const { role } = req.body;
        const allowed = ['user', 'admin', 'business'];
        if (!allowed.includes(role)) return res.status(400).json({ success: false, error: 'Invalid role' });

        const user = await User.findByPk(id);
        if (!user) return res.status(404).json({ success: false, error: 'User not found' });

        await user.update({ role });
        res.json({ success: true, message: 'User role updated', user: { id: user.id, email: user.email, role: user.role } });
      } catch (error) {
        console.error('❌ Admin update user role error:', error);
        res.status(500).json({ success: false, error: 'Failed to update role' });
      }
    });

    // Get all appointments (admin) with optional filters
    app.get('/api/admin/appointments', authMiddleware, adminOnly, async (req, res) => {
      try {
        const { status, date } = req.query;
        const where = {};
        if (status) where.status = status;
        if (date) {
          const appointmentDate = new Date(date);
          const dayStart = new Date(appointmentDate);
          dayStart.setHours(0,0,0,0);
          const dayEnd = new Date(appointmentDate);
          dayEnd.setHours(23,59,59,999);
          where.dateTime = { [Op.between]: [dayStart, dayEnd] };
        }
        const appointments = await Appointment.findAll({ where, order: [['dateTime', 'DESC']] });
        res.json({ success: true, appointments: appointments.map(a => a.toJSON()) });
      } catch (error) {
        console.error('❌ Admin get appointments error:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch appointments' });
      }
    });

    // Update appointment status (admin)
    app.patch('/api/admin/appointments/:id/status', authMiddleware, adminOnly, async (req, res) => {
      try {
        const { id } = req.params;
        const { status } = req.body;
        const allowed = ['pending', 'approved', 'rejected', 'upcoming', 'in_progress', 'completed', 'cancelled'];
        if (!allowed.includes(status)) return res.status(400).json({ success: false, error: 'Invalid status' });

        const appointment = await Appointment.findByPk(id);
        if (!appointment) return res.status(404).json({ success: false, error: 'Appointment not found' });

        await appointment.update({ status });
        res.json({ success: true, message: 'Appointment status updated', appointment: appointment.toJSON() });
      } catch (error) {
        console.error('❌ Admin update appointment status error:', error);
        res.status(500).json({ success: false, error: 'Failed to update appointment' });
      }
    });

    // ---------------- Admin Services (Departments) ----------------
    app.get('/api/admin/services', authMiddleware, adminOnly, async (req, res) => {
      try {
        const services = await Department.findAll({ order: [['name', 'ASC']] });
        res.json({ success: true, services: services.map(s => s.toJSON()) });
      } catch (error) {
        console.error('❌ Admin get services error:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch services' });
      }
    });

    app.post('/api/admin/services', authMiddleware, adminOnly, async (req, res) => {
      try {
        const { name, description } = req.body;
        if (!name) return res.status(400).json({ success: false, error: 'Name is required' });
        const service = await Department.create({ name, description });
        res.status(201).json({ success: true, service: service.toJSON() });
      } catch (error) {
        console.error('❌ Admin create service error:', error);
        res.status(500).json({ success: false, error: 'Failed to create service' });
      }
    });

    app.delete('/api/admin/services/:id', authMiddleware, adminOnly, async (req, res) => {
      try {
        const { id } = req.params;
        const service = await Department.findByPk(id);
        if (!service) return res.status(404).json({ success: false, error: 'Service not found' });
        await service.destroy();
        res.json({ success: true, message: 'Service deleted' });
      } catch (error) {
        console.error('❌ Admin delete service error:', error);
        res.status(500).json({ success: false, error: 'Failed to delete service' });
      }
    });

    // ---------------- Admin Counters ----------------
    app.get('/api/admin/counters', authMiddleware, adminOnly, async (req, res) => {
      try {
        const counters = await Counter.findAll({ include: [Department], order: [['id', 'ASC']] });
        res.json({ success: true, counters: counters.map(c => ({ ...c.toJSON(), department: c.Department ? c.Department.toJSON() : null })) });
      } catch (error) {
        console.error('❌ Admin get counters error:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch counters' });
      }
    });

    app.post('/api/admin/counters', authMiddleware, adminOnly, async (req, res) => {
      try {
        const { name, departmentId, isActive } = req.body;
        if (!name) return res.status(400).json({ success: false, error: 'Name is required' });
        const counter = await Counter.create({ name, departmentId: departmentId || null, isActive: isActive !== false });
        res.status(201).json({ success: true, counter: counter.toJSON() });
      } catch (error) {
        console.error('❌ Admin create counter error:', error);
        res.status(500).json({ success: false, error: 'Failed to create counter' });
      }
    });

    app.patch('/api/admin/counters/:id', authMiddleware, adminOnly, async (req, res) => {
      try {
        const { id } = req.params;
        const { isActive, name, departmentId } = req.body;
        const counter = await Counter.findByPk(id);
        if (!counter) return res.status(404).json({ success: false, error: 'Counter not found' });
        await counter.update({ isActive: isActive ?? counter.isActive, name: name ?? counter.name, departmentId: departmentId ?? counter.departmentId });
        res.json({ success: true, counter: counter.toJSON() });
      } catch (error) {
        console.error('❌ Admin update counter error:', error);
        res.status(500).json({ success: false, error: 'Failed to update counter' });
      }
    });

    // ---------------- Admin Reports ----------------
    app.get('/api/admin/reports/daily', authMiddleware, adminOnly, async (req, res) => {
      try {
        const today = new Date();
        const start = new Date(today); start.setHours(0,0,0,0);
        const end = new Date(today); end.setHours(23,59,59,999);

        const total = await Appointment.count({ where: { dateTime: { [Op.between]: [start, end] } } });
        const upcoming = await Appointment.count({ where: { dateTime: { [Op.between]: [start, end] }, status: 'upcoming' } });
        const completed = await Appointment.count({ where: { dateTime: { [Op.between]: [start, end] }, status: 'completed' } });
        const cancelled = await Appointment.count({ where: { dateTime: { [Op.between]: [start, end] }, status: 'cancelled' } });

        // counts per department
        const [deptCounts] = await sequelize.query(`SELECT departmentName, COUNT(*) as count FROM Appointments WHERE dateTime BETWEEN :start AND :end GROUP BY departmentName`, { replacements: { start, end } });

        res.json({ success: true, report: { total, upcoming, completed, cancelled, byDepartment: deptCounts } });
      } catch (error) {
        console.error('❌ Admin daily report error:', error);
        res.status(500).json({ success: false, error: 'Failed to generate report' });
      }
    });

    // Admin stats
    app.get('/api/admin/stats', authMiddleware, adminOnly, async (req, res) => {
      try {
        const usersCount = await User.count();
        const totalAppointments = await Appointment.count();
        const upcoming = await Appointment.count({ where: { status: 'upcoming' } });
        const completed = await Appointment.count({ where: { status: 'completed' } });
        const cancelled = await Appointment.count({ where: { status: 'cancelled' } });

        res.json({ success: true, stats: { usersCount, totalAppointments, upcoming, completed, cancelled } });
      } catch (error) {
        console.error('❌ Admin stats error:', error);
        res.status(500).json({ success: false, error: 'Failed to compute stats' });
      }
    });

    
    //M-PESA PAYMENT ENDPOINTS
    // STK Push for appointment payments
    app.post('/api/payments/mpesa/stkpush', async (req, res) => {
      try {
        const { phoneNumber, amount, accountReference, transactionDesc } =
          req.body;

        if (!phoneNumber || !amount) {
          return res.status(400).json({
            success: false,
            error: 'phoneNumber and amount are required',
          });
        }

        const stkResponse = await initiateStkPush({
          amount,
          phoneNumber,
          accountReference,
          transactionDesc,
        });

        return res.json({
          success: true,
          message: 'STK push initiated',
          data: stkResponse,
        });
      } catch (error) {
        console.error('❌ M-Pesa STK error:', error);
        return res.status(500).json({
          success: false,
          error: error.message || 'Failed to initiate M-Pesa payment',
        });
      }
    });

    // Callback endpoin
    // to edit later bofore productio
    app.post('/api/payments/mpesa/callback', (req, res) => {
      console.log('📲 M-Pesa Callback received:', JSON.stringify(req.body));
      res.json({
        ResultCode: 0,
        ResultDesc: 'Callback received successfully',
      });
    });
    
    
    //START SERVER
    app.listen(PORT, () => {
      console.log('\n' + '='.repeat(70));
      console.log('🚀 SmarTQue Backend Server (NodeMailer Version)');
      console.log('='.repeat(70));
      console.log(`📡 Server running on: http://localhost:${PORT}`);
      console.log(`🔍 Health check: http://localhost:${PORT}/api/health`);
      console.log(`📧 Email mode: ${currentEmailMode.toUpperCase()}`);
      
      if (currentEmailMode === 'console') {
        console.log('💡 OTPs will be displayed in console for testing');
      } else if (currentEmailMode === 'ethereal') {
        console.log('💡 Check server logs for Ethereal email preview URLs');
      }
      
      console.log('\n📋 Available Endpoints:');
      console.log('   POST /api/auth/login');
      console.log('   POST /api/auth/register');
      console.log('   POST /api/auth/generate-otp');
      console.log('   POST /api/auth/verify-otp');
      console.log('   POST /api/auth/forgot-password');
      console.log('   GET  /api/auth/me');
      console.log('   POST /api/appointments/book');
      console.log('   GET  /api/appointments/user/:userId');
      console.log('   POST /api/appointments/cancel/:appointmentId');
      console.log('   POST /api/appointments/reschedule/:appointmentId');
      console.log('   GET  /api/appointments/next-queue');
      console.log('   GET  /api/health');
      console.log('='.repeat(70) + '\n');
      
      console.log('💡 Test Registration Flow:');
      console.log('1. POST /api/auth/generate-otp with email');
      console.log('2. POST /api/auth/verify-otp with email and OTP');
      console.log('3. POST /api/auth/register with email, password, name\n');
      
      console.log('⚠️  For SMTP configuration, set these environment variables:');
      console.log('   SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS');
      console.log('   EMAIL_FROM, EMAIL_FROM_NAME');
    });
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    console.error('Stack trace:', error.stack);
    process.exit(1);
  }
}

startServer();