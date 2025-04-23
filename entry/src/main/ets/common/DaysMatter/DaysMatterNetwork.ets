import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getDaysMatterURL } from '../URL';

export interface DaysMatterData {
  id: string, // 倒数日 ID
  collectionId: string; // 收藏夹 ID
  collectionName: string; // 收藏夹名称
  created: string; // 创建时间（字符串格式）
  updated: string; // 更新时间（字符串格式）
  date: string, // 倒数日时间
  description: string; // 倒数日描述
}

export interface ResponseData {
  page: number; // 当前页码
  perPage: number; // 每页条目数
  totalItems: number; // 总条目数
  totalPages: number; // 总页数
  items: DaysMatterData[]; // 倒数日数组
}

export function daysMatterRequest(token: string) {
  let httpRequest = http.createHttp();

  httpRequest.on('headersReceive', (header) => {
    console.info('header: ' + JSON.stringify(header));
  });
  httpRequest.request(
    getDaysMatterURL(),
    {
      method: http.RequestMethod.GET,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      expectDataType: http.HttpDataType.STRING,
      usingCache: true,
      priority: 1,
      connectTimeout: 60000,
      readTimeout: 60000,
      usingProxy: false,
    }, (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      const resultString = data.result;
      if (typeof resultString === 'string') {
        const responseData: ResponseData = JSON.parse(resultString);
        if (responseData.items.length === 0) {
          return
        }
        const random = Math.floor(Math.random() * (responseData.items.length));
        AppStorage.setOrCreate('daysMatter', responseData.items[random]);
        const targetDateStr = responseData.items[random].date.substring(0, 10)
        const today = new Date();
        const currentYear = today.getUTCFullYear();
        const currentMonth = today.getUTCMonth();
        const currentDate = today.getUTCDate();

        // 解析目标日期（格式：xxxx-xx-xx）
        const targetYear = parseInt(targetDateStr.substring(0, 4))
        const targetMonth = parseInt(targetDateStr.substring(5, 7))
        const targetDay = parseInt(targetDateStr.substring(8, 10))

        // 创建今年的纪念日UTC时间戳（月份从0开始，需减1）
        const thisYearAnniversary = Date.UTC(currentYear, targetMonth - 1, targetDay);
        // 如果今年纪念日已过，计算明年的日期
        let nextAnniversary = thisYearAnniversary;
        if (Date.UTC(currentYear, currentMonth, currentDate) > thisYearAnniversary) {
          nextAnniversary = Date.UTC(currentYear + 1, targetMonth - 1, targetDay);
        }
        // 计算剩余天数（向下取整）
        const msPerDay = 24 * 60 * 60 * 1000;
        const daysDiff = Math.ceil((nextAnniversary - today.getTime()) / msPerDay)  >= 0 ? Math.ceil((nextAnniversary - today.getTime()) / msPerDay) : 0;
        AppStorage.setOrCreate('lastDay', daysDiff.toString());
      }
      httpRequest.destroy();
    } else {
      console.error('error:' + JSON.stringify(err));
      httpRequest.off('headersReceive');
      httpRequest.destroy();
    }
  }
  );
}