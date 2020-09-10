
proc toBin(b: byte): string =
  const BinChars = "01"
  result = newString(8)
  var n = b
  for i in countdown(7, 0):
    result[i] = BinChars[n and 0x01]
    n = n shr 1

proc toHex(b: byte): string =
  const HexChars = "0123456789ABCDEF"
  result = newString(2)
  result[1] = HexChars[b and 0x0F]
  result[0] = HexChars[(b and 0xF0) shr 4]

proc toHex(u16: uint16): string =
  const HexChars = "0123456789ABCDEF"
  var n = u16
  result = newString(8)
  for i in countdown(3, 0):
    result[i] = HexChars[n and 0x0F]
    n = n shr 4

proc to_byte_seq*(x: SomeUnsignedInt): seq[byte] =
  let mask: type(x) = 0xFF.uint8
  var n = x
  var b: byte
  for i in 0 ..< x.sizeof:
    b = (n and mask).byte
    result.add(b)
    n = n shr 8

proc to_byte_seq*(x: SomeSignedInt): seq[byte] =
  let nBytes = x.sizeof
  case nBytes:
    of 1 : result = cast[uint8](x).to_byte_seq
    of 2 : result = cast[uint16](x).to_byte_seq
    of 4 : result = cast[uint32](x).to_byte_seq
    of 8 : result = cast[uint64](x).to_byte_seq
    else: echo "to_byte_seq: unsuported type: ", $type(x)

proc to_u16_seq*(x: SomeUnsignedInt): seq[uint16] =
  let nBytes = x.sizeof
  assert nBytes >= 2
  assert nBytes.mod(2) == 0
  let nU16 = nBytes.div(2)
  let mask: type(x) = 0xFFFF
  var n = x
  var u16: uint16
  for i in 0 ..< nU16:
    u16 = (n and mask).uint16
    result.add(u16)
    n = n shr 16

proc toBinAuto(x: uint8; prefix="0b", sep=""): string =
  result = prefix & x.toBin

proc toBinAuto(x: SomeInteger; prefix="0b", sep="_"): string =
  let bs = x.to_byte_seq
  let n = bs.len
  var i = 0
  result = prefix
  for i in countdown(n-1, 0):
    let b = bs[i]
    let s = b.toBin
    result &= s
    if i > 0:
      result &= sep

proc toHexAuto(x: uint8; prefix="0x", sep="_"): string =
  result = prefix & x.toHex

proc toHexAuto(x: SomeInteger; prefix="0x", sep="_"): string =
  let u16s = x.to_u16_seq
  let n = u16s.len
  var u16 : uint16
  var i = 0
  result = prefix
  for i in countdown(n-1, 0):
    let u16 = u16s[i]
    let s = u16.toHex
    result &= s
    if i > 0:
      result &= sep

proc toBinAuto(f32: float32): string =
  result = cast[int32](f32).toBinAuto

proc toHexAuto(f32: float32): string =
  result = cast[uint32](f32).toHexAuto

proc toBinAuto(f64: float64): string =
  result = cast[uint64](f64).toBinAuto

proc toHexAuto(f64: float64): string =
  result = cast[uint64](f64).toHexAuto

#-------------------------------------

#IEEE 754 single-precision binary floating-point format: binary32
# Sign bit: 1 bit
# Exponent width: 8 bits
# Significand precision: 24 bits (23 explicitly stored)


# IEEE 754 half-precision binary floating-point format: binary16
# Sign bit: 1 bit
# Exponent width: 5 bits
# Significand precision: 11 bits (10 explicitly stored)

type Float16 = uint16

proc float32To16(f: float32): Float16 =
  var u32 = cast[uint32](f)
  u32 = u32.shr(13) # drop 13 bits over 23 of float32 mant
  let manf16 = (u32 and 0x000003FF'u32).uint16 # keep 10 bits of mant
  u32 = u32.shr(10) # drop the 10 bits of mant
  var expf16: uint16 = (u32 and 0x000000FF).uint16 # keep the 5 bits of exp
  u32 = u32.shr(8) # drop the 5 bits of exp

  let sigf16 = u32.uint16
  if expf16 == 255 : # infinite
    expf16 = 31
  elif (0 < expf16) and (expf16 < 255) :
    assert expf16 > (127 - 15).uint16, "ERROR in float32To16: " & $expf16 & " !> " & $(127 - 15)
    expf16 -= (127 - 15).uint16
  else:
    assert expf16 == 0, "ERROR in float32To16: expf16: " & $expf16 & " != 0 !"
  result = cast[Float16](sigf16.shl(15) or expf16.shl(10) or manf16)

proc float16(f32: float32): Float16 = result = float32To16(f32)
proc float16(f64: float64): Float16 = result = float32To16(f64.float32)

proc float16To32(f: Float16): float32 =
  let sgnf16 = f and 0x8000'u16 # or 0b1000_0000_0000_0000'u16
  let expf16 = f and 0x7C00'u16 # or 0b0111_1100_0000_0000'u16
  let manf16 = f and 0x03FF'u16 # or 0b0000_0011_1111_1111'u16

  let sgnf32: uint32 = sgnf16.uint32.shl(16)
  let manf32: uint32 = manf16.uint32.shl(13)

  var expf32 = expf16.shr(10).uint32
  if expf32 == 31 : # infinite
    expf32 = 255
  elif (0 < expf32) and (expf32 < 31) :
    expf32 += (127 - 15).uint32
  else:
    assert expf32 == 0, "ERROR in float16To32: expf32: " & $expf32 & " != 0 !"

  expf32 = expf32.shl(23) # let space for the 23 bits of mant

  result = cast[float32](sgnf32 or expf32 or manf32)

#============================================================
# toUnsigned

when isMainModule:
  import strformat

  if false:
    var u64 : uint64
    u64 = 0xFFFF_FFFF_FFFF_FFFF'u64
    echo "u64: ", u64.to_byte_seq

    var u32 : uint32
    u32 = 0xFFFF_FFFF'u32
    echo "u32: ", u32.to_byte_seq

    var u16 : uint16
    u16 = 0xFFFF'u16
    echo "u16: ", u16.to_byte_seq

    var u8 = 0xFF.uint8
    echo "u8: ", u8.to_byte_seq

    echo "u8:  ", u8.toBinAuto , ", ",  u8.toHexAuto, ", ", u8
    echo "u16: ", u16.toBinAuto, ", ", u16.toHexAuto, ", ", u16
    echo "u32: ", u32.toBinAuto, ", ", u32.toHexAuto, ", ", u32
    echo "u64: ", u64.toBinAuto, ", ", u64.toHexAuto, ", ", u64

    var i64 : int64
    i64 = - 1
    echo "i64: ", i64.to_byte_seq

    var i32 : int32
    i32 = - 1
    echo "i32: ", i32.to_byte_seq

    var i16 : int16
    i16 = - 1
    echo "i16: ", i16.to_byte_seq

    var i8 : int8
    i8 = - 1
    echo "i8: ", i8.to_byte_seq

  for f in [0.0, 1.0, -1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 2045.0, 2046.0, 2047.0, 2048.0, 2049.0, 2050.0, 2051.0, 2052.0, 1.0/0.0, 0.0/0.0]:
    let f16 = f.float16
    echo fmt"f64:{f:8.3f}, f64:{f.toBinAuto}, f64:{f.toHexAuto}, f16:{f16.toBinAuto}, f16:{f16.toHexAuto}, f32 form f16:{f16.float16To32:8.3f}"

