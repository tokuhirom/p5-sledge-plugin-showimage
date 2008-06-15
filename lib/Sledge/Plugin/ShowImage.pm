package Sledge::Plugin::ShowImage;
use strict;
use warnings;
use 5.00800;
use Exporter 'import';
use HTTP::MobileAgent;
our $VERSION = '0.03';

my $ONE_DOT_GIF = (
     "\x47\x49\x46\x38\x39\x61\x01\x00\x01\x00\x80\xff\x00\xff\xff\xff\x00"
    ."\x00\x00\x21\xf9\x04\x01\x00\x00\x00\x00\x2c\x00\x00\x00\x00\x01\x00"
    ."\x01\x00\x00\x02\x02\x44\x01\x00\x3b"
);

my $ONE_DOT_PNG = (
     "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52\x00"
    ."\x00\x00\x01\x00\x00\x00\x01\x01\x03\x00\x00\x00\x25\xdb\x56\xca\x00"
    ."\x00\x00\x06\x50\x4c\x54\x45\xff\xff\xff\x00\x00\x00\x55\xc2\xd3\x7e"
    ."\x00\x00\x00\x0a\x49\x44\x41\x54\x78\xda\x63\x60\x00\x00\x00\x02\x00"
    ."\x01\xe5\x27\xde\xfc\x00\x00\x00\x00\x49\x45\x4e\x44\xae\x42\x60\x82"
);

our @EXPORT = qw/show_image show_gd_image show_1dot_img/;

sub show_image {
    my $self         = shift;
    my $content      = shift;
    my $content_type = shift;
    my $cache_ok     = shift;

    unless ($cache_ok) {
        $self->r->header_out('Pragma'        => 'no-cache');
        $self->r->header_out('Cache-Control' => 'no-cache');
    }

    $self->r->content_type($content_type);
    $self->set_content_length(length $content);
    $self->send_http_header;
    $self->r->print($content);
    $self->invoke_hook('AFTER_OUTPUT');
    $self->finished(1);    
}

sub show_gd_image {
    my ($self, $image) = @_;

    my $mobile = HTTP::MobileAgent->new;
    if ( ( $mobile->agent->is_ezweb and !$mobile->agent->xhtml_compliant )
        or $mobile->agent->is_vodafone )
    {
        $self->show_image( $image->png, "image/png" );
    }
    else {
        $self->show_image( $image->gif, "image/gif" );
    }
}

sub show_1dot_img {
    my $self = shift;

    if (HTTP::MobileAgent->new->is_docomo) {
        $self->show_image($ONE_DOT_GIF, 'image/gif');
    } else {
        $self->show_image($ONE_DOT_PNG, 'image/png');
    }
}

1;
__END__

=for stopwords png gif Tokuhiro Matsuno MATSUNO gmail DoCoMo

=encoding utf8

=head1 NAME

Sledge::Plugin::ShowImage - plugin to show image from data

=head1 SYNOPSIS

  package Your::Pages;
  use Sledge::Plugin::ShowImage;
  use Your::Data;

  sub dispatch_foo {
      my $self  = shift;
      my $id    = $self->r->param('id');
      my $image = Your::Data->retrieve($id)->image;
      $self->show_image($image);
  }

  sub dispatch_bar {
      my $self  = shift;
      $self->show_1dot_img;
  }

=head1 DESCRIPTION

DB などに保存されている画像を表示するためのプラグインです。1ドット画像を表
示する機能もついています。

=over 4

=item show_image

引数で与えられた画像を表示します。

=item show_1dot_img

1ドット画像を表示します。HTTP::MobileAgent を利用して、端末ごとに最適な1
ドット画像を出力します。

DoCoMo 端末のみ gif を出力します。それ以外の端末には png を出力します。

=back

=head1 DEPENDENCIES

L<HTTP::MobileAgent>

=head1 AUTHOR

MATSUNO Tokuhiro E<lt>tokuhirom at gmail dot comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

