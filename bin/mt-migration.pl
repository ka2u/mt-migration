#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib qq($FindBin::Bin/../lib);
use MT::Migration;

MT::Migration->migrate(
    "/home/kaz/mywork/dev/work/mt-migration/blogs",
    "mt",
    "MTOS-5.01-ja.tar.gz",
    "/home/kaz/mywork/dev/work/mt-migration/backup",
    "mt4",
    "mt4",
    "mt4",
);

exit;
