# Copyright (c) 2013 Snowplow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

# Author::    Alex Dean (mailto:snowplow-user@googlegroups.com)
# Copyright:: Copyright (c) 2013 Snowplow Analytics Ltd
# License::   Apache License Version 2.0

require 'uri'
require 'contracts'
include Contracts

module Snowplow

  # A line item within a sales order: one or more units
  # of a single SKU.
  # Fields follow Google Analytics closely.  
  # Inherits from Entity
  class SalesOrderItem < Entity

    attr_reader :order_id,
                :sku,
                :name,
                :category,
                :price,
                :quantity

    # Constructor for a SalesOrderItem, i.e. a line
    # item within a SalesOrder
    #
    # TODO
    Contract String, OptionString, OptionString, OptionString, Num, Int => SalesOrderItem
    def initialize(order_id,
                   sku=nil,
                   name=nil,
                   category=nil,
                   price,
                   quantity)

      # TODO: check at least one of sku and name is set

      @order_id = order_id
      @sku = sku
      @name = name
      @category = category
      @price = price
      @quantity = quantity

    end

    # TODO: implement
    def to_payload()

    end

  end 

  # Contract synonyms
  SalesOrderItems = Array[SalesOrderItem]

  # A sales order, aka an ecommerce transaction.
  # Fields follow Google Analytics closely.
  # Is the Direct Object of a place SalesOrder event.
  # Inherits from Entity.
  class SalesOrder < Entity

    attr_reader :order_id, 
                :affiliation,
                :total,
                :tax,
                :shipping,
                :city,
                :state,
                :country,
                :items

    # Constructor for a SalesOrder, i.e. an ecommmerce
    # transaction
    #
    # TODO
    Contract String,
             OptionString,
             Num,
             Num,
             Num,
             OptionString,
             OptionString,
             OptionString,
             Or[SalesOrderItem, SalesOrderItems]
             => SalesOrder
    def initialize(order_id, 
                   affiliation=nil,
                   total,
                   tax,
                   shipping,
                   city=nil,
                   state=nil,
                   country=nil,
                   items)

      @order_id = order_id
      @affiliation = affiliation
      @total = total
      @tax = tax
      @shipping = shipping
      @city = city
      @state = state
      @country = country
      @items = Array(items) # To array if not already
    end

    # TODO: implement
    def to_payload()

    end

  end

  # A custom structured event.
  # Fields follow Google Analytics closely.  
  # Inherits from Entity
  class StructEvent < Entity

    attr_reader :category,
                :action,
                :label,
                :property,
                :value

    # Constructor for a new custom structured event
    #
    # +category+:: the name you supply for the group of
    #              objects you want to track
    # +action+:: a string that is uniquely paired with each
    #            category, and commonly used to define the
    #            type of user interaction for the object
    # +label+:: an optional string to provide additional
    #           dimensions to the event data
    # +property+:: an optional string describing the object
    #              or the action performed on it. This might
    #              be the quantity of an item added to basket
    # +value+:: an optional value that you can use to provide
    #           numerical data about the user event
    Contract String,
             String,
             OptionString,
             OptionString,
             OptionNum
             => StructEvent
    def initialize(category,
                   action,
                   label=nil,
                   property=nil,
                   value=nil)

      @category = category
      @action = action
      @label = label
      @property = property
      @value = value
    end

    # TODO: implement
    def to_payload()

    end

  end

  # A MixPanel- or KISSmetrics-style custom
  # unstructured event, consisting of a name
  # and envelope of arbitrary name:value pairs
  # (represented as a Ruby hash).
  # Inherits from Entity  
  class UnstructEvent < Entity

    attr_reader :name,
                :properties

    # Constructor for a new custom unstructured event
    #
    # +name+:: the name of the event
    # +properties+:: the properties of the event
    Contract String, Hash => UnstructEvent
    def initialize(name, properties)

      @name = name
      @properties = properties
    end

    # TODO: implement
    def to_payload()

    end

  end

  # A web page. Used as an Object
  # (page view) but also as Context
  # (page pings, ecommerce events etc).
  # Inherits from Entity
  class WebPage < Entity

    attr_reader :uri,
                :title

    # Constructor for a new WebPage.
    # The URI of the WebPage must be set.
    #
    # Parameters:
    # +uri+:: URI of this WebPage
    # +title+:: title of this WebPage (i.e. <TITLE>
    #           or customized version of same)
    Contract URI, OptionString => WebPage
    def initialize(uri, title=nil)
      @uri = uri
      @title = title
      nil
    end

    # TODO: implement
    def to_payload()

    end

  end

  # Contract synonyms
  Event = Or[StructEvent, UnstructEvent]
  OptionWebPage = Or[WebPage, nil]

end
