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

module Snowplow

  # Check we have a valid VerbHash.
  #
  # Must contain a single element:
  # "e" => String for event type.
  VerbHash = And[UnaryHash, ({:e => String})]

  # Check we have a valid ModifierHash.
  # This is the second argument passed
  # into all verbs.
  #
  # A Hash containing a ~: key and/or
  # a >>: key
  class ModifierHash

    @@valid_keys = Set::[](:~, :>>)

    def self.valid?(val)
      val.is_a? Hash &&
        val.length <= 2 &&
        TODO
    end
  end 

  # Could be empty too. (Actually this
  # is covered in the ModifierHash's
  # valid?() but better to be explicit.)
  OptionModifierHash = Or[ModifierHash, {}]
end
