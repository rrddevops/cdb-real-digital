const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 80;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB connection
let db;
const connectDB = async () => {
  try {
    const client = new MongoClient(process.env.DB_URL || 'mongodb://admin:admin@mongodb:27017');
    await client.connect();
    db = client.db('merkle_tree');
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
  }
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'Timber',
    timestamp: new Date().toISOString(),
    environment: {
      RPC_URL: process.env.RPC_URL,
      LOG_LEVEL: process.env.LOG_LEVEL,
      HASH_TYPE: process.env.HASH_TYPE,
      UNIQUE_LEAVES: process.env.UNIQUE_LEAVES,
      ESCROW_SHIELD_ADDRESS: process.env.ESCROW_SHIELD_ADDRESS
    }
  });
});

// Start timber service
app.post('/start', async (req, res) => {
  try {
    const { contractName, contractAddress, block } = req.body;
    
    if (!contractName || !contractAddress) {
      return res.status(400).json({ error: 'Contract name and address are required' });
    }

    // Simulate timber start
    const timberStart = {
      id: Date.now(),
      contractName: contractName,
      contractAddress: contractAddress,
      block: block || 'latest',
      timestamp: new Date().toISOString(),
      status: 'started'
    };

    if (db) {
      await db.collection('timber_starts').insertOne(timberStart);
    }

    res.json({
      status: 'success',
      message: 'Timber service started',
      data: timberStart
    });
  } catch (error) {
    console.error('Error starting timber:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get nodes
app.get('/nodes', async (req, res) => {
  try {
    const { contractName, contractAddress } = req.query;
    
    if (!contractName || !contractAddress) {
      return res.status(400).json({ error: 'Contract name and address are required' });
    }

    // Simulate nodes data
    const nodes = [
      {
        id: 1,
        contractName: contractName,
        contractAddress: contractAddress,
        nodeType: 'leaf',
        hash: '0x1234567890abcdef...',
        timestamp: new Date().toISOString()
      },
      {
        id: 2,
        contractName: contractName,
        contractAddress: contractAddress,
        nodeType: 'branch',
        hash: '0xabcdef1234567890...',
        timestamp: new Date().toISOString()
      }
    ];

    res.json({
      status: 'success',
      data: nodes,
      count: nodes.length
    });
  } catch (error) {
    console.error('Error getting nodes:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get metadata
app.get('/metadata', async (req, res) => {
  try {
    const metadata = {
      version: '1.0.0',
      service: 'Timber',
      hashType: process.env.HASH_TYPE || 'mimc',
      uniqueLeaves: process.env.UNIQUE_LEAVES === 'true',
      timestamp: new Date().toISOString()
    };

    res.json({
      status: 'success',
      data: metadata
    });
  } catch (error) {
    console.error('Error getting metadata:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get root
app.get('/root', async (req, res) => {
  try {
    const { contractName, contractAddress } = req.query;
    
    if (!contractName || !contractAddress) {
      return res.status(400).json({ error: 'Contract name and address are required' });
    }

    // Simulate root data
    const root = {
      contractName: contractName,
      contractAddress: contractAddress,
      rootHash: '0x9876543210fedcba...',
      timestamp: new Date().toISOString(),
      blockNumber: 12345
    };

    res.json({
      status: 'success',
      data: root
    });
  } catch (error) {
    console.error('Error getting root:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get leaves
app.get('/leaves', async (req, res) => {
  try {
    const { contractName, contractAddress } = req.query;
    
    if (!contractName || !contractAddress) {
      return res.status(400).json({ error: 'Contract name and address are required' });
    }

    // Simulate leaves data
    const leaves = [
      {
        id: 1,
        contractName: contractName,
        contractAddress: contractAddress,
        leafHash: '0x1111111111111111...',
        data: 'leaf_data_1',
        timestamp: new Date().toISOString()
      },
      {
        id: 2,
        contractName: contractName,
        contractAddress: contractAddress,
        leafHash: '0x2222222222222222...',
        data: 'leaf_data_2',
        timestamp: new Date().toISOString()
      }
    ];

    res.json({
      status: 'success',
      data: leaves,
      count: leaves.length
    });
  } catch (error) {
    console.error('Error getting leaves:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'CBD Real Digital - Timber Service',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      start: '/start',
      nodes: '/nodes',
      metadata: '/metadata',
      root: '/root',
      leaves: '/leaves'
    }
  });
});

// Start server
const startServer = async () => {
  await connectDB();
  
  app.listen(PORT, () => {
    console.log(`🚀 Timber service running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
    console.log(`🌐 Environment: ${process.env.NODE_ENV || 'development'}`);
  });
};

startServer().catch(console.error); 