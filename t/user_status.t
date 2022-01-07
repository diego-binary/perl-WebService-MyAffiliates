#!/usr/bin/perl

use strict;
use warnings;
use WebService::MyAffiliates;
use Test::More;
use Test::Exception;
use Test::MockModule;

my $aff = WebService::MyAffiliates->new(
    user => 'user',
    pass => 'pass',
    host => 'host'
);

my $mock_aff = Test::MockModule->new('WebService::MyAffiliates');

$mock_aff->mock(
    'request',
    sub {
        return +{
            'INIT' => {
                'ERROR_COUNT' => 0,
                'WARNING_COUNT' => 0,
            }};

    });

throws_ok( sub {$aff->user_status()}, qr/A HASH or HASHREF with USER_IDS attribute is expected/, 'Fails if HASH or HASHREF is passed');
throws_ok( sub {$aff->user_status({})}, qr/A HASH or HASHREF with USER_IDS attribute is expected/, 'Fails if HASHREF is empty');
throws_ok( sub {$aff->user_status((attr => 'attr'))}, qr/A HASH or HASHREF with USER_IDS attribute is expected/, 'Fails if no USER_IDS attributte is passed in HASH');
throws_ok( sub {$aff->user_status({attr => 'attr'})}, qr/A HASH or HASHREF with USER_IDS attribute is expected/, 'Fails if no USER_IDS attributte is passed in HASHREF');


throws_ok( sub { $aff->user_status(USER_IDS => 0) }, qr /USER_IDS must be positive integers/, ' USER_IDS must be a positive integer' );
throws_ok( sub { $aff->user_status(USER_IDS => ['not_int', 1]) }, qr /USER_IDS must be positive integers/, 'All USER_IDS must be a positive integers' );

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

is($aff->user_status(USER_IDS => 1), undef, 'Returns undef in case of error ');


$mock_aff->mock(
    'request',
    sub {
        return +{
          'USER' => [
                      {
                        'STATUS' => 'denied',
                        'ID' => '1'
                      },
                      {
                        'ID' => '2',
                        'STATUS' => 'denied'
                      }
                    ],
          'INIT' => {}
        };
    });

my $ret = $aff->user_status(USER_IDS => [1,2]);
is(ref $ret, 'HASH', 'Returns a HASHREF for multiple user ids passed');
is(ref $ret->{USER}, 'ARRAY', 'Returns an ARRAYREF when multiple ids are passed');

$mock_aff->mock(
    'request',
    sub {
        return +{
          'USER' => {
                    'STATUS' => 'accepted',
                    'ID' => '1'
                    },
          'INIT' => {}
        };
    });

$ret = $aff->user_status(USER_IDS => 1, status => 'accepted');
is(ref $ret, 'HASH', 'Returns a HASHREF for single id passed');
is(ref $ret->{USER}, 'HASH', 'Returns an HASHREF when a single id is passed');

done_testing();

1;
