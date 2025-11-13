import axios, { AxiosError, AxiosResponse } from "@ohos/axios";

/* ========== 接口保持原样 ========== */
interface IResponse { cinemas: ICinemas[]; count: number; success: boolean; }
interface ICinemas { id: number; name: string; address: string; price: number; tags: string[]; }
interface ISwiperResponse { count: number; images: ISwiperImage[]; success: boolean; }
interface ISwiperImage { id: number; imageURL: string; }

/* ========== 统一卡片数据结构 ========== */
export class CinemaItem {
  name: string = '';
  price: string = '';
  address: string = '';
  tags: string[] = [];
}

@Entry
@Component
export struct Movie {
  @State private imgList: string[] = [];   // ✅ 改回 string[]
  @State private cinemaList: CinemaItem[] = [];

  aboutToAppear(): void {
    /* === 2. 网络请求 === */
    this.loadSwiperImages();
    this.loadCinemas();
  }

  /* ========== 网络请求保持原逻辑 ========== */
  private loadSwiperImages(): void {
    axios.get<ISwiperResponse, AxiosResponse<ISwiperResponse>, null>('http://192.168.3.17:5000/api/swapper/images')
      .then((response: AxiosResponse<ISwiperResponse>) => {
        if (response.data.success) {
          const targetImages = response.data.images.filter((image: ISwiperImage) =>
          image.id === 5 || image.id === 6 || image.id === 7 || image.id === 8
          );
          this.imgList = targetImages.map((image: ISwiperImage) => image.imageURL);
        }
      })
      .catch((error: AxiosError) => {
        console.info(JSON.stringify(error));
      });
  }

  private loadCinemas(): void {
    axios.get<IResponse, AxiosResponse<IResponse>, null>('http://192.168.3.17:5000/api/cinemas', {
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc2MjcwMDY1NCwianRpIjoiOTJmNjBlZTMtMWY1NS00ZWJhLWIyMjUtZTQ3ZGQyNzczZmZiIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6InRlc3R1c2VyIiwibmJmIjoxNzYyNzAwNjU0LCJjc3JmIjoiMjQ0ZmVhMWQtYzA4Mi00ODkzLWI2MDUtZTU4YWIzZjFhZWZkIiwiZXhwIjoxNzYyNzg3MDU0fQ.dEqIMaVjzhqxiQhFYOj4yme4lwHRwAyohGdEFzsz5ZE'
      }
    })
      .then((response: AxiosResponse<IResponse>) => {
        console.info('>>>影院条数', response.data.cinemas.length);
        console.info('>>>影院返回', JSON.stringify(response.data)); // ✅ 看 Log
        if (response.data.success) {
          this.cinemaList = response.data.cinemas.map((c: ICinemas) => {

            const item = new CinemaItem();
            item.name = c.name;
            item.price = `${c.price}`;
            item.address = c.address;
            item.tags = c.tags;
            return item; // ✅ 显式返回 CinemaItem 实例
          });
        }
      })
      .catch((error: AxiosError) => {
        console.info(JSON.stringify(error));
      });
  }

  /* ========== 现代 UI ========== */
  build() {
    Column({ space: 0 }) {
      /* 1. 顶部轮播 - 大圆角 + 指示器动画 */
      Swiper() {
        ForEach(this.imgList, (item: string) => {
          Image(item)
            .width('100%')
            .aspectRatio(2.25) // 16:9
            .objectFit(ImageFit.Cover)
            .borderRadius(24)
        }, (item: string) => item)
      }
      .autoPlay(true)
      .interval(3000)
      .indicator(true)
      .curve(Curve.FastOutSlowIn)
      .padding({ left: 16, right: 16, top: 12 })

      /* 2. 影院列表 - 卡片圆角 + 阴影 + 悬浮价格 */
      List({ space: 16 }) {
        ForEach(this.cinemaList, (cinema: CinemaItem) => {
          ListItem() {
            ModernCinemaCard({ cinema: cinema })
          }
        }, (cinema: CinemaItem) => cinema.name)
      }
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}

/* ========== 现代卡片子组件 ========== */
@Component
struct ModernCinemaCard {
  @Prop cinema: CinemaItem;

  build() {
    Stack() {
      Column({ space: 10 }) {
        /* 顶部：名称 + 悬浮价格按钮 */
        Row() {
          Text(this.cinema.name)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .fontColor('#111111')

          Text(`¥${this.cinema.price}`)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor('#FF4C38')
            .borderRadius(12)
        }

        /* 地址 */
        Text(this.cinema.address)
          .fontSize(13)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        /* 标签 - 自动换行 + 渐变色 */
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.cinema.tags, (tag: string) => {
            Text(tag)
              .fontSize(11)
              .fontColor('#FFFFFF')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('#6366F1') // 现代蓝
              .borderRadius(12)
              .margin({ right: 6, bottom: 6 })
          }, (tag: string) => tag)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .shadow({
        radius: 10,
        color: 'rgba(0,0,0,0.08)',
        offsetX: 0,
        offsetY: 4
      })
    }
  }
}