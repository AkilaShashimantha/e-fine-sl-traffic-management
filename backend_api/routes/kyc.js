/**
 * routes/kyc.js
 * ─────────────────────────────────────────────────────────────────────────────
 * KYC Face Verification Route — e-Fine SL Backend
 *
 * POST /api/kyc/verify
 *   Accepts multipart/form-data with:
 *     • license  — driving license front photo (any common image format)
 *     • selfie   — live selfie photo (any common image format)
 *
 *   Returns:
 *     { verified: boolean, score: number (0–100), distance: number }
 *
 * Algorithm:
 *   1. Load images into canvas buffers.
 *   2. Detect a face in each image using SSD MobileNet v1.
 *   3. Extract 128-D face descriptor using FaceRecognitionNet.
 *   4. Compute Euclidean distance between the two descriptors.
 *   5. verified = distance < THRESHOLD (0.6).
 *
 * Dependencies (install with):
 *   npm install @vladmandic/face-api canvas multer
 * ─────────────────────────────────────────────────────────────────────────────
 */

const express = require('express');
const router  = express.Router();
const multer  = require('multer');
const path    = require('path');

// ── canvas must be required BEFORE face-api ───────────────────────────────────
const { createCanvas, loadImage, Canvas, Image, ImageData } = require('canvas');

// ── face-api with Node.js (canvas) back-end (using WASM) ─────────────────────
const faceapi = require('@vladmandic/face-api/dist/face-api.node-wasm.js');
faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

// ── Configuration ─────────────────────────────────────────────────────────────
const MODELS_PATH = path.join(__dirname, '..', 'face_models');
const THRESHOLD   = 0.5; // Euclidean distance threshold: < 0.5 = same person
let modelsLoaded  = false;

// ── Multer — in-memory storage (no disk writes) ───────────────────────────────
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB per file
  fileFilter: (_req, file, cb) => {
    // Check file extension (primary check — mobile clients don't always send correct MIME)
    const allowedExt = /\.(jpe?g|png|webp)$/i;
    const extOk = allowedExt.test(file.originalname);

    // Accept common image MIME types + application/octet-stream (Flutter mobile default)
    const allowedMime = ['image/jpeg', 'image/png', 'image/webp', 'application/octet-stream'];
    const mimeOk = allowedMime.includes(file.mimetype);

    console.log(`[KYC] File filter: name=${file.originalname}, mime=${file.mimetype}, extOk=${extOk}, mimeOk=${mimeOk}`);

    (extOk && mimeOk)
      ? cb(null, true)
      : cb(new Error(`Only JPEG/PNG/WebP images are accepted (got: ${file.originalname}, mime: ${file.mimetype})`));
  },
});

// ── Load face-api models once at startup ──────────────────────────────────────
async function loadModels() {
  if (modelsLoaded) return;

  // Point face-api at the canvas environment
  await faceapi.tf.setBackend('wasm');
  await faceapi.tf.ready(); // Wait for WASM backend to initialize
  
  await faceapi.nets.ssdMobilenetv1.loadFromDisk(MODELS_PATH);
  await faceapi.nets.faceLandmark68Net.loadFromDisk(MODELS_PATH);
  await faceapi.nets.faceRecognitionNet.loadFromDisk(MODELS_PATH);

  modelsLoaded = true;
  console.log('[KYC] face-api models loaded from', MODELS_PATH);
}

// Boot model loading immediately when this module is required
loadModels().catch((err) =>
  console.error('[KYC] Model load error (server will retry on first request):', err.message)
);

// ── Helper: buffer → canvas Image → face descriptor ──────────────────────────
async function getDescriptor(imageBuffer) {
  const img    = await loadImage(imageBuffer);           // canvas loadImage
  const canvas = createCanvas(img.width, img.height);
  const ctx    = canvas.getContext('2d');
  ctx.drawImage(img, 0, 0);

  // Detect the single best face and compute its descriptor
  const detection = await faceapi
    .detectSingleFace(canvas, new faceapi.SsdMobilenetv1Options({ minConfidence: 0.5 }))
    .withFaceLandmarks()
    .withFaceDescriptor();

  return detection || null; // null → no face found
}

// ── Helper: Euclidean distance between two Float32Array descriptors ───────────
function euclideanDistance(a, b) {
  let sum = 0;
  for (let i = 0; i < a.length; i++) {
    sum += (a[i] - b[i]) ** 2;
  }
  return Math.sqrt(sum);
}

// ── POST /api/kyc/verify ──────────────────────────────────────────────────────
router.post(
  '/verify',
  upload.fields([
    { name: 'license', maxCount: 1 },
    { name: 'selfie',  maxCount: 1 },
  ]),
  async (req, res) => {
    console.log('[KYC] Incoming request:', {
      timestamp: new Date().toISOString(),
      method: req.method,
      path: req.path,
      hasFiles: !!req.files,
      licenseName: req.files?.license?.[0]?.originalname,
      selfieName: req.files?.selfie?.[0]?.originalname,
      contentType: req.headers['content-type'],
    });

    try {
      // ── Ensure models are loaded (retry if boot-time load failed) ───────────
      if (!modelsLoaded) {
        await loadModels();
      }

      // ── Validate uploaded files ─────────────────────────────────────────────
      const licenseFile = req.files?.license?.[0];
      const selfieFile  = req.files?.selfie?.[0];

      if (!licenseFile) {
        console.warn('[KYC] Missing field: license');
        return res.status(400).json({ success: false, message: 'Missing field: license' });
      }
      if (!selfieFile) {
        console.warn('[KYC] Missing field: selfie');
        return res.status(400).json({ success: false, message: 'Missing field: selfie' });
      }
      
      console.log('[KYC] Starting face detection...', {
        licenseSizeMB: (licenseFile.size / (1024 * 1024)).toFixed(2),
        selfieSizeMB: (selfieFile.size / (1024 * 1024)).toFixed(2),
      });

      // ── Extract face descriptors ────────────────────────────────────────────
      const [licenseDetection, selfieDetection] = await Promise.all([
        getDescriptor(licenseFile.buffer),
        getDescriptor(selfieFile.buffer),
      ]);

      if (!licenseDetection) {
        return res.status(422).json({
          success: false,
          verified: false,
          message: 'No face detected in the license photo. Please upload a clear front-facing photo.',
        });
      }

      if (!selfieDetection) {
        return res.status(422).json({
          success: false,
          verified: false,
          message: 'No face detected in the selfie. Please retake with better lighting.',
        });
      }

      // ── Compute similarity ──────────────────────────────────────────────────
      const distance = euclideanDistance(
        licenseDetection.descriptor,
        selfieDetection.descriptor,
      );

      const verified = distance < THRESHOLD;

      // Normalise distance to a 0–100 "match score" (100 = perfect match)
      const score = Math.max(0, Math.min(100, Math.round((1 - distance) * 100)));

      console.log(`[KYC] Distance: ${distance.toFixed(4)} | Verified: ${verified}`);

      return res.status(200).json({
        success:  true,
        verified,
        score,
        distance: parseFloat(distance.toFixed(4)),
      });

      } catch (err) {
      console.error('[KYC] Verification error details:', {
        message: err.message,
        stack: err.stack,
        timestamp: new Date().toISOString()
      });
      return res.status(500).json({
        success: false,
        message: 'Face verification failed due to a server error.',
        error:   err.message,
      });
    }
  }
);

module.exports = router;
