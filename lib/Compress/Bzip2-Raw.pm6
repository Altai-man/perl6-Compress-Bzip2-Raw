use v6;
use NativeCall;

unit module Compress::Bzip2::Raw;

# structs
our class bz_stream is repr('CStruct') is export {
    has CArray[uint8] $.next-in;
    has int32 $.avail-in;
    has int32 $.total-in_lo32;
    has int32 $.total-in_hi32;

    has CArray[uint8] $.next-out;
    has int32 $.avail-out;
    has int32 $.total-out-lo32;
    has int32 $.total-out-hi32;

    has Pointer[void] $.state;

    has Pointer[void] $.bzalloc;
    has Pointer[void] $.bzfree;
    has Pointer[void] $.opaque;
}

# constants
constant BZ_RUN is export = 0;
constant BZ_FLUSH is export = 1;
constant BZ_FINISH is export = 2;

constant BZ_OK is export = 0;
constant BZ_RUN_OK is export = 1;
constant BZ_FLUSH_OK is export = 2;
constant BZ_FINISH_OK is export = 3;
constant BZ_STREAM_END is export = 4;
# Errors.
constant BZ_SEQUENCE_ERROR is export = (-1);
constant BZ_PARAM_ERROR is export = (-2);
constant BZ_MEM_ERROR is export = (-3);
constant BZ_DATA_ERROR is export = (-4);
constant BZ_DATA_ERROR_MAGIC is export = (-5);
constant BZ_IO_ERROR is export = (-6);
constant BZ_UNEXPECTED_EOF is export = (-7);
constant BZ_OUTBUFF_FULL is export = (-8);
constant BZ_CONFIG_ERROR is export = (-9);

## Low-level.
# Compress.
our sub BZ2_bzCompressInit(bz_stream, int32, int32, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzCompress(bz_stream, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ_bzCompressEnd(bz_stream) returns int32 is native("bz2", v1) is export { * }
# Decompress.
our sub BZ_bzDecompressInit(bz_stream, int32, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ_bzDecompress(bz_stream) returns int32 is native("bz2", v1) is export { * }
our sub BZ_bzDecompressEnd(bz_stream) returns int32 is native("bz2", v1) is export { * }

## High-level.
# Reading.
our sub BZ2_bzReadOpen(int32 is rw, OpaquePointer, int32, int32, Pointer[uint8], int32) returns OpaquePointer is native("bz2", v1) is export { * }
our sub BZ2_bzRead(int32 is rw, OpaquePointer, CArray[int8], int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzReadClose(int32 is rw, Pointer[void]) is native("bz2", v1) is export { * }
our sub BZ2_bzReadGetUnused(int32 is rw, Pointer[void], Pointer, int32 is rw) is native("bz2", v1) is export { * }
# Writing.
our sub BZ2_bzWriteOpen(int32 is rw, OpaquePointer, int32, int32, int32) returns OpaquePointer is native("bz2", v1) is export { * }
our sub BZ2_bzWrite(int32 is rw, OpaquePointer, CArray[int8], int32) is native("bz2", v1) is export { * }
our sub BZ2_bzWriteClose(int32 is rw, Pointer, int32, Pointer[uint32], Pointer[uint32]) is native("bz2", v1) is export { * }
our sub BZ2_bzWriteClose64(int32 is rw, OpaquePointer, int32, Pointer[uint32], Pointer[uint32], Pointer[uint32], Pointer[uint32]) is native("bz2", v1) is export { * }

## Utility.
our sub BZ2_bzBuffToBuffCompress(CArray[uint8], Pointer[uint32], CArray[uint8], uint32, int32, int32, int32) returns int32 is native("bz2", v1) is export { * }
our sub BZ2_bzBuffToBuffDecompress(CArray[uint8], Pointer[uint32], CArray[uint8], uint32, int32, int32) returns int32 is native("bz2", v1) is export { * }
