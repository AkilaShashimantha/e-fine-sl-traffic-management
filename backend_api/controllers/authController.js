const Station = require('../models/stationModel');
const Verification = require('../models/verificationModel');
const sendEmail = require('../utils/sendEmail');

// @desc    Request OTP for Police Registration
// @route   POST /api/auth/request-verification
// @access  Public
const requestVerification = async (req, res) => {
  const { badgeNumber, stationCode } = req.body;

  try {
   
    const station = await Station.findOne({ stationCode });

    if (!station) {
      return res.status(404).json({ message: 'Police Station not found' });
    }

    
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    
    await Verification.deleteMany({ badgeNumber });

    
    await Verification.create({
      badgeNumber,
      stationCode,
      otp, 
    });

    
const htmlMessage = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
        
        <div style="background-color: #003366; padding: 20px; text-align: center;">
          <h2 style="color: #ffffff; margin: 0;">E-Fine SL Verification</h2>
        </div>

        <div style="padding: 20px; background-color: #ffffff;">
          <p style="font-size: 16px; color: #333;">Dear OIC,</p>
          <p style="font-size: 16px; color: #333;">The following officer has requested official registration access:</p>
          
          <table style="width: 100%; margin-bottom: 20px; background-color: #f9f9f9; padding: 10px; border-radius: 5px;">
            <tr>
              <td style="font-weight: bold; color: #555; padding: 5px;">Badge ID:</td>
              <td style="font-weight: bold; color: #000; padding: 5px;">${badgeNumber}</td>
            </tr>
            <tr>
              <td style="font-weight: bold; color: #555; padding: 5px;">Station:</td>
              <td style="font-weight: bold; color: #000; padding: 5px;">${station.name}</td>
            </tr>
          </table>

          <div style="text-align: center; margin: 30px 0;">
            <p style="margin: 0; font-size: 14px; color: #777;">VERIFICATION CODE (OTP)</p>
            <h1 style="margin: 10px 0; font-size: 40px; color: #003366; letter-spacing: 5px; font-weight: bold;">
              ${otp}
            </h1>
          </div>

          <p style="color: #d9534f; font-size: 14px; text-align: center; font-weight: bold;">
            ⚠️ Please verify the officer's identity before providing this code.
          </p>
        </div>

        <div style="background-color: #eeeeee; padding: 10px; text-align: center; font-size: 12px; color: #777;">
          © 2025 E-Fine SL Project | Secure Verification System
        </div>
      </div>
    `;


    await sendEmail({
      email: station.officialEmail,
      subject: 'Action Required: Officer Verification Code',
      message: `Your Verification Code is: ${otp}`, 
      html: htmlMessage, 
    });

    res.status(200).json({ success: true, message: `Verification code sent to OIC of ${station.name}` });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = { requestVerification };