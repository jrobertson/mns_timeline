#!/usr/bin/env ruby

# file: mns_timeline.rb


require 'sps-sub'
require 'fileutils'
require 'daily_notices'
require 'recordx_sqlite'


class MNSTimeline < SPSSub

  def initialize(timeline: 'notices', host: 'sps', port: 59000, 
                 dir: '.', options: {})
    
    # note: a valid url_base must be provided
    
    @options = {
      url_base: 'http://yourwebsitehere.co.uk/', 
      dx_xslt: '/xsl/dynarex.xsl', 
      rss_xslt: '/xsl/feed.xsl', 
      target_page: :page, 
      target_xslt: '/xsl/page.xsl'
    }.merge(options)

    super(host: host, port: port)
    
    timeline_dir = File.join(dir, timeline)

    @notices = DailyNotices.new timeline_dir, 
        @options.merge(identifier: timeline, title: timeline.capitalize)
    
    dbfilename = File.join(timeline_dir, 'timeline.db')
    
    table = {
      notices: {
        id: 0, 
        date: Date.today,
        topic: '',
        title: '', 
        description: '',
        link: ''
      }
    }
    @rxnotices = RecordxSqlite.new(dbfilename, table: table)

  end

  def subscribe(topic='timeline/add')
    super(topic)
  end

  private

  def ontopic(timeline_topic, msg)

    puts "%s %s: %s"  % [Time.now.to_s, timeline_topic, msg.inspect]
          
    topic, id = msg.split('/').values_at 0, -1            

    url_base = @options[:url_base]
    fileid = Time.at(id.to_i)
      .strftime("%Y/%b/%-d/").downcase + id + '/index.xml'
    
    url = "%s%s/%s" % [url_base, topic, fileid]

    kvx = Kvx.new url

    add_notice(kvx.body.clone.merge(topic: topic), id, topic)

  end

  def add_notice(h, id, topic)

    return_status = @notices.add(item: h, id: id)
    
    return if return_status == :duplicate
    
    record = {
      id: id,
      date: Time.at(id.to_i).to_s,
      topic: topic,
      title: h[:title],
      description: h[:description],
      link: h[:link]      
    }
            
    @rxnotices.create record
    
  end

end