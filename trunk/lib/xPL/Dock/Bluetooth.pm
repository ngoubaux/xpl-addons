package xPL::Dock::Bluetooth;

use Inline C => Config => MYEXTLIB => '/usr/lib/libbluetooth.so';
use Inline C => <<EOT;

#include <errno.h>
#include <sys/socket.h>

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <bluetooth/l2cap.h>

void cmd_up(int ctl, int hdev)
{
	/* Start HCI device */
	if (ioctl(ctl, HCIDEVUP, hdev) < 0) {
		if (errno == EALREADY)
			return;
		fprintf(stderr, "Can't init device hci%d: %s (%d)\\n",
		hdev, strerror(errno), errno);
		exit(1);
	}
}

void cmd_down(int ctl, int hdev)
{
	/* Stop HCI device */
	if (ioctl(ctl, HCIDEVDOWN, hdev) < 0) {
		fprintf(stderr, "Can't down device hci%d: %s (%d)\\n",
		hdev, strerror(errno), errno);
		exit(1);
	}
}


void reset_adapter(int ctl) {
	int dev_id;

	dev_id = hci_get_route(NULL);
	cmd_down(ctl, dev_id);
	cmd_up(ctl, dev_id);
}

SV* open_adapter() {
	int dev_id;
	int dd;
	
	dev_id = hci_get_route(NULL);
   	if (dev_id < 0) {
		printf("Device not available\\n");
		return (newSViv(dev_id));
	}
	
	dd = hci_open_dev(dev_id);
	if (dd < 0) {
		printf("Cannot open device\\n");
	}
	return (newSViv(dd));
}

void close_adapter(int adapter) {
	close(adapter);
}

