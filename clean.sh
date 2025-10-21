#!/bin/bash
# FLOW OS Build Cleanup Script

echo "🧹 Cleaning build artifacts..."

# Remove object files
echo "  → Removing object files..."
rm -f *.o
rm -f build/*.o

# Remove kernel binaries
echo "  → Removing kernel binaries..."
rm -f kernel.elf kernel.bin myos.bin

# Remove ISO files
echo "  → Removing ISO files..."
rm -f os.iso
rm -f iso/boot/kernel.elf

# Remove build directories (optional - uncomment if needed)
# echo "  → Removing build directory..."
# rm -rf build/

# Remove log files
echo "  → Removing log files..."
rm -f *.log

echo "✅ Cleanup complete!"

