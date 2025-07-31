#!/usr/bin/env perl

##
## Author......: See docs/credits.txt
## License.....: MIT
##

use strict;
use warnings;

use Digest::MD4 qw (md4 md4_hex);
use Digest::MD5 qw (md5 md5_hex);
use Encode;

sub module_constraints { [[0, 256], [96, 96], [0, 27], [96, 96], [-1, -1]] }

sub module_generate_hash
{
  my $word = shift;
  my $salt = shift;

  my $salt_bin = pack ("H*", $salt);

  my $utf16le = encode("UTF-16LE", $word);

  my $digest = md5_hex (md4 ($utf16le) . $salt_bin);

  my $hash = sprintf ('$sntp-ms$%s$%s', $digest, unpack ("H*", $salt_bin));

  return $hash;
}

sub module_verify_hash
{
  my $line = shift;

  my $idx = index ($line, ':');

  return unless $idx >= 0;

  my $hash = substr ($line, 0, $idx);
  my $word = substr ($line, $idx + 1);

  my (undef, $signature, $digest, $salt) = split '\$', $hash;

  return unless defined $signature;
  return unless defined $digest;
  return unless defined $salt;

  return unless $signature eq 'sntp-ms';
  return unless length $salt == 96;

  my $word_packed = pack_if_HEX_notation ($word);

  my $new_hash = module_generate_hash ($word_packed, $salt);

  return ($new_hash, $word);
}

1;
