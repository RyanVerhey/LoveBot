class Reddit
  include HTTParty

  def self.random_post
    response = Reddit.get('http://www.reddit.com/r/random/random.json').parsed_response # http://www.reddit.com/r/random/random.json
    puts "http://reddit.com" + response.first["data"]["children"].first["data"]["permalink"]
    return response
  end

  def self.random_comment(post)
    replies = post[1]["data"]["children"]
    if replies.first
      comments = Reddit.parse_comments(replies)
    else
      puts "NO COMMENTS"
      comments = []
    end
    return comments.sample
  end

  private

  def self.parse_comments(top_level_comments)
    # Recursively go through comments
    comments = []
    top_level_comments.each do |comment|
      comments << comment unless comment["data"]["body"] == "[deleted]"
      if comment["data"]["replies"]["data"]
        comments << Reddit.parse_comments(comment["data"]["replies"]["data"]["children"])
#         p comment["data"]["replies"]["data"]
      end
    end
    return comments.flatten
  end

  def self.reply_to_comment(comment, text)
    # reply to comment with text
  end

  def self.submit(params) # title, message, sr, link = true, save = true, resubmit = false
    title =    params.fetch(:title, nil)
    message =  params.fetch(:message, nil)
    sr =       params.fetch(:subreddit, nil)
    link =     params.fetch(:link, true)
    save =     params.fetch(:save, true)
    resubmit = params.fetch(:resubmit, false)
    if title == nil || message == nil || sr == nil
      raise "You need to have a post title, a message, and a subreddit defined!"
    else
      data = Reddit.login
      modhash = data[0]
      cookie = data[1]
      kind = link ? "link" : "self"
      url = link ? message : false
      text = link ? false : message
      options = { body: {
        kind: kind,
        text: text,
        url: url,
        sr: sr,
        title: title,
        save: save,
        resubmit: resubmit,
        api_type: 'json',
        uh: modhash,
      }, headers: {
        'User-Agent' => 'Barnabus_Bot, proudly built by /u/GildedGrizzly',
        'X-Modhash' => modhash,
        'Cookie' => 'reddit_session=' + cookie
      } }
      response = Reddit.post('http://www.reddit.com/api/submit', options)
    end
  end

  def self.login
    account_info = ReadWrite.fetch_reddit_account_info
    username = account_info[:username]
    password = ENV[account_info[:password_var]]
    options = { body: { user: username, passwd: password, api_type: 'json' } }
    response = Reddit.post("http://www.reddit.com/api/login/", options)
    data = response['json']['data']
    return [data['modhash'], data['cookie']]
  end

end
