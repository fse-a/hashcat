#!/usr/bin/env perl

##
## Author......: See docs/credits.txt
## License.....: MIT
##

use strict;
use warnings;

use Bitcoin::Crypto         qw (btc_extprv);
use Bitcoin::Crypto::Util   qw (to_format);
use Bitcoin::Crypto::Base58 qw (decode_base58check);

use Bitcoin::Crypto::Key::Private;

sub module_constraints { [[51, 51], [-1, -1], [-1, -1], [-1, -1], [-1, -1]] }

# Note:
# We have introduced the function: module_get_random_password ()
# that will help to generate random valid passwords from a given seed.

sub module_generate_hash
{
  my $word = shift; # expecting valid raw private key

  return unless ($word =~ m/^[0-9a-fA-F]{64}$/);

  my $priv = Bitcoin::Crypto::Key::Private->from_serialized([hex => $word]);

  my $IS_COMPRESSED = 0;

  $priv->set_compressed ($IS_COMPRESSED);

  my $pub  = $priv->get_public_key    ();
  my $hash = $pub->get_compat_address ();

  return $hash;
}

sub module_verify_hash
{
  my $line = shift;

  my $idx = rindex ($line, ':');

  return unless $idx >= 0;

  my $hash = substr ($line, 0, $idx);
  my $word = substr ($line, $idx + 1);

  return unless (defined ($hash));
  return unless (defined ($word));

  return unless ($word =~ m/^[0-9a-fA-F]{64}$/);

  my @is_valid_base58 = eval
  {
    decode_base58check ($hash);
  };

  return unless (@is_valid_base58);

  my $new_hash = module_generate_hash ($word);

  return ($new_hash, $word);
}

sub module_get_random_password
{
  my $seed = shift;

  my $master_key  = btc_extprv->from_seed ($seed); # expecting random seed from test.pl
  my $derived_key = $master_key->derive_key ("m/0'");

  my $priv = $derived_key->get_basic_key ();

  return to_format([hex => $priv->to_serialized()]); # the result is padded (32 raw bytes)
}

1;
