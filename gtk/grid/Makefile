# Makefile - builds the "demo" GTK executable from demo.asm,
# linked against the static support library /usr/local/lib/lamp.a

AS       = uasm
ASFLAGS  = -elf64 -q -pie -zcw -I/usr/local/include

LD       = gcc
GTK_LIBS = $(shell pkg-config --libs gtk+-3.0)
LDFLAGS  = -pie -s -Wl,--as-needed -ldl $(GTK_LIBS) -nostartfiles -Wl,-e,_start

LIB      = /usr/local/lib/libamp.a

TARGET   = demo
SRCS     = demo.asm 
OBJS     = $(SRCS:.asm=.o)

.PHONY: all clean

all: $(TARGET)
	@rm -f $(OBJS)
	@echo \'$(TARGET)\' was built successfully.

$(TARGET): $(OBJS) $(LIB)
	@echo Linking \'$(TARGET)\'...
	@echo
	@$(LD) -o $@ $(OBJS) $(LIB) $(LDFLAGS)

%.o: %.asm
	@echo Assembling \'$<\'...
	@echo
	@$(AS) $(ASFLAGS) -Fo $@ $<

clean:
	@rm -f $(OBJS) $(TARGET)
	@echo \'$(TARGET)\' cleaned.

