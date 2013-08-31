
# Setup our Collector(s) and Tracker
collector = Snowplow::Collector(:main, cf: 'd1vjp94kduqgnd')
tracker = Snowplow::Tracker.new(collector)

# Create a couple of Subjects
end_user = Snowplow::Subject.new(ip_address='x.x.x.x', business_user_id='runkelfinker')
api_user = Snowplow::Subject.new(business_user_id=Socket.gethostname)

# Setup a couple of Contexts
end_ctx = Snowplow::Context.new('web', app_id='shop')
api_ctx = Snowplow::Context.new('pc', app_id='api')

# We can pin a Context to our Tracker
tracker.pin end_ctx

# Create our events' Objects
web_page = WebPage.new(...) # We will use this for Context too
sales_order = SalesOrder.new(...)
struct_event = StructEvent.new(...)
unstruct_event = UnstructEvent.new(...)

# Track some events
tracker.track do
  end_user views web_page
  end_user places sales_order, ~: end_ctx.on(web_page) # ~: means override/attach context
  end_user performs struct_event, ~: end_ctx.on(web_page).at(event_tstamp)
  api_user performs unstruct_event, ~: api_ctx
end, ~: end_ctx # All events in this do block get the end_ctx unless overridden
