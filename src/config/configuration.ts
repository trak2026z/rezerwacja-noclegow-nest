// src/config/configuration.ts
export default () => {
  const port = Number(process.env.PORT ?? 3000);
  const dbUri =
    process.env.MONGODB_URI ||
    process.env.MONGO_URI ||
    'mongodb://localhost:27017/rezerwacje';

  return {
    environment: process.env.NODE_ENV || 'development',
    port,
    database: {
      uri: dbUri,
    },
    jwt: {
      secret: process.env.JWT_SECRET || 'fallback_secret',
      expiresIn: process.env.JWT_EXPIRATION || '24h',
    },
    cors: {
      origin: process.env.CORS_ORIGIN || '*',
    },
  };
};
