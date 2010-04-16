package xPL::Dock::Mirror;

=head1 NAME

xPL::Dock::Mirror - xPL::Dock plugin for violet's Mirror 

=head1 SYNOPSIS

 use xPL::Dock qw/Mirror/;
 my $xpl = xPL::Dock->new(name => 'mirror');
 $XPL->main_loop();

=head1 DESCRIPTION

This module creates an xPL client for the Violet Nabaztag.

=head1 METHODS

=cut

use strict;
use warnings;

use English qw/-no_match_vars/;
use xPL::Dock::Plug;
use xPL::IOHandler;

our @ISA = qw(xPL::Dock::Plug);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = "0.3";

__PACKAGE__->make_readonly_accessor($_) foreach (qw/device/);

{
 package xPL::IORecord::MirrorHex;
 use base 'xPL::IORecord::Simple';
 sub read { 
  $_[1] =~ s/^\x00*//;
	 sleep 0.5;
  if (!length $_[1]) {
    $_[0]->new(raw => $_[1]);
    return 1;
  }
  my $len = 20;

   $_[0]->new(raw => substr $_[1], 0, $len+1, '')
   }
 1;
}

my $vendor_id = 'tlam';

=head2 C<getopts( )>

This method returns the L<Getopt::Long> option definition for the
plugin.

=cut

sub getopts {
  my $self = shift;
  # use '--mirror-device /dev/hidraw0' for original current cost
  return
    (
     'mirror-verbose+' => \$self->{_verbose},
     'mirror-device=s' => \$self->{_device},
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
                        'device',
                        'The --mirror-device parameter is required', 1);
                    
  $self->SUPER::init($xpl, @_);

  open(my $rh, '<', $self->{_device}) or die "could not open $self->{_device}";
  my $io = $self->{_io} = 
    xPL::IOHandler->new(xpl => $self->{_xpl}, verbose => $self->verbose,
                        input_handle => $rh,
                        input_record_type => 'xPL::IORecord::MirrorHex',
                        reader_callback => sub { $self->mirror_reader(@_) });
  
  return $self;
}

=head2 C<xpl_nab(%xpl_callback_parameters)>

This is the callback that processes incoming xPL messages.  It handles
the incoming control.basic schema messages.

=cut

sub mirror_reader {
  my ($self, $handler, $msg, $last) = @_;
  my $current = ""; 
  my $type = ""; 
  my $device = ""; 
  my $xpl = $self->xpl;

  if ($msg->raw =~ /\x01\x04/) {
    $type = "input";
    $current = "high";
    $device = "mirror";
  } 
  if ($msg->raw =~ /\x01\x05/) {
    $type = "input";
    $current = "low";
    $device = "mirror";
  } 
  if ($msg->raw =~ /\x02\x01\x00\x00(.{10})/) {
    $device = (sprintf 'mr.%*v.2X', ':', $1);
    $current = "0";
    $type = "distance";
  } 
  if ($msg->raw =~ /\x02\x02\x00\x00(.{10})/) {
    $device = sprintf ('mr.%*v.2X', ':', $1);
    $current = "42";
    $type = "distance";
  }
  
  if ($device) {
    my $msg =
      xPL::Message->new(head => { source => $xpl->id },
                        message_type => 'xpl-trig',
                        class => 'sensor.basic',
                        body =>
                        {
                         device => $device,
                         type => $type,
                         current => $current,
                        });
    $xpl->send($msg);
    $self->info('sending ', $msg->summary, "\n");
  }
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

Mirror:
Nicolas Goubaux, E<lt>nicolasg@goubs.netE<gt>

xpl-perl:
Mark Hindess, E<lt>soft-xpl-perl@temporalanomaly.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2010 by Nicolas Goubaux 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
