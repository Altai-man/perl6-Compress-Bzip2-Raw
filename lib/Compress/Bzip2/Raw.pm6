use v6;
use NativeCall;

# structs and pointers.
my class bz_stream is repr('CStruct') {
    has CArray[uint8] $.next-in;
    has int32 $.avail-in;
    has int32 $.total-in_lo32;
    has int32 $.total-in_hi32;

    has CArray[uint8] $.next-out;
    has int32 $.avail-out;
    has int32 $.total-out-lo32;
    has int32 $.total-out-hi32;

    has Pointer[void] $.state;

    has Pointer[void] $.bzalloc is rw;
    has Pointer[void] $.bzfree is rw;
    has Pointer[void] $.opaque is rw;

    method set-input(Blob $stuff){
        $!next-in := nativecast CArray[uint8], $stuff;
        $!avail-in = $stuff.bytes;
    }

    method set-output(Blob $stuff){
        $!next-out := nativecast CArray[uint8], $stuff;
        $!avail-out = $stuff.bytes;
    }
}

# constants
my constant BZ_RUN = 0;
my constant BZ_FLUSH = 1;
my constant BZ_FINISH = 2;

my constant BZ_OK = 0;
my constant BZ_RUN_OK = 1;
my constant BZ_FLUSH_OK = 2;
my constant BZ_FINISH_OK = 3;
my constant BZ_STREAM_END = 4;
# Errors.
my constant BZ_SEQUENCE_ERROR = (-1);
my constant BZ_PARAM_ERROR = (-2);
my constant BZ_MEM_ERROR = (-3);
my constant BZ_DATA_ERROR = (-4);
my constant BZ_DATA_ERROR_MAGIC = (-5);
my constant BZ_IO_ERROR = (-6);
my constant BZ_UNEXPECTED_EOF = (-7);
my constant BZ_OUTBUFF_FULL = (-8);
my constant BZ_CONFIG_ERROR = (-9);

## Low-level.
# Compress.
sub BZ2_bzCompressInit(bz_stream, int32, int32, int32) returns int32 is native("bz2", v1) { * }
sub BZ2_bzCompress(bz_stream, int32) returns int32 is native("bz2", v1) { * }
sub BZ2_bzCompressEnd(bz_stream) returns int32 is native("bz2", v1) { * }
# Decompress.
sub BZ2_bzDecompressInit(bz_stream, int32, int32) returns int32 is native("bz2", v1) { * }
sub BZ2_bzDecompress(bz_stream) returns int32 is native("bz2", v1) { * }
sub BZ2_bzDecompressEnd(bz_stream) returns int32 is native("bz2", v1) { * }

## High-level.
# Reading.
sub BZ2_bzReadOpen(int32 is rw, OpaquePointer, int32, int32, Pointer[uint8], int32) returns OpaquePointer is native("bz2", v1) { * }
sub bzReadOpen(int32 $bzerror is rw, OpaquePointer $file, $verbosity=0, $small=0, $unused=Pointer[uint32], $nUnused=0) {
    BZ2_bzReadOpen($bzerror, $file, $verbosity, $small, $unused, $nUnused);
}
sub BZ2_bzRead(int32 is rw, OpaquePointer, Blob, int32) returns int32 is native("bz2", v1){ * }
sub BZ2_bzReadClose(int32 is rw, Pointer[void]) is native("bz2", v1) { * }
sub BZ2_bzReadGetUnused(int32 is rw, Pointer[void], Pointer, int32 is rw) is native("bz2", v1) { * }
# Writing.
sub BZ2_bzWriteOpen(int32 is rw, OpaquePointer, int32, int32, int32) returns OpaquePointer is native("bz2", v1) { * }
sub bzWriteOpen(int32 $bzerror is rw, OpaquePointer $file, $blockSize100k = 6, $verbosity = 0, $workFactor = 0) {
    BZ2_bzWriteOpen($bzerror, $file, $blockSize100k, $verbosity, $workFactor);
}
sub BZ2_bzWrite(int32 is rw, OpaquePointer, Blob, int32) is native("bz2", v1) { * }
sub BZ2_bzWriteClose(int32 is rw, Pointer, int32, Pointer[uint32], Pointer[uint32]) is native("bz2", v1) { * }
sub bzWriteClose(int32 $bzerror is rw, OpaquePointer $bz, $abandon=0, $nbytes_in=Pointer[uint32], $nbytes_out=Pointer[uint32]) {
    BZ2_bzWriteClose($bzerror, $bz, $abandon, $nbytes_in, $nbytes_out);
}
sub BZ2_bzWriteClose64(int32 is rw, OpaquePointer, int32, Pointer[uint32], Pointer[uint32], Pointer[uint32], Pointer[uint32]) is native("bz2", v1) { * }

## Utility.
sub BZ2_bzBuffToBuffCompress(Blob, uint32 is rw, Blob, uint32, int32, int32, int32) returns int32 is native("bz2", v1) { * }
sub BZ2_bzBuffToBuffDecompress(Blob, uint32 is rw, Blob, uint32, int32, int32) returns int32 is native("bz2", v1) { * }
sub fopen(Str $filename, Str $mode) returns OpaquePointer is native(Str) { * }
sub fclose(OpaquePointer $handle) returns int32 is native(Str) { * }

# High-level helpers.
sub name-to-compress-info(Str $filename) {
    my $handle = fopen($filename ~ ".bz2", "wb");
    my $blob = slurp $filename, :bin;
    my $len = $blob.elems;
    $handle, $blob, $len;
}

sub name-to-decompress-info(Str $filename) {
    my $handle = fopen($filename, "rb");
    my Str $output = ($filename ~~ m/(.+).bz2/)[0].Str;
    my $fd = open $output, :w, :bin;
    $handle, $fd;
}

my %all-symbols = MY::.grep({ .key ~~ /:i 'bz'|'name'/ || .key eq '&fopen'|'&fclose' });
my %win-symbols = MY::.grep({ .key ~~ /:i 'BuzzToBuff'/ });

sub EXPORT {
    $*DISTRO.is-win ?? %win-symbols !! %all-symbols;
}
