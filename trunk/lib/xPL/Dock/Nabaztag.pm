package xPL::Dock::Nabaztag;

=head1 NAME

xPL::Dock::Nabaztag - xPL::Dock plugin for violet's Nabaztag

=head1 SYNOPSIS

 use xPL::Dock qw/Nabaztag/;
 my $xpl = xPL::Dock->new(name => 'nabaztag');
 $XPL->main_loop();

=head1 DESCRIPTION

This module creates an xPL client for the Violet Nabaztag.

=head1 METHODS

=cut

use strict;
use warnings;

use English qw/-no_match_vars/;
use xPL::Nabaztaglib { 'debug' => 1 };
use xPL::Dock::Plug;

our @ISA = qw(xPL::Dock::Plug);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = "0.3";

__PACKAGE__->make_readonly_accessor($_) foreach (qw/device/);

my $vendor_id = 'tlam';

=head2 C<getopts( )>

This method returns the L<Getopt::Long> option definition for the
plugin.

=cut

sub getopts {
  my $self = shift;
  # use '--cm15a-device /dev/cm15a0' for original current cost
  return
    (
     'nabaztag-verbose+' => \$self->{_verbose},
     'nabaztag-token=s' => \$self->{_token},
     'nabaztag-mac=s' => \$self->{_mac},
     'nabaztag-voice=s' => \$self->{_voice},
    );
}

=head2 C<init(%params)>

=cut

sub init {
  my $self = shift;
  my $xpl = shift;
  my %p = @_;

  # Ugly force vendor ID
  $xpl->{'_vendor_id'} = $vendor_id;

  $self->required_field($xpl,
                        'token',
                        'The --nabaztag-token parameter is required', 1);
  $self->required_field($xpl,
                        'mac',
                        'The --nabaztag-mac parameter is required', 1);
                    
  $self->SUPER::init($xpl, @_);

  my $nab = $self->{_nab} = xPL::Nabaztaglib->new();
  $nab->mac($self->{_mac});
  $nab->key('123');
  $nab->token($self->{_token});

  $xpl->add_xpl_callback(id => 'xpl-cmd-nab', 
                         callback => \&xpl_cmnd_nab,
                         arguments => $self,
                         filter =>
                         {
                          message_type => 'xpl-cmnd',
                          class => 'media',
                          class_type => 'basic',
                         });
                         
  $xpl->add_xpl_callback(id => 'xpl-tts-nab', 
                         callback => \&xpl_tts_nab,
                         arguments => $self,
                         filter =>
                         {
                          message_type => 'xpl-cmnd',
                          class => 'tts',
                          class_type => 'basic',
                         });

  return $self;
}




sub send_xpl_message {
  my $self = shift;
  my $hc = shift;
  my $uc = shift;
  my $cmd = shift;
  my $comment = shift;

  my $xpl = $self->xpl;

  my $xplmsg = xPL::Message->new(message_type => 'xpl-trig',
                                 head => { source => $xpl->id, },
                                 class => 'x10.basic',
                                 body =>
                                 {
                                   device => $hc.$uc,
                                   command => $cmd,
                                 });
  print $xplmsg->summary,"\n";
  $xpl->send($xplmsg);
}


=head2 C<xpl_nab(%xpl_callback_parameters)>

This is the callback that processes incoming xPL messages.  It handles
the incoming control.basic schema messages.

=cut

sub xpl_cmnd_nab {
  my %p = @_;
  my $msg = $p{message};
  my $peeraddr = $p{peeraddr};
  my $peerport = $p{peerport};
  my $self = $p{arguments};
 
  return 1 if ($msg->md ne "nabaztag");
  
  if ($msg->command eq "power") {
    $self->{_nab}->wakeUp() if ($msg->state eq "on");
    $self->{_nab}->sendToSleep() if ($msg->state eq "off");
  }
  return 1;
}

sub xpl_tts_nab {
  my %p = @_;
  my $msg = $p{message};
  my $peeraddr = $p{peeraddr};
  my $peerport = $p{peerport};
  my $self = $p{arguments};
 
  if (defined $msg->voice) {
  }

  $self->{_nab}->sayThis($msg->speech);
  
  return 1;
}


1;
__END__

=head1 EXPORT

None by default.

=head1 SEE ALSO

Author website: http://www.poulpy.com

xPL Perl website: http://www.xpl-perl.org.uk/

Marmitek website: http://www.marmitek.com

=head1 AUTHOR

Nabaztag:
Nicolas Goubaux, E<lt>nicolasg@goubs.netE<gt>

xpl-perl:
Mark Hindess, E<lt>soft-xpl-perl@temporalanomaly.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2010 by Nicolas Goubaux 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
