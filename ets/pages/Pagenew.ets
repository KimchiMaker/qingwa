import {Me} from '../component/Me';
import {Home} from '../component/Home';
import {Play} from '../component/Play';
import {Movie} from '../component/Movie';

@Entry
@Component
struct Pagenew {
  @State currentIndex:number = 0
  toolbarArr:IToolbar[]=[
    {text:'首页',icon:$r('app.media.home_0'),activeIcon:$r('app.media.home_1')},
    {text:'影院',icon:$r('app.media.movie_0'),activeIcon:$r('app.media.movie_1')},
    {text:'抢先看',icon:$r('app.media.play_0'),activeIcon:$r('app.media.play_1')},
    {text:'我的',icon:$r('app.media.me_0'),activeIcon:$r('app.media.me_1')}
  ]

  @Builder
  pageContent(){
    if (this.currentIndex === 0){
      Home()
    }else if (this.currentIndex === 1){
      Movie()
    }else if (this.currentIndex === 2){
      Play()
    }else if (this.currentIndex === 3){
      Me()
    }
  }

  @Builder
  toolbar(){
    ForEach(this.toolbarArr,(Item:IToolbar,index:number)=>{
      Column({space:10}){
        Image(this.currentIndex === index? Item.activeIcon : Item.icon).width(28).margin({top:10})
        Text(Item.text).fontColor(this.currentIndex === index? Color.Blue :Color.Black)
      }
      .layoutWeight(1)
      .onClick(()=>{
        this.currentIndex = index
      })
    })
  }

  build() {
    Navigation(){
      this.pageContent()
    }
    .toolbarConfiguration(this.toolbar())
    .height('100%')
    .width('100%')
  }
}

interface IToolbar{
  text:string
  icon:ResourceStr
  activeIcon:ResourceStr
}