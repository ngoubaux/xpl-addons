package xPL::Nabaztaglib;

use warnings;
use strict;

use base qw/Class::AutoAccess/ ;

use Carp ;

use LWP::UserAgent ;
use URI::Escape ;

=head1 NAME

Nabaztag - A module to interface your nabaztag!

=head1 VERSION

Version 0.04

=head1 ABOUT

Nabaztag.pm  complies with nabaztag API V1 from violet company.

The API tied to this module can be downloaded here http://www.nabaztag.com/vl/FR/gfx/1/APIV2.pdf

See api mailing list at http://fr.groups.yahoo.com/group/nabaztag_api/

See help at http://www.nabaztag.com/

=cut

our $VERSION = '0.04';
our $BASE_URL = "http://api.nabaztag.com/vl/FR/api.jsp" ;
our $ID_APP = 11 ;

our @LANGUAGES = ('en', 'fr');
our @VOICES_FR = ('julie22k', 'claire22s');
our @VOICES_EN = ('graham22s', 'lucy22s', 'heather22k', 'ryan22k', 'aaron22s', 'laura22s');
our @VOICES = ('US-Billye','RU-Maia','IT-Carlo','IN-Nima','NO-Arild','KR-Choe','DK-Karen','UK-Rachel','FR-Gertrude','FO-Sjurdur','FI-Tarja','IT-Ugo','IT-Assunta','FR-Philomene','FR-Maxence','ES-Baltasar','NL-Renate','IS-Snorri','MX-Guadalupe','SE-Hjalmar','DE-Heidi','BE-Minna','US-Clarence','UK-Mistermuggles','TR-Sezen','ES-Dunixe','ZA-Wilbur','PL-Hanka','US-Darleen','SE-Maj','GR-Dimitris','NO-Cora','NO-Kari','DE-Yannick','DE-Otto','BE-Hendrik','BE-Sofie','RU-Bella','SE-Selma','ES-Alfonsina','FR-Julie','US-Ernest','FI-Linus','ES-Rosalia','EG-Nayla','JP-Tamura','BR-Lygia','CA-Felix','DE-Steffi','AU-Colleen','ES-Bertrana','IN-Sangeeta','CN-Pan','UK-Shirley','DK-Kjeld','PT-Celia','NL-Max','SE-Liza','UK-Leonard','US-Bethany','EG-Nabil','IT-Chiara','FR-Anastasie','UK-Penelope','US-Lilian','TR-Asli','NO-Sigrid','DE-Sarah','NL-Femke','AU-Jon','DK-Pia','YUE-Baibo','FR-Archibald','GR-Antonis','US-Liberty','TH-Boon-mee','ES-Emilia','IE-Orla','UK-Edwinv','CZ-Zdenech','PL-Ignacy','CA-Antonine');

=head1 DESCRIPTION

This module is designed to allow you to control a nabaztag with perl programming language.
See ABOUT section to know which api it fits.

It has been tested with my own nabaztag and seems to work perfectly.

It also provide a simple command line tool to try your nabaztag: nabaztry (see SYNOPSIS).
This tool is install in /usr/bin/

It makes great use of LWP::Simple to interact with the rabbit.

PROXY issues:

 If you're behind a proxy, see LWP::Simple proxy issues to know how to deal with that.
 Basically, set env variable HTTP_PROXY to your proxi url in order to make it work.
 For instance : export HTTP_PROXY=http://my.proxy.company:8080/


=head1 SYNOPSIS

Commandline:

    $ nabaztry.pl MAC TOKEN POSLEFT POSRIGHT

Perl code:


    use Nabaztag ; # OR
    # use Nabaztag { 'debug' => 1 } ;


    my $nab = Nabaztag->new();

    # MANDATORY
    $nab->mac($mac);
    $nab->token($tok);

    # See new function to have details about how to get these properties.

    $nab->leftEarPos($left);
    $nab->rightEarPos($right);

    $nab->syncState();

    $nab->sayThis("Demain, il pleuvra des grillons jusqu'a extinction totale de la race humaine.");
    .....

See detailled methods for full possibilities.

Gory details :

You can access or modify BASE_URL by accessing:
   $Nabaztag::BASE_URL ;

