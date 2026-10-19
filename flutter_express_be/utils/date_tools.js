import { format } from "date-fns";
import { toZonedTime } from "date-fns-tz";

export const formatDateSystem = (
  date = new Date(),
  pattern = "yyyy-MM-dd HH:mm:ss",
  tz = process.env.APP_TZ || "Asia/Jakarta"
) => {
  try {
    const validDate = date instanceof Date ? date : new Date(date);
    if (isNaN(validDate.getTime())) {
      return format(new Date(), pattern);
    }
    const zonedDate = toZonedTime(validDate, tz);
    return format(zonedDate, pattern);
  } catch (err) {
    return format(new Date(), pattern);
  }
};