SV* read_rssi(int adapter, char* address) {
	int rv;
	uint16_t handle;
	struct hci_conn_info_req *cr;
	struct hci_request rq;
	read_rssi_rp rp;
	bdaddr_t bdaddr;
	struct sockaddr_l2 addr;
	
	str2ba(address, &bdaddr);
	
	handle = socket(AF_BLUETOOTH, SOCK_RAW, BTPROTO_L2CAP);
	if (handle < 0) {
		perror("Can't create socket");
		return newSViv(-255);
	}
	
	memset(&addr, 0, sizeof(addr));
	addr.l2_family = AF_BLUETOOTH;
	str2ba(address, &addr.l2_bdaddr);
	
	if (connect(handle, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
		close(handle);
		rv = errno;
		printf("Can't connect: %d\\n", rv);
		perror("error");
		if (rv != 112)
			return newSViv(rv);
		
		return newSViv(-255);
	}
	
	cr = malloc(sizeof(*cr) + sizeof(struct hci_conn_info));
	if (!cr) {
		printf("Could not allocate memory\\n");
		return newSViv(-255);
	}
    
	bacpy(&cr->bdaddr, &bdaddr);
	cr->type = ACL_LINK;
	if (ioctl(adapter, HCIGETCONNINFO, (unsigned long) cr) < 0) {
		printf("Get connection info failed\\n");
		return newSViv(-255);
	}
	
	memset(&rq, 0, sizeof(rq));
	rq.ogf    = OGF_STATUS_PARAM;
	rq.ocf    = OCF_READ_RSSI;
	rq.cparam = &cr->conn_info->handle;
	rq.clen   = 2;
	rq.rparam = &rp;
	rq.rlen   = READ_RSSI_RP_SIZE;
	
	if (hci_send_req(adapter, &rq, 100) < 0) {
		printf("Read RSSI failed\\n");
		return newSViv(-255);
	}
	
	if (rp.status) {
		printf("Read RSSI returned (error) status 0x%2.2X\\n", rp.status);
		return newSViv(-255);
	}
	
	close(handle);
	free(cr);
	return newSViv(rp.rssi);
}

EOT

#-------------------------------------------------------------------

=head1 NAME

xPL::Dock::Bluetooth - xPL::Dock plugin for bluetooth proximity reporting

=head1 SYNOPSIS

  use xPL::Dock qw/Bluetooth/;
  my $xpl = xPL::Dock->new();
  $xpl->main_loop();

=head1 DESCRIPTION

This L<xPL::Dock> plugin adds bluetooth proximity reporting.

=head1 METHODS

=cut

use 5.006;
use strict;
use warnings;

use English qw/-no_match_vars/;
use xPL::Dock::Plug;

our @ISA = qw(xPL::Dock::Plug);
our %EXPORT_TAGS = ( 'all' => [ qw() ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw();
our $VERSION = qw/$Revision$/[1];

__PACKAGE__->make_readonly_accessor($_) foreach (qw/interval addresses/);

=head2 C<getopts( )>

This method returns the L<Getopt::Long> option definition for the
plugin.

=cut

sub getopts {
  my $self = shift;
  $self->{_interval} = 30;
  $self->{_timeout} = 120;
  $self->{_addresses} = [];
  return
    (
     'bluetooth-verbose+' => \$self->{_verbose},
	 'bluetooth-poll-interval=i' => \$self->{_interval},
	 'bluetooth-timeout=i' => \$self->{_timeout},
     'bluetooth-address=s' => $self->{_addresses},
    );
}

=head2 C<init(%params)>

=cut

sub init {
  my $self = shift;
  my $xpl = shift;
  my %p = @_;

  $self->required_field($xpl, 'addresses',
             'At least one --bluetooth-address parameter is required',
             1);
  $self->SUPER::init($xpl, @_);

    $self->{_watch} = [ map { uc } @{$self->{_addresses}} ];
    $self->{_state} = {};
    $xpl->add_timer(id => 'poll-bluetooth',
                    timeout => -$self->{_interval},
                    callback => sub { $self->poll_bluetooth(@_) });
  return $self;
}

=head2 C<poll_bluetooth()>

This is the timer callback that polls the bluetooth network looking
for visible devices.

=cut

sub poll_bluetooth {
	my $self = shift;
	my $state = $self->{_state};
	my $xpl = $self->xpl;
	
	foreach my $addr (@{$self->{_watch}}) {
		$self->{_adapter} = open_adapter();
		my $old = defined($state->{$addr}->{v}) ? $state->{$addr}->{v} : -255;
		my $rssi = read_rssi($self->{_adapter}, $addr);
		if ($rssi > 0) {
			print "reset Bluetooth adapter\n";
			reset_adapter($self->{_adapter});
			# Pause;
			$rssi = read_rssi($self->{_adapter}, $addr);
			if ($rssi > 0) {
				$rssi = -255;
			}
		}
		my $type = "xpl-stat";
		if ($rssi == -255) 
		{
			$state->{$addr}->{count} += 1;
			print "$addr not found: check ", $state->{$addr}->{count}, "\n";
			if ($state->{$addr}->{count} > 3) {
			   $state->{$addr}->{v} = $rssi;
			}
			$type = ($old == -255) ? 'xpl-stat' : 'xpl-trig';
		}
		else 
		{
			$state->{$addr}->{count} = 0;
			$state->{$addr}->{v} = $rssi;
			$type = ($old > -255) ? 'xpl-stat' : 'xpl-trig';
		}
		
		print "Addr: $addr rssi: $old => ", $state->{$addr}->{v}," \n";	
		
		my $msg =
			xPL::Message->new(head => { source => $xpl->id },
							message_type => $type,
							class => 'sensor.basic',
							body =>
							{
								device => 'bt.'.$addr,
								type => 'distance',
								current => $rssi,
							});
		$xpl->send($msg);
		$self->info('sending ', $msg->summary, "\n");
		close_adapter($self->{_adapter});
	}
	return 1;
}

1;
__END__

=head1 EXPORT

None by default.

=head1 SEE ALSO

xPL::Dock(3), Net::Bluetooth(3)

Project website: http://www.xpl-perl.org.uk/

=head1 AUTHOR

Mark Hindess, E<lt>soft-xpl-perl@temporalanomaly.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2008, 2009 by Mark Hindess

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=cut