For application id :
   $Nabaztag::ID_APP ;


=head1 FUNCTIONS

=head2 new

Returns a new software nabaztag with ears position fetched from the hardware one if the mac and token is given.

It has following properties:

  key : The key given here http://www.nabaztag.com/vl/FR/nabaztaland_api_inscription.jsp to register your service
  mac : MAC Adress of nabaztag - equivalent to Serial Number ( SN ). Written at the back
        of your nabaztag !!
  token :  TOKEN Given by nabaztag.com to allow interaction with you nabaztag. See
           http://www.nabaztag.com/vl/FR/api_prefs.jsp to obtain yours !!
  leftEarPos : position of left ear.
  rightEarPos : position of right ear.
  ttl : how long, in seconds, the message is going to stay on the server, if undefined it will stay until archived.
  speed : choose the speed of speaking in percent - normal is 100, 200 is double speed, 50 is half speed
  pitch : modulate speech frequency in percent - normal is 100

usage:
    my $nab = Nabaztag->new($mac, $token, $key);
    print $nab->leftEarPos();
    print $nab->rightEarPos();

OR:

    my $nab = Nabaztag->new();
    $nab->mac($mac);
    $nab->token($token);
    $nab->fetchEars();

    print $nab->leftEarPos();
    print $nab->rightEarPos();

=cut

my $debug = undef ;
sub import{
    #my $callerPack = caller ;
    my ($class, $options) = @_ ;
    if(  ! defined $debug ){
    	$debug = $options->{'debug'} || 0 ;
    }
    print "\n\nDebug option : $debug \n\n" if ($debug);
}


sub new {
    my ($class , $mac, $token, $key) = @_ ;

    my $self = {
	'mac' => undef , # MAC Adress of nabaztag - equivalent to Serial Number ( SN )
	'token' => undef , # TOKEN Given by nabaztag.com to allow interaction with you nabaztag
	'key' => undef, # KEY given by http://www.nabaztag.com/vl/FR/nabaztaland_api_inscription.jsp
	'leftEarPos' => undef , # Position of left ear
	'rightEarPos' => undef,  # Position of right ear
	'_language' => 'fr', # default language
	'_voice' => 0, # default voice
	'ttl' => undef, # how long, in seconds, the message is going to stay on the server, if undefined it will stay until archived
	'speed' => undef, # choose the speed of speaking
	'pitch' => undef, # modulate speech frequency
	};

    $self = bless $self, $class ;

    $self->mac($mac) ;
    $self->token($token);
    $self->key($key);
    if( $self->mac() && $self->token() && $self->key()){
	print "Trying to fetch ears position" if ( $debug );
	$self->fetchEars();
    }
    return $self ;
}

=head2 language

Get/Sets the language the nabaztag is currently speaking.

Usage:
    $nab->language('en');

The language has to be in the list ('fr', 'en'). Default is 'fr' ;-)

=cut

sub language {
    my ($self, $language) = @_ ;
    if( defined $language ){
    	my $ok = scalar(grep{/$language/i} @LANGUAGES);
		if ( $ok ) {
		    $self->{'_language'} = $language; 
		} else {
		    confess("Language has to be in the list: " . join ",", @LANGUAGES );
		}
    }
    return $self->{'_language'};
}

=head2 voice

Get/Sets the voice the nabaztag is using to make the Text To Speech conversion by setting the index of the voices list (zero based)

Usage:
    $nab->voice(0);

The voice index has to be in the range of the list of voices associated to the currently defined language (French and English have a different set)
To retrieve the list of voices is currently able to speak:
	@voices = $nab->voices();

=cut

