export default class PageResource {
  title: string;
  img?: Resource;
  others?: string;

  constructor(title: string, img?: Resource, others?: string) {
    this.title = title;
    this.img = img;
    this.others = others;
  }
}