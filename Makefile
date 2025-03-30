include ./config.mk
include $(OPENCM3_DIR)/mk/gcc-config.mk
include $(OPENCM3_DIR)/mk/genlink-config.mk

# Arquivo de script de ligação gerado
LDSCRIPT = $(BUILDDIR)/generated.$(DEVICE).ld

# Includes
INCLUDES = -Iinclude

# Flags de compilação
CFLAGS = $(ARCH_FLAGS) -Os -ffunction-sections -fdata-sections -Wall $(INCLUDES)

# Flags de linkagem
LDFLAGS += -nostartfiles -T$(LDSCRIPT) -Wl,--gc-sections -Wl,-Map=$(BUILDDIR)/main.map
#LDFLAGS += -specs=nano.specs -specs=nosys.specs

# Arquivos do projeto
SRCS = $(wildcard $(SRCDIR)/*.c) 
OBJS = $(patsubst %.c, $(BUILDDIR)/%.o, $(SRCS))

# Linkagem final
$(BUILDDIR)/main.elf: $(OBJS) $(LDSCRIPT)
	$(CC) $(OBJS) $(LDFLAGS)  $(LDLIBS) -o $@
	$(SIZE) $@

# Alvo principal
all: $(BUILDDIR)/main.elf

# Criação da pasta build
$(BUILDDIR):
	@ mkdir -p $(BUILDDIR)

# Compilação dos arquivos do projeto
$(BUILDDIR)/%.o: %.c | $(BUILDDIR)
	@ mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

# Gerar arquivo binário para flash
$(BUILDDIR)/main.bin: $(BUILDDIR)/main.elf
	$(OBJCOPY) -O binary $< $@

# Flash via st-flash
flash: $(BUILDDIR)/main.bin
	st-flash write $(BUILDDIR)/main.bin 0x08000000

# Limpar build
clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean flash

# Incluir regras da libopencm3 para gerar o ldscript
include $(OPENCM3_DIR)/mk/genlink-rules.mk
