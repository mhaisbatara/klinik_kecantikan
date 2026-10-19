import { formatDateSystem } from "./date_tools.js";
import { status } from "./general.js";

/**
 * Standard Success Response helper
 */
export const sendSuccess = (res, message = "Success", data = null, statusCode = 200) => {
  const response = {
    status: status.SUKSES,
    message,
    datetime: formatDateSystem(),
  };

  if (data !== null && data !== undefined) {
    response.data = data;
  }

  return res.status(statusCode).json(response);
};

/**
 * Standard Error Response helper
 */
export const sendError = (
  res,
  message = "Terjadi kesalahan",
  statusCode = 400,
  statusVal = status.GAGAL,
  errors = null
) => {
  const response = {
    status: statusVal,
    message,
    datetime: formatDateSystem(),
  };

  if (errors) {
    response.errors = errors;
  }

  return res.status(statusCode).json(response);
};
