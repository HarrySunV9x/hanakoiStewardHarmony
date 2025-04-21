/**
 * BillDetail.ets
 * 账单详情页面，用于展示用户的所有账单信息
 * 包含网络请求和UI界面展示
 * 当前账单数据的获取点：
 *    登录时获取详细账单，退出登录时清空详细账单；
 *    获取主页账单时同时获取详细账单。
 * 没有实现进入账单详情页面时实时更新账单数据，原因：
 *    重渲染只走build()方法，但是build()方法无法进行非UI处理（aboutToAppear中的分数方法）
 */

import { http } from "@kit.NetworkKit";
import { getAllBillUrl } from "../common/URL";
import { BusinessError } from "@kit.BasicServicesKit";
import { BillData, ResponseData } from "../common/Bill/BillNetwork";
import { billTypeMap } from "../common/Bill/Bill";

/**
 * 请求所有账单数据的函数
 * @param username 用户名
 * @param token 用户认证令牌
 */
export function allBillRequest(username: string, token: string) {
  // 创建HTTP请求实例
  let httpRequest = http.createHttp();

  // 监听请求头接收事件
  httpRequest.on('headersReceive', (header) => {
    console.info('header: ' + JSON.stringify(header));
  });
  
  // 发起HTTP请求获取账单数据
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
      // 请求成功，处理返回的数据
      const resultString = data.result;
      if (typeof resultString === 'string') {
        const responseData: ResponseData = JSON.parse(resultString);
        // 将账单数据存储到应用存储中
        AppStorage.setOrCreate('allBillList', responseData.items);
      }
      httpRequest.destroy();
    } else {
      // 请求失败，记录错误信息并销毁请求实例
      console.error('error:' + JSON.stringify(err));
      httpRequest.off('headersReceive');
      httpRequest.destroy();
    }
  }
  );
}

/**
 * 账单项组件
 * 用于展示单个账单的信息
 */
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

/**
 * 账单详情页面组件
 * 用于展示按日期分组的所有账单信息
 */
@Entry
@Component
struct BillDetail {
  // 从应用存储中获取登录状态和用户信息
  @StorageLink('isLogin') loginStatus: boolean = false;
  @StorageLink('loginToken') loginToken: string = '';
  @StorageLink('username') username: string = '';
  @StorageLink('allBillList') allBillList: BillData[] = [];
  
  // 用于处理日期分组的变量
  private currentDate: string = ''  // 当前处理的日期
  private dateArray: string[] = []  // 存储所有不同的日期
  private billArray: BillData[][] = []  // 按日期分组的账单数组

  /**
   * 组件即将出现时的生命周期函数
   * 处理账单数据，按日期进行分组
   */
  aboutToAppear(): void {
    if (this.allBillList.length > 0) {
      for (let i = 0; i < this.allBillList.length; i++) {
        // 提取交易日期（年月日部分）
        if (this.currentDate != this.allBillList[i].transactionDate.substring(0, 10)) {
          // 如果遇到新的日期，则创建新的分组
          this.currentDate = this.allBillList[i].transactionDate.substring(0, 10)
          this.dateArray.push(this.currentDate)
          this.billArray.push([])
        }
        // 将当前账单添加到对应日期的分组中
        this.billArray[this.dateArray.length - 1].push(this.allBillList[i])
      }
    }
  }

  /**
   * 构建UI界面
   */
  build() {
    Column() {
      List() {
        // 遍历所有日期
        ForEach(this.dateArray, (date: string, index: number) => {
          ListItem() {
          Column(){
            // 显示日期标题
            Text(date).fontSize(20).fontWeight(FontWeight.Bold)
                // 遍历该日期下的所有账单
                ForEach(this.billArray[index], (item: BillData) => {
                  // 使用BillItem组件展示单个账单
                  BillItem({ item: item })
                }, (item: BillData) => JSON.stringify(item))
              }.alignItems(HorizontalAlign.Start)
            }
        })
      }
      .scrollBar(BarState.Auto)  // 添加自动滚动条
    }.width('100%').height('100%').padding(5)  // 设置容器样式
  }
}