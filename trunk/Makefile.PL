use 5.005000;
use ExtUtils::MakeMaker;
use FileHandle;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my @exe = ();
my $fh = FileHandle->new("<MANIFEST");
while (<$fh>) {
  chomp;
  push @exe, $_ if (m!^bin/!);
}
$fh->close;

WriteMakefile(
    NAME              => 'xpl-addons',
    VERSION_FROM      => 'lib/xPL/Dock/Nabaztag.pm', # finds $VERSION
    EXE_FILES         => \@exe,
    PREREQ_PM         => {
      xPL::Base => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (AUTHOR         => 'goubs <nicolasg@goubs.net>') : ()),
);
