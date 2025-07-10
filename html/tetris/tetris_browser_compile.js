(() => {
  var __create = Object.create;
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getProtoOf = Object.getPrototypeOf;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __esm = (fn, res) => function __init() {
    return fn && (res = (0, fn[__getOwnPropNames(fn)[0]])(fn = 0)), res;
  };
  var __commonJS = (cb, mod) => function __require() {
    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
    // If the importer is in node compatibility mode or this is not an ESM
    // file that has been converted to a CommonJS file using a Babel-
    // compatible transform (i.e. "__esModule" has not been set), then set
    // "default" to the CommonJS "module.exports" for node compatibility.
    isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
    mod
  ));

  // node_modules/base64-js/index.js
  var require_base64_js = __commonJS({
    "node_modules/base64-js/index.js"(exports) {
      "use strict";
      init_shim();
      exports.byteLength = byteLength;
      exports.toByteArray = toByteArray;
      exports.fromByteArray = fromByteArray;
      var lookup = [];
      var revLookup = [];
      var Arr = typeof Uint8Array !== "undefined" ? Uint8Array : Array;
      var code = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
      for (i = 0, len = code.length; i < len; ++i) {
        lookup[i] = code[i];
        revLookup[code.charCodeAt(i)] = i;
      }
      var i;
      var len;
      revLookup["-".charCodeAt(0)] = 62;
      revLookup["_".charCodeAt(0)] = 63;
      function getLens(b64) {
        var len2 = b64.length;
        if (len2 % 4 > 0) {
          throw new Error("Invalid string. Length must be a multiple of 4");
        }
        var validLen = b64.indexOf("=");
        if (validLen === -1) validLen = len2;
        var placeHoldersLen = validLen === len2 ? 0 : 4 - validLen % 4;
        return [validLen, placeHoldersLen];
      }
      function byteLength(b64) {
        var lens = getLens(b64);
        var validLen = lens[0];
        var placeHoldersLen = lens[1];
        return (validLen + placeHoldersLen) * 3 / 4 - placeHoldersLen;
      }
      function _byteLength(b64, validLen, placeHoldersLen) {
        return (validLen + placeHoldersLen) * 3 / 4 - placeHoldersLen;
      }
      function toByteArray(b64) {
        var tmp;
        var lens = getLens(b64);
        var validLen = lens[0];
        var placeHoldersLen = lens[1];
        var arr = new Arr(_byteLength(b64, validLen, placeHoldersLen));
        var curByte = 0;
        var len2 = placeHoldersLen > 0 ? validLen - 4 : validLen;
        var i2;
        for (i2 = 0; i2 < len2; i2 += 4) {
          tmp = revLookup[b64.charCodeAt(i2)] << 18 | revLookup[b64.charCodeAt(i2 + 1)] << 12 | revLookup[b64.charCodeAt(i2 + 2)] << 6 | revLookup[b64.charCodeAt(i2 + 3)];
          arr[curByte++] = tmp >> 16 & 255;
          arr[curByte++] = tmp >> 8 & 255;
          arr[curByte++] = tmp & 255;
        }
        if (placeHoldersLen === 2) {
          tmp = revLookup[b64.charCodeAt(i2)] << 2 | revLookup[b64.charCodeAt(i2 + 1)] >> 4;
          arr[curByte++] = tmp & 255;
        }
        if (placeHoldersLen === 1) {
          tmp = revLookup[b64.charCodeAt(i2)] << 10 | revLookup[b64.charCodeAt(i2 + 1)] << 4 | revLookup[b64.charCodeAt(i2 + 2)] >> 2;
          arr[curByte++] = tmp >> 8 & 255;
          arr[curByte++] = tmp & 255;
        }
        return arr;
      }
      function tripletToBase64(num) {
        return lookup[num >> 18 & 63] + lookup[num >> 12 & 63] + lookup[num >> 6 & 63] + lookup[num & 63];
      }
      function encodeChunk(uint8, start, end) {
        var tmp;
        var output = [];
        for (var i2 = start; i2 < end; i2 += 3) {
          tmp = (uint8[i2] << 16 & 16711680) + (uint8[i2 + 1] << 8 & 65280) + (uint8[i2 + 2] & 255);
          output.push(tripletToBase64(tmp));
        }
        return output.join("");
      }
      function fromByteArray(uint8) {
        var tmp;
        var len2 = uint8.length;
        var extraBytes = len2 % 3;
        var parts = [];
        var maxChunkLength = 16383;
        for (var i2 = 0, len22 = len2 - extraBytes; i2 < len22; i2 += maxChunkLength) {
          parts.push(encodeChunk(uint8, i2, i2 + maxChunkLength > len22 ? len22 : i2 + maxChunkLength));
        }
        if (extraBytes === 1) {
          tmp = uint8[len2 - 1];
          parts.push(
            lookup[tmp >> 2] + lookup[tmp << 4 & 63] + "=="
          );
        } else if (extraBytes === 2) {
          tmp = (uint8[len2 - 2] << 8) + uint8[len2 - 1];
          parts.push(
            lookup[tmp >> 10] + lookup[tmp >> 4 & 63] + lookup[tmp << 2 & 63] + "="
          );
        }
        return parts.join("");
      }
    }
  });

  // node_modules/ieee754/index.js
  var require_ieee754 = __commonJS({
    "node_modules/ieee754/index.js"(exports) {
      init_shim();
      exports.read = function(buffer, offset, isLE, mLen, nBytes) {
        var e, m;
        var eLen = nBytes * 8 - mLen - 1;
        var eMax = (1 << eLen) - 1;
        var eBias = eMax >> 1;
        var nBits = -7;
        var i = isLE ? nBytes - 1 : 0;
        var d = isLE ? -1 : 1;
        var s = buffer[offset + i];
        i += d;
        e = s & (1 << -nBits) - 1;
        s >>= -nBits;
        nBits += eLen;
        for (; nBits > 0; e = e * 256 + buffer[offset + i], i += d, nBits -= 8) {
        }
        m = e & (1 << -nBits) - 1;
        e >>= -nBits;
        nBits += mLen;
        for (; nBits > 0; m = m * 256 + buffer[offset + i], i += d, nBits -= 8) {
        }
        if (e === 0) {
          e = 1 - eBias;
        } else if (e === eMax) {
          return m ? NaN : (s ? -1 : 1) * Infinity;
        } else {
          m = m + Math.pow(2, mLen);
          e = e - eBias;
        }
        return (s ? -1 : 1) * m * Math.pow(2, e - mLen);
      };
      exports.write = function(buffer, value, offset, isLE, mLen, nBytes) {
        var e, m, c;
        var eLen = nBytes * 8 - mLen - 1;
        var eMax = (1 << eLen) - 1;
        var eBias = eMax >> 1;
        var rt = mLen === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0;
        var i = isLE ? 0 : nBytes - 1;
        var d = isLE ? 1 : -1;
        var s = value < 0 || value === 0 && 1 / value < 0 ? 1 : 0;
        value = Math.abs(value);
        if (isNaN(value) || value === Infinity) {
          m = isNaN(value) ? 1 : 0;
          e = eMax;
        } else {
          e = Math.floor(Math.log(value) / Math.LN2);
          if (value * (c = Math.pow(2, -e)) < 1) {
            e--;
            c *= 2;
          }
          if (e + eBias >= 1) {
            value += rt / c;
          } else {
            value += rt * Math.pow(2, 1 - eBias);
          }
          if (value * c >= 2) {
            e++;
            c /= 2;
          }
          if (e + eBias >= eMax) {
            m = 0;
            e = eMax;
          } else if (e + eBias >= 1) {
            m = (value * c - 1) * Math.pow(2, mLen);
            e = e + eBias;
          } else {
            m = value * Math.pow(2, eBias - 1) * Math.pow(2, mLen);
            e = 0;
          }
        }
        for (; mLen >= 8; buffer[offset + i] = m & 255, i += d, m /= 256, mLen -= 8) {
        }
        e = e << mLen | m;
        eLen += mLen;
        for (; eLen > 0; buffer[offset + i] = e & 255, i += d, e /= 256, eLen -= 8) {
        }
        buffer[offset + i - d] |= s * 128;
      };
    }
  });

  // node_modules/buffer/index.js
  var require_buffer = __commonJS({
    "node_modules/buffer/index.js"(exports) {
      "use strict";
      init_shim();
      var base64 = require_base64_js();
      var ieee754 = require_ieee754();
      var customInspectSymbol = typeof Symbol === "function" && typeof Symbol["for"] === "function" ? Symbol["for"]("nodejs.util.inspect.custom") : null;
      exports.Buffer = Buffer3;
      exports.SlowBuffer = SlowBuffer;
      exports.INSPECT_MAX_BYTES = 50;
      var K_MAX_LENGTH = 2147483647;
      exports.kMaxLength = K_MAX_LENGTH;
      Buffer3.TYPED_ARRAY_SUPPORT = typedArraySupport();
      if (!Buffer3.TYPED_ARRAY_SUPPORT && typeof console !== "undefined" && typeof console.error === "function") {
        console.error(
          "This browser lacks typed array (Uint8Array) support which is required by `buffer` v5.x. Use `buffer` v4.x if you require old browser support."
        );
      }
      function typedArraySupport() {
        try {
          var arr = new Uint8Array(1);
          var proto = { foo: function() {
            return 42;
          } };
          Object.setPrototypeOf(proto, Uint8Array.prototype);
          Object.setPrototypeOf(arr, proto);
          return arr.foo() === 42;
        } catch (e) {
          return false;
        }
      }
      Object.defineProperty(Buffer3.prototype, "parent", {
        enumerable: true,
        get: function() {
          if (!Buffer3.isBuffer(this)) return void 0;
          return this.buffer;
        }
      });
      Object.defineProperty(Buffer3.prototype, "offset", {
        enumerable: true,
        get: function() {
          if (!Buffer3.isBuffer(this)) return void 0;
          return this.byteOffset;
        }
      });
      function createBuffer(length) {
        if (length > K_MAX_LENGTH) {
          throw new RangeError('The value "' + length + '" is invalid for option "size"');
        }
        var buf = new Uint8Array(length);
        Object.setPrototypeOf(buf, Buffer3.prototype);
        return buf;
      }
      function Buffer3(arg, encodingOrOffset, length) {
        if (typeof arg === "number") {
          if (typeof encodingOrOffset === "string") {
            throw new TypeError(
              'The "string" argument must be of type string. Received type number'
            );
          }
          return allocUnsafe(arg);
        }
        return from(arg, encodingOrOffset, length);
      }
      Buffer3.poolSize = 8192;
      function from(value, encodingOrOffset, length) {
        if (typeof value === "string") {
          return fromString(value, encodingOrOffset);
        }
        if (ArrayBuffer.isView(value)) {
          return fromArrayView(value);
        }
        if (value == null) {
          throw new TypeError(
            "The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type " + typeof value
          );
        }
        if (isInstance(value, ArrayBuffer) || value && isInstance(value.buffer, ArrayBuffer)) {
          return fromArrayBuffer(value, encodingOrOffset, length);
        }
        if (typeof SharedArrayBuffer !== "undefined" && (isInstance(value, SharedArrayBuffer) || value && isInstance(value.buffer, SharedArrayBuffer))) {
          return fromArrayBuffer(value, encodingOrOffset, length);
        }
        if (typeof value === "number") {
          throw new TypeError(
            'The "value" argument must not be of type number. Received type number'
          );
        }
        var valueOf = value.valueOf && value.valueOf();
        if (valueOf != null && valueOf !== value) {
          return Buffer3.from(valueOf, encodingOrOffset, length);
        }
        var b = fromObject(value);
        if (b) return b;
        if (typeof Symbol !== "undefined" && Symbol.toPrimitive != null && typeof value[Symbol.toPrimitive] === "function") {
          return Buffer3.from(
            value[Symbol.toPrimitive]("string"),
            encodingOrOffset,
            length
          );
        }
        throw new TypeError(
          "The first argument must be one of type string, Buffer, ArrayBuffer, Array, or Array-like Object. Received type " + typeof value
        );
      }
      Buffer3.from = function(value, encodingOrOffset, length) {
        return from(value, encodingOrOffset, length);
      };
      Object.setPrototypeOf(Buffer3.prototype, Uint8Array.prototype);
      Object.setPrototypeOf(Buffer3, Uint8Array);
      function assertSize(size) {
        if (typeof size !== "number") {
          throw new TypeError('"size" argument must be of type number');
        } else if (size < 0) {
          throw new RangeError('The value "' + size + '" is invalid for option "size"');
        }
      }
      function alloc(size, fill, encoding) {
        assertSize(size);
        if (size <= 0) {
          return createBuffer(size);
        }
        if (fill !== void 0) {
          return typeof encoding === "string" ? createBuffer(size).fill(fill, encoding) : createBuffer(size).fill(fill);
        }
        return createBuffer(size);
      }
      Buffer3.alloc = function(size, fill, encoding) {
        return alloc(size, fill, encoding);
      };
      function allocUnsafe(size) {
        assertSize(size);
        return createBuffer(size < 0 ? 0 : checked(size) | 0);
      }
      Buffer3.allocUnsafe = function(size) {
        return allocUnsafe(size);
      };
      Buffer3.allocUnsafeSlow = function(size) {
        return allocUnsafe(size);
      };
      function fromString(string, encoding) {
        if (typeof encoding !== "string" || encoding === "") {
          encoding = "utf8";
        }
        if (!Buffer3.isEncoding(encoding)) {
          throw new TypeError("Unknown encoding: " + encoding);
        }
        var length = byteLength(string, encoding) | 0;
        var buf = createBuffer(length);
        var actual = buf.write(string, encoding);
        if (actual !== length) {
          buf = buf.slice(0, actual);
        }
        return buf;
      }
      function fromArrayLike(array) {
        var length = array.length < 0 ? 0 : checked(array.length) | 0;
        var buf = createBuffer(length);
        for (var i = 0; i < length; i += 1) {
          buf[i] = array[i] & 255;
        }
        return buf;
      }
      function fromArrayView(arrayView) {
        if (isInstance(arrayView, Uint8Array)) {
          var copy = new Uint8Array(arrayView);
          return fromArrayBuffer(copy.buffer, copy.byteOffset, copy.byteLength);
        }
        return fromArrayLike(arrayView);
      }
      function fromArrayBuffer(array, byteOffset, length) {
        if (byteOffset < 0 || array.byteLength < byteOffset) {
          throw new RangeError('"offset" is outside of buffer bounds');
        }
        if (array.byteLength < byteOffset + (length || 0)) {
          throw new RangeError('"length" is outside of buffer bounds');
        }
        var buf;
        if (byteOffset === void 0 && length === void 0) {
          buf = new Uint8Array(array);
        } else if (length === void 0) {
          buf = new Uint8Array(array, byteOffset);
        } else {
          buf = new Uint8Array(array, byteOffset, length);
        }
        Object.setPrototypeOf(buf, Buffer3.prototype);
        return buf;
      }
      function fromObject(obj) {
        if (Buffer3.isBuffer(obj)) {
          var len = checked(obj.length) | 0;
          var buf = createBuffer(len);
          if (buf.length === 0) {
            return buf;
          }
          obj.copy(buf, 0, 0, len);
          return buf;
        }
        if (obj.length !== void 0) {
          if (typeof obj.length !== "number" || numberIsNaN(obj.length)) {
            return createBuffer(0);
          }
          return fromArrayLike(obj);
        }
        if (obj.type === "Buffer" && Array.isArray(obj.data)) {
          return fromArrayLike(obj.data);
        }
      }
      function checked(length) {
        if (length >= K_MAX_LENGTH) {
          throw new RangeError("Attempt to allocate Buffer larger than maximum size: 0x" + K_MAX_LENGTH.toString(16) + " bytes");
        }
        return length | 0;
      }
      function SlowBuffer(length) {
        if (+length != length) {
          length = 0;
        }
        return Buffer3.alloc(+length);
      }
      Buffer3.isBuffer = function isBuffer(b) {
        return b != null && b._isBuffer === true && b !== Buffer3.prototype;
      };
      Buffer3.compare = function compare(a, b) {
        if (isInstance(a, Uint8Array)) a = Buffer3.from(a, a.offset, a.byteLength);
        if (isInstance(b, Uint8Array)) b = Buffer3.from(b, b.offset, b.byteLength);
        if (!Buffer3.isBuffer(a) || !Buffer3.isBuffer(b)) {
          throw new TypeError(
            'The "buf1", "buf2" arguments must be one of type Buffer or Uint8Array'
          );
        }
        if (a === b) return 0;
        var x = a.length;
        var y = b.length;
        for (var i = 0, len = Math.min(x, y); i < len; ++i) {
          if (a[i] !== b[i]) {
            x = a[i];
            y = b[i];
            break;
          }
        }
        if (x < y) return -1;
        if (y < x) return 1;
        return 0;
      };
      Buffer3.isEncoding = function isEncoding(encoding) {
        switch (String(encoding).toLowerCase()) {
          case "hex":
          case "utf8":
          case "utf-8":
          case "ascii":
          case "latin1":
          case "binary":
          case "base64":
          case "ucs2":
          case "ucs-2":
          case "utf16le":
          case "utf-16le":
            return true;
          default:
            return false;
        }
      };
      Buffer3.concat = function concat(list, length) {
        if (!Array.isArray(list)) {
          throw new TypeError('"list" argument must be an Array of Buffers');
        }
        if (list.length === 0) {
          return Buffer3.alloc(0);
        }
        var i;
        if (length === void 0) {
          length = 0;
          for (i = 0; i < list.length; ++i) {
            length += list[i].length;
          }
        }
        var buffer = Buffer3.allocUnsafe(length);
        var pos = 0;
        for (i = 0; i < list.length; ++i) {
          var buf = list[i];
          if (isInstance(buf, Uint8Array)) {
            if (pos + buf.length > buffer.length) {
              Buffer3.from(buf).copy(buffer, pos);
            } else {
              Uint8Array.prototype.set.call(
                buffer,
                buf,
                pos
              );
            }
          } else if (!Buffer3.isBuffer(buf)) {
            throw new TypeError('"list" argument must be an Array of Buffers');
          } else {
            buf.copy(buffer, pos);
          }
          pos += buf.length;
        }
        return buffer;
      };
      function byteLength(string, encoding) {
        if (Buffer3.isBuffer(string)) {
          return string.length;
        }
        if (ArrayBuffer.isView(string) || isInstance(string, ArrayBuffer)) {
          return string.byteLength;
        }
        if (typeof string !== "string") {
          throw new TypeError(
            'The "string" argument must be one of type string, Buffer, or ArrayBuffer. Received type ' + typeof string
          );
        }
        var len = string.length;
        var mustMatch = arguments.length > 2 && arguments[2] === true;
        if (!mustMatch && len === 0) return 0;
        var loweredCase = false;
        for (; ; ) {
          switch (encoding) {
            case "ascii":
            case "latin1":
            case "binary":
              return len;
            case "utf8":
            case "utf-8":
              return utf8ToBytes(string).length;
            case "ucs2":
            case "ucs-2":
            case "utf16le":
            case "utf-16le":
              return len * 2;
            case "hex":
              return len >>> 1;
            case "base64":
              return base64ToBytes(string).length;
            default:
              if (loweredCase) {
                return mustMatch ? -1 : utf8ToBytes(string).length;
              }
              encoding = ("" + encoding).toLowerCase();
              loweredCase = true;
          }
        }
      }
      Buffer3.byteLength = byteLength;
      function slowToString(encoding, start, end) {
        var loweredCase = false;
        if (start === void 0 || start < 0) {
          start = 0;
        }
        if (start > this.length) {
          return "";
        }
        if (end === void 0 || end > this.length) {
          end = this.length;
        }
        if (end <= 0) {
          return "";
        }
        end >>>= 0;
        start >>>= 0;
        if (end <= start) {
          return "";
        }
        if (!encoding) encoding = "utf8";
        while (true) {
          switch (encoding) {
            case "hex":
              return hexSlice(this, start, end);
            case "utf8":
            case "utf-8":
              return utf8Slice(this, start, end);
            case "ascii":
              return asciiSlice(this, start, end);
            case "latin1":
            case "binary":
              return latin1Slice(this, start, end);
            case "base64":
              return base64Slice(this, start, end);
            case "ucs2":
            case "ucs-2":
            case "utf16le":
            case "utf-16le":
              return utf16leSlice(this, start, end);
            default:
              if (loweredCase) throw new TypeError("Unknown encoding: " + encoding);
              encoding = (encoding + "").toLowerCase();
              loweredCase = true;
          }
        }
      }
      Buffer3.prototype._isBuffer = true;
      function swap(b, n, m) {
        var i = b[n];
        b[n] = b[m];
        b[m] = i;
      }
      Buffer3.prototype.swap16 = function swap16() {
        var len = this.length;
        if (len % 2 !== 0) {
          throw new RangeError("Buffer size must be a multiple of 16-bits");
        }
        for (var i = 0; i < len; i += 2) {
          swap(this, i, i + 1);
        }
        return this;
      };
      Buffer3.prototype.swap32 = function swap32() {
        var len = this.length;
        if (len % 4 !== 0) {
          throw new RangeError("Buffer size must be a multiple of 32-bits");
        }
        for (var i = 0; i < len; i += 4) {
          swap(this, i, i + 3);
          swap(this, i + 1, i + 2);
        }
        return this;
      };
      Buffer3.prototype.swap64 = function swap64() {
        var len = this.length;
        if (len % 8 !== 0) {
          throw new RangeError("Buffer size must be a multiple of 64-bits");
        }
        for (var i = 0; i < len; i += 8) {
          swap(this, i, i + 7);
          swap(this, i + 1, i + 6);
          swap(this, i + 2, i + 5);
          swap(this, i + 3, i + 4);
        }
        return this;
      };
      Buffer3.prototype.toString = function toString() {
        var length = this.length;
        if (length === 0) return "";
        if (arguments.length === 0) return utf8Slice(this, 0, length);
        return slowToString.apply(this, arguments);
      };
      Buffer3.prototype.toLocaleString = Buffer3.prototype.toString;
      Buffer3.prototype.equals = function equals(b) {
        if (!Buffer3.isBuffer(b)) throw new TypeError("Argument must be a Buffer");
        if (this === b) return true;
        return Buffer3.compare(this, b) === 0;
      };
      Buffer3.prototype.inspect = function inspect() {
        var str = "";
        var max = exports.INSPECT_MAX_BYTES;
        str = this.toString("hex", 0, max).replace(/(.{2})/g, "$1 ").trim();
        if (this.length > max) str += " ... ";
        return "<Buffer " + str + ">";
      };
      if (customInspectSymbol) {
        Buffer3.prototype[customInspectSymbol] = Buffer3.prototype.inspect;
      }
      Buffer3.prototype.compare = function compare(target, start, end, thisStart, thisEnd) {
        if (isInstance(target, Uint8Array)) {
          target = Buffer3.from(target, target.offset, target.byteLength);
        }
        if (!Buffer3.isBuffer(target)) {
          throw new TypeError(
            'The "target" argument must be one of type Buffer or Uint8Array. Received type ' + typeof target
          );
        }
        if (start === void 0) {
          start = 0;
        }
        if (end === void 0) {
          end = target ? target.length : 0;
        }
        if (thisStart === void 0) {
          thisStart = 0;
        }
        if (thisEnd === void 0) {
          thisEnd = this.length;
        }
        if (start < 0 || end > target.length || thisStart < 0 || thisEnd > this.length) {
          throw new RangeError("out of range index");
        }
        if (thisStart >= thisEnd && start >= end) {
          return 0;
        }
        if (thisStart >= thisEnd) {
          return -1;
        }
        if (start >= end) {
          return 1;
        }
        start >>>= 0;
        end >>>= 0;
        thisStart >>>= 0;
        thisEnd >>>= 0;
        if (this === target) return 0;
        var x = thisEnd - thisStart;
        var y = end - start;
        var len = Math.min(x, y);
        var thisCopy = this.slice(thisStart, thisEnd);
        var targetCopy = target.slice(start, end);
        for (var i = 0; i < len; ++i) {
          if (thisCopy[i] !== targetCopy[i]) {
            x = thisCopy[i];
            y = targetCopy[i];
            break;
          }
        }
        if (x < y) return -1;
        if (y < x) return 1;
        return 0;
      };
      function bidirectionalIndexOf(buffer, val, byteOffset, encoding, dir) {
        if (buffer.length === 0) return -1;
        if (typeof byteOffset === "string") {
          encoding = byteOffset;
          byteOffset = 0;
        } else if (byteOffset > 2147483647) {
          byteOffset = 2147483647;
        } else if (byteOffset < -2147483648) {
          byteOffset = -2147483648;
        }
        byteOffset = +byteOffset;
        if (numberIsNaN(byteOffset)) {
          byteOffset = dir ? 0 : buffer.length - 1;
        }
        if (byteOffset < 0) byteOffset = buffer.length + byteOffset;
        if (byteOffset >= buffer.length) {
          if (dir) return -1;
          else byteOffset = buffer.length - 1;
        } else if (byteOffset < 0) {
          if (dir) byteOffset = 0;
          else return -1;
        }
        if (typeof val === "string") {
          val = Buffer3.from(val, encoding);
        }
        if (Buffer3.isBuffer(val)) {
          if (val.length === 0) {
            return -1;
          }
          return arrayIndexOf(buffer, val, byteOffset, encoding, dir);
        } else if (typeof val === "number") {
          val = val & 255;
          if (typeof Uint8Array.prototype.indexOf === "function") {
            if (dir) {
              return Uint8Array.prototype.indexOf.call(buffer, val, byteOffset);
            } else {
              return Uint8Array.prototype.lastIndexOf.call(buffer, val, byteOffset);
            }
          }
          return arrayIndexOf(buffer, [val], byteOffset, encoding, dir);
        }
        throw new TypeError("val must be string, number or Buffer");
      }
      function arrayIndexOf(arr, val, byteOffset, encoding, dir) {
        var indexSize = 1;
        var arrLength = arr.length;
        var valLength = val.length;
        if (encoding !== void 0) {
          encoding = String(encoding).toLowerCase();
          if (encoding === "ucs2" || encoding === "ucs-2" || encoding === "utf16le" || encoding === "utf-16le") {
            if (arr.length < 2 || val.length < 2) {
              return -1;
            }
            indexSize = 2;
            arrLength /= 2;
            valLength /= 2;
            byteOffset /= 2;
          }
        }
        function read(buf, i2) {
          if (indexSize === 1) {
            return buf[i2];
          } else {
            return buf.readUInt16BE(i2 * indexSize);
          }
        }
        var i;
        if (dir) {
          var foundIndex = -1;
          for (i = byteOffset; i < arrLength; i++) {
            if (read(arr, i) === read(val, foundIndex === -1 ? 0 : i - foundIndex)) {
              if (foundIndex === -1) foundIndex = i;
              if (i - foundIndex + 1 === valLength) return foundIndex * indexSize;
            } else {
              if (foundIndex !== -1) i -= i - foundIndex;
              foundIndex = -1;
            }
          }
        } else {
          if (byteOffset + valLength > arrLength) byteOffset = arrLength - valLength;
          for (i = byteOffset; i >= 0; i--) {
            var found = true;
            for (var j = 0; j < valLength; j++) {
              if (read(arr, i + j) !== read(val, j)) {
                found = false;
                break;
              }
            }
            if (found) return i;
          }
        }
        return -1;
      }
      Buffer3.prototype.includes = function includes(val, byteOffset, encoding) {
        return this.indexOf(val, byteOffset, encoding) !== -1;
      };
      Buffer3.prototype.indexOf = function indexOf(val, byteOffset, encoding) {
        return bidirectionalIndexOf(this, val, byteOffset, encoding, true);
      };
      Buffer3.prototype.lastIndexOf = function lastIndexOf(val, byteOffset, encoding) {
        return bidirectionalIndexOf(this, val, byteOffset, encoding, false);
      };
      function hexWrite(buf, string, offset, length) {
        offset = Number(offset) || 0;
        var remaining = buf.length - offset;
        if (!length) {
          length = remaining;
        } else {
          length = Number(length);
          if (length > remaining) {
            length = remaining;
          }
        }
        var strLen = string.length;
        if (length > strLen / 2) {
          length = strLen / 2;
        }
        for (var i = 0; i < length; ++i) {
          var parsed = parseInt(string.substr(i * 2, 2), 16);
          if (numberIsNaN(parsed)) return i;
          buf[offset + i] = parsed;
        }
        return i;
      }
      function utf8Write(buf, string, offset, length) {
        return blitBuffer(utf8ToBytes(string, buf.length - offset), buf, offset, length);
      }
      function asciiWrite(buf, string, offset, length) {
        return blitBuffer(asciiToBytes(string), buf, offset, length);
      }
      function base64Write(buf, string, offset, length) {
        return blitBuffer(base64ToBytes(string), buf, offset, length);
      }
      function ucs2Write(buf, string, offset, length) {
        return blitBuffer(utf16leToBytes(string, buf.length - offset), buf, offset, length);
      }
      Buffer3.prototype.write = function write(string, offset, length, encoding) {
        if (offset === void 0) {
          encoding = "utf8";
          length = this.length;
          offset = 0;
        } else if (length === void 0 && typeof offset === "string") {
          encoding = offset;
          length = this.length;
          offset = 0;
        } else if (isFinite(offset)) {
          offset = offset >>> 0;
          if (isFinite(length)) {
            length = length >>> 0;
            if (encoding === void 0) encoding = "utf8";
          } else {
            encoding = length;
            length = void 0;
          }
        } else {
          throw new Error(
            "Buffer.write(string, encoding, offset[, length]) is no longer supported"
          );
        }
        var remaining = this.length - offset;
        if (length === void 0 || length > remaining) length = remaining;
        if (string.length > 0 && (length < 0 || offset < 0) || offset > this.length) {
          throw new RangeError("Attempt to write outside buffer bounds");
        }
        if (!encoding) encoding = "utf8";
        var loweredCase = false;
        for (; ; ) {
          switch (encoding) {
            case "hex":
              return hexWrite(this, string, offset, length);
            case "utf8":
            case "utf-8":
              return utf8Write(this, string, offset, length);
            case "ascii":
            case "latin1":
            case "binary":
              return asciiWrite(this, string, offset, length);
            case "base64":
              return base64Write(this, string, offset, length);
            case "ucs2":
            case "ucs-2":
            case "utf16le":
            case "utf-16le":
              return ucs2Write(this, string, offset, length);
            default:
              if (loweredCase) throw new TypeError("Unknown encoding: " + encoding);
              encoding = ("" + encoding).toLowerCase();
              loweredCase = true;
          }
        }
      };
      Buffer3.prototype.toJSON = function toJSON() {
        return {
          type: "Buffer",
          data: Array.prototype.slice.call(this._arr || this, 0)
        };
      };
      function base64Slice(buf, start, end) {
        if (start === 0 && end === buf.length) {
          return base64.fromByteArray(buf);
        } else {
          return base64.fromByteArray(buf.slice(start, end));
        }
      }
      function utf8Slice(buf, start, end) {
        end = Math.min(buf.length, end);
        var res = [];
        var i = start;
        while (i < end) {
          var firstByte = buf[i];
          var codePoint = null;
          var bytesPerSequence = firstByte > 239 ? 4 : firstByte > 223 ? 3 : firstByte > 191 ? 2 : 1;
          if (i + bytesPerSequence <= end) {
            var secondByte, thirdByte, fourthByte, tempCodePoint;
            switch (bytesPerSequence) {
              case 1:
                if (firstByte < 128) {
                  codePoint = firstByte;
                }
                break;
              case 2:
                secondByte = buf[i + 1];
                if ((secondByte & 192) === 128) {
                  tempCodePoint = (firstByte & 31) << 6 | secondByte & 63;
                  if (tempCodePoint > 127) {
                    codePoint = tempCodePoint;
                  }
                }
                break;
              case 3:
                secondByte = buf[i + 1];
                thirdByte = buf[i + 2];
                if ((secondByte & 192) === 128 && (thirdByte & 192) === 128) {
                  tempCodePoint = (firstByte & 15) << 12 | (secondByte & 63) << 6 | thirdByte & 63;
                  if (tempCodePoint > 2047 && (tempCodePoint < 55296 || tempCodePoint > 57343)) {
                    codePoint = tempCodePoint;
                  }
                }
                break;
              case 4:
                secondByte = buf[i + 1];
                thirdByte = buf[i + 2];
                fourthByte = buf[i + 3];
                if ((secondByte & 192) === 128 && (thirdByte & 192) === 128 && (fourthByte & 192) === 128) {
                  tempCodePoint = (firstByte & 15) << 18 | (secondByte & 63) << 12 | (thirdByte & 63) << 6 | fourthByte & 63;
                  if (tempCodePoint > 65535 && tempCodePoint < 1114112) {
                    codePoint = tempCodePoint;
                  }
                }
            }
          }
          if (codePoint === null) {
            codePoint = 65533;
            bytesPerSequence = 1;
          } else if (codePoint > 65535) {
            codePoint -= 65536;
            res.push(codePoint >>> 10 & 1023 | 55296);
            codePoint = 56320 | codePoint & 1023;
          }
          res.push(codePoint);
          i += bytesPerSequence;
        }
        return decodeCodePointsArray(res);
      }
      var MAX_ARGUMENTS_LENGTH = 4096;
      function decodeCodePointsArray(codePoints) {
        var len = codePoints.length;
        if (len <= MAX_ARGUMENTS_LENGTH) {
          return String.fromCharCode.apply(String, codePoints);
        }
        var res = "";
        var i = 0;
        while (i < len) {
          res += String.fromCharCode.apply(
            String,
            codePoints.slice(i, i += MAX_ARGUMENTS_LENGTH)
          );
        }
        return res;
      }
      function asciiSlice(buf, start, end) {
        var ret = "";
        end = Math.min(buf.length, end);
        for (var i = start; i < end; ++i) {
          ret += String.fromCharCode(buf[i] & 127);
        }
        return ret;
      }
      function latin1Slice(buf, start, end) {
        var ret = "";
        end = Math.min(buf.length, end);
        for (var i = start; i < end; ++i) {
          ret += String.fromCharCode(buf[i]);
        }
        return ret;
      }
      function hexSlice(buf, start, end) {
        var len = buf.length;
        if (!start || start < 0) start = 0;
        if (!end || end < 0 || end > len) end = len;
        var out = "";
        for (var i = start; i < end; ++i) {
          out += hexSliceLookupTable[buf[i]];
        }
        return out;
      }
      function utf16leSlice(buf, start, end) {
        var bytes = buf.slice(start, end);
        var res = "";
        for (var i = 0; i < bytes.length - 1; i += 2) {
          res += String.fromCharCode(bytes[i] + bytes[i + 1] * 256);
        }
        return res;
      }
      Buffer3.prototype.slice = function slice(start, end) {
        var len = this.length;
        start = ~~start;
        end = end === void 0 ? len : ~~end;
        if (start < 0) {
          start += len;
          if (start < 0) start = 0;
        } else if (start > len) {
          start = len;
        }
        if (end < 0) {
          end += len;
          if (end < 0) end = 0;
        } else if (end > len) {
          end = len;
        }
        if (end < start) end = start;
        var newBuf = this.subarray(start, end);
        Object.setPrototypeOf(newBuf, Buffer3.prototype);
        return newBuf;
      };
      function checkOffset(offset, ext, length) {
        if (offset % 1 !== 0 || offset < 0) throw new RangeError("offset is not uint");
        if (offset + ext > length) throw new RangeError("Trying to access beyond buffer length");
      }
      Buffer3.prototype.readUintLE = Buffer3.prototype.readUIntLE = function readUIntLE(offset, byteLength2, noAssert) {
        offset = offset >>> 0;
        byteLength2 = byteLength2 >>> 0;
        if (!noAssert) checkOffset(offset, byteLength2, this.length);
        var val = this[offset];
        var mul = 1;
        var i = 0;
        while (++i < byteLength2 && (mul *= 256)) {
          val += this[offset + i] * mul;
        }
        return val;
      };
      Buffer3.prototype.readUintBE = Buffer3.prototype.readUIntBE = function readUIntBE(offset, byteLength2, noAssert) {
        offset = offset >>> 0;
        byteLength2 = byteLength2 >>> 0;
        if (!noAssert) {
          checkOffset(offset, byteLength2, this.length);
        }
        var val = this[offset + --byteLength2];
        var mul = 1;
        while (byteLength2 > 0 && (mul *= 256)) {
          val += this[offset + --byteLength2] * mul;
        }
        return val;
      };
      Buffer3.prototype.readUint8 = Buffer3.prototype.readUInt8 = function readUInt8(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 1, this.length);
        return this[offset];
      };
      Buffer3.prototype.readUint16LE = Buffer3.prototype.readUInt16LE = function readUInt16LE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 2, this.length);
        return this[offset] | this[offset + 1] << 8;
      };
      Buffer3.prototype.readUint16BE = Buffer3.prototype.readUInt16BE = function readUInt16BE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 2, this.length);
        return this[offset] << 8 | this[offset + 1];
      };
      Buffer3.prototype.readUint32LE = Buffer3.prototype.readUInt32LE = function readUInt32LE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 4, this.length);
        return (this[offset] | this[offset + 1] << 8 | this[offset + 2] << 16) + this[offset + 3] * 16777216;
      };
      Buffer3.prototype.readUint32BE = Buffer3.prototype.readUInt32BE = function readUInt32BE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 4, this.length);
        return this[offset] * 16777216 + (this[offset + 1] << 16 | this[offset + 2] << 8 | this[offset + 3]);
      };
      Buffer3.prototype.readIntLE = function readIntLE(offset, byteLength2, noAssert) {
        offset = offset >>> 0;
        byteLength2 = byteLength2 >>> 0;
        if (!noAssert) checkOffset(offset, byteLength2, this.length);
        var val = this[offset];
        var mul = 1;
        var i = 0;
        while (++i < byteLength2 && (mul *= 256)) {
          val += this[offset + i] * mul;
        }
        mul *= 128;
        if (val >= mul) val -= Math.pow(2, 8 * byteLength2);
        return val;
      };
      Buffer3.prototype.readIntBE = function readIntBE(offset, byteLength2, noAssert) {
        offset = offset >>> 0;
        byteLength2 = byteLength2 >>> 0;
        if (!noAssert) checkOffset(offset, byteLength2, this.length);
        var i = byteLength2;
        var mul = 1;
        var val = this[offset + --i];
        while (i > 0 && (mul *= 256)) {
          val += this[offset + --i] * mul;
        }
        mul *= 128;
        if (val >= mul) val -= Math.pow(2, 8 * byteLength2);
        return val;
      };
      Buffer3.prototype.readInt8 = function readInt8(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 1, this.length);
        if (!(this[offset] & 128)) return this[offset];
        return (255 - this[offset] + 1) * -1;
      };
      Buffer3.prototype.readInt16LE = function readInt16LE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 2, this.length);
        var val = this[offset] | this[offset + 1] << 8;
        return val & 32768 ? val | 4294901760 : val;
      };
      Buffer3.prototype.readInt16BE = function readInt16BE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 2, this.length);
        var val = this[offset + 1] | this[offset] << 8;
        return val & 32768 ? val | 4294901760 : val;
      };
      Buffer3.prototype.readInt32LE = function readInt32LE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 4, this.length);
        return this[offset] | this[offset + 1] << 8 | this[offset + 2] << 16 | this[offset + 3] << 24;
      };
      Buffer3.prototype.readInt32BE = function readInt32BE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 4, this.length);
        return this[offset] << 24 | this[offset + 1] << 16 | this[offset + 2] << 8 | this[offset + 3];
      };
      Buffer3.prototype.readFloatLE = function readFloatLE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 4, this.length);
        return ieee754.read(this, offset, true, 23, 4);
      };
      Buffer3.prototype.readFloatBE = function readFloatBE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 4, this.length);
        return ieee754.read(this, offset, false, 23, 4);
      };
      Buffer3.prototype.readDoubleLE = function readDoubleLE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 8, this.length);
        return ieee754.read(this, offset, true, 52, 8);
      };
      Buffer3.prototype.readDoubleBE = function readDoubleBE(offset, noAssert) {
        offset = offset >>> 0;
        if (!noAssert) checkOffset(offset, 8, this.length);
        return ieee754.read(this, offset, false, 52, 8);
      };
      function checkInt(buf, value, offset, ext, max, min) {
        if (!Buffer3.isBuffer(buf)) throw new TypeError('"buffer" argument must be a Buffer instance');
        if (value > max || value < min) throw new RangeError('"value" argument is out of bounds');
        if (offset + ext > buf.length) throw new RangeError("Index out of range");
      }
      Buffer3.prototype.writeUintLE = Buffer3.prototype.writeUIntLE = function writeUIntLE(value, offset, byteLength2, noAssert) {
        value = +value;
        offset = offset >>> 0;
        byteLength2 = byteLength2 >>> 0;
        if (!noAssert) {
          var maxBytes = Math.pow(2, 8 * byteLength2) - 1;
          checkInt(this, value, offset, byteLength2, maxBytes, 0);
        }
        var mul = 1;
        var i = 0;
        this[offset] = value & 255;
        while (++i < byteLength2 && (mul *= 256)) {
          this[offset + i] = value / mul & 255;
        }
        return offset + byteLength2;
      };
      Buffer3.prototype.writeUintBE = Buffer3.prototype.writeUIntBE = function writeUIntBE(value, offset, byteLength2, noAssert) {
        value = +value;
        offset = offset >>> 0;
        byteLength2 = byteLength2 >>> 0;
        if (!noAssert) {
          var maxBytes = Math.pow(2, 8 * byteLength2) - 1;
          checkInt(this, value, offset, byteLength2, maxBytes, 0);
        }
        var i = byteLength2 - 1;
        var mul = 1;
        this[offset + i] = value & 255;
        while (--i >= 0 && (mul *= 256)) {
          this[offset + i] = value / mul & 255;
        }
        return offset + byteLength2;
      };
      Buffer3.prototype.writeUint8 = Buffer3.prototype.writeUInt8 = function writeUInt8(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 1, 255, 0);
        this[offset] = value & 255;
        return offset + 1;
      };
      Buffer3.prototype.writeUint16LE = Buffer3.prototype.writeUInt16LE = function writeUInt16LE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 2, 65535, 0);
        this[offset] = value & 255;
        this[offset + 1] = value >>> 8;
        return offset + 2;
      };
      Buffer3.prototype.writeUint16BE = Buffer3.prototype.writeUInt16BE = function writeUInt16BE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 2, 65535, 0);
        this[offset] = value >>> 8;
        this[offset + 1] = value & 255;
        return offset + 2;
      };
      Buffer3.prototype.writeUint32LE = Buffer3.prototype.writeUInt32LE = function writeUInt32LE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 4, 4294967295, 0);
        this[offset + 3] = value >>> 24;
        this[offset + 2] = value >>> 16;
        this[offset + 1] = value >>> 8;
        this[offset] = value & 255;
        return offset + 4;
      };
      Buffer3.prototype.writeUint32BE = Buffer3.prototype.writeUInt32BE = function writeUInt32BE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 4, 4294967295, 0);
        this[offset] = value >>> 24;
        this[offset + 1] = value >>> 16;
        this[offset + 2] = value >>> 8;
        this[offset + 3] = value & 255;
        return offset + 4;
      };
      Buffer3.prototype.writeIntLE = function writeIntLE(value, offset, byteLength2, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) {
          var limit = Math.pow(2, 8 * byteLength2 - 1);
          checkInt(this, value, offset, byteLength2, limit - 1, -limit);
        }
        var i = 0;
        var mul = 1;
        var sub = 0;
        this[offset] = value & 255;
        while (++i < byteLength2 && (mul *= 256)) {
          if (value < 0 && sub === 0 && this[offset + i - 1] !== 0) {
            sub = 1;
          }
          this[offset + i] = (value / mul >> 0) - sub & 255;
        }
        return offset + byteLength2;
      };
      Buffer3.prototype.writeIntBE = function writeIntBE(value, offset, byteLength2, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) {
          var limit = Math.pow(2, 8 * byteLength2 - 1);
          checkInt(this, value, offset, byteLength2, limit - 1, -limit);
        }
        var i = byteLength2 - 1;
        var mul = 1;
        var sub = 0;
        this[offset + i] = value & 255;
        while (--i >= 0 && (mul *= 256)) {
          if (value < 0 && sub === 0 && this[offset + i + 1] !== 0) {
            sub = 1;
          }
          this[offset + i] = (value / mul >> 0) - sub & 255;
        }
        return offset + byteLength2;
      };
      Buffer3.prototype.writeInt8 = function writeInt8(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 1, 127, -128);
        if (value < 0) value = 255 + value + 1;
        this[offset] = value & 255;
        return offset + 1;
      };
      Buffer3.prototype.writeInt16LE = function writeInt16LE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 2, 32767, -32768);
        this[offset] = value & 255;
        this[offset + 1] = value >>> 8;
        return offset + 2;
      };
      Buffer3.prototype.writeInt16BE = function writeInt16BE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 2, 32767, -32768);
        this[offset] = value >>> 8;
        this[offset + 1] = value & 255;
        return offset + 2;
      };
      Buffer3.prototype.writeInt32LE = function writeInt32LE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 4, 2147483647, -2147483648);
        this[offset] = value & 255;
        this[offset + 1] = value >>> 8;
        this[offset + 2] = value >>> 16;
        this[offset + 3] = value >>> 24;
        return offset + 4;
      };
      Buffer3.prototype.writeInt32BE = function writeInt32BE(value, offset, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) checkInt(this, value, offset, 4, 2147483647, -2147483648);
        if (value < 0) value = 4294967295 + value + 1;
        this[offset] = value >>> 24;
        this[offset + 1] = value >>> 16;
        this[offset + 2] = value >>> 8;
        this[offset + 3] = value & 255;
        return offset + 4;
      };
      function checkIEEE754(buf, value, offset, ext, max, min) {
        if (offset + ext > buf.length) throw new RangeError("Index out of range");
        if (offset < 0) throw new RangeError("Index out of range");
      }
      function writeFloat(buf, value, offset, littleEndian, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) {
          checkIEEE754(buf, value, offset, 4, 34028234663852886e22, -34028234663852886e22);
        }
        ieee754.write(buf, value, offset, littleEndian, 23, 4);
        return offset + 4;
      }
      Buffer3.prototype.writeFloatLE = function writeFloatLE(value, offset, noAssert) {
        return writeFloat(this, value, offset, true, noAssert);
      };
      Buffer3.prototype.writeFloatBE = function writeFloatBE(value, offset, noAssert) {
        return writeFloat(this, value, offset, false, noAssert);
      };
      function writeDouble(buf, value, offset, littleEndian, noAssert) {
        value = +value;
        offset = offset >>> 0;
        if (!noAssert) {
          checkIEEE754(buf, value, offset, 8, 17976931348623157e292, -17976931348623157e292);
        }
        ieee754.write(buf, value, offset, littleEndian, 52, 8);
        return offset + 8;
      }
      Buffer3.prototype.writeDoubleLE = function writeDoubleLE(value, offset, noAssert) {
        return writeDouble(this, value, offset, true, noAssert);
      };
      Buffer3.prototype.writeDoubleBE = function writeDoubleBE(value, offset, noAssert) {
        return writeDouble(this, value, offset, false, noAssert);
      };
      Buffer3.prototype.copy = function copy(target, targetStart, start, end) {
        if (!Buffer3.isBuffer(target)) throw new TypeError("argument should be a Buffer");
        if (!start) start = 0;
        if (!end && end !== 0) end = this.length;
        if (targetStart >= target.length) targetStart = target.length;
        if (!targetStart) targetStart = 0;
        if (end > 0 && end < start) end = start;
        if (end === start) return 0;
        if (target.length === 0 || this.length === 0) return 0;
        if (targetStart < 0) {
          throw new RangeError("targetStart out of bounds");
        }
        if (start < 0 || start >= this.length) throw new RangeError("Index out of range");
        if (end < 0) throw new RangeError("sourceEnd out of bounds");
        if (end > this.length) end = this.length;
        if (target.length - targetStart < end - start) {
          end = target.length - targetStart + start;
        }
        var len = end - start;
        if (this === target && typeof Uint8Array.prototype.copyWithin === "function") {
          this.copyWithin(targetStart, start, end);
        } else {
          Uint8Array.prototype.set.call(
            target,
            this.subarray(start, end),
            targetStart
          );
        }
        return len;
      };
      Buffer3.prototype.fill = function fill(val, start, end, encoding) {
        if (typeof val === "string") {
          if (typeof start === "string") {
            encoding = start;
            start = 0;
            end = this.length;
          } else if (typeof end === "string") {
            encoding = end;
            end = this.length;
          }
          if (encoding !== void 0 && typeof encoding !== "string") {
            throw new TypeError("encoding must be a string");
          }
          if (typeof encoding === "string" && !Buffer3.isEncoding(encoding)) {
            throw new TypeError("Unknown encoding: " + encoding);
          }
          if (val.length === 1) {
            var code = val.charCodeAt(0);
            if (encoding === "utf8" && code < 128 || encoding === "latin1") {
              val = code;
            }
          }
        } else if (typeof val === "number") {
          val = val & 255;
        } else if (typeof val === "boolean") {
          val = Number(val);
        }
        if (start < 0 || this.length < start || this.length < end) {
          throw new RangeError("Out of range index");
        }
        if (end <= start) {
          return this;
        }
        start = start >>> 0;
        end = end === void 0 ? this.length : end >>> 0;
        if (!val) val = 0;
        var i;
        if (typeof val === "number") {
          for (i = start; i < end; ++i) {
            this[i] = val;
          }
        } else {
          var bytes = Buffer3.isBuffer(val) ? val : Buffer3.from(val, encoding);
          var len = bytes.length;
          if (len === 0) {
            throw new TypeError('The value "' + val + '" is invalid for argument "value"');
          }
          for (i = 0; i < end - start; ++i) {
            this[i + start] = bytes[i % len];
          }
        }
        return this;
      };
      var INVALID_BASE64_RE = /[^+/0-9A-Za-z-_]/g;
      function base64clean(str) {
        str = str.split("=")[0];
        str = str.trim().replace(INVALID_BASE64_RE, "");
        if (str.length < 2) return "";
        while (str.length % 4 !== 0) {
          str = str + "=";
        }
        return str;
      }
      function utf8ToBytes(string, units) {
        units = units || Infinity;
        var codePoint;
        var length = string.length;
        var leadSurrogate = null;
        var bytes = [];
        for (var i = 0; i < length; ++i) {
          codePoint = string.charCodeAt(i);
          if (codePoint > 55295 && codePoint < 57344) {
            if (!leadSurrogate) {
              if (codePoint > 56319) {
                if ((units -= 3) > -1) bytes.push(239, 191, 189);
                continue;
              } else if (i + 1 === length) {
                if ((units -= 3) > -1) bytes.push(239, 191, 189);
                continue;
              }
              leadSurrogate = codePoint;
              continue;
            }
            if (codePoint < 56320) {
              if ((units -= 3) > -1) bytes.push(239, 191, 189);
              leadSurrogate = codePoint;
              continue;
            }
            codePoint = (leadSurrogate - 55296 << 10 | codePoint - 56320) + 65536;
          } else if (leadSurrogate) {
            if ((units -= 3) > -1) bytes.push(239, 191, 189);
          }
          leadSurrogate = null;
          if (codePoint < 128) {
            if ((units -= 1) < 0) break;
            bytes.push(codePoint);
          } else if (codePoint < 2048) {
            if ((units -= 2) < 0) break;
            bytes.push(
              codePoint >> 6 | 192,
              codePoint & 63 | 128
            );
          } else if (codePoint < 65536) {
            if ((units -= 3) < 0) break;
            bytes.push(
              codePoint >> 12 | 224,
              codePoint >> 6 & 63 | 128,
              codePoint & 63 | 128
            );
          } else if (codePoint < 1114112) {
            if ((units -= 4) < 0) break;
            bytes.push(
              codePoint >> 18 | 240,
              codePoint >> 12 & 63 | 128,
              codePoint >> 6 & 63 | 128,
              codePoint & 63 | 128
            );
          } else {
            throw new Error("Invalid code point");
          }
        }
        return bytes;
      }
      function asciiToBytes(str) {
        var byteArray = [];
        for (var i = 0; i < str.length; ++i) {
          byteArray.push(str.charCodeAt(i) & 255);
        }
        return byteArray;
      }
      function utf16leToBytes(str, units) {
        var c, hi, lo;
        var byteArray = [];
        for (var i = 0; i < str.length; ++i) {
          if ((units -= 2) < 0) break;
          c = str.charCodeAt(i);
          hi = c >> 8;
          lo = c % 256;
          byteArray.push(lo);
          byteArray.push(hi);
        }
        return byteArray;
      }
      function base64ToBytes(str) {
        return base64.toByteArray(base64clean(str));
      }
      function blitBuffer(src, dst, offset, length) {
        for (var i = 0; i < length; ++i) {
          if (i + offset >= dst.length || i >= src.length) break;
          dst[i + offset] = src[i];
        }
        return i;
      }
      function isInstance(obj, type) {
        return obj instanceof type || obj != null && obj.constructor != null && obj.constructor.name != null && obj.constructor.name === type.name;
      }
      function numberIsNaN(obj) {
        return obj !== obj;
      }
      var hexSliceLookupTable = function() {
        var alphabet = "0123456789abcdef";
        var table = new Array(256);
        for (var i = 0; i < 16; ++i) {
          var i16 = i * 16;
          for (var j = 0; j < 16; ++j) {
            table[i16 + j] = alphabet[i] + alphabet[j];
          }
        }
        return table;
      }();
    }
  });

  // node_modules/node-stdlib-browser/cjs/proxy/process.js
  var require_process = __commonJS({
    "node_modules/node-stdlib-browser/cjs/proxy/process.js"(exports, module) {
      "use strict";
      init_shim();
      Object.defineProperty(exports, "__esModule", { value: true });
      var browser$1 = { exports: {} };
      var process2 = browser$1.exports = {};
      var cachedSetTimeout;
      var cachedClearTimeout;
      function defaultSetTimout() {
        throw new Error("setTimeout has not been defined");
      }
      function defaultClearTimeout() {
        throw new Error("clearTimeout has not been defined");
      }
      (function() {
        try {
          if (typeof setTimeout === "function") {
            cachedSetTimeout = setTimeout;
          } else {
            cachedSetTimeout = defaultSetTimout;
          }
        } catch (e) {
          cachedSetTimeout = defaultSetTimout;
        }
        try {
          if (typeof clearTimeout === "function") {
            cachedClearTimeout = clearTimeout;
          } else {
            cachedClearTimeout = defaultClearTimeout;
          }
        } catch (e) {
          cachedClearTimeout = defaultClearTimeout;
        }
      })();
      function runTimeout(fun) {
        if (cachedSetTimeout === setTimeout) {
          return setTimeout(fun, 0);
        }
        if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
          cachedSetTimeout = setTimeout;
          return setTimeout(fun, 0);
        }
        try {
          return cachedSetTimeout(fun, 0);
        } catch (e) {
          try {
            return cachedSetTimeout.call(null, fun, 0);
          } catch (e2) {
            return cachedSetTimeout.call(this, fun, 0);
          }
        }
      }
      function runClearTimeout(marker) {
        if (cachedClearTimeout === clearTimeout) {
          return clearTimeout(marker);
        }
        if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
          cachedClearTimeout = clearTimeout;
          return clearTimeout(marker);
        }
        try {
          return cachedClearTimeout(marker);
        } catch (e) {
          try {
            return cachedClearTimeout.call(null, marker);
          } catch (e2) {
            return cachedClearTimeout.call(this, marker);
          }
        }
      }
      var queue = [];
      var draining = false;
      var currentQueue;
      var queueIndex = -1;
      function cleanUpNextTick() {
        if (!draining || !currentQueue) {
          return;
        }
        draining = false;
        if (currentQueue.length) {
          queue = currentQueue.concat(queue);
        } else {
          queueIndex = -1;
        }
        if (queue.length) {
          drainQueue();
        }
      }
      function drainQueue() {
        if (draining) {
          return;
        }
        var timeout = runTimeout(cleanUpNextTick);
        draining = true;
        var len = queue.length;
        while (len) {
          currentQueue = queue;
          queue = [];
          while (++queueIndex < len) {
            if (currentQueue) {
              currentQueue[queueIndex].run();
            }
          }
          queueIndex = -1;
          len = queue.length;
        }
        currentQueue = null;
        draining = false;
        runClearTimeout(timeout);
      }
      process2.nextTick = function(fun) {
        var args = new Array(arguments.length - 1);
        if (arguments.length > 1) {
          for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
          }
        }
        queue.push(new Item(fun, args));
        if (queue.length === 1 && !draining) {
          runTimeout(drainQueue);
        }
      };
      function Item(fun, array) {
        this.fun = fun;
        this.array = array;
      }
      Item.prototype.run = function() {
        this.fun.apply(null, this.array);
      };
      process2.title = "browser";
      process2.browser = true;
      process2.env = {};
      process2.argv = [];
      process2.version = "";
      process2.versions = {};
      function noop$1() {
      }
      process2.on = noop$1;
      process2.addListener = noop$1;
      process2.once = noop$1;
      process2.off = noop$1;
      process2.removeListener = noop$1;
      process2.removeAllListeners = noop$1;
      process2.emit = noop$1;
      process2.prependListener = noop$1;
      process2.prependOnceListener = noop$1;
      process2.listeners = function(name) {
        return [];
      };
      process2.binding = function(name) {
        throw new Error("process.binding is not supported");
      };
      process2.cwd = function() {
        return "/";
      };
      process2.chdir = function(dir) {
        throw new Error("process.chdir is not supported");
      };
      process2.umask = function() {
        return 0;
      };
      function noop() {
      }
      var browser = (
        /** @type {boolean} */
        browser$1.exports.browser
      );
      var emitWarning = noop;
      var binding = (
        /** @type {Function} */
        browser$1.exports.binding
      );
      var exit = noop;
      var pid = 1;
      var features = {};
      var kill = noop;
      var dlopen = noop;
      var uptime = noop;
      var memoryUsage = noop;
      var uvCounters = noop;
      var platform = "browser";
      var arch = "browser";
      var execPath = "browser";
      var execArgv = (
        /** @type {string[]} */
        []
      );
      var api = {
        nextTick: browser$1.exports.nextTick,
        title: browser$1.exports.title,
        browser,
        env: browser$1.exports.env,
        argv: browser$1.exports.argv,
        version: browser$1.exports.version,
        versions: browser$1.exports.versions,
        on: browser$1.exports.on,
        addListener: browser$1.exports.addListener,
        once: browser$1.exports.once,
        off: browser$1.exports.off,
        removeListener: browser$1.exports.removeListener,
        removeAllListeners: browser$1.exports.removeAllListeners,
        emit: browser$1.exports.emit,
        emitWarning,
        prependListener: browser$1.exports.prependListener,
        prependOnceListener: browser$1.exports.prependOnceListener,
        listeners: browser$1.exports.listeners,
        binding,
        cwd: browser$1.exports.cwd,
        chdir: browser$1.exports.chdir,
        umask: browser$1.exports.umask,
        exit,
        pid,
        features,
        kill,
        dlopen,
        uptime,
        memoryUsage,
        uvCounters,
        platform,
        arch,
        execPath,
        execArgv
      };
      exports.addListener = browser$1.exports.addListener;
      exports.arch = arch;
      exports.argv = browser$1.exports.argv;
      exports.binding = binding;
      exports.browser = browser;
      exports.chdir = browser$1.exports.chdir;
      exports.cwd = browser$1.exports.cwd;
      exports["default"] = api;
      exports.dlopen = dlopen;
      exports.emit = browser$1.exports.emit;
      exports.emitWarning = emitWarning;
      exports.env = browser$1.exports.env;
      exports.execArgv = execArgv;
      exports.execPath = execPath;
      exports.exit = exit;
      exports.features = features;
      exports.kill = kill;
      exports.listeners = browser$1.exports.listeners;
      exports.memoryUsage = memoryUsage;
      exports.nextTick = browser$1.exports.nextTick;
      exports.off = browser$1.exports.off;
      exports.on = browser$1.exports.on;
      exports.once = browser$1.exports.once;
      exports.pid = pid;
      exports.platform = platform;
      exports.prependListener = browser$1.exports.prependListener;
      exports.prependOnceListener = browser$1.exports.prependOnceListener;
      exports.removeAllListeners = browser$1.exports.removeAllListeners;
      exports.removeListener = browser$1.exports.removeListener;
      exports.title = browser$1.exports.title;
      exports.umask = browser$1.exports.umask;
      exports.uptime = uptime;
      exports.uvCounters = uvCounters;
      exports.version = browser$1.exports.version;
      exports.versions = browser$1.exports.versions;
      exports = module.exports = api;
    }
  });

  // node_modules/node-stdlib-browser/helpers/esbuild/shim.js
  var import_buffer, import_process, _globalThis;
  var init_shim = __esm({
    "node_modules/node-stdlib-browser/helpers/esbuild/shim.js"() {
      import_buffer = __toESM(require_buffer());
      import_process = __toESM(require_process());
      _globalThis = function(Object2) {
        function get() {
          var _global3 = this || self;
          delete Object2.prototype.__magic__;
          return _global3;
        }
        if (typeof globalThis === "object") {
          return globalThis;
        }
        if (this) {
          return get();
        } else {
          Object2.defineProperty(Object2.prototype, "__magic__", {
            configurable: true,
            get
          });
          var _global2 = __magic__;
          return _global2;
        }
      }(Object);
    }
  });

  // node_modules/json3/lib/json3.min.js
  var require_json3_min = __commonJS({
    "node_modules/json3/lib/json3.min.js"(exports, module) {
      init_shim();
      (function() {
        function O(u, v) {
          function B(a, d) {
            try {
              a();
            } catch (c) {
              d && d();
            }
          }
          function q(a) {
            if (null != q[a]) return q[a];
            if ("bug-string-char-index" == a) var d = false;
            else if ("json" == a) d = q("json-stringify") && q("date-serialization") && q("json-parse");
            else if ("date-serialization" == a) {
              if (d = q("json-stringify") && y) {
                var c = v.stringify;
                B(function() {
                  d = '"-271821-04-20T00:00:00.000Z"' == c(new z(-864e13)) && '"+275760-09-13T00:00:00.000Z"' == c(new z(864e13)) && '"-000001-01-01T00:00:00.000Z"' == c(new z(-621987552e5)) && '"1969-12-31T23:59:59.999Z"' == c(new z(-1));
                });
              }
            } else {
              var e;
              if ("json-stringify" == a) {
                c = v.stringify;
                var g = "function" == typeof c;
                g && ((e = function() {
                  return 1;
                }).toJSON = e, B(function() {
                  g = "0" === c(0) && "0" === c(new ca()) && '""' == c(new U()) && c(w) === x && c(x) === x && c() === x && "1" === c(e) && "[1]" == c([e]) && "[null]" == c([x]) && "null" == c(null) && "[null,null,null]" == c([x, w, null]) && '{"a":[1,true,false,null,"\\u0000\\b\\n\\f\\r\\t"]}' == c({ a: [e, true, false, null, "\0\b\n\f\r	"] }) && "1" === c(null, e) && "[\n 1,\n 2\n]" == c([1, 2], null, 1);
                }, function() {
                  g = false;
                }));
                d = g;
              }
              if ("json-parse" == a) {
                var l = v.parse, b;
                "function" == typeof l && B(function() {
                  0 === l("0") && !l(false) && (e = l('{"a":[1,true,false,null,"\\u0000\\b\\n\\f\\r\\t"]}'), b = 5 == e.a.length && 1 === e.a[0]) && (B(function() {
                    b = !l('"	"');
                  }), b && B(function() {
                    b = 1 !== l("01");
                  }), b && B(function() {
                    b = 1 !== l("1.");
                  }));
                }, function() {
                  b = false;
                });
                d = b;
              }
            }
            return q[a] = !!d;
          }
          u || (u = r.Object());
          v || (v = r.Object());
          var ca = u.Number || r.Number, U = u.String || r.String, I = u.Object || r.Object, z = u.Date || r.Date, da = u.SyntaxError || r.SyntaxError, ea = u.TypeError || r.TypeError, fa = u.Math || r.Math;
          u = u.JSON || r.JSON;
          "object" == typeof u && u && (v.stringify = u.stringify, v.parse = u.parse);
          I = I.prototype;
          var w = I.toString, J = I.hasOwnProperty, x, y = new z(-3509827334573292);
          B(function() {
            y = -109252 == y.getUTCFullYear() && 0 === y.getUTCMonth() && 1 === y.getUTCDate() && 10 == y.getUTCHours() && 37 == y.getUTCMinutes() && 6 == y.getUTCSeconds() && 708 == y.getUTCMilliseconds();
          });
          q["bug-string-char-index"] = q["date-serialization"] = q.json = q["json-stringify"] = q["json-parse"] = null;
          if (!q("json")) {
            var P = q("bug-string-char-index"), G = function(a, d) {
              var c = 0, e, g;
              (e = function() {
                this.valueOf = 0;
              }).prototype.valueOf = 0;
              var l = new e();
              for (g in l) J.call(l, g) && c++;
              e = l = null;
              c ? G = function(b, h) {
                var p = "[object Function]" == w.call(b), k, n;
                for (k in b) p && "prototype" == k || !J.call(b, k) || (n = "constructor" === k) || h(k);
                (n || J.call(b, k = "constructor")) && h(k);
              } : (l = "valueOf toString toLocaleString propertyIsEnumerable isPrototypeOf hasOwnProperty constructor".split(" "), G = function(b, h) {
                var p = "[object Function]" == w.call(b), k, n = !p && "function" != typeof b.constructor && H[typeof b.hasOwnProperty] && b.hasOwnProperty || J;
                for (k in b) p && "prototype" == k || !n.call(b, k) || h(k);
                for (p = l.length; k = l[--p]; ) n.call(b, k) && h(k);
              });
              return G(a, d);
            };
            if (!q("json-stringify") && !q("date-serialization")) {
              var ha = { 92: "\\\\", 34: '\\"', 8: "\\b", 12: "\\f", 10: "\\n", 13: "\\r", 9: "\\t" }, A = function(a, d) {
                return ("000000" + (d || 0)).slice(-a);
              }, L = function(a) {
                var d, c, e, g, l, b, h, p;
                if (y) var k = function(m) {
                  d = m.getUTCFullYear();
                  c = m.getUTCMonth();
                  e = m.getUTCDate();
                  l = m.getUTCHours();
                  b = m.getUTCMinutes();
                  h = m.getUTCSeconds();
                  p = m.getUTCMilliseconds();
                };
                else {
                  var n = fa.floor, K = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334], D = function(m, C) {
                    return K[C] + 365 * (m - 1970) + n((m - 1969 + (C = +(1 < C))) / 4) - n((m - 1901 + C) / 100) + n((m - 1601 + C) / 400);
                  };
                  k = function(m) {
                    e = n(m / 864e5);
                    for (d = n(e / 365.2425) + 1970 - 1; D(d + 1, 0) <= e; d++) ;
                    for (c = n((e - D(d, 0)) / 30.42); D(d, c + 1) <= e; c++) ;
                    e = 1 + e - D(d, c);
                    g = (m % 864e5 + 864e5) % 864e5;
                    l = n(g / 36e5) % 24;
                    b = n(g / 6e4) % 60;
                    h = n(g / 1e3) % 60;
                    p = g % 1e3;
                  };
                }
                L = function(m) {
                  m > -1 / 0 && m < 1 / 0 ? (k(m), m = (0 >= d || 1e4 <= d ? (0 > d ? "-" : "+") + A(6, 0 > d ? -d : d) : A(4, d)) + "-" + A(2, c + 1) + "-" + A(2, e) + "T" + A(2, l) + ":" + A(2, b) + ":" + A(
                    2,
                    h
                  ) + "." + A(3, p) + "Z", d = c = e = l = b = h = p = null) : m = null;
                  return m;
                };
                return L(a);
              };
              if (q("json-stringify") && !q("date-serialization")) {
                var ia = function() {
                  return L(this);
                }, ja = v.stringify;
                v.stringify = function(a, d, c) {
                  var e = z.prototype.toJSON;
                  z.prototype.toJSON = ia;
                  a = ja(a, d, c);
                  z.prototype.toJSON = e;
                  return a;
                };
              } else {
                var ka = function(a) {
                  a = a.charCodeAt(0);
                  var d = ha[a];
                  return d ? d : "\\u00" + A(2, a.toString(16));
                }, Q = /[\x00-\x1f\x22\x5c]/g, V = function(a) {
                  Q.lastIndex = 0;
                  return '"' + (Q.test(a) ? a.replace(Q, ka) : a) + '"';
                }, R = function(a, d, c, e, g, l, b) {
                  var h, p;
                  B(function() {
                    h = d[a];
                  });
                  "object" == typeof h && h && (h.getUTCFullYear && "[object Date]" == w.call(h) && h.toJSON === z.prototype.toJSON ? h = L(h) : "function" == typeof h.toJSON && (h = h.toJSON(a)));
                  c && (h = c.call(d, a, h));
                  if (h == x) return h === x ? h : "null";
                  var k = typeof h;
                  "object" == k && (p = w.call(h));
                  switch (p || k) {
                    case "boolean":
                    case "[object Boolean]":
                      return "" + h;
                    case "number":
                    case "[object Number]":
                      return h > -1 / 0 && h < 1 / 0 ? "" + h : "null";
                    case "string":
                    case "[object String]":
                      return V("" + h);
                  }
                  if ("object" == typeof h) {
                    for (k = b.length; k--; ) if (b[k] === h) throw ea();
                    b.push(h);
                    var n = [];
                    var K = l;
                    l += g;
                    if ("[object Array]" == p) {
                      var D = 0;
                      for (k = h.length; D < k; D++) p = R(D, h, c, e, g, l, b), n.push(p === x ? "null" : p);
                      k = n.length ? g ? "[\n" + l + n.join(",\n" + l) + "\n" + K + "]" : "[" + n.join(",") + "]" : "[]";
                    } else G(e || h, function(m) {
                      var C = R(m, h, c, e, g, l, b);
                      C !== x && n.push(V(m) + ":" + (g ? " " : "") + C);
                    }), k = n.length ? g ? "{\n" + l + n.join(",\n" + l) + "\n" + K + "}" : "{" + n.join(",") + "}" : "{}";
                    b.pop();
                    return k;
                  }
                };
                v.stringify = function(a, d, c) {
                  var e;
                  if (H[typeof d] && d) {
                    var g = w.call(d);
                    if ("[object Function]" == g) var l = d;
                    else if ("[object Array]" == g) {
                      var b = {};
                      for (var h = 0, p = d.length, k; h < p; ) if (k = d[h++], g = w.call(k), "[object String]" == g || "[object Number]" == g) b[k] = 1;
                    }
                  }
                  if (c) if (g = w.call(c), "[object Number]" == g) {
                    if (0 < (c -= c % 1)) for (10 < c && (c = 10), e = ""; e.length < c; ) e += " ";
                  } else "[object String]" == g && (e = 10 >= c.length ? c : c.slice(0, 10));
                  return R("", (k = {}, k[""] = a, k), l, b, e, "", []);
                };
              }
            }
            if (!q("json-parse")) {
              var la = U.fromCharCode, ma = { 92: "\\", 34: '"', 47: "/", 98: "\b", 116: "	", 110: "\n", 102: "\f", 114: "\r" }, f, M, t = function() {
                f = M = null;
                throw da();
              }, E = function() {
                for (var a = M, d = a.length, c, e, g, l, b; f < d; ) switch (b = a.charCodeAt(f), b) {
                  case 9:
                  case 10:
                  case 13:
                  case 32:
                    f++;
                    break;
                  case 123:
                  case 125:
                  case 91:
                  case 93:
                  case 58:
                  case 44:
                    return c = P ? a.charAt(f) : a[f], f++, c;
                  case 34:
                    c = "@";
                    for (f++; f < d; ) if (b = a.charCodeAt(f), 32 > b) t();
                    else if (92 == b) switch (b = a.charCodeAt(++f), b) {
                      case 92:
                      case 34:
                      case 47:
                      case 98:
                      case 116:
                      case 110:
                      case 102:
                      case 114:
                        c += ma[b];
                        f++;
                        break;
                      case 117:
                        e = ++f;
                        for (g = f + 4; f < g; f++) b = a.charCodeAt(f), 48 <= b && 57 >= b || 97 <= b && 102 >= b || 65 <= b && 70 >= b || t();
                        c += la("0x" + a.slice(e, f));
                        break;
                      default:
                        t();
                    }
                    else {
                      if (34 == b) break;
                      b = a.charCodeAt(f);
                      for (e = f; 32 <= b && 92 != b && 34 != b; ) b = a.charCodeAt(++f);
                      c += a.slice(e, f);
                    }
                    if (34 == a.charCodeAt(f)) return f++, c;
                    t();
                  default:
                    e = f;
                    45 == b && (l = true, b = a.charCodeAt(++f));
                    if (48 <= b && 57 >= b) {
                      for (48 == b && (b = a.charCodeAt(f + 1), 48 <= b && 57 >= b) && t(); f < d && (b = a.charCodeAt(f), 48 <= b && 57 >= b); f++) ;
                      if (46 == a.charCodeAt(f)) {
                        for (g = ++f; g < d && !(b = a.charCodeAt(g), 48 > b || 57 < b); g++) ;
                        g == f && t();
                        f = g;
                      }
                      b = a.charCodeAt(f);
                      if (101 == b || 69 == b) {
                        b = a.charCodeAt(++f);
                        43 != b && 45 != b || f++;
                        for (g = f; g < d && !(b = a.charCodeAt(g), 48 > b || 57 < b); g++) ;
                        g == f && t();
                        f = g;
                      }
                      return +a.slice(e, f);
                    }
                    l && t();
                    c = a.slice(f, f + 4);
                    if ("true" == c) return f += 4, true;
                    if ("fals" == c && 101 == a.charCodeAt(f + 4)) return f += 5, false;
                    if ("null" == c) return f += 4, null;
                    t();
                }
                return "$";
              }, S = function(a) {
                var d;
                "$" == a && t();
                if ("string" == typeof a) {
                  if ("@" == (P ? a.charAt(0) : a[0])) return a.slice(1);
                  if ("[" == a) {
                    for (d = []; ; ) {
                      a = E();
                      if ("]" == a) break;
                      if (c) "," == a ? (a = E(), "]" == a && t()) : t();
                      else var c = true;
                      "," == a && t();
                      d.push(S(a));
                    }
                    return d;
                  }
                  if ("{" == a) {
                    for (d = {}; ; ) {
                      a = E();
                      if ("}" == a) break;
                      c ? "," == a ? (a = E(), "}" == a && t()) : t() : c = true;
                      "," != a && "string" == typeof a && "@" == (P ? a.charAt(0) : a[0]) && ":" == E() || t();
                      d[a.slice(1)] = S(E());
                    }
                    return d;
                  }
                  t();
                }
                return a;
              }, X = function(a, d, c) {
                c = W(a, d, c);
                c === x ? delete a[d] : a[d] = c;
              }, W = function(a, d, c) {
                var e = a[d], g;
                if ("object" == typeof e && e) if ("[object Array]" == w.call(e)) for (g = e.length; g--; ) X(w, G, e, g, c);
                else G(e, function(l) {
                  X(e, l, c);
                });
                return c.call(a, d, e);
              };
              v.parse = function(a, d) {
                var c;
                f = 0;
                M = "" + a;
                a = S(E());
                "$" != E() && t();
                f = M = null;
                return d && "[object Function]" == w.call(d) ? W((c = {}, c[""] = a, c), "", d) : a;
              };
            }
          }
          v.runInContext = O;
          return v;
        }
        var Y = typeof define === "function" && define.amd, H = { "function": true, object: true }, T = H[typeof exports] && exports && !exports.nodeType && exports, r = H[typeof window] && window || this, F = T && H[typeof module] && module && !module.nodeType && "object" == typeof window && window;
        !F || F.global !== F && F.window !== F && F.self !== F || (r = F);
        if (T && !Y) O(r, T);
        else {
          var Z = r.JSON, aa = r.JSON3, ba = false, N = O(r, r.JSON3 = { noConflict: function() {
            ba || (ba = true, r.JSON = Z, r.JSON3 = aa, Z = aa = null);
            return N;
          } });
          r.JSON = { parse: N.parse, stringify: N.stringify };
        }
        Y && define(function() {
          return N;
        });
      }).call(exports);
    }
  });

  // tetris/src/polyfills.js
  var require_polyfills = __commonJS({
    "tetris/src/polyfills.js"() {
      init_shim();
      window.JSON = require_json3_min();
      if (!Function.prototype.bind) {
        Function.prototype.bind = function(oThis) {
          if (typeof this !== "function") {
            throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
          }
          var aArgs = Array.prototype.slice.call(arguments, 1), fToBind = this, fNOP = function() {
          }, fBound = function() {
            return fToBind.apply(
              this instanceof fNOP && oThis ? this : oThis,
              aArgs.concat(Array.prototype.slice.call(arguments))
            );
          };
          fNOP.prototype = this.prototype;
          fBound.prototype = new fNOP();
          return fBound;
        };
      }
      (function() {
        var lastTime = 0;
        var vendors = ["webkit", "moz"];
        for (var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
          window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"];
          window.cancelAnimationFrame = window[vendors[x] + "CancelAnimationFrame"] || window[vendors[x] + "CancelRequestAnimationFrame"];
        }
        if (!window.requestAnimationFrame)
          window.requestAnimationFrame = function(callback, element) {
            var currTime = (/* @__PURE__ */ new Date()).getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(
              function() {
                callback(currTime + timeToCall);
              },
              timeToCall
            );
            lastTime = currTime + timeToCall;
            return id;
          };
        if (!window.cancelAnimationFrame)
          window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
          };
      })();
    }
  });

  // tetris/src/matrix.js
  var require_matrix = __commonJS({
    "tetris/src/matrix.js"(exports, module) {
      init_shim();
      function Matrix2(width, height, originX, originY) {
        this._width = width;
        this._height = height;
        if (originX !== void 0) {
          this._originX = originX;
        } else {
          this._originX = width / 2;
        }
        if (originY !== void 0) {
          this._originY = originY;
        } else {
          this._originY = height / 2;
        }
        this._matrix = [];
        this.clear();
      }
      Matrix2.prototype.clear = function() {
        var endIndex = this._width * this._height;
        for (var index = 0; index < endIndex; index++) {
          this._matrix[index] = 0;
        }
      };
      Matrix2.prototype.getWidth = function() {
        return this._width;
      };
      Matrix2.prototype.getHeight = function() {
        return this._height;
      };
      Matrix2.prototype.getOriginX = function() {
        return this._originX;
      };
      Matrix2.prototype.getOriginY = function() {
        return this._originY;
      };
      Matrix2.prototype.index = function(x, y) {
        return y * this._width + x;
      };
      Matrix2.prototype.get = function(x, y) {
        return this._matrix[this.index(x, y)];
      };
      Matrix2.prototype.getAtIndex = function(index) {
        return this._matrix[index];
      };
      Matrix2.prototype.isOpaque = function(colour) {
        return colour > 0;
      };
      Matrix2.prototype.set = function(x, y, colour) {
        this._matrix[this.index(x, y)] = colour;
      };
      Matrix2.prototype.isRowFilled = function(y) {
        var start = this.index(0, y);
        var end = start + this._width;
        for (var index = start; index < end; index++) {
          if (!this.isOpaque(this._matrix[index])) {
            return false;
          }
        }
        return true;
      };
      Matrix2.prototype.collapseRow = function(y) {
        var width = this._width;
        var destination = this.index(this._width - 1, y);
        var source = destination - width;
        if (y > 0) {
          for (; source >= 0; source--, destination--) {
            this._matrix[destination] = this._matrix[source];
          }
        }
        for (var index = 0; index < width; index++) {
          this._matrix[index] = 0;
        }
      };
      Matrix2.prototype.rotate = function() {
        var width = this._width;
        var height = this._height;
        var originX = this._originX;
        var originY = this._originY;
        var result = new Matrix2(width, height, originX, originY);
        this.forEachOpaque(function(x, y, value) {
          var newX = -(y - originY) + originX - 1;
          var newY = x - originX + originY;
          result.set(Math.floor(newX), Math.floor(newY), value);
          return true;
        });
        return result;
      };
      Matrix2.prototype.forEachOpaque = function(callback) {
        var width = this._width;
        var matrix = this._matrix;
        var numElements = width * this._height;
        var x = -1;
        var y = -1;
        for (var index = 0; index < numElements; index++) {
          if (index % width == 0) {
            x = 0;
            y += 1;
          } else {
            x += 1;
          }
          var value = matrix[index];
          if (this.isOpaque(value)) {
            if (!callback(x, y, value)) {
              return;
            }
          }
        }
      };
      Matrix2.prototype.collision = function(x, y, visitor) {
        var detected = false;
        var self2 = this;
        var width = this._width;
        var height = this._height;
        visitor.forEachOpaque(function(innerX, innerY) {
          var absX = x + innerX;
          var absY = y + innerY;
          detected = absY >= height || absX < 0 || absX >= width || self2.isOpaque(self2.get(absX, absY));
          return !detected;
        });
        return detected;
      };
      Matrix2.prototype.copy = function(x, y, source) {
        var self2 = this;
        source.forEachOpaque(function(innerX, innerY, value) {
          self2.set(x + innerX, y + innerY, value);
          return true;
        });
      };
      module.exports = Matrix2;
    }
  });

  // node_modules/has-symbols/shams.js
  var require_shams = __commonJS({
    "node_modules/has-symbols/shams.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = function hasSymbols() {
        if (typeof Symbol !== "function" || typeof Object.getOwnPropertySymbols !== "function") {
          return false;
        }
        if (typeof Symbol.iterator === "symbol") {
          return true;
        }
        var obj = {};
        var sym = Symbol("test");
        var symObj = Object(sym);
        if (typeof sym === "string") {
          return false;
        }
        if (Object.prototype.toString.call(sym) !== "[object Symbol]") {
          return false;
        }
        if (Object.prototype.toString.call(symObj) !== "[object Symbol]") {
          return false;
        }
        var symVal = 42;
        obj[sym] = symVal;
        for (var _ in obj) {
          return false;
        }
        if (typeof Object.keys === "function" && Object.keys(obj).length !== 0) {
          return false;
        }
        if (typeof Object.getOwnPropertyNames === "function" && Object.getOwnPropertyNames(obj).length !== 0) {
          return false;
        }
        var syms = Object.getOwnPropertySymbols(obj);
        if (syms.length !== 1 || syms[0] !== sym) {
          return false;
        }
        if (!Object.prototype.propertyIsEnumerable.call(obj, sym)) {
          return false;
        }
        if (typeof Object.getOwnPropertyDescriptor === "function") {
          var descriptor = (
            /** @type {PropertyDescriptor} */
            Object.getOwnPropertyDescriptor(obj, sym)
          );
          if (descriptor.value !== symVal || descriptor.enumerable !== true) {
            return false;
          }
        }
        return true;
      };
    }
  });

  // node_modules/has-tostringtag/shams.js
  var require_shams2 = __commonJS({
    "node_modules/has-tostringtag/shams.js"(exports, module) {
      "use strict";
      init_shim();
      var hasSymbols = require_shams();
      module.exports = function hasToStringTagShams() {
        return hasSymbols() && !!Symbol.toStringTag;
      };
    }
  });

  // node_modules/es-object-atoms/index.js
  var require_es_object_atoms = __commonJS({
    "node_modules/es-object-atoms/index.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Object;
    }
  });

  // node_modules/es-errors/index.js
  var require_es_errors = __commonJS({
    "node_modules/es-errors/index.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Error;
    }
  });

  // node_modules/es-errors/eval.js
  var require_eval = __commonJS({
    "node_modules/es-errors/eval.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = EvalError;
    }
  });

  // node_modules/es-errors/range.js
  var require_range = __commonJS({
    "node_modules/es-errors/range.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = RangeError;
    }
  });

  // node_modules/es-errors/ref.js
  var require_ref = __commonJS({
    "node_modules/es-errors/ref.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = ReferenceError;
    }
  });

  // node_modules/es-errors/syntax.js
  var require_syntax = __commonJS({
    "node_modules/es-errors/syntax.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = SyntaxError;
    }
  });

  // node_modules/es-errors/type.js
  var require_type = __commonJS({
    "node_modules/es-errors/type.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = TypeError;
    }
  });

  // node_modules/es-errors/uri.js
  var require_uri = __commonJS({
    "node_modules/es-errors/uri.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = URIError;
    }
  });

  // node_modules/math-intrinsics/abs.js
  var require_abs = __commonJS({
    "node_modules/math-intrinsics/abs.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Math.abs;
    }
  });

  // node_modules/math-intrinsics/floor.js
  var require_floor = __commonJS({
    "node_modules/math-intrinsics/floor.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Math.floor;
    }
  });

  // node_modules/math-intrinsics/max.js
  var require_max = __commonJS({
    "node_modules/math-intrinsics/max.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Math.max;
    }
  });

  // node_modules/math-intrinsics/min.js
  var require_min = __commonJS({
    "node_modules/math-intrinsics/min.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Math.min;
    }
  });

  // node_modules/math-intrinsics/pow.js
  var require_pow = __commonJS({
    "node_modules/math-intrinsics/pow.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Math.pow;
    }
  });

  // node_modules/math-intrinsics/round.js
  var require_round = __commonJS({
    "node_modules/math-intrinsics/round.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Math.round;
    }
  });

  // node_modules/math-intrinsics/isNaN.js
  var require_isNaN = __commonJS({
    "node_modules/math-intrinsics/isNaN.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Number.isNaN || function isNaN2(a) {
        return a !== a;
      };
    }
  });

  // node_modules/math-intrinsics/sign.js
  var require_sign = __commonJS({
    "node_modules/math-intrinsics/sign.js"(exports, module) {
      "use strict";
      init_shim();
      var $isNaN = require_isNaN();
      module.exports = function sign(number) {
        if ($isNaN(number) || number === 0) {
          return number;
        }
        return number < 0 ? -1 : 1;
      };
    }
  });

  // node_modules/gopd/gOPD.js
  var require_gOPD = __commonJS({
    "node_modules/gopd/gOPD.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Object.getOwnPropertyDescriptor;
    }
  });

  // node_modules/gopd/index.js
  var require_gopd = __commonJS({
    "node_modules/gopd/index.js"(exports, module) {
      "use strict";
      init_shim();
      var $gOPD = require_gOPD();
      if ($gOPD) {
        try {
          $gOPD([], "length");
        } catch (e) {
          $gOPD = null;
        }
      }
      module.exports = $gOPD;
    }
  });

  // node_modules/es-define-property/index.js
  var require_es_define_property = __commonJS({
    "node_modules/es-define-property/index.js"(exports, module) {
      "use strict";
      init_shim();
      var $defineProperty = Object.defineProperty || false;
      if ($defineProperty) {
        try {
          $defineProperty({}, "a", { value: 1 });
        } catch (e) {
          $defineProperty = false;
        }
      }
      module.exports = $defineProperty;
    }
  });

  // node_modules/has-symbols/index.js
  var require_has_symbols = __commonJS({
    "node_modules/has-symbols/index.js"(exports, module) {
      "use strict";
      init_shim();
      var origSymbol = typeof Symbol !== "undefined" && Symbol;
      var hasSymbolSham = require_shams();
      module.exports = function hasNativeSymbols() {
        if (typeof origSymbol !== "function") {
          return false;
        }
        if (typeof Symbol !== "function") {
          return false;
        }
        if (typeof origSymbol("foo") !== "symbol") {
          return false;
        }
        if (typeof Symbol("bar") !== "symbol") {
          return false;
        }
        return hasSymbolSham();
      };
    }
  });

  // node_modules/get-proto/Reflect.getPrototypeOf.js
  var require_Reflect_getPrototypeOf = __commonJS({
    "node_modules/get-proto/Reflect.getPrototypeOf.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = typeof Reflect !== "undefined" && Reflect.getPrototypeOf || null;
    }
  });

  // node_modules/get-proto/Object.getPrototypeOf.js
  var require_Object_getPrototypeOf = __commonJS({
    "node_modules/get-proto/Object.getPrototypeOf.js"(exports, module) {
      "use strict";
      init_shim();
      var $Object = require_es_object_atoms();
      module.exports = $Object.getPrototypeOf || null;
    }
  });

  // node_modules/function-bind/implementation.js
  var require_implementation = __commonJS({
    "node_modules/function-bind/implementation.js"(exports, module) {
      "use strict";
      init_shim();
      var ERROR_MESSAGE = "Function.prototype.bind called on incompatible ";
      var toStr = Object.prototype.toString;
      var max = Math.max;
      var funcType = "[object Function]";
      var concatty = function concatty2(a, b) {
        var arr = [];
        for (var i = 0; i < a.length; i += 1) {
          arr[i] = a[i];
        }
        for (var j = 0; j < b.length; j += 1) {
          arr[j + a.length] = b[j];
        }
        return arr;
      };
      var slicy = function slicy2(arrLike, offset) {
        var arr = [];
        for (var i = offset || 0, j = 0; i < arrLike.length; i += 1, j += 1) {
          arr[j] = arrLike[i];
        }
        return arr;
      };
      var joiny = function(arr, joiner) {
        var str = "";
        for (var i = 0; i < arr.length; i += 1) {
          str += arr[i];
          if (i + 1 < arr.length) {
            str += joiner;
          }
        }
        return str;
      };
      module.exports = function bind(that) {
        var target = this;
        if (typeof target !== "function" || toStr.apply(target) !== funcType) {
          throw new TypeError(ERROR_MESSAGE + target);
        }
        var args = slicy(arguments, 1);
        var bound;
        var binder = function() {
          if (this instanceof bound) {
            var result = target.apply(
              this,
              concatty(args, arguments)
            );
            if (Object(result) === result) {
              return result;
            }
            return this;
          }
          return target.apply(
            that,
            concatty(args, arguments)
          );
        };
        var boundLength = max(0, target.length - args.length);
        var boundArgs = [];
        for (var i = 0; i < boundLength; i++) {
          boundArgs[i] = "$" + i;
        }
        bound = Function("binder", "return function (" + joiny(boundArgs, ",") + "){ return binder.apply(this,arguments); }")(binder);
        if (target.prototype) {
          var Empty = function Empty2() {
          };
          Empty.prototype = target.prototype;
          bound.prototype = new Empty();
          Empty.prototype = null;
        }
        return bound;
      };
    }
  });

  // node_modules/function-bind/index.js
  var require_function_bind = __commonJS({
    "node_modules/function-bind/index.js"(exports, module) {
      "use strict";
      init_shim();
      var implementation = require_implementation();
      module.exports = Function.prototype.bind || implementation;
    }
  });

  // node_modules/call-bind-apply-helpers/functionCall.js
  var require_functionCall = __commonJS({
    "node_modules/call-bind-apply-helpers/functionCall.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Function.prototype.call;
    }
  });

  // node_modules/call-bind-apply-helpers/functionApply.js
  var require_functionApply = __commonJS({
    "node_modules/call-bind-apply-helpers/functionApply.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = Function.prototype.apply;
    }
  });

  // node_modules/call-bind-apply-helpers/reflectApply.js
  var require_reflectApply = __commonJS({
    "node_modules/call-bind-apply-helpers/reflectApply.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = typeof Reflect !== "undefined" && Reflect && Reflect.apply;
    }
  });

  // node_modules/call-bind-apply-helpers/actualApply.js
  var require_actualApply = __commonJS({
    "node_modules/call-bind-apply-helpers/actualApply.js"(exports, module) {
      "use strict";
      init_shim();
      var bind = require_function_bind();
      var $apply = require_functionApply();
      var $call = require_functionCall();
      var $reflectApply = require_reflectApply();
      module.exports = $reflectApply || bind.call($call, $apply);
    }
  });

  // node_modules/call-bind-apply-helpers/index.js
  var require_call_bind_apply_helpers = __commonJS({
    "node_modules/call-bind-apply-helpers/index.js"(exports, module) {
      "use strict";
      init_shim();
      var bind = require_function_bind();
      var $TypeError = require_type();
      var $call = require_functionCall();
      var $actualApply = require_actualApply();
      module.exports = function callBindBasic(args) {
        if (args.length < 1 || typeof args[0] !== "function") {
          throw new $TypeError("a function is required");
        }
        return $actualApply(bind, $call, args);
      };
    }
  });

  // node_modules/dunder-proto/get.js
  var require_get = __commonJS({
    "node_modules/dunder-proto/get.js"(exports, module) {
      "use strict";
      init_shim();
      var callBind = require_call_bind_apply_helpers();
      var gOPD = require_gopd();
      var hasProtoAccessor;
      try {
        hasProtoAccessor = /** @type {{ __proto__?: typeof Array.prototype }} */
        [].__proto__ === Array.prototype;
      } catch (e) {
        if (!e || typeof e !== "object" || !("code" in e) || e.code !== "ERR_PROTO_ACCESS") {
          throw e;
        }
      }
      var desc = !!hasProtoAccessor && gOPD && gOPD(
        Object.prototype,
        /** @type {keyof typeof Object.prototype} */
        "__proto__"
      );
      var $Object = Object;
      var $getPrototypeOf = $Object.getPrototypeOf;
      module.exports = desc && typeof desc.get === "function" ? callBind([desc.get]) : typeof $getPrototypeOf === "function" ? (
        /** @type {import('./get')} */
        function getDunder(value) {
          return $getPrototypeOf(value == null ? value : $Object(value));
        }
      ) : false;
    }
  });

  // node_modules/get-proto/index.js
  var require_get_proto = __commonJS({
    "node_modules/get-proto/index.js"(exports, module) {
      "use strict";
      init_shim();
      var reflectGetProto = require_Reflect_getPrototypeOf();
      var originalGetProto = require_Object_getPrototypeOf();
      var getDunderProto = require_get();
      module.exports = reflectGetProto ? function getProto(O) {
        return reflectGetProto(O);
      } : originalGetProto ? function getProto(O) {
        if (!O || typeof O !== "object" && typeof O !== "function") {
          throw new TypeError("getProto: not an object");
        }
        return originalGetProto(O);
      } : getDunderProto ? function getProto(O) {
        return getDunderProto(O);
      } : null;
    }
  });

  // node_modules/hasown/index.js
  var require_hasown = __commonJS({
    "node_modules/hasown/index.js"(exports, module) {
      "use strict";
      init_shim();
      var call = Function.prototype.call;
      var $hasOwn = Object.prototype.hasOwnProperty;
      var bind = require_function_bind();
      module.exports = bind.call(call, $hasOwn);
    }
  });

  // node_modules/get-intrinsic/index.js
  var require_get_intrinsic = __commonJS({
    "node_modules/get-intrinsic/index.js"(exports, module) {
      "use strict";
      init_shim();
      var undefined2;
      var $Object = require_es_object_atoms();
      var $Error = require_es_errors();
      var $EvalError = require_eval();
      var $RangeError = require_range();
      var $ReferenceError = require_ref();
      var $SyntaxError = require_syntax();
      var $TypeError = require_type();
      var $URIError = require_uri();
      var abs = require_abs();
      var floor = require_floor();
      var max = require_max();
      var min = require_min();
      var pow = require_pow();
      var round = require_round();
      var sign = require_sign();
      var $Function = Function;
      var getEvalledConstructor = function(expressionSyntax) {
        try {
          return $Function('"use strict"; return (' + expressionSyntax + ").constructor;")();
        } catch (e) {
        }
      };
      var $gOPD = require_gopd();
      var $defineProperty = require_es_define_property();
      var throwTypeError = function() {
        throw new $TypeError();
      };
      var ThrowTypeError = $gOPD ? function() {
        try {
          arguments.callee;
          return throwTypeError;
        } catch (calleeThrows) {
          try {
            return $gOPD(arguments, "callee").get;
          } catch (gOPDthrows) {
            return throwTypeError;
          }
        }
      }() : throwTypeError;
      var hasSymbols = require_has_symbols()();
      var getProto = require_get_proto();
      var $ObjectGPO = require_Object_getPrototypeOf();
      var $ReflectGPO = require_Reflect_getPrototypeOf();
      var $apply = require_functionApply();
      var $call = require_functionCall();
      var needsEval = {};
      var TypedArray = typeof Uint8Array === "undefined" || !getProto ? undefined2 : getProto(Uint8Array);
      var INTRINSICS = {
        __proto__: null,
        "%AggregateError%": typeof AggregateError === "undefined" ? undefined2 : AggregateError,
        "%Array%": Array,
        "%ArrayBuffer%": typeof ArrayBuffer === "undefined" ? undefined2 : ArrayBuffer,
        "%ArrayIteratorPrototype%": hasSymbols && getProto ? getProto([][Symbol.iterator]()) : undefined2,
        "%AsyncFromSyncIteratorPrototype%": undefined2,
        "%AsyncFunction%": needsEval,
        "%AsyncGenerator%": needsEval,
        "%AsyncGeneratorFunction%": needsEval,
        "%AsyncIteratorPrototype%": needsEval,
        "%Atomics%": typeof Atomics === "undefined" ? undefined2 : Atomics,
        "%BigInt%": typeof BigInt === "undefined" ? undefined2 : BigInt,
        "%BigInt64Array%": typeof BigInt64Array === "undefined" ? undefined2 : BigInt64Array,
        "%BigUint64Array%": typeof BigUint64Array === "undefined" ? undefined2 : BigUint64Array,
        "%Boolean%": Boolean,
        "%DataView%": typeof DataView === "undefined" ? undefined2 : DataView,
        "%Date%": Date,
        "%decodeURI%": decodeURI,
        "%decodeURIComponent%": decodeURIComponent,
        "%encodeURI%": encodeURI,
        "%encodeURIComponent%": encodeURIComponent,
        "%Error%": $Error,
        "%eval%": eval,
        // eslint-disable-line no-eval
        "%EvalError%": $EvalError,
        "%Float16Array%": typeof Float16Array === "undefined" ? undefined2 : Float16Array,
        "%Float32Array%": typeof Float32Array === "undefined" ? undefined2 : Float32Array,
        "%Float64Array%": typeof Float64Array === "undefined" ? undefined2 : Float64Array,
        "%FinalizationRegistry%": typeof FinalizationRegistry === "undefined" ? undefined2 : FinalizationRegistry,
        "%Function%": $Function,
        "%GeneratorFunction%": needsEval,
        "%Int8Array%": typeof Int8Array === "undefined" ? undefined2 : Int8Array,
        "%Int16Array%": typeof Int16Array === "undefined" ? undefined2 : Int16Array,
        "%Int32Array%": typeof Int32Array === "undefined" ? undefined2 : Int32Array,
        "%isFinite%": isFinite,
        "%isNaN%": isNaN,
        "%IteratorPrototype%": hasSymbols && getProto ? getProto(getProto([][Symbol.iterator]())) : undefined2,
        "%JSON%": typeof JSON === "object" ? JSON : undefined2,
        "%Map%": typeof Map === "undefined" ? undefined2 : Map,
        "%MapIteratorPrototype%": typeof Map === "undefined" || !hasSymbols || !getProto ? undefined2 : getProto((/* @__PURE__ */ new Map())[Symbol.iterator]()),
        "%Math%": Math,
        "%Number%": Number,
        "%Object%": $Object,
        "%Object.getOwnPropertyDescriptor%": $gOPD,
        "%parseFloat%": parseFloat,
        "%parseInt%": parseInt,
        "%Promise%": typeof Promise === "undefined" ? undefined2 : Promise,
        "%Proxy%": typeof Proxy === "undefined" ? undefined2 : Proxy,
        "%RangeError%": $RangeError,
        "%ReferenceError%": $ReferenceError,
        "%Reflect%": typeof Reflect === "undefined" ? undefined2 : Reflect,
        "%RegExp%": RegExp,
        "%Set%": typeof Set === "undefined" ? undefined2 : Set,
        "%SetIteratorPrototype%": typeof Set === "undefined" || !hasSymbols || !getProto ? undefined2 : getProto((/* @__PURE__ */ new Set())[Symbol.iterator]()),
        "%SharedArrayBuffer%": typeof SharedArrayBuffer === "undefined" ? undefined2 : SharedArrayBuffer,
        "%String%": String,
        "%StringIteratorPrototype%": hasSymbols && getProto ? getProto(""[Symbol.iterator]()) : undefined2,
        "%Symbol%": hasSymbols ? Symbol : undefined2,
        "%SyntaxError%": $SyntaxError,
        "%ThrowTypeError%": ThrowTypeError,
        "%TypedArray%": TypedArray,
        "%TypeError%": $TypeError,
        "%Uint8Array%": typeof Uint8Array === "undefined" ? undefined2 : Uint8Array,
        "%Uint8ClampedArray%": typeof Uint8ClampedArray === "undefined" ? undefined2 : Uint8ClampedArray,
        "%Uint16Array%": typeof Uint16Array === "undefined" ? undefined2 : Uint16Array,
        "%Uint32Array%": typeof Uint32Array === "undefined" ? undefined2 : Uint32Array,
        "%URIError%": $URIError,
        "%WeakMap%": typeof WeakMap === "undefined" ? undefined2 : WeakMap,
        "%WeakRef%": typeof WeakRef === "undefined" ? undefined2 : WeakRef,
        "%WeakSet%": typeof WeakSet === "undefined" ? undefined2 : WeakSet,
        "%Function.prototype.call%": $call,
        "%Function.prototype.apply%": $apply,
        "%Object.defineProperty%": $defineProperty,
        "%Object.getPrototypeOf%": $ObjectGPO,
        "%Math.abs%": abs,
        "%Math.floor%": floor,
        "%Math.max%": max,
        "%Math.min%": min,
        "%Math.pow%": pow,
        "%Math.round%": round,
        "%Math.sign%": sign,
        "%Reflect.getPrototypeOf%": $ReflectGPO
      };
      if (getProto) {
        try {
          null.error;
        } catch (e) {
          errorProto = getProto(getProto(e));
          INTRINSICS["%Error.prototype%"] = errorProto;
        }
      }
      var errorProto;
      var doEval = function doEval2(name) {
        var value;
        if (name === "%AsyncFunction%") {
          value = getEvalledConstructor("async function () {}");
        } else if (name === "%GeneratorFunction%") {
          value = getEvalledConstructor("function* () {}");
        } else if (name === "%AsyncGeneratorFunction%") {
          value = getEvalledConstructor("async function* () {}");
        } else if (name === "%AsyncGenerator%") {
          var fn = doEval2("%AsyncGeneratorFunction%");
          if (fn) {
            value = fn.prototype;
          }
        } else if (name === "%AsyncIteratorPrototype%") {
          var gen = doEval2("%AsyncGenerator%");
          if (gen && getProto) {
            value = getProto(gen.prototype);
          }
        }
        INTRINSICS[name] = value;
        return value;
      };
      var LEGACY_ALIASES = {
        __proto__: null,
        "%ArrayBufferPrototype%": ["ArrayBuffer", "prototype"],
        "%ArrayPrototype%": ["Array", "prototype"],
        "%ArrayProto_entries%": ["Array", "prototype", "entries"],
        "%ArrayProto_forEach%": ["Array", "prototype", "forEach"],
        "%ArrayProto_keys%": ["Array", "prototype", "keys"],
        "%ArrayProto_values%": ["Array", "prototype", "values"],
        "%AsyncFunctionPrototype%": ["AsyncFunction", "prototype"],
        "%AsyncGenerator%": ["AsyncGeneratorFunction", "prototype"],
        "%AsyncGeneratorPrototype%": ["AsyncGeneratorFunction", "prototype", "prototype"],
        "%BooleanPrototype%": ["Boolean", "prototype"],
        "%DataViewPrototype%": ["DataView", "prototype"],
        "%DatePrototype%": ["Date", "prototype"],
        "%ErrorPrototype%": ["Error", "prototype"],
        "%EvalErrorPrototype%": ["EvalError", "prototype"],
        "%Float32ArrayPrototype%": ["Float32Array", "prototype"],
        "%Float64ArrayPrototype%": ["Float64Array", "prototype"],
        "%FunctionPrototype%": ["Function", "prototype"],
        "%Generator%": ["GeneratorFunction", "prototype"],
        "%GeneratorPrototype%": ["GeneratorFunction", "prototype", "prototype"],
        "%Int8ArrayPrototype%": ["Int8Array", "prototype"],
        "%Int16ArrayPrototype%": ["Int16Array", "prototype"],
        "%Int32ArrayPrototype%": ["Int32Array", "prototype"],
        "%JSONParse%": ["JSON", "parse"],
        "%JSONStringify%": ["JSON", "stringify"],
        "%MapPrototype%": ["Map", "prototype"],
        "%NumberPrototype%": ["Number", "prototype"],
        "%ObjectPrototype%": ["Object", "prototype"],
        "%ObjProto_toString%": ["Object", "prototype", "toString"],
        "%ObjProto_valueOf%": ["Object", "prototype", "valueOf"],
        "%PromisePrototype%": ["Promise", "prototype"],
        "%PromiseProto_then%": ["Promise", "prototype", "then"],
        "%Promise_all%": ["Promise", "all"],
        "%Promise_reject%": ["Promise", "reject"],
        "%Promise_resolve%": ["Promise", "resolve"],
        "%RangeErrorPrototype%": ["RangeError", "prototype"],
        "%ReferenceErrorPrototype%": ["ReferenceError", "prototype"],
        "%RegExpPrototype%": ["RegExp", "prototype"],
        "%SetPrototype%": ["Set", "prototype"],
        "%SharedArrayBufferPrototype%": ["SharedArrayBuffer", "prototype"],
        "%StringPrototype%": ["String", "prototype"],
        "%SymbolPrototype%": ["Symbol", "prototype"],
        "%SyntaxErrorPrototype%": ["SyntaxError", "prototype"],
        "%TypedArrayPrototype%": ["TypedArray", "prototype"],
        "%TypeErrorPrototype%": ["TypeError", "prototype"],
        "%Uint8ArrayPrototype%": ["Uint8Array", "prototype"],
        "%Uint8ClampedArrayPrototype%": ["Uint8ClampedArray", "prototype"],
        "%Uint16ArrayPrototype%": ["Uint16Array", "prototype"],
        "%Uint32ArrayPrototype%": ["Uint32Array", "prototype"],
        "%URIErrorPrototype%": ["URIError", "prototype"],
        "%WeakMapPrototype%": ["WeakMap", "prototype"],
        "%WeakSetPrototype%": ["WeakSet", "prototype"]
      };
      var bind = require_function_bind();
      var hasOwn = require_hasown();
      var $concat = bind.call($call, Array.prototype.concat);
      var $spliceApply = bind.call($apply, Array.prototype.splice);
      var $replace = bind.call($call, String.prototype.replace);
      var $strSlice = bind.call($call, String.prototype.slice);
      var $exec = bind.call($call, RegExp.prototype.exec);
      var rePropName = /[^%.[\]]+|\[(?:(-?\d+(?:\.\d+)?)|(["'])((?:(?!\2)[^\\]|\\.)*?)\2)\]|(?=(?:\.|\[\])(?:\.|\[\]|%$))/g;
      var reEscapeChar = /\\(\\)?/g;
      var stringToPath = function stringToPath2(string) {
        var first = $strSlice(string, 0, 1);
        var last = $strSlice(string, -1);
        if (first === "%" && last !== "%") {
          throw new $SyntaxError("invalid intrinsic syntax, expected closing `%`");
        } else if (last === "%" && first !== "%") {
          throw new $SyntaxError("invalid intrinsic syntax, expected opening `%`");
        }
        var result = [];
        $replace(string, rePropName, function(match, number, quote, subString) {
          result[result.length] = quote ? $replace(subString, reEscapeChar, "$1") : number || match;
        });
        return result;
      };
      var getBaseIntrinsic = function getBaseIntrinsic2(name, allowMissing) {
        var intrinsicName = name;
        var alias;
        if (hasOwn(LEGACY_ALIASES, intrinsicName)) {
          alias = LEGACY_ALIASES[intrinsicName];
          intrinsicName = "%" + alias[0] + "%";
        }
        if (hasOwn(INTRINSICS, intrinsicName)) {
          var value = INTRINSICS[intrinsicName];
          if (value === needsEval) {
            value = doEval(intrinsicName);
          }
          if (typeof value === "undefined" && !allowMissing) {
            throw new $TypeError("intrinsic " + name + " exists, but is not available. Please file an issue!");
          }
          return {
            alias,
            name: intrinsicName,
            value
          };
        }
        throw new $SyntaxError("intrinsic " + name + " does not exist!");
      };
      module.exports = function GetIntrinsic(name, allowMissing) {
        if (typeof name !== "string" || name.length === 0) {
          throw new $TypeError("intrinsic name must be a non-empty string");
        }
        if (arguments.length > 1 && typeof allowMissing !== "boolean") {
          throw new $TypeError('"allowMissing" argument must be a boolean');
        }
        if ($exec(/^%?[^%]*%?$/, name) === null) {
          throw new $SyntaxError("`%` may not be present anywhere but at the beginning and end of the intrinsic name");
        }
        var parts = stringToPath(name);
        var intrinsicBaseName = parts.length > 0 ? parts[0] : "";
        var intrinsic = getBaseIntrinsic("%" + intrinsicBaseName + "%", allowMissing);
        var intrinsicRealName = intrinsic.name;
        var value = intrinsic.value;
        var skipFurtherCaching = false;
        var alias = intrinsic.alias;
        if (alias) {
          intrinsicBaseName = alias[0];
          $spliceApply(parts, $concat([0, 1], alias));
        }
        for (var i = 1, isOwn = true; i < parts.length; i += 1) {
          var part = parts[i];
          var first = $strSlice(part, 0, 1);
          var last = $strSlice(part, -1);
          if ((first === '"' || first === "'" || first === "`" || (last === '"' || last === "'" || last === "`")) && first !== last) {
            throw new $SyntaxError("property names with quotes must have matching quotes");
          }
          if (part === "constructor" || !isOwn) {
            skipFurtherCaching = true;
          }
          intrinsicBaseName += "." + part;
          intrinsicRealName = "%" + intrinsicBaseName + "%";
          if (hasOwn(INTRINSICS, intrinsicRealName)) {
            value = INTRINSICS[intrinsicRealName];
          } else if (value != null) {
            if (!(part in value)) {
              if (!allowMissing) {
                throw new $TypeError("base intrinsic for " + name + " exists, but the property is not available.");
              }
              return void undefined2;
            }
            if ($gOPD && i + 1 >= parts.length) {
              var desc = $gOPD(value, part);
              isOwn = !!desc;
              if (isOwn && "get" in desc && !("originalValue" in desc.get)) {
                value = desc.get;
              } else {
                value = value[part];
              }
            } else {
              isOwn = hasOwn(value, part);
              value = value[part];
            }
            if (isOwn && !skipFurtherCaching) {
              INTRINSICS[intrinsicRealName] = value;
            }
          }
        }
        return value;
      };
    }
  });

  // node_modules/call-bound/index.js
  var require_call_bound = __commonJS({
    "node_modules/call-bound/index.js"(exports, module) {
      "use strict";
      init_shim();
      var GetIntrinsic = require_get_intrinsic();
      var callBindBasic = require_call_bind_apply_helpers();
      var $indexOf = callBindBasic([GetIntrinsic("%String.prototype.indexOf%")]);
      module.exports = function callBoundIntrinsic(name, allowMissing) {
        var intrinsic = (
          /** @type {(this: unknown, ...args: unknown[]) => unknown} */
          GetIntrinsic(name, !!allowMissing)
        );
        if (typeof intrinsic === "function" && $indexOf(name, ".prototype.") > -1) {
          return callBindBasic(
            /** @type {const} */
            [intrinsic]
          );
        }
        return intrinsic;
      };
    }
  });

  // node_modules/is-arguments/index.js
  var require_is_arguments = __commonJS({
    "node_modules/is-arguments/index.js"(exports, module) {
      "use strict";
      init_shim();
      var hasToStringTag = require_shams2()();
      var callBound = require_call_bound();
      var $toString = callBound("Object.prototype.toString");
      var isStandardArguments = function isArguments(value) {
        if (hasToStringTag && value && typeof value === "object" && Symbol.toStringTag in value) {
          return false;
        }
        return $toString(value) === "[object Arguments]";
      };
      var isLegacyArguments = function isArguments(value) {
        if (isStandardArguments(value)) {
          return true;
        }
        return value !== null && typeof value === "object" && "length" in value && typeof value.length === "number" && value.length >= 0 && $toString(value) !== "[object Array]" && "callee" in value && $toString(value.callee) === "[object Function]";
      };
      var supportsStandardArguments = function() {
        return isStandardArguments(arguments);
      }();
      isStandardArguments.isLegacyArguments = isLegacyArguments;
      module.exports = supportsStandardArguments ? isStandardArguments : isLegacyArguments;
    }
  });

  // node_modules/is-regex/index.js
  var require_is_regex = __commonJS({
    "node_modules/is-regex/index.js"(exports, module) {
      "use strict";
      init_shim();
      var callBound = require_call_bound();
      var hasToStringTag = require_shams2()();
      var hasOwn = require_hasown();
      var gOPD = require_gopd();
      var fn;
      if (hasToStringTag) {
        $exec = callBound("RegExp.prototype.exec");
        isRegexMarker = {};
        throwRegexMarker = function() {
          throw isRegexMarker;
        };
        badStringifier = {
          toString: throwRegexMarker,
          valueOf: throwRegexMarker
        };
        if (typeof Symbol.toPrimitive === "symbol") {
          badStringifier[Symbol.toPrimitive] = throwRegexMarker;
        }
        fn = function isRegex(value) {
          if (!value || typeof value !== "object") {
            return false;
          }
          var descriptor = (
            /** @type {NonNullable<typeof gOPD>} */
            gOPD(
              /** @type {{ lastIndex?: unknown }} */
              value,
              "lastIndex"
            )
          );
          var hasLastIndexDataProperty = descriptor && hasOwn(descriptor, "value");
          if (!hasLastIndexDataProperty) {
            return false;
          }
          try {
            $exec(
              value,
              /** @type {string} */
              /** @type {unknown} */
              badStringifier
            );
          } catch (e) {
            return e === isRegexMarker;
          }
        };
      } else {
        $toString = callBound("Object.prototype.toString");
        regexClass = "[object RegExp]";
        fn = function isRegex(value) {
          if (!value || typeof value !== "object" && typeof value !== "function") {
            return false;
          }
          return $toString(value) === regexClass;
        };
      }
      var $exec;
      var isRegexMarker;
      var throwRegexMarker;
      var badStringifier;
      var $toString;
      var regexClass;
      module.exports = fn;
    }
  });

  // node_modules/safe-regex-test/index.js
  var require_safe_regex_test = __commonJS({
    "node_modules/safe-regex-test/index.js"(exports, module) {
      "use strict";
      init_shim();
      var callBound = require_call_bound();
      var isRegex = require_is_regex();
      var $exec = callBound("RegExp.prototype.exec");
      var $TypeError = require_type();
      module.exports = function regexTester(regex) {
        if (!isRegex(regex)) {
          throw new $TypeError("`regex` must be a RegExp");
        }
        return function test(s) {
          return $exec(regex, s) !== null;
        };
      };
    }
  });

  // node_modules/is-generator-function/index.js
  var require_is_generator_function = __commonJS({
    "node_modules/is-generator-function/index.js"(exports, module) {
      "use strict";
      init_shim();
      var callBound = require_call_bound();
      var safeRegexTest = require_safe_regex_test();
      var isFnRegex = safeRegexTest(/^\s*(?:function)?\*/);
      var hasToStringTag = require_shams2()();
      var getProto = require_get_proto();
      var toStr = callBound("Object.prototype.toString");
      var fnToStr = callBound("Function.prototype.toString");
      var getGeneratorFunc = function() {
        if (!hasToStringTag) {
          return false;
        }
        try {
          return Function("return function*() {}")();
        } catch (e) {
        }
      };
      var GeneratorFunction;
      module.exports = function isGeneratorFunction(fn) {
        if (typeof fn !== "function") {
          return false;
        }
        if (isFnRegex(fnToStr(fn))) {
          return true;
        }
        if (!hasToStringTag) {
          var str = toStr(fn);
          return str === "[object GeneratorFunction]";
        }
        if (!getProto) {
          return false;
        }
        if (typeof GeneratorFunction === "undefined") {
          var generatorFunc = getGeneratorFunc();
          GeneratorFunction = generatorFunc ? (
            /** @type {GeneratorFunctionConstructor} */
            getProto(generatorFunc)
          ) : false;
        }
        return getProto(fn) === GeneratorFunction;
      };
    }
  });

  // node_modules/is-callable/index.js
  var require_is_callable = __commonJS({
    "node_modules/is-callable/index.js"(exports, module) {
      "use strict";
      init_shim();
      var fnToStr = Function.prototype.toString;
      var reflectApply = typeof Reflect === "object" && Reflect !== null && Reflect.apply;
      var badArrayLike;
      var isCallableMarker;
      if (typeof reflectApply === "function" && typeof Object.defineProperty === "function") {
        try {
          badArrayLike = Object.defineProperty({}, "length", {
            get: function() {
              throw isCallableMarker;
            }
          });
          isCallableMarker = {};
          reflectApply(function() {
            throw 42;
          }, null, badArrayLike);
        } catch (_) {
          if (_ !== isCallableMarker) {
            reflectApply = null;
          }
        }
      } else {
        reflectApply = null;
      }
      var constructorRegex = /^\s*class\b/;
      var isES6ClassFn = function isES6ClassFunction(value) {
        try {
          var fnStr = fnToStr.call(value);
          return constructorRegex.test(fnStr);
        } catch (e) {
          return false;
        }
      };
      var tryFunctionObject = function tryFunctionToStr(value) {
        try {
          if (isES6ClassFn(value)) {
            return false;
          }
          fnToStr.call(value);
          return true;
        } catch (e) {
          return false;
        }
      };
      var toStr = Object.prototype.toString;
      var objectClass = "[object Object]";
      var fnClass = "[object Function]";
      var genClass = "[object GeneratorFunction]";
      var ddaClass = "[object HTMLAllCollection]";
      var ddaClass2 = "[object HTML document.all class]";
      var ddaClass3 = "[object HTMLCollection]";
      var hasToStringTag = typeof Symbol === "function" && !!Symbol.toStringTag;
      var isIE68 = !(0 in [,]);
      var isDDA = function isDocumentDotAll() {
        return false;
      };
      if (typeof document === "object") {
        all = document.all;
        if (toStr.call(all) === toStr.call(document.all)) {
          isDDA = function isDocumentDotAll(value) {
            if ((isIE68 || !value) && (typeof value === "undefined" || typeof value === "object")) {
              try {
                var str = toStr.call(value);
                return (str === ddaClass || str === ddaClass2 || str === ddaClass3 || str === objectClass) && value("") == null;
              } catch (e) {
              }
            }
            return false;
          };
        }
      }
      var all;
      module.exports = reflectApply ? function isCallable(value) {
        if (isDDA(value)) {
          return true;
        }
        if (!value) {
          return false;
        }
        if (typeof value !== "function" && typeof value !== "object") {
          return false;
        }
        try {
          reflectApply(value, null, badArrayLike);
        } catch (e) {
          if (e !== isCallableMarker) {
            return false;
          }
        }
        return !isES6ClassFn(value) && tryFunctionObject(value);
      } : function isCallable(value) {
        if (isDDA(value)) {
          return true;
        }
        if (!value) {
          return false;
        }
        if (typeof value !== "function" && typeof value !== "object") {
          return false;
        }
        if (hasToStringTag) {
          return tryFunctionObject(value);
        }
        if (isES6ClassFn(value)) {
          return false;
        }
        var strClass = toStr.call(value);
        if (strClass !== fnClass && strClass !== genClass && !/^\[object HTML/.test(strClass)) {
          return false;
        }
        return tryFunctionObject(value);
      };
    }
  });

  // node_modules/for-each/index.js
  var require_for_each = __commonJS({
    "node_modules/for-each/index.js"(exports, module) {
      "use strict";
      init_shim();
      var isCallable = require_is_callable();
      var toStr = Object.prototype.toString;
      var hasOwnProperty = Object.prototype.hasOwnProperty;
      var forEachArray = function forEachArray2(array, iterator, receiver) {
        for (var i = 0, len = array.length; i < len; i++) {
          if (hasOwnProperty.call(array, i)) {
            if (receiver == null) {
              iterator(array[i], i, array);
            } else {
              iterator.call(receiver, array[i], i, array);
            }
          }
        }
      };
      var forEachString = function forEachString2(string, iterator, receiver) {
        for (var i = 0, len = string.length; i < len; i++) {
          if (receiver == null) {
            iterator(string.charAt(i), i, string);
          } else {
            iterator.call(receiver, string.charAt(i), i, string);
          }
        }
      };
      var forEachObject = function forEachObject2(object, iterator, receiver) {
        for (var k in object) {
          if (hasOwnProperty.call(object, k)) {
            if (receiver == null) {
              iterator(object[k], k, object);
            } else {
              iterator.call(receiver, object[k], k, object);
            }
          }
        }
      };
      function isArray(x) {
        return toStr.call(x) === "[object Array]";
      }
      module.exports = function forEach(list, iterator, thisArg) {
        if (!isCallable(iterator)) {
          throw new TypeError("iterator must be a function");
        }
        var receiver;
        if (arguments.length >= 3) {
          receiver = thisArg;
        }
        if (isArray(list)) {
          forEachArray(list, iterator, receiver);
        } else if (typeof list === "string") {
          forEachString(list, iterator, receiver);
        } else {
          forEachObject(list, iterator, receiver);
        }
      };
    }
  });

  // node_modules/possible-typed-array-names/index.js
  var require_possible_typed_array_names = __commonJS({
    "node_modules/possible-typed-array-names/index.js"(exports, module) {
      "use strict";
      init_shim();
      module.exports = [
        "Float16Array",
        "Float32Array",
        "Float64Array",
        "Int8Array",
        "Int16Array",
        "Int32Array",
        "Uint8Array",
        "Uint8ClampedArray",
        "Uint16Array",
        "Uint32Array",
        "BigInt64Array",
        "BigUint64Array"
      ];
    }
  });

  // node_modules/available-typed-arrays/index.js
  var require_available_typed_arrays = __commonJS({
    "node_modules/available-typed-arrays/index.js"(exports, module) {
      "use strict";
      init_shim();
      var possibleNames = require_possible_typed_array_names();
      var g = typeof globalThis === "undefined" ? window : globalThis;
      module.exports = function availableTypedArrays() {
        var out = [];
        for (var i = 0; i < possibleNames.length; i++) {
          if (typeof g[possibleNames[i]] === "function") {
            out[out.length] = possibleNames[i];
          }
        }
        return out;
      };
    }
  });

  // node_modules/define-data-property/index.js
  var require_define_data_property = __commonJS({
    "node_modules/define-data-property/index.js"(exports, module) {
      "use strict";
      init_shim();
      var $defineProperty = require_es_define_property();
      var $SyntaxError = require_syntax();
      var $TypeError = require_type();
      var gopd = require_gopd();
      module.exports = function defineDataProperty(obj, property, value) {
        if (!obj || typeof obj !== "object" && typeof obj !== "function") {
          throw new $TypeError("`obj` must be an object or a function`");
        }
        if (typeof property !== "string" && typeof property !== "symbol") {
          throw new $TypeError("`property` must be a string or a symbol`");
        }
        if (arguments.length > 3 && typeof arguments[3] !== "boolean" && arguments[3] !== null) {
          throw new $TypeError("`nonEnumerable`, if provided, must be a boolean or null");
        }
        if (arguments.length > 4 && typeof arguments[4] !== "boolean" && arguments[4] !== null) {
          throw new $TypeError("`nonWritable`, if provided, must be a boolean or null");
        }
        if (arguments.length > 5 && typeof arguments[5] !== "boolean" && arguments[5] !== null) {
          throw new $TypeError("`nonConfigurable`, if provided, must be a boolean or null");
        }
        if (arguments.length > 6 && typeof arguments[6] !== "boolean") {
          throw new $TypeError("`loose`, if provided, must be a boolean");
        }
        var nonEnumerable = arguments.length > 3 ? arguments[3] : null;
        var nonWritable = arguments.length > 4 ? arguments[4] : null;
        var nonConfigurable = arguments.length > 5 ? arguments[5] : null;
        var loose = arguments.length > 6 ? arguments[6] : false;
        var desc = !!gopd && gopd(obj, property);
        if ($defineProperty) {
          $defineProperty(obj, property, {
            configurable: nonConfigurable === null && desc ? desc.configurable : !nonConfigurable,
            enumerable: nonEnumerable === null && desc ? desc.enumerable : !nonEnumerable,
            value,
            writable: nonWritable === null && desc ? desc.writable : !nonWritable
          });
        } else if (loose || !nonEnumerable && !nonWritable && !nonConfigurable) {
          obj[property] = value;
        } else {
          throw new $SyntaxError("This environment does not support defining a property as non-configurable, non-writable, or non-enumerable.");
        }
      };
    }
  });

  // node_modules/has-property-descriptors/index.js
  var require_has_property_descriptors = __commonJS({
    "node_modules/has-property-descriptors/index.js"(exports, module) {
      "use strict";
      init_shim();
      var $defineProperty = require_es_define_property();
      var hasPropertyDescriptors = function hasPropertyDescriptors2() {
        return !!$defineProperty;
      };
      hasPropertyDescriptors.hasArrayLengthDefineBug = function hasArrayLengthDefineBug() {
        if (!$defineProperty) {
          return null;
        }
        try {
          return $defineProperty([], "length", { value: 1 }).length !== 1;
        } catch (e) {
          return true;
        }
      };
      module.exports = hasPropertyDescriptors;
    }
  });

  // node_modules/set-function-length/index.js
  var require_set_function_length = __commonJS({
    "node_modules/set-function-length/index.js"(exports, module) {
      "use strict";
      init_shim();
      var GetIntrinsic = require_get_intrinsic();
      var define2 = require_define_data_property();
      var hasDescriptors = require_has_property_descriptors()();
      var gOPD = require_gopd();
      var $TypeError = require_type();
      var $floor = GetIntrinsic("%Math.floor%");
      module.exports = function setFunctionLength(fn, length) {
        if (typeof fn !== "function") {
          throw new $TypeError("`fn` is not a function");
        }
        if (typeof length !== "number" || length < 0 || length > 4294967295 || $floor(length) !== length) {
          throw new $TypeError("`length` must be a positive 32-bit integer");
        }
        var loose = arguments.length > 2 && !!arguments[2];
        var functionLengthIsConfigurable = true;
        var functionLengthIsWritable = true;
        if ("length" in fn && gOPD) {
          var desc = gOPD(fn, "length");
          if (desc && !desc.configurable) {
            functionLengthIsConfigurable = false;
          }
          if (desc && !desc.writable) {
            functionLengthIsWritable = false;
          }
        }
        if (functionLengthIsConfigurable || functionLengthIsWritable || !loose) {
          if (hasDescriptors) {
            define2(
              /** @type {Parameters<define>[0]} */
              fn,
              "length",
              length,
              true,
              true
            );
          } else {
            define2(
              /** @type {Parameters<define>[0]} */
              fn,
              "length",
              length
            );
          }
        }
        return fn;
      };
    }
  });

  // node_modules/call-bind-apply-helpers/applyBind.js
  var require_applyBind = __commonJS({
    "node_modules/call-bind-apply-helpers/applyBind.js"(exports, module) {
      "use strict";
      init_shim();
      var bind = require_function_bind();
      var $apply = require_functionApply();
      var actualApply = require_actualApply();
      module.exports = function applyBind() {
        return actualApply(bind, $apply, arguments);
      };
    }
  });

  // node_modules/call-bind/index.js
  var require_call_bind = __commonJS({
    "node_modules/call-bind/index.js"(exports, module) {
      "use strict";
      init_shim();
      var setFunctionLength = require_set_function_length();
      var $defineProperty = require_es_define_property();
      var callBindBasic = require_call_bind_apply_helpers();
      var applyBind = require_applyBind();
      module.exports = function callBind(originalFunction) {
        var func = callBindBasic(arguments);
        var adjustedLength = originalFunction.length - (arguments.length - 1);
        return setFunctionLength(
          func,
          1 + (adjustedLength > 0 ? adjustedLength : 0),
          true
        );
      };
      if ($defineProperty) {
        $defineProperty(module.exports, "apply", { value: applyBind });
      } else {
        module.exports.apply = applyBind;
      }
    }
  });

  // node_modules/which-typed-array/index.js
  var require_which_typed_array = __commonJS({
    "node_modules/which-typed-array/index.js"(exports, module) {
      "use strict";
      init_shim();
      var forEach = require_for_each();
      var availableTypedArrays = require_available_typed_arrays();
      var callBind = require_call_bind();
      var callBound = require_call_bound();
      var gOPD = require_gopd();
      var getProto = require_get_proto();
      var $toString = callBound("Object.prototype.toString");
      var hasToStringTag = require_shams2()();
      var g = typeof globalThis === "undefined" ? window : globalThis;
      var typedArrays = availableTypedArrays();
      var $slice = callBound("String.prototype.slice");
      var $indexOf = callBound("Array.prototype.indexOf", true) || function indexOf(array, value) {
        for (var i = 0; i < array.length; i += 1) {
          if (array[i] === value) {
            return i;
          }
        }
        return -1;
      };
      var cache = { __proto__: null };
      if (hasToStringTag && gOPD && getProto) {
        forEach(typedArrays, function(typedArray) {
          var arr = new g[typedArray]();
          if (Symbol.toStringTag in arr && getProto) {
            var proto = getProto(arr);
            var descriptor = gOPD(proto, Symbol.toStringTag);
            if (!descriptor && proto) {
              var superProto = getProto(proto);
              descriptor = gOPD(superProto, Symbol.toStringTag);
            }
            cache["$" + typedArray] = callBind(descriptor.get);
          }
        });
      } else {
        forEach(typedArrays, function(typedArray) {
          var arr = new g[typedArray]();
          var fn = arr.slice || arr.set;
          if (fn) {
            cache[
              /** @type {`$${import('.').TypedArrayName}`} */
              "$" + typedArray
            ] = /** @type {import('./types').BoundSlice | import('./types').BoundSet} */
            // @ts-expect-error TODO FIXME
            callBind(fn);
          }
        });
      }
      var tryTypedArrays = function tryAllTypedArrays(value) {
        var found = false;
        forEach(
          /** @type {Record<`\$${import('.').TypedArrayName}`, Getter>} */
          cache,
          /** @type {(getter: Getter, name: `\$${import('.').TypedArrayName}`) => void} */
          function(getter, typedArray) {
            if (!found) {
              try {
                if ("$" + getter(value) === typedArray) {
                  found = /** @type {import('.').TypedArrayName} */
                  $slice(typedArray, 1);
                }
              } catch (e) {
              }
            }
          }
        );
        return found;
      };
      var trySlices = function tryAllSlices(value) {
        var found = false;
        forEach(
          /** @type {Record<`\$${import('.').TypedArrayName}`, Getter>} */
          cache,
          /** @type {(getter: Getter, name: `\$${import('.').TypedArrayName}`) => void} */
          function(getter, name) {
            if (!found) {
              try {
                getter(value);
                found = /** @type {import('.').TypedArrayName} */
                $slice(name, 1);
              } catch (e) {
              }
            }
          }
        );
        return found;
      };
      module.exports = function whichTypedArray(value) {
        if (!value || typeof value !== "object") {
          return false;
        }
        if (!hasToStringTag) {
          var tag = $slice($toString(value), 8, -1);
          if ($indexOf(typedArrays, tag) > -1) {
            return tag;
          }
          if (tag !== "Object") {
            return false;
          }
          return trySlices(value);
        }
        if (!gOPD) {
          return null;
        }
        return tryTypedArrays(value);
      };
    }
  });

  // node_modules/is-typed-array/index.js
  var require_is_typed_array = __commonJS({
    "node_modules/is-typed-array/index.js"(exports, module) {
      "use strict";
      init_shim();
      var whichTypedArray = require_which_typed_array();
      module.exports = function isTypedArray(value) {
        return !!whichTypedArray(value);
      };
    }
  });

  // node_modules/util/support/types.js
  var require_types = __commonJS({
    "node_modules/util/support/types.js"(exports) {
      "use strict";
      init_shim();
      var isArgumentsObject = require_is_arguments();
      var isGeneratorFunction = require_is_generator_function();
      var whichTypedArray = require_which_typed_array();
      var isTypedArray = require_is_typed_array();
      function uncurryThis(f) {
        return f.call.bind(f);
      }
      var BigIntSupported = typeof BigInt !== "undefined";
      var SymbolSupported = typeof Symbol !== "undefined";
      var ObjectToString = uncurryThis(Object.prototype.toString);
      var numberValue = uncurryThis(Number.prototype.valueOf);
      var stringValue = uncurryThis(String.prototype.valueOf);
      var booleanValue = uncurryThis(Boolean.prototype.valueOf);
      if (BigIntSupported) {
        bigIntValue = uncurryThis(BigInt.prototype.valueOf);
      }
      var bigIntValue;
      if (SymbolSupported) {
        symbolValue = uncurryThis(Symbol.prototype.valueOf);
      }
      var symbolValue;
      function checkBoxedPrimitive(value, prototypeValueOf) {
        if (typeof value !== "object") {
          return false;
        }
        try {
          prototypeValueOf(value);
          return true;
        } catch (e) {
          return false;
        }
      }
      exports.isArgumentsObject = isArgumentsObject;
      exports.isGeneratorFunction = isGeneratorFunction;
      exports.isTypedArray = isTypedArray;
      function isPromise(input) {
        return typeof Promise !== "undefined" && input instanceof Promise || input !== null && typeof input === "object" && typeof input.then === "function" && typeof input.catch === "function";
      }
      exports.isPromise = isPromise;
      function isArrayBufferView(value) {
        if (typeof ArrayBuffer !== "undefined" && ArrayBuffer.isView) {
          return ArrayBuffer.isView(value);
        }
        return isTypedArray(value) || isDataView(value);
      }
      exports.isArrayBufferView = isArrayBufferView;
      function isUint8Array(value) {
        return whichTypedArray(value) === "Uint8Array";
      }
      exports.isUint8Array = isUint8Array;
      function isUint8ClampedArray(value) {
        return whichTypedArray(value) === "Uint8ClampedArray";
      }
      exports.isUint8ClampedArray = isUint8ClampedArray;
      function isUint16Array(value) {
        return whichTypedArray(value) === "Uint16Array";
      }
      exports.isUint16Array = isUint16Array;
      function isUint32Array(value) {
        return whichTypedArray(value) === "Uint32Array";
      }
      exports.isUint32Array = isUint32Array;
      function isInt8Array(value) {
        return whichTypedArray(value) === "Int8Array";
      }
      exports.isInt8Array = isInt8Array;
      function isInt16Array(value) {
        return whichTypedArray(value) === "Int16Array";
      }
      exports.isInt16Array = isInt16Array;
      function isInt32Array(value) {
        return whichTypedArray(value) === "Int32Array";
      }
      exports.isInt32Array = isInt32Array;
      function isFloat32Array(value) {
        return whichTypedArray(value) === "Float32Array";
      }
      exports.isFloat32Array = isFloat32Array;
      function isFloat64Array(value) {
        return whichTypedArray(value) === "Float64Array";
      }
      exports.isFloat64Array = isFloat64Array;
      function isBigInt64Array(value) {
        return whichTypedArray(value) === "BigInt64Array";
      }
      exports.isBigInt64Array = isBigInt64Array;
      function isBigUint64Array(value) {
        return whichTypedArray(value) === "BigUint64Array";
      }
      exports.isBigUint64Array = isBigUint64Array;
      function isMapToString(value) {
        return ObjectToString(value) === "[object Map]";
      }
      isMapToString.working = typeof Map !== "undefined" && isMapToString(/* @__PURE__ */ new Map());
      function isMap(value) {
        if (typeof Map === "undefined") {
          return false;
        }
        return isMapToString.working ? isMapToString(value) : value instanceof Map;
      }
      exports.isMap = isMap;
      function isSetToString(value) {
        return ObjectToString(value) === "[object Set]";
      }
      isSetToString.working = typeof Set !== "undefined" && isSetToString(/* @__PURE__ */ new Set());
      function isSet(value) {
        if (typeof Set === "undefined") {
          return false;
        }
        return isSetToString.working ? isSetToString(value) : value instanceof Set;
      }
      exports.isSet = isSet;
      function isWeakMapToString(value) {
        return ObjectToString(value) === "[object WeakMap]";
      }
      isWeakMapToString.working = typeof WeakMap !== "undefined" && isWeakMapToString(/* @__PURE__ */ new WeakMap());
      function isWeakMap(value) {
        if (typeof WeakMap === "undefined") {
          return false;
        }
        return isWeakMapToString.working ? isWeakMapToString(value) : value instanceof WeakMap;
      }
      exports.isWeakMap = isWeakMap;
      function isWeakSetToString(value) {
        return ObjectToString(value) === "[object WeakSet]";
      }
      isWeakSetToString.working = typeof WeakSet !== "undefined" && isWeakSetToString(/* @__PURE__ */ new WeakSet());
      function isWeakSet(value) {
        return isWeakSetToString(value);
      }
      exports.isWeakSet = isWeakSet;
      function isArrayBufferToString(value) {
        return ObjectToString(value) === "[object ArrayBuffer]";
      }
      isArrayBufferToString.working = typeof ArrayBuffer !== "undefined" && isArrayBufferToString(new ArrayBuffer());
      function isArrayBuffer(value) {
        if (typeof ArrayBuffer === "undefined") {
          return false;
        }
        return isArrayBufferToString.working ? isArrayBufferToString(value) : value instanceof ArrayBuffer;
      }
      exports.isArrayBuffer = isArrayBuffer;
      function isDataViewToString(value) {
        return ObjectToString(value) === "[object DataView]";
      }
      isDataViewToString.working = typeof ArrayBuffer !== "undefined" && typeof DataView !== "undefined" && isDataViewToString(new DataView(new ArrayBuffer(1), 0, 1));
      function isDataView(value) {
        if (typeof DataView === "undefined") {
          return false;
        }
        return isDataViewToString.working ? isDataViewToString(value) : value instanceof DataView;
      }
      exports.isDataView = isDataView;
      var SharedArrayBufferCopy = typeof SharedArrayBuffer !== "undefined" ? SharedArrayBuffer : void 0;
      function isSharedArrayBufferToString(value) {
        return ObjectToString(value) === "[object SharedArrayBuffer]";
      }
      function isSharedArrayBuffer(value) {
        if (typeof SharedArrayBufferCopy === "undefined") {
          return false;
        }
        if (typeof isSharedArrayBufferToString.working === "undefined") {
          isSharedArrayBufferToString.working = isSharedArrayBufferToString(new SharedArrayBufferCopy());
        }
        return isSharedArrayBufferToString.working ? isSharedArrayBufferToString(value) : value instanceof SharedArrayBufferCopy;
      }
      exports.isSharedArrayBuffer = isSharedArrayBuffer;
      function isAsyncFunction(value) {
        return ObjectToString(value) === "[object AsyncFunction]";
      }
      exports.isAsyncFunction = isAsyncFunction;
      function isMapIterator(value) {
        return ObjectToString(value) === "[object Map Iterator]";
      }
      exports.isMapIterator = isMapIterator;
      function isSetIterator(value) {
        return ObjectToString(value) === "[object Set Iterator]";
      }
      exports.isSetIterator = isSetIterator;
      function isGeneratorObject(value) {
        return ObjectToString(value) === "[object Generator]";
      }
      exports.isGeneratorObject = isGeneratorObject;
      function isWebAssemblyCompiledModule(value) {
        return ObjectToString(value) === "[object WebAssembly.Module]";
      }
      exports.isWebAssemblyCompiledModule = isWebAssemblyCompiledModule;
      function isNumberObject(value) {
        return checkBoxedPrimitive(value, numberValue);
      }
      exports.isNumberObject = isNumberObject;
      function isStringObject(value) {
        return checkBoxedPrimitive(value, stringValue);
      }
      exports.isStringObject = isStringObject;
      function isBooleanObject(value) {
        return checkBoxedPrimitive(value, booleanValue);
      }
      exports.isBooleanObject = isBooleanObject;
      function isBigIntObject(value) {
        return BigIntSupported && checkBoxedPrimitive(value, bigIntValue);
      }
      exports.isBigIntObject = isBigIntObject;
      function isSymbolObject(value) {
        return SymbolSupported && checkBoxedPrimitive(value, symbolValue);
      }
      exports.isSymbolObject = isSymbolObject;
      function isBoxedPrimitive(value) {
        return isNumberObject(value) || isStringObject(value) || isBooleanObject(value) || isBigIntObject(value) || isSymbolObject(value);
      }
      exports.isBoxedPrimitive = isBoxedPrimitive;
      function isAnyArrayBuffer(value) {
        return typeof Uint8Array !== "undefined" && (isArrayBuffer(value) || isSharedArrayBuffer(value));
      }
      exports.isAnyArrayBuffer = isAnyArrayBuffer;
      ["isProxy", "isExternal", "isModuleNamespaceObject"].forEach(function(method) {
        Object.defineProperty(exports, method, {
          enumerable: false,
          value: function() {
            throw new Error(method + " is not supported in userland");
          }
        });
      });
    }
  });

  // node_modules/util/support/isBufferBrowser.js
  var require_isBufferBrowser = __commonJS({
    "node_modules/util/support/isBufferBrowser.js"(exports, module) {
      init_shim();
      module.exports = function isBuffer(arg) {
        return arg && typeof arg === "object" && typeof arg.copy === "function" && typeof arg.fill === "function" && typeof arg.readUInt8 === "function";
      };
    }
  });

  // node_modules/inherits/inherits_browser.js
  var require_inherits_browser = __commonJS({
    "node_modules/inherits/inherits_browser.js"(exports, module) {
      init_shim();
      if (typeof Object.create === "function") {
        module.exports = function inherits(ctor, superCtor) {
          if (superCtor) {
            ctor.super_ = superCtor;
            ctor.prototype = Object.create(superCtor.prototype, {
              constructor: {
                value: ctor,
                enumerable: false,
                writable: true,
                configurable: true
              }
            });
          }
        };
      } else {
        module.exports = function inherits(ctor, superCtor) {
          if (superCtor) {
            ctor.super_ = superCtor;
            var TempCtor = function() {
            };
            TempCtor.prototype = superCtor.prototype;
            ctor.prototype = new TempCtor();
            ctor.prototype.constructor = ctor;
          }
        };
      }
    }
  });

  // node_modules/util/util.js
  var require_util = __commonJS({
    "node_modules/util/util.js"(exports) {
      init_shim();
      var getOwnPropertyDescriptors = Object.getOwnPropertyDescriptors || function getOwnPropertyDescriptors2(obj) {
        var keys = Object.keys(obj);
        var descriptors = {};
        for (var i = 0; i < keys.length; i++) {
          descriptors[keys[i]] = Object.getOwnPropertyDescriptor(obj, keys[i]);
        }
        return descriptors;
      };
      var formatRegExp = /%[sdj%]/g;
      exports.format = function(f) {
        if (!isString(f)) {
          var objects = [];
          for (var i = 0; i < arguments.length; i++) {
            objects.push(inspect(arguments[i]));
          }
          return objects.join(" ");
        }
        var i = 1;
        var args = arguments;
        var len = args.length;
        var str = String(f).replace(formatRegExp, function(x2) {
          if (x2 === "%%") return "%";
          if (i >= len) return x2;
          switch (x2) {
            case "%s":
              return String(args[i++]);
            case "%d":
              return Number(args[i++]);
            case "%j":
              try {
                return JSON.stringify(args[i++]);
              } catch (_) {
                return "[Circular]";
              }
            default:
              return x2;
          }
        });
        for (var x = args[i]; i < len; x = args[++i]) {
          if (isNull(x) || !isObject(x)) {
            str += " " + x;
          } else {
            str += " " + inspect(x);
          }
        }
        return str;
      };
      exports.deprecate = function(fn, msg) {
        if (typeof import_process.default !== "undefined" && import_process.default.noDeprecation === true) {
          return fn;
        }
        if (typeof import_process.default === "undefined") {
          return function() {
            return exports.deprecate(fn, msg).apply(this, arguments);
          };
        }
        var warned = false;
        function deprecated() {
          if (!warned) {
            if (import_process.default.throwDeprecation) {
              throw new Error(msg);
            } else if (import_process.default.traceDeprecation) {
              console.trace(msg);
            } else {
              console.error(msg);
            }
            warned = true;
          }
          return fn.apply(this, arguments);
        }
        return deprecated;
      };
      var debugs = {};
      var debugEnvRegex = /^$/;
      if ("") {
        debugEnv = "";
        debugEnv = debugEnv.replace(/[|\\{}()[\]^$+?.]/g, "\\$&").replace(/\*/g, ".*").replace(/,/g, "$|^").toUpperCase();
        debugEnvRegex = new RegExp("^" + debugEnv + "$", "i");
      }
      var debugEnv;
      exports.debuglog = function(set) {
        set = set.toUpperCase();
        if (!debugs[set]) {
          if (debugEnvRegex.test(set)) {
            var pid = import_process.default.pid;
            debugs[set] = function() {
              var msg = exports.format.apply(exports, arguments);
              console.error("%s %d: %s", set, pid, msg);
            };
          } else {
            debugs[set] = function() {
            };
          }
        }
        return debugs[set];
      };
      function inspect(obj, opts) {
        var ctx = {
          seen: [],
          stylize: stylizeNoColor
        };
        if (arguments.length >= 3) ctx.depth = arguments[2];
        if (arguments.length >= 4) ctx.colors = arguments[3];
        if (isBoolean(opts)) {
          ctx.showHidden = opts;
        } else if (opts) {
          exports._extend(ctx, opts);
        }
        if (isUndefined(ctx.showHidden)) ctx.showHidden = false;
        if (isUndefined(ctx.depth)) ctx.depth = 2;
        if (isUndefined(ctx.colors)) ctx.colors = false;
        if (isUndefined(ctx.customInspect)) ctx.customInspect = true;
        if (ctx.colors) ctx.stylize = stylizeWithColor;
        return formatValue(ctx, obj, ctx.depth);
      }
      exports.inspect = inspect;
      inspect.colors = {
        "bold": [1, 22],
        "italic": [3, 23],
        "underline": [4, 24],
        "inverse": [7, 27],
        "white": [37, 39],
        "grey": [90, 39],
        "black": [30, 39],
        "blue": [34, 39],
        "cyan": [36, 39],
        "green": [32, 39],
        "magenta": [35, 39],
        "red": [31, 39],
        "yellow": [33, 39]
      };
      inspect.styles = {
        "special": "cyan",
        "number": "yellow",
        "boolean": "yellow",
        "undefined": "grey",
        "null": "bold",
        "string": "green",
        "date": "magenta",
        // "name": intentionally not styling
        "regexp": "red"
      };
      function stylizeWithColor(str, styleType) {
        var style = inspect.styles[styleType];
        if (style) {
          return "\x1B[" + inspect.colors[style][0] + "m" + str + "\x1B[" + inspect.colors[style][1] + "m";
        } else {
          return str;
        }
      }
      function stylizeNoColor(str, styleType) {
        return str;
      }
      function arrayToHash(array) {
        var hash = {};
        array.forEach(function(val, idx) {
          hash[val] = true;
        });
        return hash;
      }
      function formatValue(ctx, value, recurseTimes) {
        if (ctx.customInspect && value && isFunction(value.inspect) && // Filter out the util module, it's inspect function is special
        value.inspect !== exports.inspect && // Also filter out any prototype objects using the circular check.
        !(value.constructor && value.constructor.prototype === value)) {
          var ret = value.inspect(recurseTimes, ctx);
          if (!isString(ret)) {
            ret = formatValue(ctx, ret, recurseTimes);
          }
          return ret;
        }
        var primitive = formatPrimitive(ctx, value);
        if (primitive) {
          return primitive;
        }
        var keys = Object.keys(value);
        var visibleKeys = arrayToHash(keys);
        if (ctx.showHidden) {
          keys = Object.getOwnPropertyNames(value);
        }
        if (isError(value) && (keys.indexOf("message") >= 0 || keys.indexOf("description") >= 0)) {
          return formatError(value);
        }
        if (keys.length === 0) {
          if (isFunction(value)) {
            var name = value.name ? ": " + value.name : "";
            return ctx.stylize("[Function" + name + "]", "special");
          }
          if (isRegExp(value)) {
            return ctx.stylize(RegExp.prototype.toString.call(value), "regexp");
          }
          if (isDate(value)) {
            return ctx.stylize(Date.prototype.toString.call(value), "date");
          }
          if (isError(value)) {
            return formatError(value);
          }
        }
        var base = "", array = false, braces = ["{", "}"];
        if (isArray(value)) {
          array = true;
          braces = ["[", "]"];
        }
        if (isFunction(value)) {
          var n = value.name ? ": " + value.name : "";
          base = " [Function" + n + "]";
        }
        if (isRegExp(value)) {
          base = " " + RegExp.prototype.toString.call(value);
        }
        if (isDate(value)) {
          base = " " + Date.prototype.toUTCString.call(value);
        }
        if (isError(value)) {
          base = " " + formatError(value);
        }
        if (keys.length === 0 && (!array || value.length == 0)) {
          return braces[0] + base + braces[1];
        }
        if (recurseTimes < 0) {
          if (isRegExp(value)) {
            return ctx.stylize(RegExp.prototype.toString.call(value), "regexp");
          } else {
            return ctx.stylize("[Object]", "special");
          }
        }
        ctx.seen.push(value);
        var output;
        if (array) {
          output = formatArray(ctx, value, recurseTimes, visibleKeys, keys);
        } else {
          output = keys.map(function(key) {
            return formatProperty(ctx, value, recurseTimes, visibleKeys, key, array);
          });
        }
        ctx.seen.pop();
        return reduceToSingleString(output, base, braces);
      }
      function formatPrimitive(ctx, value) {
        if (isUndefined(value))
          return ctx.stylize("undefined", "undefined");
        if (isString(value)) {
          var simple = "'" + JSON.stringify(value).replace(/^"|"$/g, "").replace(/'/g, "\\'").replace(/\\"/g, '"') + "'";
          return ctx.stylize(simple, "string");
        }
        if (isNumber(value))
          return ctx.stylize("" + value, "number");
        if (isBoolean(value))
          return ctx.stylize("" + value, "boolean");
        if (isNull(value))
          return ctx.stylize("null", "null");
      }
      function formatError(value) {
        return "[" + Error.prototype.toString.call(value) + "]";
      }
      function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
        var output = [];
        for (var i = 0, l = value.length; i < l; ++i) {
          if (hasOwnProperty(value, String(i))) {
            output.push(formatProperty(
              ctx,
              value,
              recurseTimes,
              visibleKeys,
              String(i),
              true
            ));
          } else {
            output.push("");
          }
        }
        keys.forEach(function(key) {
          if (!key.match(/^\d+$/)) {
            output.push(formatProperty(
              ctx,
              value,
              recurseTimes,
              visibleKeys,
              key,
              true
            ));
          }
        });
        return output;
      }
      function formatProperty(ctx, value, recurseTimes, visibleKeys, key, array) {
        var name, str, desc;
        desc = Object.getOwnPropertyDescriptor(value, key) || { value: value[key] };
        if (desc.get) {
          if (desc.set) {
            str = ctx.stylize("[Getter/Setter]", "special");
          } else {
            str = ctx.stylize("[Getter]", "special");
          }
        } else {
          if (desc.set) {
            str = ctx.stylize("[Setter]", "special");
          }
        }
        if (!hasOwnProperty(visibleKeys, key)) {
          name = "[" + key + "]";
        }
        if (!str) {
          if (ctx.seen.indexOf(desc.value) < 0) {
            if (isNull(recurseTimes)) {
              str = formatValue(ctx, desc.value, null);
            } else {
              str = formatValue(ctx, desc.value, recurseTimes - 1);
            }
            if (str.indexOf("\n") > -1) {
              if (array) {
                str = str.split("\n").map(function(line) {
                  return "  " + line;
                }).join("\n").slice(2);
              } else {
                str = "\n" + str.split("\n").map(function(line) {
                  return "   " + line;
                }).join("\n");
              }
            }
          } else {
            str = ctx.stylize("[Circular]", "special");
          }
        }
        if (isUndefined(name)) {
          if (array && key.match(/^\d+$/)) {
            return str;
          }
          name = JSON.stringify("" + key);
          if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
            name = name.slice(1, -1);
            name = ctx.stylize(name, "name");
          } else {
            name = name.replace(/'/g, "\\'").replace(/\\"/g, '"').replace(/(^"|"$)/g, "'");
            name = ctx.stylize(name, "string");
          }
        }
        return name + ": " + str;
      }
      function reduceToSingleString(output, base, braces) {
        var numLinesEst = 0;
        var length = output.reduce(function(prev, cur) {
          numLinesEst++;
          if (cur.indexOf("\n") >= 0) numLinesEst++;
          return prev + cur.replace(/\u001b\[\d\d?m/g, "").length + 1;
        }, 0);
        if (length > 60) {
          return braces[0] + (base === "" ? "" : base + "\n ") + " " + output.join(",\n  ") + " " + braces[1];
        }
        return braces[0] + base + " " + output.join(", ") + " " + braces[1];
      }
      exports.types = require_types();
      function isArray(ar) {
        return Array.isArray(ar);
      }
      exports.isArray = isArray;
      function isBoolean(arg) {
        return typeof arg === "boolean";
      }
      exports.isBoolean = isBoolean;
      function isNull(arg) {
        return arg === null;
      }
      exports.isNull = isNull;
      function isNullOrUndefined(arg) {
        return arg == null;
      }
      exports.isNullOrUndefined = isNullOrUndefined;
      function isNumber(arg) {
        return typeof arg === "number";
      }
      exports.isNumber = isNumber;
      function isString(arg) {
        return typeof arg === "string";
      }
      exports.isString = isString;
      function isSymbol(arg) {
        return typeof arg === "symbol";
      }
      exports.isSymbol = isSymbol;
      function isUndefined(arg) {
        return arg === void 0;
      }
      exports.isUndefined = isUndefined;
      function isRegExp(re) {
        return isObject(re) && objectToString(re) === "[object RegExp]";
      }
      exports.isRegExp = isRegExp;
      exports.types.isRegExp = isRegExp;
      function isObject(arg) {
        return typeof arg === "object" && arg !== null;
      }
      exports.isObject = isObject;
      function isDate(d) {
        return isObject(d) && objectToString(d) === "[object Date]";
      }
      exports.isDate = isDate;
      exports.types.isDate = isDate;
      function isError(e) {
        return isObject(e) && (objectToString(e) === "[object Error]" || e instanceof Error);
      }
      exports.isError = isError;
      exports.types.isNativeError = isError;
      function isFunction(arg) {
        return typeof arg === "function";
      }
      exports.isFunction = isFunction;
      function isPrimitive(arg) {
        return arg === null || typeof arg === "boolean" || typeof arg === "number" || typeof arg === "string" || typeof arg === "symbol" || // ES6 symbol
        typeof arg === "undefined";
      }
      exports.isPrimitive = isPrimitive;
      exports.isBuffer = require_isBufferBrowser();
      function objectToString(o) {
        return Object.prototype.toString.call(o);
      }
      function pad(n) {
        return n < 10 ? "0" + n.toString(10) : n.toString(10);
      }
      var months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      function timestamp() {
        var d = /* @__PURE__ */ new Date();
        var time = [
          pad(d.getHours()),
          pad(d.getMinutes()),
          pad(d.getSeconds())
        ].join(":");
        return [d.getDate(), months[d.getMonth()], time].join(" ");
      }
      exports.log = function() {
        console.log("%s - %s", timestamp(), exports.format.apply(exports, arguments));
      };
      exports.inherits = require_inherits_browser();
      exports._extend = function(origin, add) {
        if (!add || !isObject(add)) return origin;
        var keys = Object.keys(add);
        var i = keys.length;
        while (i--) {
          origin[keys[i]] = add[keys[i]];
        }
        return origin;
      };
      function hasOwnProperty(obj, prop) {
        return Object.prototype.hasOwnProperty.call(obj, prop);
      }
      var kCustomPromisifiedSymbol = typeof Symbol !== "undefined" ? Symbol("util.promisify.custom") : void 0;
      exports.promisify = function promisify(original) {
        if (typeof original !== "function")
          throw new TypeError('The "original" argument must be of type Function');
        if (kCustomPromisifiedSymbol && original[kCustomPromisifiedSymbol]) {
          var fn = original[kCustomPromisifiedSymbol];
          if (typeof fn !== "function") {
            throw new TypeError('The "util.promisify.custom" argument must be of type Function');
          }
          Object.defineProperty(fn, kCustomPromisifiedSymbol, {
            value: fn,
            enumerable: false,
            writable: false,
            configurable: true
          });
          return fn;
        }
        function fn() {
          var promiseResolve, promiseReject;
          var promise = new Promise(function(resolve, reject) {
            promiseResolve = resolve;
            promiseReject = reject;
          });
          var args = [];
          for (var i = 0; i < arguments.length; i++) {
            args.push(arguments[i]);
          }
          args.push(function(err, value) {
            if (err) {
              promiseReject(err);
            } else {
              promiseResolve(value);
            }
          });
          try {
            original.apply(this, args);
          } catch (err) {
            promiseReject(err);
          }
          return promise;
        }
        Object.setPrototypeOf(fn, Object.getPrototypeOf(original));
        if (kCustomPromisifiedSymbol) Object.defineProperty(fn, kCustomPromisifiedSymbol, {
          value: fn,
          enumerable: false,
          writable: false,
          configurable: true
        });
        return Object.defineProperties(
          fn,
          getOwnPropertyDescriptors(original)
        );
      };
      exports.promisify.custom = kCustomPromisifiedSymbol;
      function callbackifyOnRejected(reason, cb) {
        if (!reason) {
          var newReason = new Error("Promise was rejected with a falsy value");
          newReason.reason = reason;
          reason = newReason;
        }
        return cb(reason);
      }
      function callbackify(original) {
        if (typeof original !== "function") {
          throw new TypeError('The "original" argument must be of type Function');
        }
        function callbackified() {
          var args = [];
          for (var i = 0; i < arguments.length; i++) {
            args.push(arguments[i]);
          }
          var maybeCb = args.pop();
          if (typeof maybeCb !== "function") {
            throw new TypeError("The last argument must be of type Function");
          }
          var self2 = this;
          var cb = function() {
            return maybeCb.apply(self2, arguments);
          };
          original.apply(this, args).then(
            function(ret) {
              import_process.default.nextTick(cb.bind(null, null, ret));
            },
            function(rej) {
              import_process.default.nextTick(callbackifyOnRejected.bind(null, rej, cb));
            }
          );
        }
        Object.setPrototypeOf(callbackified, Object.getPrototypeOf(original));
        Object.defineProperties(
          callbackified,
          getOwnPropertyDescriptors(original)
        );
        return callbackified;
      }
      exports.callbackify = callbackify;
    }
  });

  // node_modules/events/events.js
  var require_events = __commonJS({
    "node_modules/events/events.js"(exports, module) {
      "use strict";
      init_shim();
      var R = typeof Reflect === "object" ? Reflect : null;
      var ReflectApply = R && typeof R.apply === "function" ? R.apply : function ReflectApply2(target, receiver, args) {
        return Function.prototype.apply.call(target, receiver, args);
      };
      var ReflectOwnKeys;
      if (R && typeof R.ownKeys === "function") {
        ReflectOwnKeys = R.ownKeys;
      } else if (Object.getOwnPropertySymbols) {
        ReflectOwnKeys = function ReflectOwnKeys2(target) {
          return Object.getOwnPropertyNames(target).concat(Object.getOwnPropertySymbols(target));
        };
      } else {
        ReflectOwnKeys = function ReflectOwnKeys2(target) {
          return Object.getOwnPropertyNames(target);
        };
      }
      function ProcessEmitWarning(warning) {
        if (console && console.warn) console.warn(warning);
      }
      var NumberIsNaN = Number.isNaN || function NumberIsNaN2(value) {
        return value !== value;
      };
      function EventEmitter() {
        EventEmitter.init.call(this);
      }
      module.exports = EventEmitter;
      module.exports.once = once;
      EventEmitter.EventEmitter = EventEmitter;
      EventEmitter.prototype._events = void 0;
      EventEmitter.prototype._eventsCount = 0;
      EventEmitter.prototype._maxListeners = void 0;
      var defaultMaxListeners = 10;
      function checkListener(listener) {
        if (typeof listener !== "function") {
          throw new TypeError('The "listener" argument must be of type Function. Received type ' + typeof listener);
        }
      }
      Object.defineProperty(EventEmitter, "defaultMaxListeners", {
        enumerable: true,
        get: function() {
          return defaultMaxListeners;
        },
        set: function(arg) {
          if (typeof arg !== "number" || arg < 0 || NumberIsNaN(arg)) {
            throw new RangeError('The value of "defaultMaxListeners" is out of range. It must be a non-negative number. Received ' + arg + ".");
          }
          defaultMaxListeners = arg;
        }
      });
      EventEmitter.init = function() {
        if (this._events === void 0 || this._events === Object.getPrototypeOf(this)._events) {
          this._events = /* @__PURE__ */ Object.create(null);
          this._eventsCount = 0;
        }
        this._maxListeners = this._maxListeners || void 0;
      };
      EventEmitter.prototype.setMaxListeners = function setMaxListeners(n) {
        if (typeof n !== "number" || n < 0 || NumberIsNaN(n)) {
          throw new RangeError('The value of "n" is out of range. It must be a non-negative number. Received ' + n + ".");
        }
        this._maxListeners = n;
        return this;
      };
      function _getMaxListeners(that) {
        if (that._maxListeners === void 0)
          return EventEmitter.defaultMaxListeners;
        return that._maxListeners;
      }
      EventEmitter.prototype.getMaxListeners = function getMaxListeners() {
        return _getMaxListeners(this);
      };
      EventEmitter.prototype.emit = function emit(type) {
        var args = [];
        for (var i = 1; i < arguments.length; i++) args.push(arguments[i]);
        var doError = type === "error";
        var events = this._events;
        if (events !== void 0)
          doError = doError && events.error === void 0;
        else if (!doError)
          return false;
        if (doError) {
          var er;
          if (args.length > 0)
            er = args[0];
          if (er instanceof Error) {
            throw er;
          }
          var err = new Error("Unhandled error." + (er ? " (" + er.message + ")" : ""));
          err.context = er;
          throw err;
        }
        var handler = events[type];
        if (handler === void 0)
          return false;
        if (typeof handler === "function") {
          ReflectApply(handler, this, args);
        } else {
          var len = handler.length;
          var listeners = arrayClone(handler, len);
          for (var i = 0; i < len; ++i)
            ReflectApply(listeners[i], this, args);
        }
        return true;
      };
      function _addListener(target, type, listener, prepend) {
        var m;
        var events;
        var existing;
        checkListener(listener);
        events = target._events;
        if (events === void 0) {
          events = target._events = /* @__PURE__ */ Object.create(null);
          target._eventsCount = 0;
        } else {
          if (events.newListener !== void 0) {
            target.emit(
              "newListener",
              type,
              listener.listener ? listener.listener : listener
            );
            events = target._events;
          }
          existing = events[type];
        }
        if (existing === void 0) {
          existing = events[type] = listener;
          ++target._eventsCount;
        } else {
          if (typeof existing === "function") {
            existing = events[type] = prepend ? [listener, existing] : [existing, listener];
          } else if (prepend) {
            existing.unshift(listener);
          } else {
            existing.push(listener);
          }
          m = _getMaxListeners(target);
          if (m > 0 && existing.length > m && !existing.warned) {
            existing.warned = true;
            var w = new Error("Possible EventEmitter memory leak detected. " + existing.length + " " + String(type) + " listeners added. Use emitter.setMaxListeners() to increase limit");
            w.name = "MaxListenersExceededWarning";
            w.emitter = target;
            w.type = type;
            w.count = existing.length;
            ProcessEmitWarning(w);
          }
        }
        return target;
      }
      EventEmitter.prototype.addListener = function addListener(type, listener) {
        return _addListener(this, type, listener, false);
      };
      EventEmitter.prototype.on = EventEmitter.prototype.addListener;
      EventEmitter.prototype.prependListener = function prependListener(type, listener) {
        return _addListener(this, type, listener, true);
      };
      function onceWrapper() {
        if (!this.fired) {
          this.target.removeListener(this.type, this.wrapFn);
          this.fired = true;
          if (arguments.length === 0)
            return this.listener.call(this.target);
          return this.listener.apply(this.target, arguments);
        }
      }
      function _onceWrap(target, type, listener) {
        var state = { fired: false, wrapFn: void 0, target, type, listener };
        var wrapped = onceWrapper.bind(state);
        wrapped.listener = listener;
        state.wrapFn = wrapped;
        return wrapped;
      }
      EventEmitter.prototype.once = function once2(type, listener) {
        checkListener(listener);
        this.on(type, _onceWrap(this, type, listener));
        return this;
      };
      EventEmitter.prototype.prependOnceListener = function prependOnceListener(type, listener) {
        checkListener(listener);
        this.prependListener(type, _onceWrap(this, type, listener));
        return this;
      };
      EventEmitter.prototype.removeListener = function removeListener(type, listener) {
        var list, events, position, i, originalListener;
        checkListener(listener);
        events = this._events;
        if (events === void 0)
          return this;
        list = events[type];
        if (list === void 0)
          return this;
        if (list === listener || list.listener === listener) {
          if (--this._eventsCount === 0)
            this._events = /* @__PURE__ */ Object.create(null);
          else {
            delete events[type];
            if (events.removeListener)
              this.emit("removeListener", type, list.listener || listener);
          }
        } else if (typeof list !== "function") {
          position = -1;
          for (i = list.length - 1; i >= 0; i--) {
            if (list[i] === listener || list[i].listener === listener) {
              originalListener = list[i].listener;
              position = i;
              break;
            }
          }
          if (position < 0)
            return this;
          if (position === 0)
            list.shift();
          else {
            spliceOne(list, position);
          }
          if (list.length === 1)
            events[type] = list[0];
          if (events.removeListener !== void 0)
            this.emit("removeListener", type, originalListener || listener);
        }
        return this;
      };
      EventEmitter.prototype.off = EventEmitter.prototype.removeListener;
      EventEmitter.prototype.removeAllListeners = function removeAllListeners(type) {
        var listeners, events, i;
        events = this._events;
        if (events === void 0)
          return this;
        if (events.removeListener === void 0) {
          if (arguments.length === 0) {
            this._events = /* @__PURE__ */ Object.create(null);
            this._eventsCount = 0;
          } else if (events[type] !== void 0) {
            if (--this._eventsCount === 0)
              this._events = /* @__PURE__ */ Object.create(null);
            else
              delete events[type];
          }
          return this;
        }
        if (arguments.length === 0) {
          var keys = Object.keys(events);
          var key;
          for (i = 0; i < keys.length; ++i) {
            key = keys[i];
            if (key === "removeListener") continue;
            this.removeAllListeners(key);
          }
          this.removeAllListeners("removeListener");
          this._events = /* @__PURE__ */ Object.create(null);
          this._eventsCount = 0;
          return this;
        }
        listeners = events[type];
        if (typeof listeners === "function") {
          this.removeListener(type, listeners);
        } else if (listeners !== void 0) {
          for (i = listeners.length - 1; i >= 0; i--) {
            this.removeListener(type, listeners[i]);
          }
        }
        return this;
      };
      function _listeners(target, type, unwrap) {
        var events = target._events;
        if (events === void 0)
          return [];
        var evlistener = events[type];
        if (evlistener === void 0)
          return [];
        if (typeof evlistener === "function")
          return unwrap ? [evlistener.listener || evlistener] : [evlistener];
        return unwrap ? unwrapListeners(evlistener) : arrayClone(evlistener, evlistener.length);
      }
      EventEmitter.prototype.listeners = function listeners(type) {
        return _listeners(this, type, true);
      };
      EventEmitter.prototype.rawListeners = function rawListeners(type) {
        return _listeners(this, type, false);
      };
      EventEmitter.listenerCount = function(emitter, type) {
        if (typeof emitter.listenerCount === "function") {
          return emitter.listenerCount(type);
        } else {
          return listenerCount.call(emitter, type);
        }
      };
      EventEmitter.prototype.listenerCount = listenerCount;
      function listenerCount(type) {
        var events = this._events;
        if (events !== void 0) {
          var evlistener = events[type];
          if (typeof evlistener === "function") {
            return 1;
          } else if (evlistener !== void 0) {
            return evlistener.length;
          }
        }
        return 0;
      }
      EventEmitter.prototype.eventNames = function eventNames() {
        return this._eventsCount > 0 ? ReflectOwnKeys(this._events) : [];
      };
      function arrayClone(arr, n) {
        var copy = new Array(n);
        for (var i = 0; i < n; ++i)
          copy[i] = arr[i];
        return copy;
      }
      function spliceOne(list, index) {
        for (; index + 1 < list.length; index++)
          list[index] = list[index + 1];
        list.pop();
      }
      function unwrapListeners(arr) {
        var ret = new Array(arr.length);
        for (var i = 0; i < ret.length; ++i) {
          ret[i] = arr[i].listener || arr[i];
        }
        return ret;
      }
      function once(emitter, name) {
        return new Promise(function(resolve, reject) {
          function errorListener(err) {
            emitter.removeListener(name, resolver);
            reject(err);
          }
          function resolver() {
            if (typeof emitter.removeListener === "function") {
              emitter.removeListener("error", errorListener);
            }
            resolve([].slice.call(arguments));
          }
          ;
          eventTargetAgnosticAddListener(emitter, name, resolver, { once: true });
          if (name !== "error") {
            addErrorHandlerIfEventEmitter(emitter, errorListener, { once: true });
          }
        });
      }
      function addErrorHandlerIfEventEmitter(emitter, handler, flags) {
        if (typeof emitter.on === "function") {
          eventTargetAgnosticAddListener(emitter, "error", handler, flags);
        }
      }
      function eventTargetAgnosticAddListener(emitter, name, listener, flags) {
        if (typeof emitter.on === "function") {
          if (flags.once) {
            emitter.once(name, listener);
          } else {
            emitter.on(name, listener);
          }
        } else if (typeof emitter.addEventListener === "function") {
          emitter.addEventListener(name, function wrapListener(arg) {
            if (flags.once) {
              emitter.removeEventListener(name, wrapListener);
            }
            listener(arg);
          });
        } else {
          throw new TypeError('The "emitter" argument must be of type EventEmitter. Received type ' + typeof emitter);
        }
      }
    }
  });

  // tetris/src/gamestate.js
  var require_gamestate = __commonJS({
    "tetris/src/gamestate.js"(exports, module) {
      init_shim();
      var util = require_util();
      var EventEmitter = require_events().EventEmitter;
      var Matrix2 = require_matrix();
      function GameState2(width, height) {
        EventEmitter.call(this);
        this._background = new Matrix2(width, height);
        this._width = width;
        this._height = height;
        this._pieces = [];
        this._gameover = true;
        this._running = false;
        this._pauseCount = 0;
        this.clearBackground();
        this.clearMovingPiece();
      }
      util.inherits(GameState2, EventEmitter);
      GameState2.prototype.clearBackground = function() {
        this._background.clear();
      };
      GameState2.prototype.clearMovingPiece = function() {
        this._movingPieceMatrix = null;
        this._movingPiecePosition = { x: null, y: null };
      };
      GameState2.prototype.start = function() {
        this.clearBackground();
        this.clearMovingPiece();
        this._nextPiece = null;
        this._gameover = false;
        this._running = true;
        this._pauseCount = 0;
        this.emit("start");
      };
      GameState2.prototype.isGameover = function() {
        return this._gameover;
      };
      GameState2.prototype.isPaused = function() {
        return !this._running;
      };
      GameState2.prototype.pause = function() {
        this._pauseCount += 1;
        if (this._running && !this._gameover) {
          this._running = false;
          this.emit("pause");
        }
      };
      GameState2.prototype.resume = function() {
        this._pauseCount -= 1;
        if (!this._running && !this._gameover && this._pauseCount <= 0) {
          this._running = true;
          this.emit("resume");
        }
      };
      GameState2.prototype.loadPieceMatrix = function(matrix) {
        this._pieces.push(matrix);
      };
      GameState2.prototype.getRandomPieceIndex = function() {
        return Math.round(Math.random() * 99999) % this._pieces.length;
      };
      GameState2.prototype.setNextPiece = function(index) {
        this._nextPiece = this._pieces[index];
        this.emit("set-next-piece", index, this._nextPiece);
      };
      GameState2.prototype.getStartingPosition = function(matrix) {
        return {
          x: Math.floor(this._background.getWidth() / 2 - matrix.getWidth() / 2),
          y: 0
        };
      };
      GameState2.prototype.loadNextMovingPiece = function() {
        this._movingPieceMatrix = this._nextPiece;
        this._movingPiecePosition = this.getStartingPosition(this._movingPieceMatrix);
        if (this.hasCollision(0, 0)) {
          this._gameover = true;
          this._running = false;
          this._movingPieceMatrix = new Matrix2(0, 0);
          this.emit("gameover");
        } else {
          this.emit("new-piece");
        }
      };
      GameState2.prototype.createMatrixFromString = function(spec) {
        var string, originX, originY;
        if (typeof spec === "string") {
          string = spec;
        } else if (typeof spec === "array") {
          string = spec[0];
          originX = spec[1];
          originY = spec[2];
        }
        var maxX = 0;
        var x = -1;
        var y = 0;
        var sets = [];
        for (var i = 0; i < string.length; i++) {
          var c = string[i];
          if (c == "\n") {
            maxX = Math.max(maxX, x);
            x = -1;
            y += 1;
          } else {
            x += 1;
            var value = parseInt(c, 10);
            if (value > 0) {
              sets.push({ x, y, colour: value });
            }
          }
        }
        maxX = Math.max(maxX, x);
        var matrix = new Matrix2(maxX + 1, y + 1, originX, originY);
        for (i = 0; i < sets.length; i++) {
          var fill = sets[i];
          matrix.set(fill.x, fill.y, fill.colour);
        }
        return matrix;
      };
      GameState2.prototype.getBackgroundMatrix = function() {
        return this._background;
      };
      GameState2.prototype.getMovingPieceMatrix = function() {
        return this._movingPieceMatrix;
      };
      GameState2.prototype.getMovingPiecePosition = function() {
        return this._movingPiecePosition;
      };
      GameState2.prototype.hasCollision = function(x, y) {
        return this._background.collision(
          this._movingPiecePosition.x + x,
          this._movingPiecePosition.y + y,
          this._movingPieceMatrix
        );
      };
      GameState2.prototype.collapse = function(minY, maxY) {
        var collapses = [];
        var width = this._width;
        for (var y = maxY, originalY = maxY; y >= minY; y--, originalY--) {
          if (this._background.isRowFilled(y)) {
            collapses.push(originalY);
            this._background.collapseRow(y);
            y = maxY + 1;
            originalY = y - collapses.length;
          }
        }
        if (collapses.length > 0) {
          this.emit("collapse", collapses);
        }
      };
      GameState2.prototype.stopMovingPiece = function() {
        this._background.copy(
          this._movingPiecePosition.x,
          this._movingPiecePosition.y,
          this._movingPieceMatrix
        );
        this.emit("hit");
        this.collapse(0, this._background.getHeight() - 1);
      };
      GameState2.prototype.getCompositeMatrix = function() {
        var width = this._background.getWidth();
        var height = this._background.getHeight();
        var result = new Matrix2(width, height);
        result.copy(0, 0, this._background);
        result.copy(
          this._movingPiecePosition.x,
          this._movingPiecePosition.y,
          this._movingPieceMatrix
        );
        return result;
      };
      GameState2.prototype.move = function(x, y) {
        if (!this._running) {
          return;
        }
        if (!this.hasCollision(x, y)) {
          this._movingPiecePosition.x += x;
          this._movingPiecePosition.y += y;
          this.emit("move", x, y);
        } else if (y > 0) {
          this.stopMovingPiece();
        }
      };
      GameState2.prototype._applyRotate = function(rotated, x, y) {
        var collision = this._background.collision(x, y, rotated);
        if (!collision) {
          this._movingPiecePosition.x = x;
          this._movingPiecePosition.y = y;
          this._movingPieceMatrix = rotated;
          this.emit("rotate");
          return true;
        }
        return false;
      };
      GameState2.prototype.rotate = function() {
        if (!this._running) {
          return;
        }
        var rotated = this._movingPieceMatrix.rotate();
        var x = this._movingPiecePosition.x;
        var y = this._movingPiecePosition.y;
        if (this._applyRotate(rotated, x, y)) {
          return;
        }
        var start = x;
        var background = this._background;
        var piece = this._movingPieceMatrix;
        var rightEnd = start + rotated.getWidth();
        for (x = start; x < rightEnd; x++) {
          if (background.collision(x, y, piece)) {
            break;
          }
          if (this._applyRotate(rotated, x, y)) {
            return;
          }
        }
        var leftEnd = start - rotated.getWidth();
        for (x = start; x > leftEnd; x--) {
          if (background.collision(x, y, piece)) {
            break;
          }
          if (this._applyRotate(rotated, x, y)) {
            return;
          }
        }
      };
      module.exports = GameState2;
    }
  });

  // tetris/src/player_gamemode.js
  var require_player_gamemode = __commonJS({
    "tetris/src/player_gamemode.js"(exports, module) {
      init_shim();
      function PlayerGameMode2(game) {
        this._game = game;
        this._timer = null;
        this._lines = 0;
        this._level = 1;
        var self2 = this;
        game.on("hit", function() {
          self2._loadMovingPiece();
        });
        game.on("start", function() {
          self2.start();
        });
        game.on("gameover", function() {
          self2._stopTimer();
        });
        game.on("collapse", function(collapses) {
          self2._lines += collapses.length;
          self2._level = Math.floor(Math.min(self2._lines, 200) / 20) + 1;
        });
      }
      PlayerGameMode2.prototype.getLevel = function() {
        return this._level;
      };
      PlayerGameMode2.prototype._setNextPiece = function() {
        this._game.setNextPiece(this._game.getRandomPieceIndex());
      };
      PlayerGameMode2.prototype._loadMovingPiece = function() {
        this._game.loadNextMovingPiece();
        this._setNextPiece();
      };
      PlayerGameMode2.prototype.update = function() {
        this._game.move(0, 1);
      };
      PlayerGameMode2.prototype._startTimer = function() {
        if (this._timer) {
          return;
        }
        var self2 = this;
        var update = function() {
          schedNextUpdate();
          self2.update();
        };
        var schedNextUpdate = function() {
          self2._timer = setTimeout(update, (10 - self2._level) * 65 + 50);
        };
        schedNextUpdate();
      };
      PlayerGameMode2.prototype._stopTimer = function() {
        if (!this._timer) {
          return;
        }
        clearTimeout(this._timer);
        this._timer = null;
      };
      PlayerGameMode2.prototype.start = function() {
        this._level = 1;
        this._lines = 0;
        this._setNextPiece();
        this._loadMovingPiece();
        this._startTimer();
      };
      module.exports = PlayerGameMode2;
    }
  });

  // tetris/src/input.js
  var require_input = __commonJS({
    "tetris/src/input.js"(exports, module) {
      init_shim();
      var $3 = window.jQuery;
      function onKeyDown(callback) {
        var keydowns = {};
        var repeat = function(event) {
          var delay = callback(event);
          scheduleRepeat(delay, event);
        };
        var scheduleRepeat = function(delay, event) {
          var keydown = keydowns[event.which];
          if (delay >= 0) {
            var timeout = setTimeout(function() {
              repeat(keydown.event);
            }, delay);
            keydown.timeout = timeout;
          } else {
            keydown.timeout = null;
          }
        };
        var onKeydown = function(event) {
          var keydown = keydowns[event.which];
          if (keydown) {
            if (keydown.timeout === null) {
              repeat(event);
            }
            if (keydown.isDefaultPrevented) {
              event.preventDefault();
            }
          } else {
            keydowns[event.which] = {
              timeout: null,
              isDefaultPrevented: false,
              event: {
                which: event.which,
                preventDefault: function() {
                },
                isDefaultPrevented: function() {
                  return false;
                }
              }
            };
            repeat(event);
            keydowns[event.which].isDefaultPrevented = event.isDefaultPrevented();
          }
        };
        var onKeyup = function(event) {
          var keydown = keydowns[event.which];
          if (keydown) {
            clearTimeout(keydown.timeout);
            delete keydowns[event.which];
          }
        };
        $3(document).keydown(onKeydown);
        $3(document).keyup(onKeyup);
        var uninstall = function() {
          $3(document).unbind("keydown", onKeydown);
          $3(document).unbind("keyup", onKeyup);
          for (var code in keydowns) {
            clearTimeout(keydowns[code].timeout);
          }
        };
        return uninstall;
      }
      function bindKeys(bindings) {
        return onKeyDown(function(event) {
          var binding = bindings[event.which];
          if (binding) {
            event.preventDefault();
            binding.action();
            return binding.delay;
          }
        });
      }
      module.exports = {
        bindKeys
      };
    }
  });

  // tetris/src/player_controller.js
  var require_player_controller = __commonJS({
    "tetris/src/player_controller.js"(exports, module) {
      init_shim();
      var input = require_input();
      function PlayerController2(game) {
        this._game = game;
        this._uninstallBindings = null;
        this._dropping = false;
      }
      PlayerController2.prototype.move = function(x, y) {
        if (!this._dropping) {
          this._game.move(x, y);
        }
      };
      PlayerController2.prototype.rotate = function() {
        if (!this._dropping) {
          this._game.rotate();
        }
      };
      PlayerController2.prototype.drop = function() {
        if (this._dropping || this._game.isPaused() || this._game.isGameover()) {
          return;
        }
        this._dropping = true;
        var self2 = this;
        this._droppingInterval = setInterval(function() {
          self2._game.move(0, 1);
        }, 10);
        this._game.once("hit", function() {
          clearInterval(self2._droppingInterval);
          self2._dropping = false;
        });
      };
      PlayerController2.prototype.togglePause = function() {
        if (!this._game.isPaused()) {
          this._game.pause();
        } else {
          this._game.resume();
        }
      };
      PlayerController2.prototype.bindKeys = function(bindings) {
        var resolvedBindings = {};
        var actions = {
          "left": this.move.bind(this, -1, 0),
          "right": this.move.bind(this, 1, 0),
          "down": this.move.bind(this, 0, 1),
          "rotate": this.rotate.bind(this),
          "drop": this.drop.bind(this),
          "togglePause": this.togglePause.bind(this)
        };
        for (var code in bindings) {
          resolvedBindings[code] = {
            action: actions[bindings[code].action],
            delay: bindings[code].delay
          };
        }
        if (this._uninstallBindings) {
          this._uninstallBindings();
        }
        this._uninstallBindings = input.bindKeys(resolvedBindings);
      };
      module.exports = PlayerController2;
    }
  });

  // tetris/src/score.js
  var require_score = __commonJS({
    "tetris/src/score.js"(exports, module) {
      init_shim();
      var util = require_util();
      var EventEmitter = require_events().EventEmitter;
      function Score2(game, gameMode) {
        EventEmitter.call(this);
        this._game = game;
        this._gameMode = gameMode;
        this._lines = 0;
        this._score = 0;
        this._dropScore = 0;
        this.initNormalScoring();
      }
      util.inherits(Score2, EventEmitter);
      Score2.prototype.initNormalScoring = function() {
        var self2 = this;
        this._game.on("start", function() {
          self2._lines = 0;
          self2._score = 0;
          self2.emit("update", 0);
        });
        var points = [40, 100, 300, 1200];
        this._game.on("collapse", function(collapses) {
          var lines = collapses.length;
          self2._lines += lines;
          self2.add(points[lines - 1] * self2._gameMode.getLevel());
        });
        this._game.on("rotate", function() {
          self2._dropScore = 0;
        });
        this._game.on("move", function(x, y) {
          if (y > 0 && x == 0) {
            self2._dropScore += y;
          } else if (x !== 0) {
            self2._dropScore = 0;
          }
        });
        this._game.on("hit", function() {
          self2.add(self2._dropScore);
          self2._dropScore = 0;
        });
        this._game.on("gameover", function() {
          self2.emit("final", self2.getStats());
        });
      };
      Score2.prototype.getStats = function() {
        return {
          score: this._score,
          lines: this._lines,
          level: this._gameMode.getLevel()
        };
      };
      Score2.prototype.add = function(addition) {
        if (addition !== 0) {
          this._score += addition;
          this.emit("update", addition);
          submitScore(this._score);
        }
      };
      Score2.prototype.getLines = function() {
        return this._lines;
      };
      Score2.prototype.getScore = function() {
        return this._score;
      };
      Score2.prototype.getLevel = function() {
        return this._gameMode.getLevel();
      };
      module.exports = Score2;
    }
  });

  // tetris/src/scoreboard.js
  var require_scoreboard = __commonJS({
    "tetris/src/scoreboard.js"(exports, module) {
      init_shim();
      var util = require_util();
      var EventEmitter = require_events().EventEmitter;
      function Scoreboard2(scoring, storage) {
        this._scoring = scoring;
        this._storage = storage;
        this._bestStats = [];
        this._load();
        var self2 = this;
        scoring.on("final", function(stats) {
          if (ga) {
            ga("send", "event", "game", "gameover", "score", stats.score);
            ga("send", "event", "game", "gameover", "lines", stats.lines);
            ga("send", "event", "game", "gameover", "level", stats.level);
          }
          self2._insertStats(stats);
          self2._save();
        });
      }
      util.inherits(Scoreboard2, EventEmitter);
      Scoreboard2.prototype.getCurrentStats = function() {
        return this._scoring.getStats();
      };
      Scoreboard2.prototype.getBestStats = function() {
        return this._bestStats;
      };
      Scoreboard2.prototype._load = function() {
        var bestStats = JSON.parse(this._storage.getItem("bestStats"));
        if (bestStats && bestStats.length) {
          this._bestStats = bestStats;
        }
      };
      Scoreboard2.prototype._save = function() {
        this._storage.setItem("bestStats", JSON.stringify(this._bestStats));
        this.emit("save");
      };
      Scoreboard2.prototype._insertStats = function(stats) {
        this._bestStats.push(stats);
        this._bestStats.sort(function(a, b) {
          if (a.score > b.score) {
            return -1;
          } else if (a.score < b.score) {
            return 1;
          }
          return 0;
        });
        var size = 3;
        if (this._bestStats.length > size) {
          this._bestStats = this._bestStats.slice(0, size);
        }
      };
      module.exports = Scoreboard2;
    }
  });

  // tetris/src/menu.js
  var require_menu = __commonJS({
    "tetris/src/menu.js"(exports, module) {
      init_shim();
      var $3 = window.jQuery;
      function Menu2(game, foreground, background) {
        this._game = game;
        this._foreground = $3(foreground);
        this._background = $3(background);
        this._dialogs = [];
      }
      Menu2.prototype.show = function(element) {
        var index = this._dialogs.length;
        this._dialogs.push(element);
        if (index === 0) {
          this._background.css({
            "-webkit-filter": "blur(2px) grayscale(100%)"
          });
          this._game.pause();
        }
        this._showElement(element);
        var self2 = this;
        return function() {
          self2.hide(index);
        };
      };
      Menu2.prototype._showElement = function(element, callback) {
        var foreground = this._foreground;
        foreground.fadeOut(200, function() {
          foreground.empty();
          if (element) {
            foreground.append(element).fadeIn(200, callback);
          } else {
            if (callback) {
              callback();
            }
          }
        });
      };
      Menu2.prototype.getVisibleIndex = function() {
        for (var index = this._dialogs.length - 1; index >= 0; index--) {
          if (this._dialogs[index] !== null) {
            return index;
          } else {
            this._dialogs.pop();
          }
        }
        return -1;
      };
      Menu2.prototype.hide = function(index) {
        if (index === void 0) {
          index = this._dialogs.length - 1;
        }
        if (index >= this._dialogs.length) {
          return;
        }
        var visibleIndex = this.getVisibleIndex();
        this._dialogs[index] = null;
        if (index === visibleIndex) {
          var nextVisibleIndex = this.getVisibleIndex();
          var nextVisible;
          if (nextVisibleIndex === -1) {
            this._dialogs = [];
            nextVisible = null;
          } else {
            nextVisible = this._dialogs[nextVisibleIndex];
          }
          var self2 = this;
          this._showElement(nextVisible, function() {
            if (self2._dialogs.length === 0) {
              self2._background.css({
                "-webkit-filter": "none"
              });
              self2._game.resume();
            }
          });
        }
      };
      Menu2.prototype.title = function(text) {
        var h1 = document.createElement("h1");
        h1.appendChild(document.createTextNode(text));
        return h1;
      };
      Menu2.prototype.button = function(text, clickHandler) {
        var button = $3('<button type="button" class="btn"></button>');
        button.text(text);
        if (clickHandler) {
          button.get(0).onclick = clickHandler;
        }
        return button.get(0);
      };
      Menu2.prototype.tablerow = function(row, cellNodeName) {
        cellNodeName = cellNodeName || "td";
        var tr = document.createElement("tr");
        for (var i = 0; i < row.length; i++) {
          var td = document.createElement(cellNodeName);
          var element = row[i];
          switch (typeof element) {
            case "string":
            case "number":
              element = document.createTextNode(element);
              break;
            case "function":
              element = element();
              break;
          }
          td.appendChild(element);
          tr.appendChild(td);
        }
        return tr;
      };
      module.exports = Menu2;
    }
  });

  // tetris/src/canvas/matrix_renderer.js
  var require_matrix_renderer = __commonJS({
    "tetris/src/canvas/matrix_renderer.js"(exports, module) {
      init_shim();
      var $3 = window.jQuery;
      function RGB(r, g, b) {
        this.r = r;
        this.g = g;
        this.b = b;
      }
      RGB.prototype.toString = function() {
        return "rgb(" + [
          Math.round(this.r),
          Math.round(this.g),
          Math.round(this.b)
        ].join(",") + ")";
      };
      RGB.prototype.blend = function(colour, alpha) {
        var ia = 1 - alpha;
        return new RGB(
          this.r * alpha + colour.r * ia,
          this.g * alpha + colour.g * ia,
          this.b * alpha + colour.b * ia
        );
      };
      RGB.prototype.darken = function(v) {
        return this.blend(new RGB(0, 0, 0), 1 - v);
      };
      RGB.prototype.lighten = function(v) {
        return this.blend(new RGB(255, 255, 255), 1 - v);
      };
      function fillRectangle(ctx, startX, startY, width, height, borderRadius) {
        borderRadius = Math.min(Math.min(borderRadius || 0, width / 2), height / 2);
        ctx.beginPath();
        var x = startX;
        var y = startY;
        if (borderRadius === 0) {
          ctx.moveTo(x, y);
          ctx.lineTo(x + width, y);
          ctx.lineTo(x + width, y + height);
          ctx.lineTo(x, y + height);
        } else {
          var br = borderRadius;
          var hll = width - br * 2;
          var vll = height - br * 2;
          ctx.moveTo(x + br, y);
          ctx.lineTo(x + br + hll, y);
          ctx.arcTo(x + width, y, x + width, y + br, br);
          ctx.lineTo(x + width, y + br + vll);
          ctx.arcTo(x + width, y + height, x + br + hll, y + height, br);
          ctx.lineTo(x + br, y + height);
          ctx.arcTo(x, y + height, x, y + br + vll, br);
          ctx.lineTo(x, y + br);
          ctx.arcTo(x, y, x + br, y, br);
        }
        ctx.fill();
        ctx.closePath();
      }
      function paintTile(ctx, options) {
        var x = options.x;
        var y = options.y;
        var width = options.width;
        var height = options.height;
        var colour = options.colour;
        ctx.fillStyle = options.borderColour ? options.borderColour.toString() : "#000";
        var borderRadius = options.borderRadius || 3;
        var borderWidth = options.borderWidth || 0;
        fillRectangle(
          ctx,
          x,
          y,
          width + borderWidth,
          height + borderWidth,
          borderRadius
        );
        var grad = ctx.createLinearGradient(
          x + borderWidth,
          y + borderWidth,
          x + width,
          y + height
        );
        var lighten = colour.lighten(0.35);
        var darken = colour.darken(0.35);
        grad.addColorStop(0, lighten.toString());
        grad.addColorStop(0.48, lighten.toString());
        grad.addColorStop(0.52, darken.toString());
        grad.addColorStop(1, darken.toString());
        ctx.fillStyle = grad;
        fillRectangle(
          ctx,
          x + borderWidth,
          y + borderWidth,
          width - borderWidth,
          height - borderWidth,
          borderRadius
        );
        ctx.fillStyle = colour.toString();
        var xheight = Math.round(0.1 * width);
        var yheight = Math.round(0.1 * height);
        fillRectangle(
          ctx,
          x + xheight + borderWidth,
          y + yheight + borderWidth,
          width - xheight * 2 - borderWidth,
          height - yheight * 2 - borderWidth,
          borderRadius
        );
      }
      function MatrixRenderer(container, matrix) {
        this._container = $3(container);
        this._canvas = document.createElement("canvas");
        this._canvas.width = this._container.width();
        this._canvas.height = this._container.height();
        this._container.empty().append(this._canvas);
        this._ctx = this._canvas.getContext("2d");
        this._matrix = matrix;
        this._calculatePixelDimensions();
        this._createTileImages();
        this._tiles = [];
      }
      MatrixRenderer.prototype.setMatrix = function(matrix) {
        this._matrix = matrix;
      };
      MatrixRenderer.prototype._calculatePixelDimensions = function() {
        var matrix = this._matrix;
        this._tileWidth = Math.round(this._canvas.width / matrix.getWidth());
        this._tileHeight = Math.round(this._canvas.height / matrix.getHeight());
      };
      MatrixRenderer.prototype._createTileImages = function() {
        var ctx = this._ctx;
        var colours = [
          new RGB(54, 179, 179),
          new RGB(54, 54, 179),
          new RGB(179, 134, 54),
          new RGB(179, 179, 54),
          new RGB(54, 179, 54),
          new RGB(179, 54, 179),
          new RGB(179, 54, 54)
        ];
        var tiles = [null];
        var tileWidth = this._tileWidth;
        var tileHeight = this._tileHeight;
        var borderWidth = 2;
        for (var i = 0; i < colours.length; i++) {
          paintTile(ctx, {
            x: 0,
            y: 0,
            width: tileWidth,
            height: tileHeight,
            borderWidth,
            borderRadius: 3,
            colour: colours[i]
          });
          tiles.push(ctx.getImageData(
            0,
            0,
            tileWidth + borderWidth,
            tileHeight + borderWidth
          ));
          ctx.clearRect(0, 0, tileWidth + borderWidth, tileHeight + borderWidth);
        }
        this._tileImages = tiles;
      };
      MatrixRenderer.prototype._paintTile = function(x, y, colour) {
        if (colour > 0) {
          this._ctx.putImageData(
            this._tileImages[colour],
            x * this._tileWidth,
            y * this._tileHeight
          );
        }
      };
      MatrixRenderer.prototype.render = function() {
        var matrix = this._matrix;
        var ctx = this._ctx;
        ctx.clearRect(0, 0, this._canvas.width, this._canvas.height);
        var width = matrix.getWidth();
        var height = matrix.getHeight();
        var tileWidth = this._tileWidth;
        var tileHeight = this._tileHeight;
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            this._paintTile(x, y, matrix.get(x, y));
          }
        }
      };
      module.exports = MatrixRenderer;
    }
  });

  // tetris/src/canvas/game_renderer.js
  var require_game_renderer = __commonJS({
    "tetris/src/canvas/game_renderer.js"(exports, module) {
      init_shim();
      var util = require_util();
      var MatrixRenderer = require_matrix_renderer();
      function GameRenderer(container, game) {
        MatrixRenderer.call(this, container, game.getBackgroundMatrix());
        this._game = game;
        this._piece = null;
        this._renderUpdate = true;
        var self2 = this;
        game.on("hit", function() {
          self2.createBackgroundImage();
        });
        game.on("collapse", function(collapses) {
          game.pause();
          var normalRender = self2.render;
          var flashCount = 0;
          var flashInterval = setInterval(function() {
            flashCount += 60;
            self2._renderUpdate = true;
          }, 16);
          var background = self2._background;
          self2.render = function() {
            var ctx = self2._ctx;
            var width = self2._canvas.width;
            var height = self2._canvas.height;
            ctx.clearRect(0, 0, width, height);
            ctx.putImageData(background, 0, 0);
            var alpha = 0.3 * (Math.cos(flashCount * 0.017453292519943295 + Math.PI) + 1) / 2 + 0.4;
            ctx.fillStyle = "rgba(255, 255, 255, " + alpha + ")";
            var tileHeight = self2._tileHeight;
            for (var i = 0; i < collapses.length; i++) {
              var y = collapses[i];
              ctx.fillRect(0, y * tileHeight, width, tileHeight);
            }
          };
          setTimeout(function() {
            clearInterval(flashInterval);
            self2.render = normalRender;
            self2.createBackgroundImage();
            self2._renderUpdate = true;
            game.resume();
          }, 200);
        });
        game.on("new-piece", function() {
          self2._renderUpdate = true;
        });
        game.on("move", function() {
          self2._renderUpdate = true;
        });
        game.on("rotate", function() {
          self2._renderUpdate = true;
        });
        game.on("start", function() {
          self2.createBackgroundImage();
          self2._renderUpdate = true;
        });
        var renderLoop = function() {
          if (self2._renderUpdate) {
            self2._renderUpdate = false;
            self2.render();
          }
          window.requestAnimationFrame(renderLoop);
        };
        renderLoop();
      }
      util.inherits(GameRenderer, MatrixRenderer);
      GameRenderer.prototype.renderGrid = function() {
        var tileWidth = this._tileWidth;
        var tileHeight = this._tileHeight;
        var width = this._canvas.width;
        var height = this._canvas.height;
        var cols = width / tileWidth;
        var rows = height / tileHeight;
        var ctx = this._ctx;
        ctx.strokeStyle = "rgba(255, 255, 255, 0.07)";
        for (var y = 0; y < rows; y++) {
          for (var x = 0; x < cols; x++) {
            ctx.beginPath();
            ctx.moveTo(x * tileWidth + tileWidth + 1.5, y * tileHeight + 1.5);
            ctx.lineTo(x * tileWidth + tileWidth + 1.5, y * tileHeight + tileHeight + 1.5);
            ctx.stroke();
            ctx.closePath();
            ctx.beginPath();
            ctx.moveTo(x * tileWidth + 1.5, y * tileHeight + tileHeight + 1.5);
            ctx.lineTo(x * tileWidth + tileWidth + 1.5, y * tileHeight + tileHeight + 1.5);
            ctx.stroke();
            ctx.closePath();
          }
        }
      };
      GameRenderer.prototype.renderMovingPiece = function() {
        var pieceMatrix = this._game.getMovingPieceMatrix();
        var piecePosition = this._game.getMovingPiecePosition();
        if (pieceMatrix) {
          var tileWidth = this._tileWidth;
          var tileHeight = this._tileHeight;
          var width = pieceMatrix.getWidth();
          var height = pieceMatrix.getHeight();
          var worldX = piecePosition.x;
          var worldY = piecePosition.y;
          for (var y = 0; y < height; y++) {
            for (var x = 0; x < width; x++) {
              this._paintTile(worldX + x, worldY + y, pieceMatrix.get(x, y));
            }
          }
        }
      };
      GameRenderer.prototype.createBackgroundImage = function() {
        var matrix = this._matrix;
        var ctx = this._ctx;
        ctx.clearRect(0, 0, this._canvas.width, this._canvas.height);
        this.renderGrid();
        var width = matrix.getWidth();
        var height = matrix.getHeight();
        var tileWidth = this._tileWidth;
        var tileHeight = this._tileHeight;
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            this._paintTile(x, y, matrix.get(x, y));
          }
        }
        this._background = this._ctx.getImageData(
          0,
          0,
          this._canvas.width,
          this._canvas.height
        );
      };
      GameRenderer.prototype.render = function() {
        var self2 = this;
        var ctx = this._ctx;
        if (this._background) {
          ctx.putImageData(this._background, 0, 0);
        }
        this.renderMovingPiece();
      };
      module.exports = GameRenderer;
    }
  });

  // tetris/src/dom/matrix_renderer.js
  var require_matrix_renderer2 = __commonJS({
    "tetris/src/dom/matrix_renderer.js"(exports, module) {
      init_shim();
      var $3 = window.jQuery;
      function MatrixRenderer(container, matrix) {
        this._container = $3(container);
        this._matrix = matrix;
        this._tiles = [];
        this._tileWidth = 0;
        this._tilHeight = 0;
        this._container.css({
          position: "relative",
          overflow: "hidden"
        });
        this._calculatePixelDimensions();
      }
      MatrixRenderer.prototype.createTile = function() {
        var tile = document.createElement("div");
        tile.style.position = "absolute";
        tile.style.width = this._tileWidth + "px";
        tile.style.height = this._tileHeight + "px";
        return tile;
      };
      MatrixRenderer.prototype._calculatePixelDimensions = function() {
        var matrix = this._matrix;
        this._tileWidth = Math.round(this._container.width() / matrix.getWidth());
        this._tileHeight = Math.round(this._container.height() / matrix.getHeight());
      };
      MatrixRenderer.prototype.render = function() {
        this._container.empty();
        var matrix = this._matrix;
        this._tiles = [];
        var width = matrix.getWidth();
        var height = matrix.getHeight();
        var tileWidth = this._tileWidth;
        var tileHeight = this._tileHeight;
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            var tile = this.createTile();
            tile.style.left = x * tileWidth + "px";
            tile.style.top = y * tileHeight + "px";
            tile.className = "tile-" + matrix.get(x, y);
            this._container.append(tile);
            this._tiles.push(tile);
          }
        }
      };
      MatrixRenderer.prototype.getRowOfTiles = function(y) {
        var width = this._matrix.getWidth();
        var start = y * width;
        var end = start + width;
        var tiles = [];
        for (var i = start; i < end; i++) {
          tiles.push(this._tiles[i]);
        }
        return tiles;
      };
      MatrixRenderer.prototype._update = function() {
        var matrix = this._matrix;
        var tiles = this._tiles;
        var numTiles = tiles.length;
        for (var index = 0; index < numTiles; index++) {
          var value = matrix.getAtIndex(index);
          tiles[index].className = "tile-" + value;
        }
      };
      MatrixRenderer.prototype.setMatrix = function(matrix) {
        this._matrix = matrix;
      };
      module.exports = MatrixRenderer;
    }
  });

  // tetris/src/dom/game_renderer.js
  var require_game_renderer2 = __commonJS({
    "tetris/src/dom/game_renderer.js"(exports, module) {
      init_shim();
      var util = require_util();
      var MatrixRenderer = require_matrix_renderer2();
      function GameRenderer(container, game) {
        MatrixRenderer.call(this, container, game.getBackgroundMatrix());
        this._game = game;
        this._piece = null;
        var self2 = this;
        game.on("hit", function() {
          self2.updateBackground();
        });
        game.on("collapse", function(collapses) {
          for (var i = 0; i < collapses.length; i++) {
            var y = collapses[i];
            $(self2.getRowOfTiles(y)).addClass("tile-collapsing");
          }
          self2.updateBackground();
        });
        game.on("new-piece", function() {
          self2.renderMovingPiece();
        });
        game.on("move", function() {
          self2.updateMovingPiece();
        });
        game.on("rotate", function() {
          self2.rotateMovingPiece();
        });
        game.on("start", function() {
          self2._container.empty();
          self2.renderBackground();
          self2.renderMovingPiece();
        });
      }
      util.inherits(GameRenderer, MatrixRenderer);
      GameRenderer.prototype.renderBackground = function() {
        this.render();
      };
      GameRenderer.prototype.updateBackground = function() {
        this._update();
      };
      GameRenderer.prototype.renderMovingPiece = function() {
        if (this._piece) {
          $(this._piece).remove();
        }
        var pieceMatrix = this._game.getMovingPieceMatrix();
        var piecePosition = this._game.getMovingPiecePosition();
        var tileWidth = this._tileWidth;
        var tileHeight = this._tileHeight;
        var el = document.createElement("div");
        el.style.position = "absolute";
        el.style.width = pieceMatrix.getWidth() * tileWidth + "px";
        el.style.height = pieceMatrix.getHeight() * tileHeight + "px";
        el.style.left = piecePosition.x * tileWidth + "px";
        el.style.top = piecePosition.y * tileHeight + "px";
        el.className = "piece";
        var width = pieceMatrix.getWidth();
        var height = pieceMatrix.getHeight();
        for (var y = 0; y < height; y++) {
          for (var x = 0; x < width; x++) {
            var tile = this.createTile();
            tile.style.left = x * tileWidth + "px";
            tile.style.top = y * tileHeight + "px";
            tile.className = "tile-" + pieceMatrix.get(x, y);
            el.appendChild(tile);
          }
        }
        this._container.append(el);
        this._piece = el;
      };
      GameRenderer.prototype.updateMovingPiece = function() {
        var pieceMatrix = this._game.getMovingPieceMatrix();
        var piecePosition = this._game.getMovingPiecePosition();
        var tileWidth = this._tileWidth;
        var tileHeight = this._tileHeight;
        this._piece.style.left = piecePosition.x * tileWidth + "px";
        this._piece.style.top = piecePosition.y * tileHeight + "px";
      };
      GameRenderer.prototype.rotateMovingPiece = function() {
        return this.renderMovingPiece();
      };
      module.exports = GameRenderer;
    }
  });

  // tetris/src/sound.js
  var require_sound = __commonJS({
    "tetris/src/sound.js"(exports, module) {
      init_shim();
      function initSounds(game, audio) {
        if (!window.Audio) {
          return;
        }
        var schedPlay = function(audio2, timeout) {
          setTimeout(function() {
            audio2.currentTime = 0;
            audio2.play();
          }, timeout);
        };
        game.on("collapse", function(collapses) {
          for (var i = 0; i < collapses.length; i++) {
            var sound2 = audio.collapses[i];
            if (sound2) {
              schedPlay(sound2, i * 150);
            }
          }
        });
      }
      module.exports = {
        initSounds
      };
    }
  });

  // tetris/src/main.js
  init_shim();
  require_polyfills();
  var $2 = window.jQuery;
  var Matrix = require_matrix();
  var GameState = require_gamestate();
  var PlayerGameMode = require_player_gamemode();
  var PlayerController = require_player_controller();
  var Score = require_score();
  var Scoreboard = require_scoreboard();
  var Menu = require_menu();
  var CanvasMatrixRenderer = require_matrix_renderer();
  var CanvasGameRenderer = require_game_renderer();
  var DomMatrixRenderer = require_matrix_renderer2();
  var DomGameRenderer = require_game_renderer2();
  var sound = require_sound();
  function createGame() {
    var game = new GameState(10, 20);
    var pieces = [
      "\n1111\n\n",
      "2\n222\n",
      "003\n333\n",
      "0440\n0440\n",
      "055\n55\n",
      "06\n666\n",
      "77\n077\n"
    ];
    for (var i = 0; i < pieces.length; i++) {
      game.loadPieceMatrix(game.createMatrixFromString(pieces[i]));
    }
    return game;
  }
  function createPlayerController(game) {
    var player = new PlayerController(game);
    player.bindKeys({
      37: { action: "left", delay: 100 },
      38: { action: "rotate", delay: 200 },
      39: { action: "right", delay: 100 },
      40: { action: "down", delay: 40 },
      32: { action: "drop", delay: -1 }
    });
    return player;
  }
  function initStartMenu(menu, game) {
    var el = document.createElement("div");
    $2("#game-start").detach().appendTo(el);
    var hide;
    var playButton = menu.button("Play", function() {
      game.start();
    });
    el.appendChild(playButton);
    game.once("start", function() {
      hide();
    });
    hide = menu.show(el);
  }
  function initPauseMenu(menu, game) {
    var el = document.createElement("div");
    el.appendChild(menu.title("Paused"));
    var hide = null;
    var resumeButton = menu.button("Resume", function() {
      hide();
      hide = null;
    });
    el.appendChild(resumeButton);
    var show = function() {
      if (game.isGameover() || hide) {
        return;
      }
      hide = menu.show(el);
    };
    $2(window).keydown(function(event) {
      if (event.keyCode === 80) {
        show();
      }
    });
    $2(window).blur(function() {
      show();
    });
  }
  function initGameoverMenu(menu, game, scoreboard) {
    var el = document.createElement("div");
    el.appendChild(menu.title("Game Over"));
    var table = document.createElement("table");
    table.className = "scoreboard";
    var thead = document.createElement("thead");
    thead.appendChild(menu.tablerow([
      "high scores"
    ], "th"));
    table.appendChild(thead);
    var tbody = document.createElement("tbody");
    table.appendChild(tbody);
    scoreboard.on("save", function() {
      var currentStats = scoreboard.getCurrentStats();
      $2(tbody).empty();
      var stats = scoreboard.getBestStats();
      if (!stats) {
        return;
      }
      for (var i = 0; i < stats.length; i++) {
        var tr = menu.tablerow([
          stats[i].score
        ]);
        if (stats[i].score === currentStats.score) {
          tr.className = "selected";
        }
        tbody.appendChild(tr);
      }
    });
    el.appendChild(table);
    var restartButton = menu.button("New game", function() {
      game.start();
    });
    el.appendChild(restartButton);
    var hide = $2.noop;
    game.on("gameover", function() {
      hide = menu.show(el);
    });
    game.on("start", function() {
      hide();
    });
  }
  function initGameUI(game, gameMode, gameScoreboard, gameElement, menuElement) {
    var GameRenderer = getGameRenderer();
    var view = new GameRenderer(gameElement, game);
    var menu = new Menu(game, menuElement, gameElement);
    initStartMenu(menu, game);
    initPauseMenu(menu, game);
    initGameoverMenu(menu, game, gameScoreboard);
    var controller = createPlayerController(game);
  }
  function initStatusUI(score, scoreElement, linesElement, levelElement) {
    var update = function() {
      $2(scoreElement).text(score.getScore());
      $2(linesElement).text(score.getLines());
      $2(levelElement).text(score.getLevel());
    };
    score.on("update", update);
    update();
  }
  function isCanvasSupported() {
    var el = document.createElement("canvas");
    return !!(el.getContext && el.getContext("2d"));
  }
  function getMatrixRenderer() {
    return isCanvasSupported() ? CanvasMatrixRenderer : DomMatrixRenderer;
  }
  function getGameRenderer() {
    return isCanvasSupported() ? CanvasGameRenderer : DomGameRenderer;
  }
  function init(elementSelectors) {
    var game = createGame();
    var gameMode = new PlayerGameMode(game);
    var gameScore = new Score(game, gameMode);
    var gameScoreboard = new Scoreboard(gameScore, localStorage);
    initGameUI(game, gameMode, gameScoreboard, $2("#game"), $2("#menu"));
    initStatusUI(gameScore, $2("#score"), $2("#lines"), $2("#level"));
    initNextPiecePreviewUI(game, $2("#preview"));
    sound.initSounds(game, {
      collapses: [
        $2("#collapse1-sound").get(0),
        $2("#collapse2-sound").get(0),
        $2("#collapse3-sound").get(0),
        $2("#collapse4-sound").get(0)
      ]
    });
  }
  function initNextPiecePreviewUI(game, element) {
    var MatrixRenderer = getMatrixRenderer();
    var previewRenderer = new MatrixRenderer(element, new Matrix(4, 4));
    game.on("set-next-piece", function(index, matrix) {
      previewRenderer.setMatrix(createPaddedMatrix(matrix, 4, 4));
      previewRenderer.render();
    });
  }
  function createPaddedMatrix(matrix, widthExtent, heightExtent) {
    var width = Math.max(matrix.getWidth(), widthExtent);
    var height = Math.max(matrix.getHeight(), heightExtent);
    var padded = new Matrix(width, height);
    padded.copy(0, 0, matrix);
    return padded;
  }
  $2(document).ready(function() {
    $2("#game-loading").remove();
    $2(".status-container,.game-container").show();
    init({
      game: "#game",
      menu: "#menu",
      score: "#score",
      lines: "#lines",
      level: "#level"
    });
  });
})();
/*! Bundled license information:

ieee754/index.js:
  (*! ieee754. BSD-3-Clause License. Feross Aboukhadijeh <https://feross.org/opensource> *)

buffer/index.js:
  (*!
   * The buffer module from node.js, for the browser.
   *
   * @author   Feross Aboukhadijeh <https://feross.org>
   * @license  MIT
   *)

json3/lib/json3.min.js:
  (*! JSON v3.3.2 | https://bestiejs.github.io/json3 | Copyright 2012-2015, Kit Cambridge, Benjamin Tan | http://kit.mit-license.org *)
*/
