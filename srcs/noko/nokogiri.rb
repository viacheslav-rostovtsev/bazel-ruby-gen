require 'nokogiri'

# Fetch and parse HTML document
doc = Nokogiri::HTML("<body>foo</body>")
print doc
