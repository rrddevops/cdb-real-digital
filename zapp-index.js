const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
let db;
const connectDB = async () => {
  try {
    const client = new MongoClient(process.env.MONGO_URL || 'mongodb://admin:admin@mongodb:27017');
    await client.connect();
    db = client.db('zapp_db');
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
  }
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'ZApp',
    timestamp: new Date().toISOString(),
    environment: {
      ESCROW_SHIELD_ADDRESS: process.env.ESCROW_SHIELD_ADDRESS,
      ERC20_ADDRESS: process.env.ERC20_ADDRESS,
      ZOKRATES_URL: process.env.ZOKRATES_URL,
      TIMBER_URL: process.env.TIMBER_URL,
      RPC_URL: process.env.RPC_URL
    }
  });
});

// Get all commitments
app.get('/getAllCommitments', async (req, res) => {
  try {
    if (!db) {
      return res.status(500).json({ error: 'Database not connected' });
    }
    
    const commitments = await db.collection('commitments').find({}).toArray();
    res.json({
      status: 'success',
      data: commitments,
      count: commitments.length
    });
  } catch (error) {
    console.error('Error getting commitments:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Deposit ERC20
app.post('/depositErc20', async (req, res) => {
  try {
    const { amount, account } = req.body;
    
    if (!amount || !account) {
      return res.status(400).json({ error: 'Amount and account are required' });
    }

    // Simulate deposit operation
    const deposit = {
      id: Date.now(),
      type: 'ERC20_DEPOSIT',
      amount: amount,
      account: account,
      timestamp: new Date().toISOString(),
      status: 'completed'
    };

    if (db) {
      await db.collection('deposits').insertOne(deposit);
    }

    res.json({
      status: 'success',
      message: 'ERC20 deposit completed',
      data: deposit
    });
  } catch (error) {
    console.error('Error depositing ERC20:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Deposit ERC1155
app.post('/depositErc1155', async (req, res) => {
  try {
    const { tokenId, amount, account } = req.body;
    
    if (!tokenId || !amount || !account) {
      return res.status(400).json({ error: 'TokenId, amount and account are required' });
    }

    // Simulate deposit operation
    const deposit = {
      id: Date.now(),
      type: 'ERC1155_DEPOSIT',
      tokenId: tokenId,
      amount: amount,
      account: account,
      timestamp: new Date().toISOString(),
      status: 'completed'
    };

    if (db) {
      await db.collection('deposits').insertOne(deposit);
    }

    res.json({
      status: 'success',
      message: 'ERC1155 deposit completed',
      data: deposit
    });
  } catch (error) {
    console.error('Error depositing ERC1155:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Transfer
app.post('/transfer', async (req, res) => {
  try {
    const { to, amount } = req.body;
    
    if (!to || !amount) {
      return res.status(400).json({ error: 'To address and amount are required' });
    }

    // Simulate transfer operation
    const transfer = {
      id: Date.now(),
      type: 'TRANSFER',
      to: to,
      amount: amount,
      timestamp: new Date().toISOString(),
      status: 'completed'
    };

    if (db) {
      await db.collection('transfers').insertOne(transfer);
    }

    res.json({
      status: 'success',
      message: 'Transfer completed',
      data: transfer
    });
  } catch (error) {
    console.error('Error transferring:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start swap from ERC20 to ERC1155
app.post('/startSwapFromErc20ToErc1155', async (req, res) => {
  try {
    const { erc20Address, counterParty, amountSent, tokenIdReceived, tokenReceivedAmount } = req.body;
    
    if (!erc20Address || !counterParty || !amountSent || !tokenIdReceived || !tokenReceivedAmount) {
      return res.status(400).json({ error: 'All swap parameters are required' });
    }

    // Simulate swap operation
    const swap = {
      id: Date.now(),
      type: 'SWAP_ERC20_TO_ERC1155',
      erc20Address: erc20Address,
      counterParty: counterParty,
      amountSent: amountSent,
      tokenIdReceived: tokenIdReceived,
      tokenReceivedAmount: tokenReceivedAmount,
      timestamp: new Date().toISOString(),
      status: 'pending'
    };

    if (db) {
      await db.collection('swaps').insertOne(swap);
    }

    res.json({
      status: 'success',
      message: 'Swap started',
      data: swap
    });
  } catch (error) {
    console.error('Error starting swap:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Complete swap
app.post('/completeSwapFromErc20ToErc1155', async (req, res) => {
  try {
    const { swapId } = req.body;
    
    if (!swapId) {
      return res.status(400).json({ error: 'SwapId is required' });
    }

    // Simulate swap completion
    const completion = {
      id: Date.now(),
      swapId: swapId,
      type: 'SWAP_COMPLETION',
      timestamp: new Date().toISOString(),
      status: 'completed'
    };

    if (db) {
      await db.collection('swaps').updateOne(
        { id: parseInt(swapId) },
        { $set: { status: 'completed' } }
      );
      await db.collection('completions').insertOne(completion);
    }

    res.json({
      status: 'success',
      message: 'Swap completed',
      data: completion
    });
  } catch (error) {
    console.error('Error completing swap:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'CBD Real Digital - ZApp Service',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      getAllCommitments: '/getAllCommitments',
      depositErc20: '/depositErc20',
      depositErc1155: '/depositErc1155',
      transfer: '/transfer',
      startSwapFromErc20ToErc1155: '/startSwapFromErc20ToErc1155',
      completeSwapFromErc20ToErc1155: '/completeSwapFromErc20ToErc1155'
    }
  });
});

// Start server
const startServer = async () => {
  await connectDB();
  
  app.listen(PORT, () => {
    console.log(`🚀 ZApp service running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
    console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  });
};

startServer().catch(console.error); 