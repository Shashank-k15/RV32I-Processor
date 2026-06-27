#!/usr/bin/env bash
# compile.sh — Compile assembly or C source to program.hex for the RV32I processor
#
# Examples:
#   ./toolchain/compile.sh my_program.S                  # → program.hex
#   ./toolchain/compile.sh my_program.c                  # → program.hex
#   ./toolchain/compile.sh my_program.S output.hex       # → output.hex

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LINKER_SCRIPT="$SCRIPT_DIR/link.ld"

# Tool prefix
PREFIX="riscv64-elf"
GCC="${PREFIX}-gcc"
OBJCOPY="${PREFIX}-objcopy"
OBJDUMP="${PREFIX}-objdump"

# Architecture flags
ARCH_FLAGS="-march=rv32i -mabi=ilp32"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
  echo -e "${CYAN}Usage:${NC} $0 <source_file.S|.c> [output.hex]"
  echo ""
  echo "Compiles RISC-V assembly (.S) or C (.c) source files into a"
  echo "program.hex file suitable for the RV32I-Processor simulator."
  echo ""
  echo -e "${CYAN}Examples:${NC}"
  echo "  $0 my_program.S                  # outputs program.hex"
  echo "  $0 my_program.c                  # outputs program.hex"
  echo "  $0 my_program.S custom_out.hex   # outputs custom_out.hex"
  exit 1
}

# Check arguments
if [ $# -lt 1 ]; then
  usage
fi

SRC_FILE="$1"
OUT_HEX="${2:-${PROJECT_DIR}/program.hex}"

# Check source file exists
if [ ! -f "$SRC_FILE" ]; then
  echo -e "${RED}Error:${NC} Source file '$SRC_FILE' not found."
  exit 1
fi

# Check tools are installed
for tool in $GCC $OBJCOPY $OBJDUMP; do
  if ! command -v "$tool" &>/dev/null; then
    echo -e "${RED}Error:${NC} '$tool' not found. Install with: brew install riscv64-elf-gcc"
    exit 1
  fi
done

# Create temp directory
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

ELF_FILE="$TMPDIR/output.elf"
BIN_FILE="$TMPDIR/output.bin"

echo -e "${CYAN}[1/4]${NC} Compiling ${SRC_FILE}..."
$GCC $ARCH_FLAGS -nostdlib -nostartfiles -T "$LINKER_SCRIPT" -o "$ELF_FILE" "$SRC_FILE"

echo -e "${CYAN}[2/4]${NC} Extracting binary..."
$OBJCOPY -O binary "$ELF_FILE" "$BIN_FILE"

echo -e "${CYAN}[3/4]${NC} Generating hex file..."
# Convert binary to hex: 4 bytes per line, big-endian word order
# The hex file format is one 32-bit word per line in hexadecimal
python3 -c "
import sys
with open('$BIN_FILE', 'rb') as f:
    data = f.read()
while len(data) % 4 != 0:
    data += b'\x00'
with open('$OUT_HEX', 'w') as out:
    for i in range(0, len(data), 4):
        word = int.from_bytes(data[i:i+4], byteorder='little')
        out.write(f'{word:08X}\n')
"

WORD_COUNT=$(wc -l <"$OUT_HEX" | tr -d ' ')
echo -e "${CYAN}[4/4]${NC} Disassembly:"
$OBJDUMP -d "$ELF_FILE" --disassembler-options=no-aliases | head -60

echo ""
echo -e "Generated ${OUT_HEX} (${WORD_COUNT} words)"
