package EhrEntityScraper;

use strict;
use warnings;
use DBI;
use LWP::UserAgent;

sub new {
    my ($class, $args_hash) = @_;
    my $self = bless $self, $class;
    $self->initialize($args_hash);
    return $self;
}

sub initialize {
    my ($self, $args) = @_;

    $self->{dbh} = DBI->connect ('dbi:mysql:database=phr', 'root', 'root', {RaiseError => 1, AutoCommit => 1});

    $self->{ehr_entity_user} = $args->{ehr_entity_user};
    $self->{ehr_entity_pass} = $args->{ehr_entity_pass};
    $self->{ehr_entity_url}  = args->{ehr_entity_url};

    $self->{ua} = new LWP::UserAgent(agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.1 (KHTML, like Gecko) Ubuntu/10.10 ' . 
                              'Chromium/14.0.808.0 Chrome/14.0.808.0 Safari/535.1');
}

sub login {
    die "login not overridden";
}

1;
