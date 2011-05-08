# Nokogiri is required for XML parsing:
begin
  require 'nokogiri'
rescue LoadError
  puts '[ExactTarget] Error: Nokogiri is missing, run "bundle install".'
end

# Standard:
require 'net/https'
require 'uri'
require 'erb'

# Library:
require 'exacttarget/client'
require 'exacttarget/email'
