# Copyright (c) 2013-2014 SnowPlow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

# Author:: Alex Dean, Fred Blundun (mailto:support@snowplowanalytics.com)
# Copyright:: Copyright (c) 2013-2014 SnowPlow Analytics Ltd
# License:: Apache License Version 2.0

require 'net/http'
require 'contracts'
include Contracts

module Snowplow

  class Tracker

    @@version = TRACKER_VERSION
    @@default_encode_base64 = true
    @@default_platform = 'pc'
    @@default_vendor = 'com.snowplowanalytics'
    @@supported_platforms = ['pc', 'tv', 'mob', 'cnsl', 'iot']

    Contract String, Maybe[String], Maybe[String], Bool => Tracker
    def initialize(endpoint, namespace=nil, app_id=nil, encode_base64=@@default_encode_base64)
      @collector_uri = as_collector_uri(endpoint)
      @standard_nv_pairs = {
        'tna' => namespace,
        'tv'  => @@version,
        'p'   => @@default_platform,
        'aid' => app_id
      }
      @config = {
        'encode_base64' => encode_base64
      }
      self
    end

    Contract String => String
    def as_collector_uri(host)
      "http://#{host}/i"
    end

    Contract nil => Num
    def get_transaction_id
      rand(100000..999999)
    end

    Contract nil => Num
    def get_timestamp
      Time.now.to_i
    end

    Contract Payload => [Bool, Num]
    def http_get(payload)
      r = Net::HTTP.get_response(URI(@collector_uri + '?' + URI.encode_www_form(payload.context)))
      if r.code.to_i < 0 or 400 <= r.code.to_i # TODO: add set of http errors
        return false, r.code.to_i
      else
        return true, r.code.to_i
      end
    end

    # Setter methods

    Contract String => String
    def set_platform(value)
      if @@supported_platforms.include?(value)
        @standard_nv_pairs['p'] = value
      else
        raise "#{value} is not a supported platform"
      end
    end

    Contract String => String
    def set_user_id(user_id)
      @standard_nv_pairs['uid'] = user_id
    end

    Contract Num, Num => String
    def set_screen_resolution(width, height)
      @standard_nv_pairs['res'] = "#{width}x#{height}"
    end

    Contract Num, Num => String
    def set_viewport(width, height)
      @standard_nv_pairs['vp'] = "#{width}x#{height}"
    end

    Contract Num => Num
    def set_color_depth(depth)
      @standard_nv_pairs['cd'] = depth
    end

    Contract String => String
    def set_timezone(timezone)
      @standard_nv_pairs['tz'] = timezone
    end

    Contract String => String
    def set_lang(lang)
      @standard_nv_pairs['lang'] = lang
    end

    # Tracking methods

    Contract Payload => [Bool, Num]
    def track(pb)
      pb.add_dict(@standard_nv_pairs)
      self.http_get(pb)
    end

    Contract String, Maybe[String], Maybe[String], Maybe[Hash] => [Bool, Num]
    def track_page_view(page_url, page_title=nil, referrer=nil, context=nil, tstamp=nil)
      pb = Snowplow::Payload.new
      pb.add('e', 'pv')
      pb.add('url', page_url)
      pb.add('page', page_title)
      pb.add('refr', referrer)
      pb.add('evn', @@default_vendor)
      pb.add_json(context, @config['encode_base64'], 'cx', 'co')
      tid = self.get_transaction_id
      pb.add('tid', tid)
      if tstamp.nil?
        tstamp = get_timestamp
      end
      pb.add('dtm', tstamp)
      self.track(pb)
    end

    Contract Hash => [Bool, Num]
    def track_ecommerce_transaction_item(argmap)
      pb = Snowplow::Payload.new
      pb.add('e', 'ti')
      pb.add('ti_id', argmap['order_id'])
      pb.add('ti_sk', argmap['sku'])
      pb.add('ti_pr', argmap['price'])
      pb.add('ti_qu', argmap['quantity'])
      pb.add('ti_nm', argmap['name'])
      pb.add('ti_ca', argmap['category'])
      pb.add('ti_cu', argmap['currency'])
      pb.add('evn', @default_vendor)
      pb.add_json(argmap['context'], @config['encode_base64'], 'cx', 'co')
      pb.add('tid', argmap['tid'])
      pb.add('dtm', argmap['tstamp'])
      self.track(pb)
    end

    Contract Hash, Array, Maybe[Hash], Maybe[Num] => ({"transaction_result" => [Bool, Num], "item_results" => ArrayOf[[Bool, Num]]})
    def track_ecommerce_transaction(transaction, items,
                                    context=nil, tstamp=nil)
      pb = Snowplow::Payload.new
      pb.add('e', 'tr')
      pb.add('tr_id', transaction['order_id'])
      pb.add('tr_tt', transaction['total_value'])
      pb.add('tr_af', transaction['affiliation'])
      pb.add('tr_tx', transaction['tax_value'])
      pb.add('tr_sh', transaction['shipping'])
      pb.add('tr_ci', transaction['city'])
      pb.add('tr_st', transaction['state'])
      pb.add('tr_co', transaction['country'])
      pb.add('tr_cu', transaction['currency'])
      pb.add('evn', @@default_vendor)
      pb.add_json(context, @config['encode_base64'], 'cx', 'co')
      tid = self.get_transaction_id
      pb.add('tid', tid)
      if tstamp.nil?
        tstamp = get_timestamp
      end
      pb.add('dtm', tstamp)

      transaction_result = self.track(pb)
      item_results = []

      for item in items
        item['tstamp'] = tstamp
        item['tid'] = tid
        item['order_id'] = transaction['order_id']
        item['currency'] = transaction['currency']
        item_results.push(track_ecommerce_transaction_item(item))
      end

      {"transaction_result" => transaction_result, "item_results" => item_results}
    end

    Contract String, String, Maybe[String], Maybe[String], Maybe[Num], Maybe[Hash], Maybe[Num] => [Bool, Num]
    def track_struct_event(category, action, label=nil, property=nil, value=nil, context=nil, tstamp=nil)
      pb = Snowplow::Payload.new
      pb.add('e', 'se')
      pb.add('se_ca', category)
      pb.add('se_ac', action)
      pb.add('se_la', label)
      pb.add('se_pr', property)
      pb.add('se_va', value)
      pb.add_json(context, @config['encode_base64'], 'cx', 'co')
      tid = self.get_transaction_id
      pb.add('tid', tid)
      if tstamp.nil?
        tstamp = get_timestamp
      end
      pb.add('dtm', tstamp)
      self.track(pb)
    end

    Contract String, Maybe[String],  Maybe[Hash], Maybe[Num] => [Bool, Num]
    def track_screen_view(name, id=nil, context=nil, tstamp=nil)
      self.track_unstruct_event('screen_view', {'name' => name, 'id' => id}, @@default_vendor, context, tstamp)
    end

    Contract String, Hash, Maybe[String], Maybe[Hash], Maybe[Num] => [Bool, Num]
    def track_unstruct_event(event_name, dict, event_vendor=nil, context=nil, tstamp=nil)
      pb = Snowplow::Payload.new
      pb.add('e', 'ue')
      pb.add('ue_na', event_name)
      pb.add_json(dict, @config['encode_base64'], 'ue_px', 'ue_pr')
      pb.add('evn', event_vendor)
      pb.add_json(context, @config['encode_base64'], 'cx', 'co')
      tid = self.get_transaction_id
      pb.add('tid', tid)
      if tstamp.nil?
        tstamp = get_timestamp
      end
      pb.add('dtm', tstamp)
      self.track(pb)
    end

    private :track_ecommerce_transaction_item

  end

end

