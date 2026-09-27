# Makefile - builds the "amp" executable from amp.asm and amp_support.asm,
# linked against the static support library /usr/local/lib/lamp.a

AS       = uasm
ASFLAGS  = -elf64 -q -zcw -I/usr/local/include

LD       = ld
LDFLAGS  = -s -no-pie -e _start

LIB      = /usr/local/lib/libamp.a

TARGET   = amp
SRCS     = amp.asm 
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

