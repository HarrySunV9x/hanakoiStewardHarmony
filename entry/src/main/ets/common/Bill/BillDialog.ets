import { CommonConstants } from "../CommonConstants"
import { promptAction, router } from "@kit.ArkUI";
import { connection } from "@kit.NetworkKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { http } from '@kit.NetworkKit';
import { billBaseURL } from '../URL';
import { billRequest } from "./BillNetwork";
import { allBillRequest } from "../../pages/BillDetail";

function judgeHasNet(): boolean {
  try {
    let netHandle = connection.getDefaultNetSync();
    if (!netHandle || netHandle.netId < 100) {
      return false;
    }

    let netCapability = connection.getNetCapabilitiesSync(netHandle);
    let cap = netCapability.networkCap;
    if (!cap) {
      return false;
    }

    for (let em of cap) {
      if (connection.NetCap.NET_CAPABILITY_VALIDATED === em) {
        return true;
      }
    }
  } catch (e) {
    let err = e as BusinessError;
    hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
  }
  return false;
}

interface GeneratedObjectLiteralInterface_1 {
  categoryId: number;
  amount: number;
  description: string;
  selectedDate: Date;
  selectedTime: Date;
}

function pad(n: number):string {
  return n.toString().padStart(2, '0');
}

function addBill(username: string, token: string, categoryId: number, amount: number, description: string,
  selectedDate: Date, selectedTime: Date) {
  let httpRequest = http.createHttp();

  // 生成本地日期时间字符串（格式：YYYY-MM-DD HH:mm:ss.SSS+08:00）
  const localDateStr = `${selectedDate.getFullYear()}-${pad(selectedDate.getMonth() + 1)}-${pad(selectedDate.getDate())}`;
  const localTimeStr = `${pad(selectedTime.getHours())}:${pad(selectedTime.getMinutes())}:${pad(selectedTime.getSeconds())}.${selectedTime.getMilliseconds().toString().padStart(3, '0')}`;
  // 拼接结果（显式指定时区）
  const date = `${localDateStr} ${localTimeStr}Z`;

  if (categoryId == undefined) {
    categoryId = 0
  }
  httpRequest.on('headersReceive', (header) => {
    console.info('header: ' + JSON.stringify(header));
  });
  httpRequest.request(
    billBaseURL,
    {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      extraData: {
        "userName": username,
        "categoryId": categoryId,
        "amount": amount.toString(),
        "description": description,
        "transactionDate": date,
        "createdDate": date,
        "updatedDate": date,
      },
      expectDataType: http.HttpDataType.STRING,
      usingCache: true,
      priority: 1,
      connectTimeout: 60000,
      readTimeout: 60000,
      usingProxy: false,
    }, (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      console.log(JSON.stringify(data.result))
      billRequest(username, token)
      allBillRequest(token)
      httpRequest.destroy();
    } else {
      console.error('error:' + JSON.stringify(err));
      httpRequest.off('headersReceive');
      httpRequest.destroy();
    }
  }
  );
}

// xxx.ets
@CustomDialog
@Component
export struct AddBillDialog {
  @StorageLink('loginToken') loginToken: string = '';
  @StorageLink('username') username: string = '';
  private categoryId: number = 0;
  private amount: number = -1;
  private description: string = '';
  private selectedDate: Date = new Date();
  private selectedTime: Date = new Date();
  private category: string[] = ['早餐', '午餐', '晚餐', '夜宵', '零食', '交通', '娱乐', '购物', '水电', '其他']
  @StorageProp('NetJudge.currNet.isUseful') isHasNetwork: boolean = judgeHasNet();
  controller?: CustomDialogController

  addBillVerification(): boolean {
    if (this.amount == -1 || this.description == '') {
      promptAction.showToast({
        message: '请输入信息',
        duration: 2000
      });
      return false
    }

    if (!this.isHasNetwork) {
      promptAction.showToast({
        message: '网络连接错误',
        duration: 2000
      });
      return false
    }

    return true
  }

  build() {
    Column() {
      TextInput({
        placeholder: '金额'
      })
        .type(InputType.Normal)
        .enableKeyboardOnFocus(true)
        .defaultFocus(true)
        .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
        .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
        .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
        .maxLength(CommonConstants.TEXT_INPUT_MAX_LENGTH)
        .width(CommonConstants.FULL_SCREEN)
        .constraintSize({ minHeight: $r('app.float.textInput_constraintSize') })
        .padding({
          left: $r('app.float.textInput_padding_left')
        })
        .borderRadius($r('app.float.textInput_borderRadius'))
        .borderColor($r('sys.color.ohos_id_color_warning'))
        .onChange((value: string) => {
          this.amount = parseFloat(value);
        })
        .margin({ top: $r('app.float.customDialog_row_margin_top'), bottom: $r('app.float.textInput_margin_bottom') })
      TextInput({
        placeholder: '描述'
      })
        .type(InputType.Normal)
        .enableKeyboardOnFocus(true)
        .defaultFocus(true)
        .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
        .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
        .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .maxLength(CommonConstants.PASSWORD_MAX_LENGTH)
        .width(CommonConstants.FULL_SCREEN)
        .constraintSize({ minHeight: $r('app.float.password_constraintSize') })
        .padding({
          left: $r('app.float.password_padding_left')
        })
        .borderRadius($r('app.float.password_borderRadius'))
        .borderColor($r('sys.color.ohos_id_color_warning'))
        .margin({ bottom: $r('app.float.password_margin_bottom') })
        .onChange((value: string) => {
          this.description = value;
        })

      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date('2100-1-1'),
        selected: this.selectedDate
      })
        .disappearTextStyle({ color: Color.Gray, font: { size: '5fp', weight: FontWeight.Bold } })
        .textStyle({ color: '#ff182431', font: { size: '10fp', weight: FontWeight.Normal } })
        .selectedTextStyle({ color: '#ff0000FF', font: { size: '15fp', weight: FontWeight.Regular } })
        .lunar(false)
        .onDateChange((value: Date) => {
          this.selectedDate = value
        })
        .height('10%')
      Row() {
        TextPicker({ range: this.category, selected: 0 })
          .onChange((value: string | string[], index: number | number[]) => {
            if (typeof index === 'number') {
              this.categoryId = index;
            }
          })
          .disappearTextStyle({ color: Color.Red, font: { size: 5, weight: FontWeight.Lighter } })
          .textStyle({ color: Color.Black, font: { size: 10, weight: FontWeight.Normal } })
          .selectedTextStyle({ color: Color.Blue, font: { size: 15, weight: FontWeight.Bolder } })
          .width('33%')
        TimePicker({
          selected: this.selectedTime,
        })
          .useMilitaryTime(true)
          .onChange((value: TimePickerResult) => {
            if (value.hour >= 0) {
              this.selectedTime.setHours(value.hour, value.minute)
            }
          })
          .disappearTextStyle({ color: Color.Red, font: { size: 5, weight: FontWeight.Lighter } })
          .textStyle({ color: Color.Black, font: { size: 10, weight: FontWeight.Normal } })
          .selectedTextStyle({ color: Color.Blue, font: { size: 15, weight: FontWeight.Bolder } })
          .width('66%')
      }.height('10%')

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('确认')
          .onClick(() => {
            if (this.controller != undefined) {
              addBill(this.username, this.loginToken, this.categoryId + 1, this.amount, this.description, this.selectedDate,
                this.selectedTime);
              this.controller.close()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })
    }.borderRadius(10).width('80%')
  }
}