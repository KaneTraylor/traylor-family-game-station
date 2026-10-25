#!/usr/bin/env python3
"""Extract and rebuild Aurora skin packages (.xzp, magic 'XUIZ').

Format (all integers big-endian):

    header   'XUIZ' | u32 version=1 | u32 total file size | u32 0 | u32 table size | u16 file count
    entry    u32 size | u32 offset | u8 name length (UTF-16 code units) | UTF-16BE name
    data     file contents back to back, offsets relative to the end of the table

Names use backslashes (``Images\\Icons\\foo.png``). Extraction writes a
``manifest.txt`` listing the original entry order so ``pack`` can rebuild the
package byte-for-byte; files not in the manifest are appended in sorted order.

    xzp.py list    skin.xzp
    xzp.py extract skin.xzp out_dir
    xzp.py pack    src_dir skin.xzp
"""
import os
import struct
import sys

HEADER = ">4sIIIIH"
HEADER_SIZE = struct.calcsize(HEADER)
MANIFEST = "manifest.txt"


def parse(buf):
    magic, version, total, _reserved, table_size, count = struct.unpack(HEADER, buf[:HEADER_SIZE])
    if magic != b"XUIZ":
        sys.exit(f"not an XZP package (magic {magic!r})")
    if total != len(buf):
        print(f"warning: header says {total} bytes, file is {len(buf)}", file=sys.stderr)
    pos = HEADER_SIZE
    entries = []
    for _ in range(count):
        size, offset, nlen = struct.unpack(">IIB", buf[pos:pos + 9])
        pos += 9
        name = buf[pos:pos + nlen * 2].decode("utf-16-be")
        pos += nlen * 2
        entries.append((name, size, offset))
    if pos != HEADER_SIZE + table_size:
        print(f"warning: table ends at {pos}, header says {HEADER_SIZE + table_size}", file=sys.stderr)
    return pos, entries


def cmd_list(path):
    with open(path, "rb") as f:
        buf = f.read()
    data_start, entries = parse(buf)
    print(f"{len(entries)} files, data starts at {data_start}, {len(buf)} bytes total")
    for name, size, offset in entries:
        print(f"{size:9d}  {name}")


def cmd_extract(path, out):
    with open(path, "rb") as f:
        buf = f.read()
    data_start, entries = parse(buf)
    os.makedirs(out, exist_ok=True)
    for name, size, offset in entries:
        rel = name.replace("\\", "/")
        if rel.startswith("/") or ".." in rel.split("/"):
            sys.exit(f"refusing unsafe entry name {name!r}")
        dest = os.path.join(out, rel)
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        start = data_start + offset
        with open(dest, "wb") as f:
            f.write(buf[start:start + size])
    with open(os.path.join(out, MANIFEST), "w", encoding="utf-8") as f:
        f.write("\n".join(name for name, _, _ in entries) + "\n")
    print(f"extracted {len(entries)} files to {out}")


def cmd_pack(src, path):
    manifest = os.path.join(src, MANIFEST)
    ordered = []
    if os.path.exists(manifest):
        with open(manifest, encoding="utf-8") as f:
            ordered = [line.rstrip("\n") for line in f if line.strip()]
    present = set()
    for root, _dirs, files in os.walk(src):
        for fn in files:
            rel = os.path.relpath(os.path.join(root, fn), src)
            if rel != MANIFEST:
                present.add(rel.replace(os.sep, "\\"))
    names = [n for n in ordered if n in present]
    missing = [n for n in ordered if n not in present]
    if missing:
        print(f"warning: {len(missing)} manifest entries missing on disk, skipping:", file=sys.stderr)
        for n in missing:
            print(f"  {n}", file=sys.stderr)
    names += sorted(present - set(ordered))

    table = bytearray()
    data = bytearray()
    for name in names:
        with open(os.path.join(src, name.replace("\\", os.sep)), "rb") as f:
            blob = f.read()
        encoded = name.encode("utf-16-be")
        if len(encoded) // 2 > 255:
            sys.exit(f"name too long for the format: {name}")
        table += struct.pack(">IIB", len(blob), len(data), len(encoded) // 2) + encoded
        data += blob
    total = HEADER_SIZE + len(table) + len(data)
    header = struct.pack(HEADER, b"XUIZ", 1, total, 0, len(table), len(names))
    with open(path, "wb") as f:
        f.write(header + table + data)
    print(f"packed {len(names)} files into {path} ({total} bytes)")


def main(argv):
    try:
        cmd = argv[1]
        if cmd == "list":
            cmd_list(argv[2])
        elif cmd == "extract":
            cmd_extract(argv[2], argv[3])
        elif cmd == "pack":
            cmd_pack(argv[2], argv[3])
        else:
            raise IndexError
    except IndexError:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv)
