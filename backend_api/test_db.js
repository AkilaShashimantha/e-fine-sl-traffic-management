require('dotenv').config();
const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        console.log('Attempting to connect to MongoDB...');
        console.log('URI:', process.env.MONGO_URI);
        const conn = await mongoose.connect(process.env.MONGO_URI);
        console.log(`MongoDB Connected: ${conn.connection.host}`);

        // Try a simple operation
        const collections = await mongoose.connection.db.listCollections().toArray();
        console.log('Collections:', collections.map(c => c.name));

        process.exit(0);
    } catch (error) {
        console.error(`Error: ${error.message}`);
        console.error(error);
        process.exit(1);
    }
};

connectDB();
