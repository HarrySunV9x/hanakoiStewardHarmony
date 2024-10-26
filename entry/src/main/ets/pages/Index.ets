import { Bill } from '../common/Bill/Bill';
import { Login } from '../common/Login/Login';

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
  // 获取状态
  @StorageLink('isLogin') loginStatus: boolean = false;
  @StorageLink('loginToken') loginToken: string = '';
  @StorageLink('username') username: string = '';

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Login()
      }.width('90%').height('10%').backgroundColor(0xFFFFFF).borderRadius(10)

      Flex({ direction: FlexDirection.Column }) {

      }.width('90%').height('20%').backgroundColor(0xFFFFFF).borderRadius(10)

      Flex({ direction: FlexDirection.Column }) {
        Bill()
      }.width('90%').height('60%').backgroundColor(0xFFFFFF).borderRadius(10)
    }
    .height('100%')
    .width('100%')
    .padding(20)
    .backgroundColor(0xF2F2F2)
  }
}