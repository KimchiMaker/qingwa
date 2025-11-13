import axios, { AxiosError, AxiosResponse } from '@ohos/axios';

interface IResponse {
  count: number;
  images: IImages[];
  success: boolean;
}

interface IImages {
  id: number;
  imageURL: string;
}

@Entry
@Component
export struct Home {
  @State swiperImages: string[] = [];
  @State img1: string = '';
  @State img2: string = '';
  @State img3: string = '';
  @State img4: string = '';

  aboutToAppear() {
    axios.get<IResponse>('http://192.168.3.17:5000/api/swapper/images')
      .then((res: AxiosResponse<IResponse>) => {
        if (res.data.success) {
          const arr = res.data.images
            .filter((v: IImages) => [1, 2, 3, 4].includes(v.id))
            .sort((a, b) => a.id - b.id);

          this.swiperImages = arr.map(v => v.imageURL);

          // 低版本 ArkTS 不支持解构赋值，逐项写
          this.img1 = this.swiperImages[0] || '';
          this.img2 = this.swiperImages[1] || '';
          this.img3 = this.swiperImages[2] || '';
          this.img4 = this.swiperImages[3] || '';
        }
      })
      .catch((e: AxiosError) => console.info(JSON.stringify(e)));
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        /* 1 标题 */
        Text('首页')
          .fontSize(25)
          .fontWeight(FontWeight.Bolder)
          .width('95%')

        /* 2 轮播图 —— 直接用 Swiper，API 2.x 就有 */
        Swiper() {
          ForEach(this.swiperImages, (url: string) => {
            Image(url)
              .borderRadius(15)
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
          })
        }
        .autoPlay(true)
        .height(200)
        .margin({ top: 15 })

        /* 3 宫格 —— 用 2.x 就存在的 Grid */
        Grid() {
          ForEach(
            ['电影影院', '演出玩乐', '演唱会', '脱口秀',
              '密室', '景点门票', '放映厅', '剧集综艺'],
            (t: string) => {
              GridItem() {
                Column({ space: 4 }) {
                  Image(this.icon(t))   // 见下方辅助函数
                    .width(24).height(24)
                  Text(t).fontSize(12)
                }
              }
            }
          )
        }
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(12)
        .padding(12)
        .height(124)
        .backgroundColor(Color.White)
        .borderRadius(10)

        /* 4 热门电影横向列表 —— 用 Scroll+Row，2.x 完全支持 */
        Text('热门电影')
          .fontSize(25)
          .fontWeight(FontWeight.Bolder)
          .width('95%')
          .margin({ top: 15, bottom: 10 })

        Scroll() {
          Row({ space: 15 }) {
            this.movieCard($r('app.media.movie1'), '七夕')
            this.movieCard($r('app.media.movie2'), '世界晚安')
            this.movieCard($r('app.media.movie3'), '三十而已')
            this.movieCard($r('app.media.movie4'), '你该学习了')
            this.movieCard($r('app.media.movie5'), '七夕节')
          }
          .padding(10)
        }
        .scrollBar(BarState.Off)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .scrollable(ScrollDirection.Horizontal)
      }
      .width('90%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#E8E8E8')
  }

  /* 辅助函数：根据文字返回对应媒体资源，2.x 不能用 switch 表达式，用 if 即可 */
  icon(title: string): Resource {
    if (title === '电影影院') return $r('app.media.icon_dianying');
    if (title === '演出玩乐') return $r('app.media.icon_yanchu');
    if (title === '演唱会') return $r('app.media.icon_yanchanghui');
    if (title === '脱口秀') return $r('app.media.icon_tuokouxiu');
    if (title === '密室') return $r('app.media.icon_mishi');
    if (title === '景点门票') return $r('app.media.icon_jingdian');
    if (title === '放映厅') return $r('app.media.icon_bofang');
    return $r('app.media.icon_juji');
  }

  /* 辅助函数：生成单个电影卡片 */
  @Builder
  movieCard(pic: Resource, name: string) {
    Column({ space: 5 }) {
      Image(pic).height(170).borderRadius(8)
      Text(name).fontSize(14)
      Button('预订').width(70).height(30).borderRadius(15)
    }
  }
}