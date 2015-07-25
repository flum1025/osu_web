osu!Web
===========

##What is it?

osu!のapiからでは取得できないデータをwebから拾ってくるプログラム。  
自動でosu!のWEBにログインし国内ランキングなどを取得することができます。  

  
動作確認はubuntu14.04 ruby1.9.3とOS X Yosemite ruby2.0.0です。

##How to Use
まず、osuの公式サイトからAPIキーを取得してください。  
requireしてから

```
osu_web = Osu_web.new('username', 'password','api_key', 'mode', "userid")
```

で使用することができます。  
username,passwordにはosu!のログインのものを入力してください。  
useridはないなら自動で取得しますが、入力すると少しだけレスポンスが速くなります。  
modeは取得したいモードの数字を入力してください。  
```
osu!standard = 0
osu!Taiko = 1
osu!CatchTheBeat = 2
osu!mania = 3
```

##メソッド一覧
###get\_api\_data
  api経由でユーザーデータを取得します。
###osu\_login
  osu!にログインしてクッキーを取り出します。
###parse\cookies :param cookie_str
  クッキーをパースします。
###get\_user_id
  WEB経由でユーザーIDを取得します。
###get\_user_page :param page
  ユーザーページを取得します。  
  
  >:param  
  
    >>general  ユーザーページのgeneralタブ内のデータを取得します。  
    
    >>leader  ユーザーページのtop ranksタブ内のデータを取得します。  
    
    >>history  ユーザーページのhistoryタブ内のデータを取得します。  
    
    >>beatmaps  ユーザーページのbeatmapsタブ内のデータを取得します。  
    
    >>achievements  ユーザーページのachievementsタブ内のデータを取得します。 
    
###get\_domestic_rank
国内ランクを取得します。  
###next\_domestic_rank_up :param rank_up
指定ランクになるにはどれだけppが必要かを判定します。  
###other_page :param page
osu!のクッキーを使い別のページを取得します。  
例：ランキングページなど  

##Notice
国内ランクを取得する際、自分のユーザーページが200ページ以降にある場合は取得することができません。  
その他エラーが発生した場合はOsuErrorをraiseします。  
一応osu!Standardでもテストしましたが、osu!maniaで使うことを想定していますので、他のモードだとエラーが発生するかもしれません。
  

質問等ありましたらTwitter:[@flum_](https://twitter.com/flum_)までお願いします。

##License

The MIT License

-------
(c) @2015 flum_
