import { BillData, billRequest } from "./BillNetwork";
import { HashMap } from "@kit.ArkTS";
import { AddBillDialog } from "./BillDialog";

let billTypeMap = new HashMap<number, string>();
billTypeMap.set(0, '早餐');
billTypeMap.set(1, '午餐');
billTypeMap.set(2, '晚餐');
billTypeMap.set(3, '夜宵');
billTypeMap.set(4, '零食');
billTypeMap.set(5, '交通');
billTypeMap.set(6, '娱乐');
billTypeMap.set(7, '购物');
billTypeMap.set(8, '水电');
billTypeMap.set(9, '其他');

@Entry
@Component
export struct Bill {
  @StorageLink('isLogin') loginStatus: boolean = false;
  @StorageLink('loginToken') loginToken: string = '';
  @StorageLink('username') username: string = '';
  @StorageLink('itemList') itemList: BillData[] = [];
  @StorageLink('todayCost') todayCost: number = 0;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: AddBillDialog({}),
    cancel: () => {
      console.log("dialog cancel")
    },
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 10,
  })

  aboutToAppear(): void {
    billRequest(this.username, this.loginToken)
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text('本日消费：' + this.todayCost).fontSize(20).width('80%')
        SymbolGlyph($r('sys.symbol.plus'))
          .fontSize(20)
          .fontWeight('bolder')
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          .fontColor([Color.Black, Color.Green, Color.White])
          .onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open()
            }
          })
        SymbolGlyph($r('sys.symbol.more'))
          .fontSize(20)
          .fontWeight('bolder')
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          .fontColor([Color.Black, Color.Green, Color.White])
      }.width('100%').height('10%').backgroundColor(0xF5DEB3)

      Column() {
        List() {
          ForEach(this.itemList, (item: BillData) => {
            ListItem() {
              Flex({
                direction: FlexDirection.Row,
                justifyContent: FlexAlign.SpaceBetween,
                alignItems: ItemAlign.Center
              }) {
                Text(billTypeMap.get(item.categoryId)).width('15%')
                Text(parseFloat(item.amount.toString()).toFixed(2).toString()).width('20%').textAlign(TextAlign.End)
                Text('').width('2%')
                Text('元').width('5%')
                Text('').width('18%')
                Text(item.description).width('40%')
              }
            }.margin({ top: 5, bottom: 5 })
          }, (item: BillData) => JSON.stringify(item))
        }
        .scrollBar(BarState.Auto)

      }.width('100%').height('88%').backgroundColor(0xF5DEB3).padding(5)
    }.width('100%').padding(5)
  }
}