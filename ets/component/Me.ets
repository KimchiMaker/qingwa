import axios, { AxiosError, AxiosResponse } from '@ohos/axios';

/* ========== 接口保持原样 ========== */
interface ServiceCard {
  title: string
  desc1: string
  desc2: string
  image: Resource
}

@Entry
@Component
export struct Me {
  @State progressValue: number = 80
  private serviceCards: ServiceCard[] = [
    { title: '省钱月卡', desc1: '双享礼遇', desc2: '双享礼遇', image: $r('app.media.servicecard') },
    { title: '0元观影', desc1: '双享礼遇', desc2: '双享礼遇', image: $r('app.media.servicecard1') },
    { title: '时尚周边', desc1: '周边', desc2: '双享礼遇', image: $r('app.media.servicecard2') },
    { title: '蛙币捐赠', desc1: '双享礼遇', desc2: '双享礼遇', image: $r('app.media.servicecard3') },
    { title: '连连看', desc1: '双享礼遇', desc2: '双享礼遇', image: $r('app.media.servicecard4') },
    { title: '惠惠省', desc1: '双享礼遇', desc2: '双享礼遇', image: $r('app.media.servicecard5') }
  ]

  /* ========== 现代 UI 一锅端 ========== */
  build() {
    Scroll() {
      Column({ space: 12 }) {
        /* 1. 顶部卡片 - 圆角 + 阴影 */
        Column({ space: 10 }) {
          Row() {
            Image($rawfile('1.jpg')).width(50).borderRadius(30)
            Column({ space: 4 }) {
              Text('超级皮特大王').fontSize(20).fontWeight(FontWeight.Medium)
              Text('钻石VIP').fontSize(11).fontColor('#6366F1')
            }.offset({
              x:5
            })
            .alignItems(HorizontalAlign.Start)
          }.width('100%')

          Row() {
            Text('成长值 80/100').fontSize(12).fontColor('#666')
            Blank()
            Progress({ value: 80, total: 100, type: ProgressType.Linear })
              .width(120)
              .color('#6366F1')
          }.width('100%')
        }
        .width('93%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 2 })

        /* 2. 订单入口 - 现代横条 */
        Row({ space: 25 }) {
          Column({ space: 4 }) {
            Image($r('app.media.movie_32x32')).width(32)
            Text('电影票').fontSize(12)
          }
          Column({ space: 4 }) {
            Image($r('app.media.yanchu32x32')).width(32)
            Text('演出/玩乐').fontSize(12)
          }
          Column({ space: 4 }) {
            Image($r('app.media.theater32x32')).width(32)
            Text('在线观影').fontSize(12)
          }
          Column({ space: 4 }) {
            Image($r('app.media.local32x32')).width(32)
            Text('周边').fontSize(12)
          }
        }
        .width('93%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

        /* 3. 优惠券一行 - 现代按钮 */
        Row({ space: 20 }) {
          ForEach(['优惠券', '影城卡', '蛙享卡', '蛙币'], (txt: string, idx: number) => {
            Column({ space: 4 }) {
              Text(txt).fontSize(15).fontWeight(FontWeight.Medium)
              Text(`${[25, 21, 21, 0][idx]}张可用`).fontSize(11).fontColor('#666')
            }.layoutWeight(1)
          }, (txt: string) => txt)
        }
        .width('93%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 6, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

        /* 4. 精选服务 - 现代网格卡片 */
        Text('精选服务').fontSize(18).fontWeight(FontWeight.Medium).width('93%')
        Grid() {
          ForEach(this.serviceCards, (item: ServiceCard) => {
            GridItem() {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(item.title).fontSize(16).fontWeight(FontWeight.Medium)
                  Text(item.desc1).fontSize(12).fontColor('#666')
                  Text(item.desc2).fontSize(12).fontColor('#666')
                  Text('立即参加').fontSize(10).fontColor('#FFFFFF')
                    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                    .backgroundColor('#6366F1')
                    .borderRadius(16)
                    .margin({ top: 4 })
                }.layoutWeight(1)

                Image(item.image)
                  .width(56)
                  .height(56)
                  .borderRadius(12)
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.08)', offsetY: 2 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
              .shadow({ radius: 10, color: 'rgba(0,0,0,0.06)', offsetY: 4 })
            }
          }, (item: ServiceCard) => item.title)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .width('93%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding({ bottom: 24 })
      .backgroundColor('#F2F4F7')
    }
    .scrollBar(BarState.Off)
  }
}