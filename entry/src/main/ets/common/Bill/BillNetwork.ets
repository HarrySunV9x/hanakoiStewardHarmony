import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getTodayBillUrl } from '../URL';

export interface BillData {
  amount: number; // 账单金额
  categoryId: number; // 类别 ID
  collectionId: string; // 收藏夹 ID
  collectionName: string; // 收藏夹名称
  created: string; // 创建时间（字符串格式）
  createdDate: string; // 创建日期（字符串格式）
  description: string; // 账单描述
  id: string; // 账单 ID
  transactionDate: string; // 交易日期（字符串格式）
  updated: string; // 更新时间（字符串格式）
  updatedDate: string; // 更新日期（字符串格式）
  userName: string; // 用户名
}

export interface ResponseData {
  page: number; // 当前页码
  perPage: number; // 每页条目数
  totalItems: number; // 总条目数
  totalPages: number; // 总页数
  items: BillData[]; // 账单数组
}

export function billRequest(username: string, token: string) {
  let httpRequest = http.createHttp();

  httpRequest.on('headersReceive', (header) => {
    console.info('header: ' + JSON.stringify(header));
  });
  httpRequest.request(
    getTodayBillUrl(username),
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
        AppStorage.setOrCreate('itemList', responseData.items);

        let todayCost = 0;
        responseData.items.forEach(item => {
          // 这里好像有bug，item.amount的实际返回类型应该是number，但是实际是string
          // 如果直接相加会变成字符串拼接，但是toString又能生效……
          todayCost += parseFloat(item.amount.toString());
        })
        AppStorage.setOrCreate('todayCost', todayCost.toFixed(2));
      }
      httpRequest.destroy();
    } else {
      console.log("harry: " + JSON.stringify(err))
      console.error('error:' + JSON.stringify(err));
      httpRequest.off('headersReceive');
      httpRequest.destroy();
    }
  }
  );
}