use v6;
use Test;
use NativeCall;
use Compress::Bzip2::Raw;
plan *;

if $*VM.osname eq 'linux' {
    # File testing
    my int32 $bzerror;
    constant $file-location = $*TMPDIR.child('test.bz2');
    my $text = "Text string.";
    my buf8 $write-buffer = buf8.new($text.encode);

    # Open a handle to write to
    my $handle = fopen($file-location.Str, "wb");
    my $bz = bzWriteOpen($bzerror, $handle);
    is $bzerror, BZ_OK, 'Stream was opened'
            or diag "bzWriteOpen returned $bzerror";
    bzWriteClose($bzerror, $bz) if $bzerror != BZ_OK;

    # Write to the handle
    BZ2_bzWrite($bzerror, $bz, $write-buffer, $write-buffer.elems);
    ok $bzerror == BZ_OK, 'No errors in writing';
    bzWriteClose($bzerror, $bz) if $bzerror != BZ_OK;

    # Closing the handle
    bzWriteClose($bzerror, $bz);
    ok $bzerror == BZ_OK, 'Stream was closed properly';
    is fclose($handle), 0, "fclose returned 0";

    # Open a handle to read from
    $handle = fopen($file-location.Str, "rb");
    $bz = bzReadOpen($bzerror, $handle);
    ok $bzerror == BZ_OK, 'Stream was opened';
    bzWriteClose($bzerror, $bz) if $bzerror != BZ_OK;

    # Read from the handle
    my $read-buffer = buf8.new;
    $read-buffer[($write-buffer.elems)-1] = 0;
    my $len = BZ2_bzRead($bzerror, $bz, $read-buffer, $write-buffer.elems);
    ok $bzerror == BZ_STREAM_END, 'No errors at reading';

    is $read-buffer.decode, $text, 'Text is correct';

    # Closing the handle
    BZ2_bzReadClose($bzerror, $bz);
    ok $bzerror == BZ_OK, 'Stream was closed properly';
    is fclose($handle), 0, "fclose returned 0";
} else {
    pass 'Tests are skipped for everything that is not GNU/Linux';
}

done-testing;
