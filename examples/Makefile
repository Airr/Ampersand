# Makefile - Batch UASM build for Linux x86-64
# Usage: 
#   make           (Links with ld by default)
#   make USE_GCC=1 (Links with cc)

LIB ?= /usr/local/lib/libamp.a
INCLUDE ?= /usr/local/include

SRCDIR = src
OBJDIR = obj
BINDIR = bin

# USE_GCC = 1

.PRECIOUS: $(OBJDIR)/%.o

# Automatically discover all .asm files in src/ and map them to obj/ and bin/
SRC_FILES = $(wildcard $(SRCDIR)/*.asm)
OBJ_FILES = $(patsubst $(SRCDIR)/%.asm, $(OBJDIR)/%.o, $(SRC_FILES))
BIN_FILES = $(patsubst $(SRCDIR)/%.asm, $(BINDIR)/%, $(SRC_FILES))

.PHONY: all clean

all: directories $(BIN_FILES)
	@echo "All builds completed successfully!"

# Create required directories
directories:
	@mkdir -p $(OBJDIR)
	@mkdir -p $(BINDIR)

# Pattern rule to assemble any .asm file into .o
$(OBJDIR)/%.o: $(SRCDIR)/%.asm
	@echo "Assembling $(notdir $<)..."
	@uasm -elf64 -q -zcw -I$(INCLUDE) -Fo$@ $<

# Pattern rule to link using GCC if USE_GCC=1
ifeq ($(USE_GCC),1)
$(BINDIR)/%: $(OBJDIR)/%.o
	@echo "Linking $(notdir $@) with cc...\n"
	@cc -o $@ $< $(LIB) -no-pie -s -Wl,--as-needed -ldl -nostartfiles -Wl,-e,_start
else
# Pattern rule to link using LD by default
$(BINDIR)/%: $(OBJDIR)/%.o
	@echo "Linking $(notdir $@) with ld...\n"
	@ld $< $(LIB) -o $@ -s -no-pie -e _start
endif

# Clean both object files and binaries directories
clean:
	@rm -rf $(OBJDIR) $(BINDIR)