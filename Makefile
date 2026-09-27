# Define tools
ASM = uasm
ASFLAGS = -elf64 -q -pie -Fo 
AR = ar
ARFLAGS = rcs
OBJCOPY = objcopy

LIBRARYNAME = libamp.a

# Define directories
OBJ_DIR = obj
LIB_DIR = lib
SRC_DIR = src

# Automatically find all .asm files in the src directory
ASM_SRCS = $(wildcard $(SRC_DIR)/*.asm)

# Strip the src/ prefix and add obj/ prefix, changing .asm to .o
OBJS = $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(ASM_SRCS))

# Library goes in LIB_DIR
TARGET_LIB = $(LIB_DIR)/$(LIBRARYNAME)

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

# Clean build artifacts
clean:
	rm -rf $(OBJ_DIR) $(LIB_DIR)

.PHONY: all clean