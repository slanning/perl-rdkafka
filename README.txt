RdKafka - Perl bindings for librdkafka C library

See https://github.com/edenhill/librdkafka for the C library.


INSTALLATION

You'll need to install the C library somehow, either yourself
or by installing a "-devel" package.
FWIW, on CentOS 6.8 I installed librdkafka-devel.x86_64 .

To install this module, do the usual:

   perl Makefile.PL
   make
   make test
   make install


COPYRIGHT AND LICENCE

Copyright 2016, Scott Lanning. All rights reserved.

This Perl library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
