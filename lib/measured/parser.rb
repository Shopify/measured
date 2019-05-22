# frozen_string_literal: true
module Measured::Parser
  extend self

  PARSE_REGEX = /
    \A         # beginning of input
    \s*        # optionally any whitespace
    (          # capture the value
      -?       # number can be negative
      \d+      # must have some digits
      (?:      # do not capture
        [\.\/] # period or slash to split fractional part
        \d+    # some digits after it
      )?       # fractional part is optional
    )
    \s*        # optionally any space between number and unit
    (          # capture the unit
      [a-zA-Z] # unit must start with a letter
      [\w-]*   # any word characters or dashes
      (?:      # non capturing group that is optional for multiple words
        \s+    # space in the unit for multiple words
        [\w-]+ # there must be something after the space
      )*       # allow many words
    )
    \s*        # optionally any whitespace
    \Z         # end of unit
  /x

  def parse_string(string)
    raise Measured::UnitError, "Cannot parse blank measurement" if string.blank?

    result = PARSE_REGEX.match(string)

    raise Measured::UnitError, "Cannot parse measurement from '#{string}'" unless result

    [result.captures[0].to_r, result.captures[1]]
  end
end
