import { loginOut } from './LoginNetWork';
import { LoginDialog } from './LoginDialog';

@Entry
@Component
export struct Login {
  // 获取状态
  @StorageLink('isLogin') loginStatus: boolean = false;
  @StorageLink('loginToken') loginToken: boolean = false;
  @StorageLink('username') username: boolean = false;

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: LoginDialog({}),
    cancel: ()=>{console.log("dialog cancel")},
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
  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems:ItemAlign.Center }) {
      if (this.loginStatus) {
        Text('欢迎 ' + this.username + ', 再次点击退出登录').onClick(()=>{
          loginOut();
        })
      } else {
        Text('点击登录').onClick(()=>{
          if (this.dialogController != null) {
            this.dialogController.open()
          }
        })
      }
    }.width('90%').height('10%').backgroundColor(0xF5DEB3)
  }
}