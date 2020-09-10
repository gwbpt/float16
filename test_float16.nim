
import float16
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
  let fback = f16.float
  echo fmt"f64:{f:8.3f}, f64:{f.toBinAuto}, f64:{f.toHexAuto}, f16:{f16.toBinAuto}, f16:{f16.toHexAuto}, f32 form f16:{f16.float32:11.6f}, f64 back:{f16.toF64:11.6f}, f64 back:{f16.toF64.toHexAuto}"

