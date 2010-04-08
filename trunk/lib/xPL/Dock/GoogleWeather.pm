package xPL::Dock::GoogleWeather;

=head1 NAME

xPL::Dock::GoogleWeather - xPL::Dock plugin for GoogleWeather monitoring

=head1 SYNOPSIS

  use xPL::Dock qw/GoogleWeather/;
  my $xpl = xPL::Dock->new();
  $xpl->main_loop();

=head1 DESCRIPTION

This L<xPL::Dock> plugin adds Google Weather monitoring.

=head1 METHODS

=cut

use strict;
use warnings;
use encoding 'utf8';

use English qw/-no_match_vars/;
use xPL::Dock::Plug;
use LWP::Simple;
use XML::Simple;
use Unicode::String;

our @ISA = qw(xPL::Dock::Plug);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

__PACKAGE__->make_readonly_accessor($_) foreach (qw/interval server/);

=head2 C<getopts( )>

This method returns the L<Getopt::Long> option definition for the
plugin.

=cut

sub getopts {
  my $self = shift;
  $self->{_interval} = 120;
  $self->{_cp} = '06800';
  return
    (
     'googleweather-verbose+' => \$self->{_verbose},
     'googleweather-poll-interval=i' => \$self->{_interval},
     'googleweather-cp=s' => \$self->{_cp},
    );
}

=head2 C<init(%params)>

=cut

sub init {
  my $self = shift;
  my $xpl = shift;
  my %p = @_;

  $self->SUPER::init($xpl, @_);

  $xpl->add_timer(id => 'GoogleWeather',
                  timeout => -$self->interval,
                  callback => sub { $self->poll(); 1 });

  $self->{_buf} = '';
  $self->{_url} = 'http://www.google.com/ig/api?weather=06800&hl=fr';
  $self->{_xml} = new XML::Simple;
  return $self;
}

=head2 C<poll( )>

This method is the timer callback that polls the mythtv daemon.

=cut

sub poll {
  my $self = shift;

  my $content = get $self->{_url}; 
  unless ($content) {
    warn "Can't get $self->{_url} \n";  
    return 1;
  }
	#print $content;
	#my $u = Unicode::String->new($content);
	my  $u =  Encode::decode_utf8($content);
  my $data = $self->{_xml}->XMLin($u);

    $self->xpl->send(message_type => 'xpl-stat', class => 'sensor.basic',
                     body => { device => $self->xpl->instance_id.'-gweather',
                               type => 'temp',
                               current => $data->{weather}->{current_conditions}->{temp_c}->{data},
                               units => 'c' });
  return 1;
}

1;
__END__

=head1 EXPORT

None by default.

=head1 SEE ALSO

xPL::Dock(3)

Project website: http://www.xpl-perl.org.uk/

MythTV website: http://www.mythtv.org/

=head1 AUTHOR

Mark Hindess, E<lt>soft-xpl-perl@temporalanomaly.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2008, 2009 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
