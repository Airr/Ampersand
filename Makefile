# Define tools
ASM = uasm
ASFLAGS = -elf64 -q -pie -Fo 
AR = ar
ARFLAGS = rcs
OBJCOPY = objcopy
INSTALL = install
INSTALL_DATA = install -m 644
INSTALL_DIR = install -d

LIBRARYNAME = libamp.a

# Define directories
OBJ_DIR = obj
LIB_DIR = lib
SRC_DIR = src
INC_DIR = include

# Installation directories
PREFIX ?= /usr/local
INSTALL_LIB_DIR = $(DESTDIR)$(PREFIX)/lib
INSTALL_INC_DIR = $(DESTDIR)$(PREFIX)/include

# Automatically find all .asm files in the src directory
ASM_SRCS = $(wildcard $(SRC_DIR)/*.asm)

# Strip the src/ prefix and add obj/ prefix, changing .asm to .o
OBJS = $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(ASM_SRCS))

# Library goes in LIB_DIR
TARGET_LIB = $(LIB_DIR)/$(LIBRARYNAME)
# TARGET_INCS = $(INC_DIR)/amp.inc $(INC_DIR)/syscall.inc
TARGET_INCS = $(wildcard $(INC_DIR)/*.inc)

all: $(TARGET_LIB)

# Create directories if they don't exist
$(OBJ_DIR) $(LIB_DIR):
	mkdir -p $@

# Rule to assemble .asm into .o in OBJ_DIR
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm | $(OBJ_DIR)
	$(ASM) $(ASFLAGS)$@ $<
	@strip --strip-debug $@

# Rule to create the static archive in LIB_DIR
$(TARGET_LIB): $(OBJS) | $(LIB_DIR)
	$(AR) $(ARFLAGS) $@ $(OBJS)

# Install library and include files
install: $(TARGET_LIB)
	$(INSTALL_DIR) $(INSTALL_LIB_DIR) $(INSTALL_INC_DIR)
	$(INSTALL_DATA) $(TARGET_LIB) $(INSTALL_LIB_DIR)/
	$(INSTALL_DATA) $(TARGET_INCS) $(INSTALL_INC_DIR)/

# Uninstall library and include files
uninstall:
	rm -f $(INSTALL_LIB_DIR)/$(LIBRARYNAME)
	rm -f $(addprefix $(INSTALL_INC_DIR)/,$(notdir $(TARGET_INCS)))

# Clean build artifacts
clean:
	rm -rf $(OBJ_DIR) $(LIB_DIR)

.PHONY: all clean install uninstall