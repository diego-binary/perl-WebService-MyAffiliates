#!/usr/bin/perl

use strict;
use warnings;
use WebService::MyAffiliates;
use Test::More;
use Test::MockModule qw/strict/;

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

my $mock_aff = Test::MockModule->new('WebService::MyAffiliates');

$mock_aff->mock(
    'request',
    sub {
        return +{
            'INIT' => {
                'ERROR_COUNT' => 1,
                'ERROR'       => {
                    'MSG'    => 'An account with this email already exists.',
                    'DETAIL' => 'email'
                }}};

    });

my $args = {
    'first_name'    => 'Charles',
    'last_name'     => 'Babbage',
    'date_of_birth' => '1871-10-18',
    'individual'    => 'individual',
    'phone_number'  => '+4412341234',
    'address'       => 'Some street',
    'city'          => 'Some City',
    'state'         => 'Some State',
    'postcode'      => '1234',
    'website'       => 'https://www.example.com/',
    'agreement'     => 1,
    'username'      => 'charles_babbage.com',
    'email'         => 'repeated@email.com',
    'country'       => 'GB',
    'password'      => 's3cr3t',
    'plans'         => '2,4',
};

$res = $aff->create_affiliate($args);

ok(!$res, 'Returns undef in case of a single error');

$mock_aff->mock(
    'request',
    sub {
        return +{
            'INIT' => {
                'ERROR_COUNT' => 2,
                'ERROR'       => [{
                        'MSG'    => 'An account with this email already exists.',
                        'DETAIL' => 'email'
                    },
                    {
                        'DETAIL' => 'username',
                        'MSG'    => 'Username not available'
                    }]}};

    });

$res = $aff->create_affiliate($args);

ok(!$res, 'Returns undef in case of multiple errors');

done_testing();

1;
