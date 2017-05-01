#!/usr/bin/env ruby

# file: mns_timeline.rb


require 'sps-sub'
require "sqlite3"
require 'fileutils'
require 'daily_notices'


class MNSTimeline < SPSSub

  def initialize(timeline: 'notices', host: 'sps', port: 59000, dir: '.', options: {})
    
    # note: a valid url_base must be provided
    
    @options = {
      url_base: 'http://yourwebsitehere.co.uk/', 
      dx_xslt: '/xsl/dynarex.xsl', 
      rss_xslt: '/xsl/feed.xsl', 
      target_page: :page, 
      target_xslt: '/xsl/page.xsl'
    }.merge(options)

    super(host: host, port: port)
    @filepath = dir
    @timeline = timeline

  end

  def subscribe(topic='timeline/add')
    super(topic)
  end

  private

  def ontopic(timeline_topic, msg)

    puts "%s: %s %s"  % [timeline_topic, Time.now.to_s, msg.inspect]
          
    topic, id = msg.split('/').values_at 0, -1            
    url_base = @options[:url_base]
    fileid = Time.at(id.to_i).strftime("%Y/%b/%d/").downcase + id + '/index.xml'
    
    url = "%s%s/%s" % [url_base, topic, fileid]
    kvx = Kvx.new url

    add_notice(kvx.body.clone.merge(topic: topic), id)    

  end

  def add_notice(h, id)

    timeline_dir = File.join(@filepath, @timeline)

    notices = DailyNotices.new timeline_dir, 
        @options.merge(identifier: @timeline, title: @timeline.capitalize)

    return_status = notices.add(item: h, id: id)
    
    return if return_status == :duplicate

    dbfilename = File.join(timeline_dir, h[:topic] + '.db')
            
    if File.exists? dbfilename then

      db = SQLite3::Database.new dbfilename   
      
    else

      db = SQLite3::Database.new dbfilename   
      
db.execute <<-SQL
  create table notices (
    ID INT PRIMARY KEY     NOT NULL,
    MESSAGE TEXT
  );
SQL
            
    end   

    db.execute("INSERT INTO notices (id, message) 
            VALUES (?, ?)", [id, msg=h[:description]])    
    sleep 1.5
    
  end

end