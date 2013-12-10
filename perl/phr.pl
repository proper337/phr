#!/usr/bin/perl
#
#
# $Id: $

use strict;
use warnings;

use DBI;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use HTML::TreeBuilder::XPath;
use JSON -support_by_pp;
use Data::Dumper;
use EhrEntityScraper::Scrapers qw(getScraper);

my ($dbh, $sth);
$dbh = DBI->connect ('dbi:mysql:database=phr', 'root', 'root', {RaiseError => 1, AutoCommit => 1});

scrape_for_user_ehr_entity(@ARGV);

sub scrape_for_user_ehr_entity {
    my ($user_email, @ehr_entities) = @_;
    my $user = $dbh->selectall_hashref("select * from users where email=?", "email", {}, $user_email);
    my $user_id = $user->{$user_email}{id};

    die "no ehr_entities specified" if (!scalar(@ehr_entities));
    print "user: $user_email [";
    for my $entity_name (@ehr_entities) {
        my $ehr_entity = $dbh->selectall_hashref("select * from ehr_entities where name=?", "name", {}, $entity_name);
        my $ehr_entity_id = $ehr_entity->{$entity_name}{id};
        my $user_ehr   = $dbh->selectall_hashref("select * from user_has_these_ehrs where userId=? and ehrEntityId=?", 
                                               "userId", {}, $user_id, $ehr_entity_id);

        my $user_ehr_entity_scraper = getScraper(
                                                 $ehr_entity->{$entity_name}{name},
                                                 {
                                                  ehr_entity_user => $user_ehr->{$user_id}{ehrUserId},
                                                  ehr_entity_pass => $user_ehr->{$user_id}{ehrPassword},
                                                  ehr_entity_url  => $ehr_entity->{$entity_name}{url}
                                                 }
                                                );
        if ($user_ehr_entity_scraper->login() ||
            $user_ehr_entity_scraper->postprocess()) {
        }
        print " $entity_name";
    }
    print " ]";
}

sub write_user {
    my ($email, $first, $last, $password) = @_;
    $sth = $dbh->prepare ("insert into users(status, email, firstName, lastName, password) " .
                          "values(\'Active\',$email, $first, $last, $password) " . "on duplicate key update seen=now()");
    $sth->execute;
}
