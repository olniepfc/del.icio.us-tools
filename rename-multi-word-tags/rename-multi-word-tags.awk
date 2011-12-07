# rename-multi-word-tags v.2011-1206-1856
# A GAWK script to rename multi-(space-separated-)word del.icio.us tags
# Copyright (C) 2011 Olivier Nisole (on.git@edpnet.be)
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# Dependencies: 
# -------------
#    gawk 3.1
#    curl
#
# Usage:
# ------
# $ curl -u USERNAME:PASSWORD https://api.del.icio.us/v1/tags/get | \
#   sed 's/></>\n</g' | sed -n '/^<tag count/ p' | \
#   sed 's/^<tag count=\"\([^\"]\+\)" tag=\"\(.*\)\"\/>$/\1 \2/' \
#   > delicious.tags
# $ gawk -f rename-multi-word-tags.awk delicious.tags

BEGIN {
    print "\nYour Delicious username?"; getline username < ("-")
    print "\nYour delicious password?"; getline password < ("-")
}

NF > 2 { 
    occ = $1
    old = $2
    for (i=3;i<=NF;i++) old = old " " $i

    print "\n----------\n"

    if (occ == 1) print occ " bookmark is tagged with this multi-(space-separated-)word tag:"
    else print occ " bookmarks share this multi-(space-separated-)word tag:"
    print "   “" old "”\n"
    print "You can" 
    print "  (K)eep it like that"
    print "  (R)eplace all spaces with commas"
    print "  (C)hange this tag to (an)other tag(s)"
    print ""

    action = ""
    while (action !~ /^[KkRrCc]$/) {
        print "Your choice: [K/R/C]?"; getline action < ("-")
    }

    if (action ~ /^[Cc]$/ ) {
       do {
            confirm = ""
            print "\nNew tag(s) [!comma separated!]:"; getline new < ("-")
            if (new ~ /[&]/)
                print "\nERROR: Delicious tags can't use the “&“ character."
            else {
                print "\nDo you really want to change"
                print "   “" old "”"
                print "to"
                print "   “" new "”\n?"
                do {
                    print "\nYour choice: [Y/N]?"; getline confirm < ("-")
                } while (confirm !~ /^[YyNn]$/) 
            }
        } while (confirm !~ /^[Yy]$/) 
    }

    if (action ~ /^[Rr]$/) new = gensub(/[ ]/, ",", "g", old)

    if (action ~ /^[RrCc]$/ ) {
        cmd = "curl -u " username ":" password 
        cmd = cmd " -d 'old=" old "&new=" new "'"
        cmd = cmd " https://api.del.icio.us/v1/tags/rename"
        #print cmd
        system("") # portable flush output
        system(cmd)
    }
}

END {
    system("")
}
