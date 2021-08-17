#!/usr/bin/perl

use strict;
# use warnings;
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

$res = $aff->create_affiliate({
    'first_name'    => 'Chales',
    'last_name'     => 'Babbage',
    'date_of_birth' => '1871-10-18',
    'individual'    => 1,
    'phone_number'  => '+4412341234',
    'address'       => 'Some street',
    'city'          => 'Some City',
    'state'         => 'Some State',
    'postcode'      => '1234',
    'website'       => 'https://locahost.com/',
    'agreement'     => 1,
    'username'      => 'charles_babbage.com',
    'email'         => 'charles@babbage.com',
    'country'       => 'GB',
    'password'      => 's3cr3t',
    'individual'    => 'individual',
    'plans'         => '2,4',
});

ok($res, 'Returns the created account');

done_testing();

1;
