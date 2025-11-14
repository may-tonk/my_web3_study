require('dotenv').config();
const ethers = require('ethers');
// Get Alchemy API Key
const API_KEY = process.env.API_KEY;
// Define an Alchemy Provider
const provider = new ethers.providers.AlchemyProvider('sepolia', API_KEY)