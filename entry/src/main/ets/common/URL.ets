// 服务器URL逻辑
// 需根据自己配置的数据库自定义
export const loginUrl = "http://xxx/api/collections/users/auth-with-password"
export const billBaseURL = "http://xxx/api/collections/Bill/records";

function getToday() {
  const calendar = new Date();
  const options: Intl.DateTimeFormatOptions = { year: 'numeric', month: '2-digit', day: '2-digit' };
  const dayFormat = new Intl.DateTimeFormat('en-US', options);

  // 使用 formatToParts 获取日期部分
  const parts = dayFormat.formatToParts(calendar);
  // 明确声明类型并初始化
  let month: string = '';
  let day: string = '';
  let year: string = '';

  // 遍历日期部分，赋值
  for (const part of parts) {
    if (part.type === 'year') {
      year = part.value;
    } else if (part.type === 'month') {
      month = part.value;
    } else if (part.type === 'day') {
      day = part.value;
    }
  }

  // 确保所有变量都已赋值
  if (!year || !month || !day) {
    throw new Error('Date parts are not fully defined');
  }
  return `${year}-${month}-${day}`;
}

export function getTodayBillUrl(username: string) {
  const billFilter = encodeURIComponent(`(userName='${username}' && transactionDate>='${getToday()}')`);
  const billPerPage = encodeURIComponent("9999");
  const billSort = encodeURIComponent("-transactionDate");

  return `${billBaseURL}?filter=${billFilter}&perPage=${billPerPage}&sort=${billSort}`;
}

export function getAllBillUrl(username: string) {
  const billPerPage = encodeURIComponent("9999");
  const billSort = encodeURIComponent("-transactionDate");

  return `${billBaseURL}?perPage=${billPerPage}&sort=${billSort}`;
}
