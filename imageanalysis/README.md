Installation for Analyzer.rb
----
1. Install MacPorts
    - http://www.macports.org/install.php (Use the .pkg installer)
2. Install ImageMagick via Macports
    - `sudo port install ImageMagick` (This will take a long while)
3. Install RMagick
    - `gem install rmagick`

Analyzer.rb Usage
---
analyzer.rb [--verbose] city_directory
e.g. `ruby analyzer.rb ../images/lat-long-bbox/la`
