import knex from "knex";
import knexConfig from "../../knexfile.js";

const environment = process.env.NODE_ENV || "development";
const config = knexConfig[environment] || knexConfig.development;

const DB = knex(config);

export default DB;
