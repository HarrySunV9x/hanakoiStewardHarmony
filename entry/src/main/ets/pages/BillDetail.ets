import { http } from "@kit.NetworkKit";
import { getAllBillUrl } from "../common/URL";
import { BusinessError } from "@kit.BasicServicesKit";
import { BillData, ResponseData } from "../common/Bill/BillNetwork";
import { billTypeMap } from "../common/Bill/Bill";

export function allBillRequest(username: string, token: string) {
  let httpRequest = http.createHttp();

  httpRequest.on('headersReceive', (header) => {
    console.info('header: ' + JSON.stringify(header));
  });
  httpRequest.request(
    getAllBillUrl(username),
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
        AppStorage.setOrCreate('allBillList', responseData.items);
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

@Component
struct BillItem {
  @Prop item: BillData;

  build() {
    ListItem() {
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween,
        alignItems: ItemAlign.Center
      }) {
        Text(billTypeMap.get(this.item.categoryId)).width('15%')
        Text(this.item.userName).width('25%')
        Text(parseFloat(this.item.amount.toString()).toFixed(2).toString()).width('15%').textAlign(TextAlign.End)
        Text('').width('2%')
        Text('元').width('5%')
        Text('').width('8%')
        Text(this.item.description).width('40%')
      }
    }.margin({ top: 5, bottom: 5 })
  }
}

@Entry
@Component
struct BillDetail {
  @StorageLink('isLogin') loginStatus: boolean = false;
  @StorageLink('loginToken') loginToken: string = '';
  @StorageLink('username') username: string = '';
  @StorageLink('allBillList') allBillList: BillData[] = [];

  aboutToAppear(): void {
    allBillRequest(this.username, this.loginToken)
  }

  build() {
    Column() {
      List() {
        ForEach(this.allBillList, (item: BillData) => {
          BillItem({ item: item })
        }, (item: BillData) => JSON.stringify(item))
      }
      .scrollBar(BarState.Auto)
    }.width('100%').height('88%').padding(5)
  }
}