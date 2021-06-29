# Keep a little note

## Bing Wallpaper API

### Get URL:
`https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160
`
* idx: indexing date from today (0, yesterday 1)
* n: number of image returns

### Region:
`https://www.bing.com/?setmkt=en-us&setlang=en-uk`


[language Code](http://help.ads.microsoft.com/apex/index/18/en-US/10004#!)

### Return json:

```json
{
  "images": [
    {
      "startdate": "20210619",
      "fullstartdate": "202106190700",
      "enddate": "20210620",
      "url": "/th?id=OHR.BurleighHeads_EN-US4425800469_UHD.jpg&rf=LaDigue_UHD.jpg&pid=hp&w=3840&h=2160&rs=1&c=4",
      "urlbase": "/th?id=OHR.BurleighHeads_EN-US4425800469",
      "copyright": "People surfing at Burleigh Heads, Gold Coast, Australia (© Vicki Smith/Getty Images)",
      "copyrightlink": "/search?q=international+surfing+day&form=hpcapt&filters=HpDate%3a%2220210619_0700%22",
      "title": "Surf's up—Down Under",
      "caption": "Surf's up—Down Under",
      "copyrightonly": "© Vicki Smith/Getty Images",
      "desc": "It's International Surfing Day! Here in the US we may be welcoming summer tomorrow, but these Aussie surfers are saying g'day to the rad waves of winter (which started for them on June 1). Though peak surf season is autumn (that is, our spring) here in the Gold Coast area of Queensland, these tropical beaches offer world-class breaks all year long.",
      "date": "Jun 19, 2021",
      "bsTitle": "Surf's up—Down Under",
      "quiz": "/search?q=Bing+homepage+quiz&filters=WQOskey:%22HPQuiz_20210619_BurleighHeads%22&FORM=HPQUIZ",
      "wp": true,
      "hsh": "8dc7dd0ff6b89173b228fdb2e7a93795",
      "drk": 1,
      "top": 1,
      "bot": 1,
      "hs": []
    }
  ],
  "tooltips": {
    "loading": "Loading...",
    "previous": "Previous image",
    "next": "Next image",
    "walle": "This image is not available to download as wallpaper.",
    "walls": "Download this image. Use of this image is restricted to wallpaper only."
  }
}

```
## Icon size:
* 18x18
* 36x36
* 54x54


## Bug Memo

1. left/right button turns grey after change number of wallpapers
  Reproduce:
  * switch to the wallpaper with maximum index
  * change maximum number of wallpapers in setting
  * update
Solved: error in counting index and button.isenabled executions in buttonCtrl function















