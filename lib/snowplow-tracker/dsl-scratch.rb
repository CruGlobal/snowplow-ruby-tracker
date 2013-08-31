tracker = SnowplowTracker.new

# Create a couple of Subjects
end_user = Subject.new(ip_address='x.x.x.x', business_user_id='runkelfinker')
api_user = Subject.new(business_user_id='gpfeed')

# Setup Context
ctx = Context.new('web', app_id='shop')

# Attach the Context to the Subject
end_user pin ctx

# Track some events
tracker.track do
  end_user views web_page
  end_user places sales_order ~: ctx.on(web_page)
  end_user performs struct_event ~: ctx.on(web_page).at(event_tstamp)
  api_user performs unstruct_event ~: Context.new("pc")
end