sub voice {
    my ($self, $voice) = @_ ;
    if( defined $voice ){
    	my @voices = $self->voices;
    	my $ok = $voice <= $#voices;
		if ( $ok ) {
		    $self->{'_voice'} = $voice; 
		} else {
		    confess("Voice is an integer in the range 0-" . $#voices);
		}
    }
    return $self->{'_voice'};
}
###############################################################################################################################

sub voices {
	my $self = shift;
	if ($self->language eq 'en') {
		return @VOICES_EN;
	} elsif ($self->language eq 'fr') {
		return @VOICES_FR;
	} else {
		confess("Undefined language: ", $self->language);
	}
}

###############################################################################################################################
=head2 leftEarPos

Get/Sets the left ear position of the nabaztag.

Usage:
    $nab->leftEarPos($newPos);

The new position has to be between 0 (vertical ear) and 16 included

=cut

sub leftEarPos{
    my ($self, $pos) = @_ ;
    if( defined $pos ){
	if ( ( $pos >= 0 )  && ( $pos <= 16 )){
	    return $self->{'leftEarPos'} = $pos ;
	}else{
	    confess("Position has to be between 0 and 16");
	}
    }
    return $self->{'leftEarPos'} ;
}


=head2 rightEarPos

 See leftEarPos. Same but for right.

=cut

sub rightEarPos{
    my ($self, $pos) = @_ ;
    if( defined $pos ){
	if ( ( $pos >= 0 )  && ( $pos <= 16 )){
	    return $self->{'rightEarPos'} = $pos ;
	}else{
	    confess("Position has to be between 0 and 16");
	}
    }
    return $self->{'rightEarPos'} ;
}


=head2 sendMessageNumber

Given a message number, sends this message to this nabaztag.

To obtain message numbers, go to http://www.nabaztag.com/vl/FR/messages-disco.jsp and
choose a message !!

Usage:
    $nab->sendMessageNumber($num);

=cut

sub sendMessageNumber{
    my ($self, $num ) = @_ ;

    my $url =  $self->_cookUrl();
    unless( defined $num ){
	confess("No message number given");
    }

    $url .= '&idmessage='.$num ;

    print "Accessing URL : $url\n" if ($debug);

    my $content = $self->_getUserAgent->()->get($url)->content();

    print "content :".$content."\n" if ($debug);
    unless( defined $content ){
	confess("An error occured while processing request");
    }
}


=head2 syncState

Synchronise the current state of the soft nabaztag with the hardware one.
Actually sends the state to the hardware nabaztag.

Usage:

    $nab->syncState();

=cut

sub syncState{
    my ($self) = @_ ;

    my $url = $self->_cookUrl();

    if( defined $self->leftEarPos() ){
	$url .=	'&posleft='.$self->leftEarPos() ;
    }
    if( defined $self->rightEarPos() ){
	$url .= '&posright='.$self->rightEarPos();
    }

    print "Getting url:".$url."\n" if ($debug);
    my $content = $self->_getUserAgent()->get($url)->content();
    print "Content:".$content."\n" if ($debug);
    unless( defined $content ){
	confess("An error occured while processing request");
    }

}

=head2 wakeUp

Wake up your rabbit

=cut

sub wakeUp{
    my ($self) = @_ ;

    my $url = $self->_cookUrl();
    $url .= '&action=14' ;

    print "Accessing: ".$url."\n" if ($debug);
    my $content = $self->_getUserAgent()->get($url)->content();
    print "Content: \n".$content."\n" if ($debug);
}

=head2 sendToSleep

Send your rabbit to sleep

=cut

sub sendToSleep{
    my ($self) = @_ ;

    my $url = $self->_cookUrl();
    $url .= '&action=13' ;

    print "Accessing: ".$url."\n" if ($debug);
    my $content = $self->_getUserAgent()->get($url)->content();
    print "Content: \n".$content."\n" if ($debug);
}

=head2 fetchEars

Fetches the real position of ear from the device and fill
the leftEarPos and the rightEarPos properties.

=cut

sub fetchEars{
    my ($self) = @_ ;

    my $url = $self->_cookUrl();
    $url .= '&ears=ok' ;

    print "Accessing: ".$url."\n" if ($debug);
    my $content = $self->_getUserAgent()->get($url)->content();
    print "Ear content \n".$content."\n" if ($debug);

    my ($left , $right) =  $content =~ /([0-9]+)/g  ;

    #print "Left :".$left."\n";
    #print "Right:".$right."\n";

    $self->leftEarPos($left);
    $self->rightEarPos($right);

}

=head2 sayThis

Makes the rabbit tell the sentence you give as parameter

Usage:

    $nab->sayThis("Demain, il pleuvra des grillons jusqu'a extinction totale de la race humaine."); # (example)

=cut

sub sayThis{
    my ($self, $text ) = @_ ;
    my $url = $self->_cookUrl();
    $url .= '&tts='.uri_escape($text) ;
    warn "URL=$url\n" ;
    my $content = $self->_getUserAgent()->get($url)->content();
    print "TTS: ".$content."\n" if ($debug);
}

=head2 danceThis

Sends a choregraphy to the rabbit, with the optionnaly given title

Please refer to the APIV1 documentation to know how to compose your choregraphy

Usage:
    my $chor = '10,0,motor,1,20,0,0,0,led,2,0,238,0,2,led,1,250,0,0,3,led,2,0,0,0' ;
    my $title = 'example' ;
    $nab->danceThis($chor, $title);

=cut

sub danceThis{
    my ($self, $chor, $title) = @_ ;
    my $url = $self->_cookUrl();
    $url .= '&chor='.uri_escape($chor) ;
    $url .= '&chortitle='.uri_escape($title) if (defined $title);
    print "Getting url:".$url."\n" if ($debug);
    my $content = $self->_getUserAgent()->get($url)->content();
    print "Content :".$content."\n" if ($debug);
}

=head2 nabcastMessage

Sends the given message id to the given nabcast id with given title

Please refer to nabaztag website to get these identifiers.

usage:
    $nab->nabcastMessage($nabcastId, $title, $idMessage);

=cut

sub nabcastMessage{
    my ($self, $nabcastID, $title, $idmessage) = @_ ;
    my $url = $self->_cookUrl();

    $url .= '&nabcast='.$nabcastID ;
    $url .= '&nabcasttitle='.$title ;
    $url .= '&idmessage='.$idmessage ;

    print "Accessing :".$url."\n" if ($debug);
    my $content = $self->_getUserAgent()->get($url)->content();
    print "Content:".$content."\n" if ($debug) ;
}

=head2 nabcastText

Sends the given texttosay to the given nabcast id with given title

Please refer to nabaztag website to get these identifiers.

usage:
    $nab->nabcastText($nabcastId, $title, $texttosay);


=cut

sub nabcastText{
    my ($self, $nabcastID, $title, $text) = @_ ;
    my $url = $self->_cookUrl();

    $url .= '&nabcast='.$nabcastID ;
    $url .= '&nabcasttitle='.$title ;
    $url .= '&tts='.uri_escape($text) ;

    print "Getting url.".$url."\n" if ($debug);
    my $content = $self->_getUserAgent()->get($url)->content();
    print "Content:".$content."\n" if ($debug) ;
}

=head2 _cookUrl

Returns a cooked url ready for sending something usefull

Usage:

    my $url = $this->_cookUrl();

=cut

sub _cookUrl{
    my ($self) = @_ ;
    my @voices = $self->voices;
    my $voice = $voices[$self->voice];
    my $ttl = $self->ttl;
    my $speed = $self->speed;
    my $pitch = $self->pitch;

    my $url =  $BASE_URL . "?voice=$voice&idapp=$ID_APP";

	$url .= "&ttlive=$ttl" if ($ttl);
	$url .= "&speed=$speed" if ($speed);
	$url .= "&pitch=$pitch" if ($pitch);

    $self->_assume('mac');
    $self->_assume('token');
    $self->_assume('key');
    
    $url .= '&key='.$self->key() ;
    $url .= '&sn='.$self->mac() ;
    $url .= '&token='.$self->token() ;

    return $url ;
}

sub _getUserAgent{
    my ($self) = @_ ;
    my $ua = LWP::UserAgent->new;
    $ua->timeout(60);
    $ua->env_proxy;
    $ua->default_headers->push_header('Accept-Language' => "fr");
    return $ua ;
}


sub _assume{
    my ($self, $propertie ) = @_ ;
    unless( defined $self->$propertie() ){
	confess($propertie." is not set in $self\n Please set it first !");
    }
}

=head1 AUTHOR

Jerome Eteve, C<< <jerome@eteve.net> >>
Christophe Gevrey << <gevrey+cpan@pobox.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-nabaztag@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Nabaztag>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Jerome Eteve, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Nabaztag
