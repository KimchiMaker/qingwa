import axios, {AxiosError,AxiosResponse}  from  '@ohos/axios'
import common from '@ohos.app.ability.common';
import app from '@ohos.app.ability.UIAbility';


@Entry
@Component
struct Index {
  @State private errorMsg: string = '';   // ✅ 新增：错误提示
  private message: string = ''
  @State username:string=''
  @State password:string=''
  @LocalStorageLink('isAgree') isAgree: boolean = false

  dialogController: CustomDialogController = new CustomDialogController({
    builder: MyDialog()
  })

  aboutToAppear(): void {
    if (this.isAgree===false) {
      this.dialogController.open()
    }
  }

  build() {
    Column(){
      Column(){
        Text('青蛙影院')
          .fontSize(45)
      }.height('10%')
      .margin('40')

      Column({space:10}){
        TextInput({placeholder:'用户名', text: this.username})
          .onChange((value: string) => {
            this.username = value
          })
          .height(50)
          .backgroundColor(Color.White)
        Row() {
          TextInput({ placeholder: '请输入密码',text: this.password})
            .onChange((value: string) => {
            this.password = value
          })
            .type(InputType.Password)
            .backgroundColor(Color.White)
        }
        .width('100%')
        if (this.errorMsg.length > 0) {
          Text(this.errorMsg)
            .fontSize(12)
            .fontColor(Color.Red)
            .margin({ top: 4 })
        }
      }.height('25%')
      .padding(15)
      Column() {
        Button('登录')
          .width(200)

          .onClick(async () => {
            this.errorMsg = '';
            if (this.username.trim().length <= 0 || this.password.trim().length <= 0) {
              this.errorMsg = '用户名密码不能为空';
              this.getUIContext().getPromptAction().showToast({
                message: '用户名密码不能为空'
              })
              return
            }

            axios.post<Ia, AxiosResponse<Ib>, IUser>('http://192.168.3.17:5000/api/login', {
              username: this.username.trim(),
              password: this.password.trim()
            })
              .then((response: AxiosResponse<Ib>) => {
                if (response.data.success) {
                  console.log('登录成功');
                  this.getUIContext().getRouter().pushUrl({
                    url: "pages/Pagenew"
                  })
                } else {
                  this.errorMsg = response.data.message || '用户名或密码错误';
                  console.log('登录失败');
                  this.getUIContext().getPromptAction().showToast({
                    message: '用户名或密码错误'
                  })
                }
              })
              .catch((error: AxiosError) => {
                this.errorMsg = '登录失败,账号与密码不一致';   // ✅ 直接写死
                console.info(JSON.stringify(error));
              });
          })
      }
      .height('10%')

      Column(){
        Button('注册')
          .width(200)
          .onClick(async () => {
            if (this.username.trim().length <= 0 || this.password.trim().length <= 0) {
              this.getUIContext().getPromptAction().showToast({
                message: '用户名密码不能为空'
              })
              return
            }

            axios.post<Ia, AxiosResponse<Ib>, IUser>('http://192.168.3.17:5000/api/register', {
              username: this.username.trim(),
              password: this.password.trim()
            })
              .then((response: AxiosResponse<Ib>) => {
                if (response.data.success) {
                  this.getUIContext().getPromptAction().showToast({
                    message: '注册成功'
                  })
                  console.log('注册成功');
                } else {
                  this.errorMsg = response.data.message || '注册失败';
                  console.log('注册失败');
                  this.getUIContext().getPromptAction().showToast({
                    message: '用户名或密码错误'
                  })
                }
              })
              .catch((error: AxiosError) => {
                this.errorMsg = '账户已被注册';
                console.info(JSON.stringify(error));
              });
          })
        Row() {
          Toggle({ type: ToggleType.Checkbox, isOn: this.isAgree })
            .onChange((isChecked: boolean) => {
              this.isAgree = isChecked
            })
          Text('请勾选用户隐私协议')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })
      }
      .height('15%')

    }
    .height('100%')
    .width('100%')
    .backgroundImage($r('app.media.frog'))
    .backgroundImageSize({width:'100%',height:'100%'})

  }
}

@CustomDialog
struct MyDialog{
  controller: CustomDialogController = new CustomDialogController({
    builder: MyDialog()
  })

  build() {
    Column({space:10}){
      Text('欢迎使用青蛙影院')
        .margin({top:10})
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      TextArea({text:'感谢您信任并使用青蛙影院我们将通过《用户协文》和《青蛙影院隐私政策》帮助您了解找们收集、使用、存储和共享个人信息的情况，特别是我们所采集的个人信息类型与用途的对应关系。此外，您还能了解到您所享有的相关权利及实现途径，如您同意，请点击下方按钮开始接受我们的服务'})
        .backgroundColor(Color.White)

      Button('同意')
        .width(100)
        .onClick(() => {
          AppStorage.set("isAgree", true)
          this.controller.close()
          this.controller = new CustomDialogController({
            builder: MyDialog(),
            cancel: () => { AppStorage.set('isAgree', true) }
          })
        })

      Button('不同意')
        .width(100)
        .onClick(()=>{
          (getContext(this) as common.UIAbilityContext).terminateSelf();
        })
    }
    .width('90%')
  }
}

interface Ia{
  username:string
  password:string
}

interface Ib{
  success:boolean
  message:string
  token:string
  user: IUser[]
}

interface IUser{
  username:string
  password:string
}