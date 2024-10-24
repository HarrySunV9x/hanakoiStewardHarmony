import { loginOut } from '../common/NetWork';
import { LoginDialog } from './LoginDialog';

// 持久化状态, https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-appstorage-V5
AppStorage.link('isLogin');
AppStorage.link('loginToken');
AppStorage.link('username');
PersistentStorage.persistProp("isLogin", false);
PersistentStorage.persistProp("loginToken", '');
PersistentStorage.persistProp("username", '');

@Entry
@Component
struct Index {
  @State DialogState: boolean = false;

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
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center}) {
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
      Flex({ direction: FlexDirection.Column }) {

      }.width('90%').height('20%').backgroundColor(0xF5DEB3)
      Flex({ direction: FlexDirection.Column }) {

      }.width('90%').height('60%').backgroundColor(0xF5DEB3)
    }
    .height('100%')
    .width('100%')
    .padding(20)
  }
}