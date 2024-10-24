import { CommonConstants } from "../common/CommonConstants"

// xxx.ets
@CustomDialog
@Component
export struct LoginDialog {
  @State inputContent: string = '';
  @State password: string = '';
  controller?: CustomDialogController
  loginVerification() {

  }
  build() {
    Column() {
      TextInput({
        placeholder: '用户名'
      })
        .type(InputType.PhoneNumber)
        .enterKeyType(EnterKeyType.Next)
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
        .inputFilter('^[0-9*]+$')
        .onChange((value: string) => {
          this.inputContent = value;
        })
        .margin({ top: $r('app.float.customDialog_row_margin_top'), bottom: $r('app.float.textInput_margin_bottom') })
      TextInput({
        placeholder: '密码'
      })
        .type(InputType.Password)
        .enterKeyType(EnterKeyType.Next)
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
          this.password = value;
        })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button('登录')
          .onClick(() => {
            if (this.controller != undefined) {

              this.controller.close()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })
    }.borderRadius(10)
  }
}