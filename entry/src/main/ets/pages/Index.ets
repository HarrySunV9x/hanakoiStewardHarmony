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
  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center}) {
      Login()
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