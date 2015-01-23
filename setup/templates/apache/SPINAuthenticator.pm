#!/usr/bin/perl -wT
package SPINAuthenticator;

use strict;
use warnings;

use MIME::Base64 qw(decode_base64 encode_base64);
use JSON qw(decode_json);
use Digest::SHA qw(hmac_sha256);
use APR::Table ();
use Apache2::RequestRec ();
use Apache2::RequestUtil ();
use Apache2::Log ();
use Apache2::Const -compile => qw(OK HTTP_FORBIDDEN HTTP_UNAUTHORIZED);

sub decode_urlsafe_base64($) {
  my $encoded = shift;
  $encoded =~ tr|-_|+/|;
  decode_base64($encoded);
}

sub encode_urlsafe_base64($) {
  my $encoded = encode_base64(shift);
  $encoded =~ tr|+/=\n|-_|d;
  $encoded;
}

# http://perl.apache.org/docs/1.0/guide/snippets.html
sub get_cookies($) {
  my $r = shift;
  my $cookies = ($r->headers_in()->get('Cookie') || '');
  map { split /=/, $_, 2 } split /; /, $cookies;
}

sub handler($) {
  my $r = shift;
  my $secret = $r->dir_config('auth_secret');

  my %cookies = get_cookies($r);
  my $jws = $cookies{'spin_login'};

  return Apache2::Const::HTTP_UNAUTHORIZED unless $jws;

  my ($header_raw, $data_raw, $signature) = split(/\./, $jws, 3);
  my $header = decode_json(decode_urlsafe_base64($header_raw));
  my $data = decode_json(decode_urlsafe_base64($data_raw));

  my $typ = $header->{'typ'};
  my $alg = $header->{'alg'};
  return Apache2::Const::HTTP_FORBIDDEN unless ($typ eq 'JWT' and $alg eq 'HS256');

  my $payload = "$header_raw.$data_raw";
  my $check = encode_urlsafe_base64(hmac_sha256($payload, $secret));

  return Apache2::Const::HTTP_FORBIDDEN unless ($check eq $signature);

  my $exp = $data->{'exp'};
  return Apache2::Const::HTTP_FORBIDDEN unless $exp and $exp > time();

  my $sub = $data->{'sub'};
  return Apache2::Const::HTTP_FORBIDDEN unless $sub and $sub =~ /\A[\w-]+\z/;

  $r->log->notice("Mapped to SPIN session: $sub");
  $r->user($sub);

  Apache2::Const::OK;
}

1;
