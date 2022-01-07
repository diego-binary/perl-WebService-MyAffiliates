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
            'INIT' => {
                'ERROR_COUNT'    => 0,
                'WARNING_COUNT'  => 1,
                'WARNING_DETAIL' => {
                    'DETAIL' => 'password',
                    'MSG'    => 'Setting a password for a new affiliate is optional and will be deprecated in future'
                },
                'USERNAME' => 'charles_babbage',
                'PASSWORD' => 's3cr3t',
                'PARENT'   => 0,
                'USERID'   => 170890,
                'COUNTRY'  => 'GB',
                'LANGUAGE' => 0,
                'EMAIL'    => 'repeated@email.com'
            }};
    });

is($aff->user_status(USER_IDS => 1), undef, 'Returns undef in case of error ');

done_testing();

1;
