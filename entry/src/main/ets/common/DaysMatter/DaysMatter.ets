import { DaysMatterData, daysMatterRequest } from "./DaysMatterNetwork";

@Entry
@Component
export struct DaysMatter {
    @StorageLink('isLogin') loginStatus: boolean = false;
    @StorageLink('loginToken') loginToken: string = '';
    @StorageLink('username') username: string = '';
    @StorageLink('daysMatter') daysMatter: DaysMatterData = {
        id: "",
        collectionId: "",
        collectionName: "",
        created: "",
        updated: "",
        date: "",
        description: ""
    };
    @StorageLink('lastDay') lastDay: string = ''

    aboutToAppear(): void {
        daysMatterRequest(this.loginToken)
    }
    build() {
        Column(){
            if (this.loginStatus && this.daysMatter.id != "") {
            Text('距离 ' + this.daysMatter.description + ' 还有').height('20%')
            Text(this.lastDay + '天').height('60%')
            Text(this.daysMatter.date.substring(0, 10)).height('20%')
            } else {
                Text('请登录').height('100%')
            }
        }.width('100%').height('100%').alignItems(HorizontalAlign.Center).padding({top: 10, bottom: 10})
    }
}