import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { loginUrl } from '../URL';
import { billRequest } from '../Bill/BillNetwork';
import { allBillRequest } from '../../pages/BillDetail';

interface Record {
  avatar: string;
  collectionId: string;
  collectionName: string;
  created: string; // 可以使用 Date 类型，但存储为字符串
  email: string;
  emailVisibility: boolean;
  id: string;
  name: string;
  updated: string; // 同样可以使用 Date 类型
  username: string;
  verified: boolean;
}

interface ResponseData {
  record: Record;
  token: string;
}

export function loginRequest(username: string, password: string) {
  let httpRequest = http.createHttp();
  httpRequest.on('headersReceive', (header) => {
    console.info('header: ' + JSON.stringify(header));
  });
  httpRequest.request(
    loginUrl,
    {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json'
      },
      extraData: {
        "identity": username,
        "password": password
      },
      expectDataType: http.HttpDataType.STRING,
      usingCache: true,
      priority: 1,
      connectTimeout: 60000,
      readTimeout: 60000,
      usingProxy: false,
    }, (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      AppStorage.setOrCreate('isLogin', true);
      const resultString = data.result;
      if (typeof resultString === 'string') {
        const responseData: ResponseData = JSON.parse(resultString);
        AppStorage.setOrCreate('loginToken', responseData.token);
        AppStorage.setOrCreate('username', responseData.record.username);
        billRequest(responseData.record.username, responseData.token)
        allBillRequest(responseData.record.username, responseData.token)
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

export function loginOut() {
  AppStorage.setOrCreate('isLogin', false);
  AppStorage.setOrCreate('loginToken', "");
  AppStorage.setOrCreate('username', "");
  AppStorage.setOrCreate('itemList', []);
  AppStorage.setOrCreate('todayCost', 0);
  AppStorage.setOrCreate('allBillList', []);
}