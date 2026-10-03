# ==============================================================================
# Makefile - glade_ex1
#
# Builds glade_ex1.asm with UASM and links it against:
#   - /usr/local/lib/libamp.a
#   - GTK+ 3
#   - embedded interface.ui resource
#
# Target:
#   glade_ex1
# ==============================================================================

AS       := uasm
LD       := gcc

ASFLAGS  := -elf64 -q -pie -zcw -I/usr/local/include

GTK_LIBS := $(shell pkg-config --libs gtk+-3.0)

LDFLAGS  := -pie \
            -s \
            -Wl,--as-needed \
            -rdynamic \
            -nostartfiles \
            -Wl,-z,noexecstack \
            -Wl,-e,_start

LIB      := /usr/local/lib/libamp.a

TARGET   := glade_ex2
SRCS     := glade_ex2.asm
OBJS     := $(SRCS:.asm=.o)

RES_DIR  := res
UI_FILE  := ui/interface.ui
RES_FILE := $(RES_DIR)/interface.o

.PHONY: all clean

# ------------------------------------------------------------------------------
# Default target
# ------------------------------------------------------------------------------

all: $(TARGET)
	@rm -f $(OBJS)
	@echo "'$(TARGET)' was built successfully."

# ------------------------------------------------------------------------------
# Link
# ------------------------------------------------------------------------------

$(TARGET): $(RES_FILE) $(OBJS) $(LIB) 
	@echo "Linking '$(TARGET)'..."
	@echo
	@$(LD) -o $@ \
		$(OBJS) \
		$(RES_FILE) \
		$(LIB) \
		$(LDFLAGS) \
		$(GTK_LIBS) \
		-ldl

# ------------------------------------------------------------------------------
# Assemble UASM source
# ------------------------------------------------------------------------------

%.o: %.asm
	@echo "Assembling '$<'..."
	@echo
	@$(AS) $(ASFLAGS) -Fo $@ $<

# ------------------------------------------------------------------------------
# Convert the GTK UI file into an ELF relocatable object.
#
# ld -r -b binary creates symbols:
#
#   _binary_interface_ui_start
#   _binary_interface_ui_end
#   _binary_interface_ui_size
#
# The assembly can reference these symbols directly.
# ------------------------------------------------------------------------------

$(RES_FILE): $(UI_FILE)
	@mkdir -p $(RES_DIR)
	@echo "Generating '$@' from '$<'..."
	@echo
	@ld -r -b binary -o $@ $<

# ------------------------------------------------------------------------------
# Clean
# ------------------------------------------------------------------------------

clean:
	@rm -f $(OBJS) $(TARGET) $(RES_FILE)
	@rmdir $(RES_DIR) 2>/dev/null || true
	@echo "'$(TARGET)' cleaned."
