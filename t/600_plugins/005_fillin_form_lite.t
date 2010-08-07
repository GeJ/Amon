use strict;
use warnings;
use Test::More;
use Test::Requires 'HTML::FillInForm::Lite';
use File::Spec;
use File::Temp qw/tempdir/;

BEGIN {
    $INC{'MyApp/Web/Dispatcher.pm'} = __FILE__;
    $INC{'MyApp/V/MT.pm'} = __FILE__;
    $INC{'MyApp.pm'} = __FILE__;
}


{
    package MyApp;
    use Amon2 -base;

    package MyApp::V::MT;
    use Amon2::V::MT -base;

    package MyApp::Web;
    use Amon2::Web -base => (
        default_view_class => 'Text::MicroTemplate::File',
    );
    __PACKAGE__->load_plugins(
        'FillInFormLite' => {},
    );
}

use Amon2::Web::Declare;
my $tmp = tempdir(CLEANUP => 1);
my $c = MyApp::Web->bootstrap(config => {
    'Tfall::Text::MicroTemplate::File' => {
        include_path => [$tmp],
    },
});

{
    open my $fh, '>', File::Spec->catfile($tmp, 'hoge.mt') or die $!;
    print $fh <<'...';
<html>
<head>
</head>
<body>
<form action="/" method="post">
<input type="text" name="body" />
<input type="submit" name="post" />
</form>
</body>
</html>
...
    close $fh;
}

my $res = render('hoge.mt')->fillin_form({body => "hello"});
like $res->body(), qr{<input type="text" name="body" value="hello" />};
done_testing;