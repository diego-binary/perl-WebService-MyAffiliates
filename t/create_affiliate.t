#!/usr/bin/perl

use strict;
use warnings;
use WebService::MyAffiliates;
use Test::More;

plan skip_all => "ENV MYAFFILIATES_USER/MYAFFILIATES_PASS/MYAFFILIATES_HOST is required to continue."
    unless $ENV{MYAFFILIATES_USER}
    and $ENV{MYAFFILIATES_PASS}
    and $ENV{MYAFFILIATES_HOST};
my $aff = WebService::MyAffiliates->new(
    user => $ENV{MYAFFILIATES_USER},
    pass => $ENV{MYAFFILIATES_PASS},
    host => $ENV{MYAFFILIATES_HOST});

my $res = $aff->create_affiliate({'incomplete' => 'params'});

ok(!$res, 'Returns undef if incomplete parameters are passed');

done_testing();

1;
