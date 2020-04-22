require 'terminal-table'

rows = []
rows << ['One', 1]
rows << ['Two', 2]
rows << ['Three', 3]
table = Terminal::Table.new :rows => rows

puts table

# +-------+---+
# | One   | 1 |
# | Two   | 2 |
# | Three | 3 |
# +-------+---+