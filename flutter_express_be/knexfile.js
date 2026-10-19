import "dotenv/config";

const knexConfig = {
  development: {
    client: process.env.DB_DBMS || "mysql2",
    connection: {
      host: process.env.DB_HOST || "127.0.0.1",
      port: Number(process.env.DB_PORT) || 3306,
      user: process.env.DB_USERNAME || "root",
      password: process.env.DB_PASSWORD !== undefined ? process.env.DB_PASSWORD : "",
      database: process.env.DB_DATABASE || "db_klinik_kecantikan",
      timezone: "+00:00",
      dateStrings: false,
      multipleStatements: true,
    },
    pool: {
      min: 2,
      max: 20,
      idleTimeoutMillis: 30000,
    },
  },
  production: {
    client: process.env.DB_DBMS || "mysql2",
    connection: {
      host: process.env.DB_HOST || "127.0.0.1",
      port: Number(process.env.DB_PORT) || 3306,
      user: process.env.DB_USERNAME || "root",
      password: process.env.DB_PASSWORD !== undefined ? process.env.DB_PASSWORD : "",
      database: process.env.DB_DATABASE || "db_klinik_kecantikan",
      timezone: "+00:00",
      dateStrings: false,
      multipleStatements: true,
    },
    pool: {
      min: 2,
      max: 20,
      idleTimeoutMillis: 30000,
    },
  },
};

export default knexConfig;
