The XML files are generated from rdkafka.h files
for the given versions like this (for 0.9.2):

castxml --castxml-gccxml --castxml-cc-gnu-c /usr/bin/gcc -o genscripts/rdkafka-0.9.2.xml genscripts/rdkafka-0.9.2.h

