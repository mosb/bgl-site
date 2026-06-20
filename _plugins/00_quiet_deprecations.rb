# Opt in to ActiveSupport 7.x to_time timezone handling so the build stops
# warning about it. :zone is the correct value for AS 7.1+ (not `true`,
# which AS 7.2 itself deprecates).
require "active_support"
if ActiveSupport.respond_to?(:to_time_preserves_timezone=)
  ActiveSupport.to_time_preserves_timezone = :zone
end
