require 'net/https'
require 'json'

require File.join(File.expand_path('../', __FILE__), 'osu_api.rb')

class OsuError < Exception; end

class Osu_web
  attr_accessor :cookie, :username, :password, :userid, :location, :playcount, :level, :pp_rank, :pp_raw, :accuracy, :mode
  
  def initialize(username, password, api_key, mode, userid=nil)
    @osu_api = Osu_Application.new(api_key)
    self.mode = mode
    self.username = username
    self.password = password
    @https = Net::HTTP.new('osu.ppy.sh', 443)
    @https.use_ssl = true
    @https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    osu_login
    if userid.nil?
      get_user_id
    else
      self.userid = userid
    end
    get_api_data
  end
  
  def get_api_data
    status, result = @osu_api.osu_api("/api/get_user", "&u=#{self.username}&m=#{self.mode}")
    self.location = result[0]['country']
    self.playcount = result[0]['playcount']
    self.level = result[0]['level']
    self.pp_rank = result[0]['pp_rank']
    self.pp_raw = result[0]['pp_raw']
    self.accuracy = result[0]['accuracy']
  end
  
  def osu_login
    response = @https.start{|https|
      https.post('/forum/ucp.php?mode=login', "username=#{self.username}&password=#{self.password}&login=login")
    }
    cookies = ""
    response.get_fields('set-cookie').each {|cookie|
      cookies << cookie << " "
    }
    self.cookie = parse_cookies(cookies).join(" ").gsub(/HttpOnly/, "").gsub(/expires.*?;/, "").gsub(/\s\s/, " ")
    raise OsuError, "You have specified an incorrect username or password." if /^__cfduid=.+?; path=\/; domain=\.ppy\.sh; ;$/ =~ self.cookie
  end
  
  def parse_cookies(cookie_str)
    if cookie_str == nil
      return
    end
    cookies = cookie_str.split(/\s*;,\s*/)
    for i in 0..cookies.size - 1
      cookies[i].strip!
      pos = cookies[i].rindex(";")
      if pos != (cookies[i].size - 1)
        cookies[i] = cookies[i] + ";"
      end
    end
    return cookies
  end
  
  def get_user_id
    response = @https.start{|https|
      https.get('/', {'Cookie'=>self.cookie})
    }
    if /var\slocalUserId\s=\s(\d+);/ =~ response.body
      userid = $1
    else
      raise OsuError, "Not Found User ID"
    end
    self.userid = userid
  end
  
  def get_user_page(page)
    raise OsuError, "Wrong this parameter" unless /^(general|leader|history|beatmaps|achievements)$/ =~ page
    response = @https.start{|https|
      https.get("/pages/include/profile-#{page}.php?u=#{self.userid}&m=#{self.mode}", {'Cookie'=>self.cookie})
    }
    return response.body
=begin
    general        https://osu.ppy.sh/pages/include/profile-general.php?u=4108244&m=3
    top ranks      https://osu.ppy.sh/pages/include/profile-leader.php?u=4108244&m=3
    history        https://osu.ppy.sh/pages/include/profile-history.php?u=4108244&m=3
    beatmaps       https://osu.ppy.sh/pages/include/profile-beatmaps.php?u=4108244&m=3
    achievements   https://osu.ppy.sh/pages/include/profile-achievements.php?u=4108244&m=3
=end
  end
  
  def get_domestic_rank
    if /\.gif'\/>\n<\/a>\n#(.+?)\n<\/span>/ =~ get_user_page("general")
      domestic_rank = $1.gsub(/,/, "")
    else
      raise OsuError, "Failed to get domestic_rank"
    end
    return domestic_rank
  end
  
  def next_domestic_rank_up(rank_up)
    rank = get_domestic_rank.to_i
    page = (rank / 50).ceil + 1
    raise OsuError, "Your rank is too low." if page > 200
    response = other_page("/p/pp/?c=#{self.location}&m=#{self.mode}&s=3&o=1&f=&page=#{page}")
    if /<tr class='' onclick='document\.location="\/u\/#{self.userid}"'>\n<td><b>#(\d+)<\/b><\/td>/m =~ response
      rank = $1.to_i
    else
      raise OsuError, "Failed to get your ranking"
    end
    next_rank = rank - rank_up
    next_page = (next_rank / 50).ceil + 1
    response = other_page("/p/pp/?c=#{self.location}&m=#{self.mode}&s=3&o=1&f=&page=#{next_page}")
    if /<td><b>##{next_rank}<\/b><\/td>\n<td><img class='flag' src="\/\/s.ppy.sh\/images\/flags\/#{self.location.swapcase}.gif" title=""\/> <a href='\/u\/(\d+)'>.+?<\/a><\/td>\n<td>(.+?)%<\/td>\n<td><span>(.+?)<\/span><\/td>\n<td>\n<span style='font-weight:bold'>(.+?)<\/span>/m =~ response
      opp_user = $1
      opp_pp = $4.gsub(/,/, "").to_i
    else
      raise OsuError, "Failed to get your ranking"
    end
    return (opp_pp - self.pp_raw.to_i), opp_user
  end
  
  def other_page(page)
    response = @https.start{|https|
      https.get(page, {'Cookie'=>self.cookie})
    }
    return response.body
  end
end

#osu_web = Osu_web.new('username', 'password','api_key', '3', "userid")
#p osu_web.next_domestic_rank_up(50)