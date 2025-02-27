const express = require('express');
const axios = require('axios');
const app = express();

const ZEPTOMAIL_API_KEY = process.env.ZEPTOMAIL_API_KEY;
const cors = require('cors');

app.use(cors({
    origin: function (origin, callback) {
      // Allow requests with no origin (like mobile apps or curl) or origins starting with http://localhost:
      if (!origin || origin.startsWith('http://localhost:')) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true
  }));
app.use(express.json());

app.post('/send-email', async (req, res) => {
  try {
    const response = await axios.post('https://api.zeptomail.com/v1.1/email', req.body, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': `Zoho-enczapikey ${ZEPTOMAIL_API_KEY}`
      }
    });
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('Server started on port 3000');
});