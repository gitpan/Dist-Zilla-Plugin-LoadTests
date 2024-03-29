package Dist::Zilla::Plugin::LoadTests;
BEGIN {
  $Dist::Zilla::Plugin::LoadTests::VERSION = '0.06';
}

# ABSTRACT: Common tests to test whether your module loads or not

use 5.008;
use strict;
use warnings;

use Moose;
extends 'Dist::Zilla::Plugin::InlineFiles';
with 'Dist::Zilla::Role::FileMunger';


# -- attributes

has needs_display => ( is => 'ro', predicate => 'has_needs_display' );

# -- public methods

# called by the filemunger role
sub munge_file {
	my ( $self, $file ) = @_;

	return unless $file->name eq 't/00-load.t';

	# Construct module name from 'name'
	( my $module = $self->zilla->name ) =~ s/-/::/g;

	# Skip all tests if you need a display for this test and $ENV{DISPLAY} is not set
	my $needs_display = '';
	if ( $self->has_needs_display && $self->needs_display ) {
		$needs_display = <<'CODE';
BEGIN {
	if( not $ENV{DISPLAY} and not $^O eq 'MSWin32' ) {
		plan skip_all => 'Needs DISPLAY';
		exit 0;
	}
}
CODE
	}

	# replace strings in the file
	my $content = $file->content;
	$content =~ s/LOADTESTS_MODULE/$module/g;
	$content =~ s/LOADTESTS_NEEDS_DISPLAY/$needs_display/;
	$file->content($content);
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;




=pod

=head1 NAME

Dist::Zilla::Plugin::LoadTests - Common tests to test whether your module loads or not

=head1 VERSION

version 0.06

=head1 SYNOPSIS

In your dist.ini:

    [LoadTests]
    ; needs_display = 1

=head1 DESCRIPTION

This is an extension of L<Dist::Zilla::Plugin::InlineFiles>, providing
the following files:

=over 4

=item * t/00-load.t - a standard test to check whether your module loads or not

This test will try to load the module specified by C<name>. The C<needs_display>
is useful for GUI tests that need an $ENV{DISPLAY} to work.

=back

This plugin accepts the following options:

=over 4

=item * needs_display (OPTIONAL): a boolean to ensure that tests needing a display
have one otherwise it will skip all the test. Defaults to false.

=back

=head1 SEE ALSO

If you need a more generic but slower test for all the packages in your distribution, please use L<Dist::Zilla::Plugin::CompileTests>.

=head1 AUTHOR

Ahmad M. Zawawi <ahmad.zawawi@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Ahmad M. Zawawi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__DATA__
___[ t/00-load.t ]___
#!perl

use strict;
use warnings;

use Test::More;

LOADTESTS_NEEDS_DISPLAY

plan tests => 1;

use_ok('LOADTESTS_MODULE');
diag("Testing LOADTESTS_MODULE $LOADTESTS_MODULE::VERSION, Perl $], $^X");
