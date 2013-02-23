#  Run our tests, either quietly or with verbose output
all:
	perl -I ../../org.ziptie.adapters.perl/scripts invoke.pl ZipTie::Adapters::Cisco::IOS backup -i samples/c2610.xml > out.xml
	xmltidy out.xml
