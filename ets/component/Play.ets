@Entry
@Component
export  struct Play {
  controller: VideoController[] = [
    new VideoController(),
    new VideoController(),
    new VideoController()
  ];

  videoArray: ResourceStr[] = [
    $r('app.media.huoying'),
    $r('app.media.xingji01'),
    $r('app.media.xingji02')
  ];

  videoInfoArray: Array<VideoInfo> = [
    { author: "鸿蒙开发者", desc: "火影忍者中鸣人与佐助在终末之谷的经典决战场景，两人各自施展最强忍术，展现了友情与信念的碰撞，忍界未来的命运在此刻交织。" },
    { author: "星辰团队", desc: "星际穿越中库珀驾驶飞船穿越虫洞的震撼场景，展现了五维空间的奇妙构造，人类为拯救族群勇敢探索未知宇宙的壮丽史诗。" },
    { author: "银河工作室", desc: "太空探索纪录片详细记录国际空间站宇航员的日常生活，展示在失重环境下进行科学实验、太空行走以及观测地球的独特体验。" }
  ];

  @State currentIndex: number = 0;
  @State isLiked: boolean[] = [false, false, false];
  @State likeCounts: number[] = [0, 0, 0];
  @State commentCounts: number[] = [0, 0, 0];
  @State shareCounts: number[] = [0, 0, 0];

  private normalImg: Resource = $r('app.media.like3')
  private activeImg: Resource = $r('app.media.like1')

  aboutToAppear() {
    this.likeCounts = this.likeCounts.map(() => Math.floor(Math.random() * 1000) + 1);
    this.commentCounts = this.commentCounts.map(() => Math.floor(Math.random() * 500) + 1);
    this.shareCounts = this.shareCounts.map(() => Math.floor(Math.random() * 200) + 1);
  }

  build() {
    Stack() {
      Swiper() {
        ForEach(this.videoArray, (item: ResourceStr, index: number) => {
          Stack() {
            Video({
              src: item,
              controller: this.controller[index]
            })
              .onPrepared(() => {
                this.controller[index].setCurrentTime(0);
              })
              .width('100%')
              .height('100%')
              .autoPlay(true)

            Text(`@${this.videoInfoArray[index].author}\n简介：${this.videoInfoArray[index].desc}`)
              .fontSize(16)
              .fontColor(Color.White)
              .position({ x: '10px', y: '80%' })

          }
        })
      }
      .indicator(false)
      .vertical(true)
      .index(this.currentIndex)
      .onChange((index: number) => {
        this.controller[this.currentIndex].stop();
        this.controller[index].setCurrentTime(0);
        this.controller[index].start();
        this.currentIndex = index;
      })

      Column(){
        Image($rawfile('1.jpg'))
          .width(48)
          .height(48)
          .borderRadius(24)
          .margin({ bottom: 24 })

        Column() {
          Image(this.isLiked[this.currentIndex] ? this.activeImg : this.normalImg)
            .width(48)
            .height(48)
            .onClick(() => {
              if (this.isLiked[this.currentIndex]) {
                this.likeCounts[this.currentIndex] -= 1;
              } else {
                this.likeCounts[this.currentIndex] += 1;
              }
              this.isLiked[this.currentIndex] = !this.isLiked[this.currentIndex];
            })

          Text(this.likeCounts[this.currentIndex].toString())
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 16 })

        Column() {
          Image($r('app.media.comment3'))
            .width(40)
            .height(40)

          Text(this.commentCounts[this.currentIndex].toString())
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 16 })

        Column() {
          Image($r('app.media.share3'))
            .width(40)
            .height(40)

          Text(this.shareCounts[this.currentIndex].toString())
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 16 })
      }
      .offset({x:150})
      .padding(12)
      .alignItems(HorizontalAlign.Center)
    }
    .height('100%')
    .width('100%')
  }
}

interface VideoInfo {
  author: string;
  desc: string;
}